# 项目结构说明

本文档说明 ClickHouse Analytics Demo 项目的目录结构和服务组织方式。

## 目录结构

```
clickhouse-analytics-demo/
├── services/                    # 服务目录
│   ├── app/                    # Web 应用服务
│   │   ├── app.py              # Flask 应用主文件
│   │   ├── Dockerfile          # Docker 构建文件
│   │   ├── requirements.txt    # Python 依赖
│   │   ├── templates/          # HTML 模板
│   │   ├── static/             # 静态资源
│   │   └── README.md           # 服务说明
│   ├── chat/                   # AI 聊天服务
│   │   ├── chat_service.py     # 聊天服务主文件
│   │   ├── Dockerfile.chat     # Docker 构建文件
│   │   ├── requirements.txt    # Python 依赖
│   │   └── README.md           # 服务说明
│   ├── streaming/              # 实时数据流服务
│   │   ├── stream_data.py      # 数据流脚本
│   │   ├── Dockerfile.streaming # Docker 构建文件
│   │   ├── requirements.txt    # Python 依赖
│   │   └── README.md           # 服务说明
│   ├── init-data/              # 数据初始化服务
│   │   ├── generate_data.py    # 数据生成脚本
│   │   ├── Dockerfile.init-data # Docker 构建文件
│   │   ├── requirements.txt    # Python 依赖
│   │   └── README.md           # 服务说明
│   └── clickhouse/             # ClickHouse 配置
│       ├── config/             # 配置文件目录
│       │   └── users.xml       # 用户认证配置
│       ├── init-scripts/       # 初始化脚本目录
│       │   └── 01-create-tables.sql
│       └── README.md           # 配置说明
├── scripts/                    # 启动脚本目录
│   ├── start.sh                # 一键启动脚本
│   ├── stop.sh                 # 一键停止脚本
│   ├── start_streaming.sh      # 启动流服务脚本
│   ├── start_ai_chat.sh        # 启动 AI 聊天脚本
│   ├── start_chat_local.sh     # 本地启动聊天脚本
│   ├── setup_ai_chat.sh        # AI 聊天设置脚本
├── docs/                       # 文档目录
│   ├── AI_CHAT_FEATURES.md     # AI 聊天功能说明
│   ├── PROJECT_STATUS.md       # 项目状态
│   └── PROJECT_STRUCTURE.md    # 项目结构说明（本文件）
├── examples/                   # 示例文件目录
│   ├── README.md
│   └── sample_queries.sql      # 示例 SQL 查询
├── docker-compose.yml          # Docker 编排配置
└── README.md                   # 项目主文档
```

## 服务说明

### 1. Web 应用服务 (services/app)

Flask Web 应用，提供数据分析仪表板和 REST API。

- **端口**: 3000
- **主要文件**: `app.py`, `templates/`, `static/`
- **依赖**: Flask, ClickHouse Driver, Plotly, Pandas

### 2. AI 聊天服务 (services/chat)

使用 Llama 3 模型提供自然语言查询 ClickHouse 数据的功能。

- **端口**: 5001
- **主要文件**: `chat_service.py`
- **依赖**: Flask, ClickHouse Driver, Requests
- **依赖服务**: ClickHouse, Azure OpenAI API

### 3. 实时数据流服务 (services/streaming)

持续生成新的测试数据，用于演示实时分析功能。

- **主要文件**: `stream_data.py`
- **依赖**: Requests, Faker
- **功能**: 每 30 秒生成新数据

### 4. 数据初始化服务 (services/init-data)

生成初始测试数据集。

- **主要文件**: `generate_data.py`
- **依赖**: Requests, Faker
- **生成数据**: 10K 用户, 500K+ 事件, 1K 产品, 25K 订单

### 5. ClickHouse 配置 (services/clickhouse)

ClickHouse 数据库的配置和初始化脚本。

- **配置文件**: `config/users.xml`
- **初始化脚本**: `init-scripts/01-create-tables.sql`
- **端口**: 8123 (HTTP), 9000 (Native)

## 脚本说明

所有启动和管理脚本位于 `scripts/` 目录：

- `start.sh` - 一键启动脚本（支持 basic/ai/all 模式）
- `stop.sh` - 一键停止脚本（支持 basic/all 模式）
- `start_streaming.sh` - 启动实时流服务
- `start_ai_chat.sh` - 启动 AI 聊天服务
- `setup_ai_chat.sh` - 设置 AI 聊天环境（Azure OpenAI）

## 使用建议

1. **开发新功能**: 在对应的服务目录下进行开发
2. **添加新服务**: 在 `services/` 下创建新目录，并更新 `docker-compose.yml`
3. **修改配置**: ClickHouse 配置在 `services/clickhouse/config/` 目录
4. **查看文档**: 各服务的详细说明在对应目录的 `README.md` 文件中

## 构建和部署

所有服务通过 Docker Compose 统一管理，配置文件位于项目根目录的 `docker-compose.yml`。

每个服务都有独立的 Dockerfile 和 requirements.txt，便于独立构建和部署。

