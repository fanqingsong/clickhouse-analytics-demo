# 🤖 AI Chat Assistant for ClickHouse

## What We've Built

A complete AI-powered chat interface that lets users query ClickHouse data using natural language!

### Architecture

```
User Question → Azure OpenAI → ClickHouse SQL → Results → User
     ↓              ↓              ↓            ↓
"Top countries"  SELECT country  [US, UK, DE]  Beautiful UI
  by revenue     ,sum(revenue)     with data     with tables
                 FROM orders...
```

## Components

### 1. AI Chat Service (`chat_service.py`)
- **Flask web application** serving the chat interface
- **Natural language processing** with Azure OpenAI (GPT-4, GPT-3.5-turbo, etc.)
- **SQL generation** from user questions
- **Safe query execution** (SELECT only)
- **Results formatting** with beautiful tables

### 2. Azure OpenAI Integration
- **Azure OpenAI API** for language understanding
- **Configurable models** (GPT-4, GPT-3.5-turbo, etc.)
- **Cloud-based inference** - reliable and scalable
- **Optimized prompts** for ClickHouse SQL generation

### 3. Modern Web Interface
- **Chat-style UI** like ChatGPT
- **Real-time responses** with loading indicators
- **Syntax highlighting** for generated SQL
- **Responsive design** works on mobile/desktop
- **Query suggestions** to get users started

## Features

### 🧠 Smart SQL Generation
The AI understands your schema and generates optimized ClickHouse queries:

**User**: "What are the top 5 countries by revenue?"

**AI Generates**:
```sql
SELECT 
    u.country,
    sum(o.total_amount) as total_revenue,
    count(o.order_id) as order_count
FROM orders o
JOIN users u ON o.user_id = u.user_id
WHERE o.status = 'completed'
GROUP BY u.country
ORDER BY total_revenue DESC
LIMIT 5
```

### 🔒 Safety First
- **Only SELECT queries** allowed - no data modification
- **Query validation** before execution
- **Error handling** with user-friendly messages
- **Schema awareness** prevents invalid queries

### 📊 Beautiful Results
- **Formatted tables** with proper alignment
- **Limited results** (first 10 rows) for readability
- **Query display** so users can learn SQL
- **Error messages** that help users refine questions

## Setup

### Prerequisites
1. **Azure OpenAI Resource**
   - Create an Azure OpenAI resource in Azure Portal
   - Get your endpoint URL and API key
   - Deploy a model (e.g., GPT-4, GPT-3.5-turbo)

### Configuration

Set environment variables:
```bash
export AZURE_OPENAI_ENDPOINT='https://your-resource.openai.azure.com'
export AZURE_OPENAI_API_KEY='your-api-key'
export AZURE_OPENAI_DEPLOYMENT_NAME='gpt-4'
export AZURE_OPENAI_API_VERSION='2024-02-15-preview'
```

Or create a `.env` file:
```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4
AZURE_OPENAI_API_VERSION=2024-02-15-preview
```

### Start the Service

```bash
# Start ClickHouse first
docker compose up -d clickhouse

# Start chat service
docker compose up -d chat

# Or use the setup script
./scripts/setup_ai_chat.sh
```

### Access the Interface

Open your browser to: **http://localhost:5001**

## Example Queries

Try asking:
- "What are the top 5 countries by revenue?"
- "Show me daily user activity for the last week"
- "Which products are most popular?"
- "How many premium vs regular users do we have?"
- "What's our conversion rate from page views to purchases?"
- "Show me revenue trends by month"

## Technical Details

### API Endpoints

- `GET /` - Chat interface (HTML)
- `POST /api/chat` - Process chat messages
- `GET /health` - Health check endpoint

### Request Format

```json
{
  "question": "What are the top 5 countries by revenue?"
}
```

### Response Format

```json
{
  "explanation": "This query finds the top 5 countries...",
  "query": "SELECT ...",
  "results": [
    ["US", "125000.50", "150"],
    ["UK", "98000.25", "120"],
    ...
  ]
}
```

## Troubleshooting

### Chat service won't start
- Check Azure OpenAI credentials are set correctly
- Verify endpoint URL format: `https://your-resource.openai.azure.com`
- Ensure API key is valid and has access to the deployment

### AI returns errors
- Check Azure OpenAI deployment name matches your configuration
- Verify the model is deployed and available
- Check API version compatibility

### No responses from AI
- Check network connectivity to Azure OpenAI
- Verify API key has sufficient quota
- Check service logs: `docker compose logs -f chat`

## Performance

- **Response time**: ~2-5 seconds per query (depends on Azure OpenAI)
- **Concurrent users**: Handles multiple users simultaneously
- **Query execution**: Fast ClickHouse queries (< 1 second typically)

## Security

- **API keys**: Stored as environment variables, never in code
- **Query safety**: Only SELECT queries allowed
- **Input validation**: All user input is sanitized
- **Error messages**: Don't expose sensitive information
