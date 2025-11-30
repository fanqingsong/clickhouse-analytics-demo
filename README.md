# ClickHouse Analytics Dashboard Demo

A comprehensive demonstration of ClickHouse with a modern web dashboard for real-time analytics. This project showcases ClickHouse's capabilities for handling large datasets and performing fast analytical queries.

## 🚀 Features

- **ClickHouse Database**: High-performance columnar database optimized for analytics
- **Realistic Test Data**: 500K+ events, 10K users, 1K products, and 25K orders
- **Interactive Dashboard**: Modern web interface with real-time charts and analytics
- **AI Chat Assistant**: Natural language queries powered by Azure OpenAI
- **Real-time Data Streaming**: Continuous data generation for live demos
- **Docker Setup**: Easy deployment with Docker Compose
- **RESTful API**: Backend API for data access and analytics
- **Responsive Design**: Beautiful, mobile-friendly dashboard

## 📊 What's Included

### Database Schema
- **Users Table**: User profiles with demographics and spending data
- **Events Table**: User activity tracking (page views, clicks, purchases)
- **Products Table**: Product catalog with categories and pricing
- **Orders Table**: Transaction records with order details
- **Materialized Views**: Pre-aggregated data for faster queries

### Analytics Features
- Daily user activity trends
- Event type distribution
- Revenue analytics by month
- Geographic user distribution
- Product performance metrics
- User segmentation analysis
- Real-time search and filtering

## 🛠 Prerequisites

- Docker and Docker Compose installed
- At least 4GB of RAM available for containers (8GB+ recommended if using AI chat)
- Ports 8123, 9000, 3000, 5001, and 11434 available
- **Note**: Requires Azure OpenAI API credentials (endpoint and API key)

## 🚀 Quick Start

### 方式一：一键启动（推荐）

使用提供的一键启停脚本，自动完成所有启动步骤：

```bash
# 启动基础服务（ClickHouse + Web 应用）
./scripts/start.sh basic

# 或启动所有服务（包括 AI 聊天和实时流）
./scripts/start.sh all

# 或仅启动基础服务 + AI 聊天
./scripts/start.sh ai
```

停止服务：
```bash
# 停止服务但保留数据
./scripts/stop.sh basic

# 停止服务并删除所有数据
./scripts/stop.sh all
```

脚本会自动完成：
- ✅ 检查依赖和端口占用
- ✅ 启动 ClickHouse 并等待就绪
- ✅ 自动初始化数据（如果未初始化）
- ✅ 启动 Web 应用
- ✅ （可选）启动 AI 聊天服务和实时流

### 方式二：手动启动

### 1. Clone and Setup
```bash
cd ~/clickhouse-demo
```

### 2. Start ClickHouse Database
```bash
docker compose up -d clickhouse
```

Wait for ClickHouse to be fully ready (about 30-60 seconds).

### 3. Generate Test Data
```bash
# Generate substantial test data in container (this will take a few minutes)
docker compose up init-data
```

This will automatically generate all test data (500K+ events, 10K users, 1K products, 25K orders) in the container.

### 4. Start the Web Application
```bash
docker compose up -d app
```

### 5. Access the Dashboard
Open your browser and navigate to: http://localhost:3000

### 6. (Optional) Start Real-time Data Streaming
```bash
# Start continuous data generation in container for live dashboard updates
docker compose up -d streaming
```

This will add new events and orders every 30 seconds, perfect for demonstrating real-time analytics!

To stop streaming:
```bash
docker compose stop streaming
```

To view streaming logs:
```bash
docker compose logs -f streaming
```

### 7. (Optional) Enable AI Chat Assistant

**Prerequisites**: You need Azure OpenAI API credentials.

