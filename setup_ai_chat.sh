#!/bin/bash

echo "🤖 Setting up ClickHouse AI Chat Assistant with Llama 3.1-8B"
echo "=================================================="

# Start Ollama first
echo "1. Starting Ollama service..."
docker compose up -d ollama

echo "2. Waiting for Ollama to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "✅ Ollama is ready!"
        break
    fi
    echo "   Waiting... ($i/30)"
    sleep 10
done

# Pull Llama 3.1-8B model
echo "3. Pulling Llama 3.1-8B model (this may take a while - ~4.7GB download)..."
docker exec clickhouse-demo-ollama ollama pull llama3.1:8b

if [ $? -eq 0 ]; then
    echo "✅ Llama 3.1-8B model downloaded successfully!"
else
    echo "❌ Failed to download model. Please check your internet connection."
    exit 1
fi

# Start the chat service
echo "4. Starting AI chat service..."
docker compose up -d chat

echo "5. Waiting for chat service to be ready..."
for i in {1..20}; do
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
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
echo "🤖 AI Chat Interface:   http://localhost:5000"
echo ""
echo "💡 Try asking questions like:"
echo "   • 'What are the top 5 countries by revenue?'"
echo "   • 'Show me daily user activity for the last week'"
echo "   • 'Which products are most popular?'"
echo "   • 'How many premium vs regular users do we have?'"
echo ""
echo "🔍 The AI will analyze your questions and write ClickHouse SQL queries!"
