#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🤖 Setting up ClickHouse AI Chat Assistant with Azure OpenAI"
echo "=================================================="

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

echo "✅ Azure OpenAI configuration found"
echo ""

# Start ClickHouse if not running
if ! curl -s http://localhost:8123/ping > /dev/null 2>&1; then
    echo "1. Starting ClickHouse..."
    docker compose up -d clickhouse
    
    echo "2. Waiting for ClickHouse to be ready..."
    for i in {1..30}; do
        if curl -s http://localhost:8123/ping > /dev/null 2>&1; then
            echo "✅ ClickHouse is ready!"
            break
        fi
        echo "   Waiting... ($i/30)"
        sleep 2
    done
else
    echo "✅ ClickHouse is already running"
fi

# Start the chat service
echo "3. Starting AI chat service..."
docker compose up -d chat

echo "4. Waiting for chat service to be ready..."
for i in {1..20}; do
    if curl -s http://localhost:5001/health > /dev/null 2>&1; then
        echo "✅ Chat service is ready!"
        break
    fi
    echo "   Waiting... ($i/20)"
    sleep 5
done

echo ""
echo "🎉 AI Chat Assistant is ready!"
echo "=================================================="
echo "🌐 Analytics Dashboard: http://localhost:3000"
echo "🤖 AI Chat Interface:   http://localhost:5001"
echo ""
echo "💡 Try asking questions like:"
echo "   • 'What are the top 5 countries by revenue?'"
echo "   • 'Show me daily user activity for the last week'"
echo "   • 'Which products are most popular?'"
echo "   • 'How many premium vs regular users do we have?'"
echo ""
echo "🔍 The AI will analyze your questions and write ClickHouse SQL queries!"
