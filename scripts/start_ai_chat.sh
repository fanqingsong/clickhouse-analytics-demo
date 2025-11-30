#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🤖 Starting ClickHouse AI Chat Assistant"
echo "========================================"

# Check Azure OpenAI configuration
if [ -z "$AZURE_OPENAI_ENDPOINT" ] || [ -z "$AZURE_OPENAI_API_KEY" ]; then
    echo "❌ Error: Azure OpenAI configuration is missing!"
    echo ""
    echo "Please set the following environment variables:"
    echo "  export AZURE_OPENAI_ENDPOINT='https://your-resource.openai.azure.com'"
    echo "  export AZURE_OPENAI_API_KEY='your-api-key'"
    echo "  export AZURE_OPENAI_DEPLOYMENT_NAME='gpt-4'  # Optional, defaults to gpt-4"
    echo ""
    echo "Or create a .env file with these variables"
    exit 1
fi

# Check if chat service is already running
if curl -s http://localhost:5001/health > /dev/null 2>&1; then
    echo "✅ AI Chat is already running!"
    echo "🌐 Analytics Dashboard: http://localhost:3000"
    echo "🤖 AI Chat Interface:   http://localhost:5001"
    exit 0
fi

# Start all services
echo "Starting services..."
docker compose up -d clickhouse chat

echo "Waiting for services to be ready..."

# Wait for ClickHouse
echo "⏳ Waiting for ClickHouse..."
for i in {1..30}; do
    if curl -s http://localhost:8123/ping > /dev/null 2>&1; then
        echo "✅ ClickHouse is ready!"
        break
    fi
    sleep 2
done

# Wait for chat service
echo "⏳ Waiting for chat service..."
for i in {1..20}; do
    if curl -s http://localhost:5001/health > /dev/null 2>&1; then
        echo "✅ Chat service is ready!"
        break
    fi
    sleep 5
done

echo ""
echo "🎉 All services are running!"
echo "========================================"
echo "🌐 Analytics Dashboard: http://localhost:3000"
echo "🤖 AI Chat Interface:   http://localhost:5001"
echo ""
echo "💡 Ask the AI questions about your data in natural language!"