**Option 1: Using .env file (Recommended)**

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` and fill in your Azure OpenAI credentials:
```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_API_KEY=your-api-key-here
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4
```

3. Start the chat service:
```bash
docker compose up -d chat
```

**Option 2: Using environment variables**

1. Set environment variables:
```bash
export AZURE_OPENAI_ENDPOINT='https://your-resource.openai.azure.com'
export AZURE_OPENAI_API_KEY='your-api-key'
export AZURE_OPENAI_DEPLOYMENT_NAME='gpt-4'  # Optional, defaults to gpt-4
```

2. Start the chat service:
```bash
docker compose up -d chat
```

**Or use the setup script:**
```bash
./scripts/setup_ai_chat.sh
```

Then access the AI chat interface at: **http://localhost:5001**

**Note**: 
- Azure OpenAI requires an Azure subscription and OpenAI resource
- You can use GPT-4, GPT-3.5-turbo, or other Azure OpenAI models
- API credentials are passed via environment variables

To stop the service:
```bash
docker compose stop chat
```

To view service logs:
```bash
docker compose logs -f chat
```

This adds an AI assistant that can answer questions about your data in natural language!

## 📈 Understanding the Data

### Data Volume
- **Users**: 10,000 user profiles
- **Events**: 500,000+ user interactions
- **Products**: 1,000 products across 10 categories  
- **Orders**: 25,000 purchase transactions

### Key Metrics Available
- **User Analytics**: Registration trends, geographic distribution, spending patterns
- **Event Analytics**: Daily activity, event type distribution, session analysis
- **Revenue Analytics**: Monthly revenue trends, order patterns
- **Product Analytics**: Top sellers, category performance
- **User Segmentation**: High/medium/low value customers

## 🔧 Configuration

## 🌊 Real-time Data Streaming

The project includes a smart streaming script that continuously generates new data:

### Features
- **Automatic Data Generation**: New events and orders every 30 seconds
- **Size Management**: Automatically maintains database size limits
- **Realistic Data**: Generates authentic user interactions and transactions
- **Graceful Shutdown**: Stop with Ctrl+C without data corruption
- **Resource Safe**: Built-in protections against overwhelming the database

### Configuration
- **Stream Interval**: 30 seconds (configurable)
- **Max Events**: 10,000 total (auto-cleanup older data)
- **Max Orders**: 1,000 total (auto-cleanup older data)
- **Events per Batch**: 10 new events
- **Orders per Batch**: 3 new orders

### Usage
```bash
# Start streaming in container (recommended)
docker compose up -d streaming

# View streaming logs
docker compose logs -f streaming

# Stop streaming
docker compose stop streaming

# Or run locally (requires virtual environment)
./start_streaming.sh
```

Perfect for demonstrating real-time analytics and dashboard updates!

## 🤖 AI Chat Assistant

Query your ClickHouse data using natural language with Azure OpenAI!

### Features
- **Natural Language Queries**: Ask questions in plain English
- **Smart SQL Generation**: AI writes optimized ClickHouse queries
- **Real-time Results**: Execute queries and see results instantly
- **Schema Awareness**: AI understands your database structure
- **Safety First**: Only SELECT queries allowed, no destructive operations
- **Beautiful Interface**: Modern chat UI with syntax highlighting
- **Cloud AI**: Powered by Azure OpenAI (GPT-4, GPT-3.5-turbo, etc.)

### Example Questions
- "What are the top 5 countries by revenue?"
- "Show me daily user activity for the last week"
- "Which products are most popular?"
- "How many premium vs regular users do we have?"
- "What's our conversion rate from page views to purchases?"
- "Show me revenue trends by month"

### Technical Details
- **Model**: Azure OpenAI (GPT-4 by default, configurable)
- **Interface**: http://localhost:5001
- **Backend**: Flask + Azure OpenAI + ClickHouse
- **Safety**: Query validation and sanitization
- **Performance**: Optimized prompts for accurate SQL generation

### Setup Requirements

1. **Get Azure OpenAI credentials**:
   - Create an Azure OpenAI resource in Azure Portal
   - Get your endpoint URL and API key
   - Deploy a model (e.g., GPT-4, GPT-3.5-turbo)

2. **Configure Azure OpenAI credentials**:

   **Option A: Using .env file (Recommended)**
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env and fill in your credentials
   # AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
   # AZURE_OPENAI_API_KEY=your-api-key-here
   # AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4
   ```

   **Option B: Using environment variables**
   ```bash
   export AZURE_OPENAI_ENDPOINT='https://your-resource.openai.azure.com'
   export AZURE_OPENAI_API_KEY='your-api-key'
   export AZURE_OPENAI_DEPLOYMENT_NAME='gpt-4'  # Optional, defaults to gpt-4
   export AZURE_OPENAI_API_VERSION='2024-02-15-preview'  # Optional
   ```

