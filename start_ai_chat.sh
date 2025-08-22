#!/bin/bash

echo "🤖 Starting ClickHouse AI Chat Assistant"
echo "========================================"

# Check if everything is already running
if curl -s http://localhost:5001/health > /dev/null 2>&1; then
    echo "✅ AI Chat is already running!"
    echo "🌐 Analytics Dashboard: http://localhost:3000"
    echo "🤖 AI Chat Interface:   http://localhost:5001"
    exit 0
fi

# Start all services
echo "Starting all services..."
docker compose up -d

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

# Wait for Ollama
echo "⏳ Waiting for Ollama..."
for i in {1..30}; do
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "✅ Ollama is ready!"
        break
    fi
    sleep 3
done

# Check if Llama model is available
echo "🔍 Checking for Llama 3.1-8B model..."
if docker exec clickhouse-demo-ollama ollama list | grep -q "llama3.1:8b"; then
    echo "✅ Llama 3.1-8B model is available!"
else
    echo "📥 Llama 3.1-8B model not found. Downloading..."
    echo "⚠️  This is a large download (~4.7GB). Please be patient..."
    docker exec clickhouse-demo-ollama ollama pull llama3.1:8b
    
    if [ $? -eq 0 ]; then
        echo "✅ Model downloaded successfully!"
    else
        echo "❌ Failed to download model. Chat may not work properly."
    fi
fi

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
echo "🤖 AI Chat Interface:   http://localhost:5000"
echo ""
echo "💡 Ask the AI questions about your data in natural language!"
