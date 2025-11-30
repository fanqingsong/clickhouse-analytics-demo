#!/bin/bash

# ClickHouse Analytics Demo - 一键启动脚本
# 使用方法: ./start.sh [all|basic|ai]
#   all   - 启动所有服务（包括 AI 聊天和实时流）（默认）
#   basic - 启动基础服务 + AI 聊天服务
#   ai    - 启动基础服务 + AI 聊天服务（与 basic 相同）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker 和 Docker Compose
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose 未安装或版本过低"
        exit 1
    fi
    
    print_success "依赖检查通过"
}

# 检查端口占用
check_ports() {
    local ports=(8123 9000 3000 8080 11434 5001)
    local occupied=()
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            occupied+=($port)
        fi
    done
    
    if [ ${#occupied[@]} -gt 0 ]; then
        print_warning "以下端口已被占用: ${occupied[*]}"
        print_warning "这可能会影响服务启动，请检查是否有其他实例在运行"
    fi
}

# 等待 ClickHouse 就绪
wait_for_clickhouse() {
    print_info "等待 ClickHouse 服务就绪..."
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker compose exec -T clickhouse wget --no-verbose --tries=1 --spider http://localhost:8123/ping 2>/dev/null; then
            print_success "ClickHouse 已就绪"
            return 0
        fi
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    echo ""
    print_error "ClickHouse 启动超时"
    return 1
}

# 检查数据是否已初始化
check_data_initialized() {
    local count=$(docker compose exec -T clickhouse clickhouse-client \
        --user demo_user \
        --password demo_password \
        --database demo_db \
        --query "SELECT count() FROM system.tables WHERE database = 'demo_db' AND name IN ('users', 'events', 'products', 'orders')" 2>/dev/null || echo "0")
    
    if [ "$count" -ge "4" ]; then
        return 0
    else
        return 1
    fi
}

# 初始化数据
init_data() {
    if check_data_initialized; then
        print_info "数据已存在，跳过初始化"
        return 0
    fi
    
    print_info "开始初始化数据（这可能需要几分钟）..."
    if docker compose up init-data; then
        print_success "数据初始化完成"
        return 0
    else
        print_error "数据初始化失败"
        return 1
    fi
}

# 启动基础服务
start_basic() {
    print_info "启动基础服务..."
    
    # 启动 ClickHouse
    print_info "启动 ClickHouse..."
    docker compose up -d clickhouse
    
    # 等待 ClickHouse 就绪
    if ! wait_for_clickhouse; then
        print_error "ClickHouse 启动失败"
        return 1
    fi
    
    # 初始化数据
    if ! init_data; then
        print_error "数据初始化失败"
        return 1
    fi
    
    # 启动 Web 应用
    print_info "启动 Web 应用..."
    docker compose up -d app
    
    # 启动 AI 聊天服务（默认包含）
    start_ai
    
    print_success "基础服务启动完成！"
    echo ""
    print_info "访问地址："
    echo "  - Web 仪表板: http://localhost:3000"
    echo "  - AI 聊天界面: http://localhost:5001"
    echo "  - ClickHouse HTTP: http://localhost:8123"
    echo ""
}

# 启动实时数据流
start_streaming() {
    print_info "启动实时数据流服务..."
    docker compose up -d streaming
    print_success "实时数据流服务已启动"
    print_info "查看日志: docker compose logs -f streaming"
}

# 启动 AI 服务
start_ai() {
    print_info "启动 AI 聊天服务..."
    
    # 检查 Azure OpenAI 配置
    if [ -z "$AZURE_OPENAI_ENDPOINT" ] || [ -z "$AZURE_OPENAI_API_KEY" ]; then
        print_warning "Azure OpenAI 配置未设置"
        print_info "请设置以下环境变量："
        echo "  export AZURE_OPENAI_ENDPOINT='your-endpoint'"
        echo "  export AZURE_OPENAI_API_KEY='your-api-key'"
        echo "  export AZURE_OPENAI_DEPLOYMENT_NAME='gpt-4'  # 可选，默认为 gpt-4"
        echo ""
        print_info "或者创建 .env 文件并设置这些变量"
        print_warning "继续启动聊天服务，但可能无法正常工作..."
    else
        print_success "Azure OpenAI 配置已设置"
    fi
    
    # 启动聊天服务
    print_info "启动聊天服务..."
    docker compose up -d chat
    
    print_success "AI 聊天服务启动完成！"
    echo ""
    print_info "访问地址："
    echo "  - AI 聊天界面: http://localhost:5001"
    echo ""
    print_info "注意：确保已设置 Azure OpenAI 环境变量"
    echo ""
}

# 主函数
main() {
    local mode=${1:-all}
    
    echo ""
    print_info "=========================================="
    print_info "ClickHouse Analytics Demo - 启动脚本"
    print_info "=========================================="
    echo ""
    
    check_dependencies
    check_ports
    echo ""
    
    case "$mode" in
        all)
            start_basic
            start_streaming
            # start_ai 已经在 start_basic 中调用，无需重复
            ;;
        basic)
            start_basic
            ;;
        ai)
            start_basic
            # start_ai 已经在 start_basic 中调用，无需重复
            ;;
        *)
            echo "使用方法: $0 [all|basic|ai]"
            echo ""
            echo "选项："
            echo "  all   - 启动所有服务（包括 AI 聊天和实时流）（默认）"
            echo "  basic - 启动基础服务 + AI 聊天服务"
            echo "  ai    - 启动基础服务 + AI 聊天服务（与 basic 相同）"
            echo ""
            echo "默认: all（启动所有服务）"
            exit 1
            ;;
    esac
    
    echo ""
    print_info "=========================================="
    print_success "所有服务启动完成！"
    print_info "=========================================="
    echo ""
    print_info "查看服务状态: docker compose ps"
    print_info "查看日志: docker compose logs -f [service_name]"
    print_info "停止服务: ./stop.sh"
    echo ""
}

main "$@"