3. **Start the chat service**:
```bash
docker compose up -d chat
```

Or use the setup script:
```bash
./scripts/setup_ai_chat.sh
```

**Note**: Docker Compose automatically loads variables from `.env` file if it exists in the project root.

### ClickHouse Access

#### HTTP Interface
- **HTTP Interface**: http://localhost:8123
- **Username**: demo_user
- **Password**: demo_password
- **Database**: demo_db

#### Command Line Client
You can connect directly to ClickHouse using the command line:

```bash
# Access ClickHouse client
docker exec -it clickhouse-demo clickhouse-client --user demo_user --password demo_password --database demo_db

# Example queries
SELECT count() FROM users;
SELECT event_type, count() FROM events GROUP BY event_type ORDER BY count() DESC;
SELECT toYYYYMM(order_date) as month, sum(total_amount) FROM orders WHERE status = 'completed' GROUP BY month ORDER BY month;
```

## 📁 Project Structure

```
clickhouse-analytics-demo/
├── services/              # 各服务目录
│   ├── app/              # Web 应用服务
│   │   ├── app.py        # Flask 应用主文件
│   │   ├── Dockerfile    # Docker 构建文件
│   │   ├── requirements.txt
│   │   ├── templates/    # HTML 模板
│   │   └── static/       # 静态资源
│   ├── chat/             # AI 聊天服务
│   │   ├── chat_service.py
│   │   ├── Dockerfile.chat
│   │   └── requirements.txt
│   ├── streaming/        # 实时数据流服务
│   │   ├── stream_data.py
│   │   ├── Dockerfile.streaming
│   │   └── requirements.txt
│   ├── init-data/        # 数据初始化服务
│   │   ├── generate_data.py
│   │   ├── Dockerfile.init-data
│   │   └── requirements.txt
│   └── clickhouse/       # ClickHouse 配置
│       ├── config/       # 配置文件
│       └── init-scripts/ # 初始化脚本
├── scripts/              # 启动脚本
│   ├── start.sh          # 一键启动脚本
│   ├── stop.sh           # 一键停止脚本
│   └── ...
├── docs/                 # 文档
│   ├── AI_CHAT_FEATURES.md
│   └── PROJECT_STATUS.md
├── examples/             # 示例文件
├── docker-compose.yml    # Docker 编排配置
└── README.md             # 项目说明
```

## 🏗 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Browser   │───▶│  Flask App      │───▶│   ClickHouse    │
│                 │    │  (Port 3000)    │    │  (Port 8123)    │
│  Dashboard UI   │    │                 │    │                 │
│  Charts & Tables│    │  REST API       │    │  Analytics DB   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Components
- **ClickHouse**: Columnar database for analytics workloads
- **Flask**: Python web framework serving the API and dashboard
- **Plotly.js**: Interactive charting library
- **Bootstrap**: Responsive CSS framework
- **Docker**: Containerization for easy deployment

## 📝 API Endpoints

The Flask application provides several REST API endpoints:

