#!/bin/bash
#
# Start AI Chat Service (Local Ollama)
# 
# This script starts the AI chat service using your local Ollama installation.
# Make sure you have:
# 1. Ollama installed and running
# 2. Llama3 model pulled: ollama pull llama3
# 3. ClickHouse container running: docker compose up -d clickhouse

echo "🤖 Starting AI Chat Service with Local Ollama..."

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "❌ Error: Ollama is not running on localhost:11434"
    echo "Please start Ollama and ensure you have the llama3 model:"
    echo "  ollama pull llama3"
    exit 1
fi

# Check if llama3 model is available
if ! ollama list | grep -q "llama3"; then
    echo "❌ Error: llama3 model not found"
    echo "Please pull the model first:"
    echo "  ollama pull llama3"
    exit 1
fi

# Check if ClickHouse is running
if ! curl -s http://localhost:8123/ping > /dev/null 2>&1; then
    echo "❌ Error: ClickHouse is not running on localhost:8123"
    echo "Please start ClickHouse first:"
    echo "  docker compose up -d clickhouse"
    exit 1
fi

# Activate virtual environment and start chat service
echo "✅ Dependencies check passed!"
echo "🚀 Starting chat service on http://localhost:5001"
echo "Press Ctrl+C to stop"

source venv/bin/activate
export CLICKHOUSE_HOST=localhost
export CLICKHOUSE_PORT=9000
export CLICKHOUSE_USER=demo_user
export CLICKHOUSE_PASSWORD=demo_password
export CLICKHOUSE_DB=demo_db
export OLLAMA_HOST=localhost
export OLLAMA_PORT=11434

python3 chat_service.py
