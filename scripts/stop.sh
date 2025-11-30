#!/bin/bash

# ClickHouse Analytics Demo - 一键停止脚本
# 使用方法: ./stop.sh [all|basic]
#   all   - 停止所有服务并清理（包括数据卷）
#   basic - 仅停止服务，保留数据

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

# 停止所有服务
stop_services() {
    local mode=$1
    
    print_info "正在停止服务..."
    
    if [ "$mode" == "all" ]; then
        print_warning "将停止所有服务并删除数据卷（数据将被清除）"
        read -p "确认继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "操作已取消"
            exit 0
        fi
        
        docker compose down -v
        print_success "所有服务已停止，数据卷已删除"
    else
        docker compose down
        print_success "所有服务已停止（数据已保留）"
    fi
}

# 显示运行中的服务
show_running_services() {
    local running=$(docker compose ps --services --filter "status=running" 2>/dev/null || echo "")
    
    if [ -z "$running" ]; then
        print_info "当前没有运行中的服务"
        return 1
    else
        print_info "当前运行中的服务："
        docker compose ps
        return 0
    fi
}

# 主函数
main() {
    local mode=${1:-basic}
    
    echo ""
    print_info "=========================================="
    print_info "ClickHouse Analytics Demo - 停止脚本"
    print_info "=========================================="
    echo ""
    
    # 检查 Docker Compose
    if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
        print_error "Docker 或 Docker Compose 未安装"
        exit 1
    fi
    
    # 显示当前运行的服务
    if ! show_running_services; then
        print_info "无需停止服务"
        exit 0
    fi
    
    echo ""
    
    case "$mode" in
        all)
            stop_services "all"
            ;;
        basic)
            stop_services "basic"
            ;;
        *)
            echo "使用方法: $0 [all|basic]"
            echo ""
            echo "选项："
            echo "  all   - 停止所有服务并删除数据卷（数据将被清除）"
            echo "  basic - 仅停止服务，保留数据（默认）"
            echo ""
            echo "默认: basic"
            exit 1
            ;;
    esac
    
    echo ""
    print_info "=========================================="
    print_success "服务停止完成！"
    print_info "=========================================="
    echo ""
    print_info "重新启动服务: ./start.sh"
    echo ""
}

main "$@"

