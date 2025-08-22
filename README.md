# ClickHouse Analytics Dashboard Demo

A comprehensive demonstration of ClickHouse with a modern web dashboard for real-time analytics. This project showcases ClickHouse's capabilities for handling large datasets and performing fast analytical queries.

## 🚀 Features

- **ClickHouse Database**: High-performance columnar database optimized for analytics
- **Realistic Test Data**: 500K+ events, 10K users, 1K products, and 25K orders
- **Interactive Dashboard**: Modern web interface with real-time charts and analytics
- **AI Chat Assistant**: Natural language queries powered by Llama 3 (local Ollama)
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

- Docker and Docker Compose installed on your macOS
- At least 4GB of RAM available for containers
- Ports 8123, 9000, 3000, and 5001 available
- **Ollama** (installed locally) for AI chat features
- **Llama 3 model** pulled in Ollama: `ollama pull llama3`

## 🚀 Quick Start

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
# Install Python dependencies (in virtual environment)
source venv/bin/activate
pip install -r requirements.txt

# Generate substantial test data (this will take a few minutes)
python3 generate_data.py
```

### 4. Start the Web Application
```bash
docker compose up -d app
```

### 5. Access the Dashboard
Open your browser and navigate to: http://localhost:3000

### 6. (Optional) Start Real-time Data Streaming
```bash
# Start continuous data generation for live dashboard updates
./start_streaming.sh
```

This will add new events and orders every 30 seconds, perfect for demonstrating real-time analytics!

### 7. (Optional) Enable AI Chat Assistant
```bash
# Make sure Ollama is running locally and has llama3 model
ollama pull llama3

# Start AI chat service (uses your local Ollama)
cd ~/clickhouse-demo
source venv/bin/activate
CLICKHOUSE_HOST=localhost CLICKHOUSE_PORT=9000 CLICKHOUSE_USER=demo_user CLICKHOUSE_PASSWORD=demo_password CLICKHOUSE_DB=demo_db OLLAMA_HOST=localhost OLLAMA_PORT=11434 python3 chat_service.py
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
# Start streaming (from project directory)
./start_streaming.sh

# Or run directly
source venv/bin/activate
python3 stream_data.py
```

Perfect for demonstrating real-time analytics and dashboard updates!

## 🤖 AI Chat Assistant

Query your ClickHouse data using natural language with Llama 3!

### Features
- **Natural Language Queries**: Ask questions in plain English
- **Smart SQL Generation**: AI writes optimized ClickHouse queries
- **Real-time Results**: Execute queries and see results instantly
- **Schema Awareness**: AI understands your database structure
- **Safety First**: Only SELECT queries allowed, no destructive operations
- **Beautiful Interface**: Modern chat UI with syntax highlighting
- **Local AI**: Uses your local Ollama installation for privacy and performance

### Example Questions
- "What are the top 5 countries by revenue?"
- "Show me daily user activity for the last week"
- "Which products are most popular?"
- "How many premium vs regular users do we have?"
- "What's our conversion rate from page views to purchases?"
- "Show me revenue trends by month"

### Technical Details
- **Model**: Llama 3 (via local Ollama)
- **Interface**: http://localhost:5001
- **Backend**: Flask + Local Ollama + ClickHouse
- **Safety**: Query validation and sanitization
- **Performance**: Optimized prompts for accurate SQL generation

### Setup Requirements
```bash
# Install Ollama (if not already installed)
# Visit: https://ollama.ai

# Pull the Llama 3 model
ollama pull llama3

# Start the chat service
cd ~/clickhouse-demo
source venv/bin/activate
CLICKHOUSE_HOST=localhost python3 chat_service.py
```

### ClickHouse Access
- **HTTP Interface**: http://localhost:8123
- **Username**: demo_user
- **Password**: demo_password
- **Database**: demo_db

### Manual ClickHouse Queries
You can connect directly to ClickHouse using the command line:

```bash
# Access ClickHouse client
docker exec -it clickhouse-demo clickhouse-client --user demo_user --password demo_password --database demo_db

# Example queries
SELECT count() FROM users;
SELECT event_type, count() FROM events GROUP BY event_type ORDER BY count() DESC;
SELECT toYYYYMM(order_date) as month, sum(total_amount) FROM orders WHERE status = 'completed' GROUP BY month ORDER BY month;
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