- `GET /api/stats` - Basic database statistics
- `GET /api/daily-events` - Daily event trends
- `GET /api/event-types` - Event type distribution
- `GET /api/top-countries` - User distribution by country
- `GET /api/revenue-by-month` - Monthly revenue data
- `GET /api/top-products` - Best-selling products
- `GET /api/user-segments` - User segmentation analysis
- `GET /api/search` - Search users or products

## 🛠 Development

### Running Components Separately

**ClickHouse Only:**
```bash
docker-compose up -d clickhouse
```

**Flask App Locally:**
```bash
export CLICKHOUSE_HOST=localhost
export CLICKHOUSE_PORT=9000
export CLICKHOUSE_USER=demo_user
export CLICKHOUSE_PASSWORD=demo_password
export CLICKHOUSE_DB=demo_db

python3 app.py
```

### Customizing Data Generation

Edit `generate_data.py` to modify:
- Number of users, events, products, orders
- Data patterns and distributions
- Date ranges for historical data
- Geographic distributions

### Adding New Analytics

1. Add new SQL queries to `app.py`
2. Create new API endpoints
3. Update the dashboard HTML with new charts
4. Use Plotly.js for visualizations

## 🔍 Sample Queries to Try

```sql
-- Top users by activity
SELECT u.username, count(e.event_id) as events
FROM users u 
JOIN events e ON u.user_id = e.user_id 
GROUP BY u.user_id, u.username 
ORDER BY events DESC 
LIMIT 10;

-- Revenue by country
SELECT u.country, sum(o.total_amount) as revenue
FROM users u 
JOIN orders o ON u.user_id = o.user_id 
WHERE o.status = 'completed'
GROUP BY u.country 
ORDER BY revenue DESC;

-- Daily active users trend
SELECT 
    toDate(event_timestamp) as date,
    uniq(user_id) as active_users
FROM events 
WHERE event_timestamp >= now() - INTERVAL 30 DAY
GROUP BY date 
ORDER BY date;

-- Product category performance
SELECT 
    p.category,
    count(o.order_id) as orders,
    sum(o.total_amount) as revenue,
    avg(o.total_amount) as avg_order_value
FROM products p
JOIN orders o ON p.product_id = o.product_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY revenue DESC;
```

## 🧹 Cleanup

To stop and remove all containers:
```bash
docker-compose down -v
```

To remove all data and start fresh:
```bash
docker-compose down -v
docker volume prune
```

## 🎯 Next Steps

This demo provides a solid foundation for exploring ClickHouse. Consider extending it with:

- **Real-time data ingestion** using Kafka or streaming APIs
- **Advanced analytics** like cohort analysis, funnel analysis
- **Machine learning** integration for predictive analytics
- **Additional visualizations** and dashboard customization
- **Performance monitoring** and query optimization
- **Data partitioning** strategies for larger datasets

## 📚 Learning Resources

- [ClickHouse Documentation](https://clickhouse.com/docs)
- [ClickHouse SQL Reference](https://clickhouse.com/docs/en/sql-reference/)
- [Performance Optimization Guide](https://clickhouse.com/docs/en/operations/performance/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Plotly.js Documentation](https://plotly.com/javascript/)

## 🐛 Troubleshooting

**ClickHouse won't start:**
- Check if ports 8123 and 9000 are available
- Ensure Docker has enough memory allocated
- Check logs: `docker-compose logs clickhouse`

**Data generation fails:**
- Wait longer for ClickHouse to be fully ready
- Check network connectivity: `curl http://localhost:8123/ping`
- Verify credentials in the configuration

**Dashboard shows no data:**
- Ensure data generation completed successfully
- Check Flask app logs: `docker-compose logs app`
- Verify ClickHouse contains data: `docker exec -it clickhouse-demo clickhouse-client --user demo_user --password demo_password -q "SELECT count() FROM demo_db.users"`

**Performance issues:**
- ClickHouse performs better with more RAM
- Consider adjusting Docker memory limits
- Monitor query performance in ClickHouse logs

---

🎉 **Enjoy exploring the power of ClickHouse for analytics!**
