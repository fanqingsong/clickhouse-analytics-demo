#!/bin/bash

# Start ClickHouse data streaming
echo "🚀 Starting ClickHouse Real-time Data Streaming..."
echo "📊 This will add new data every 30 seconds"
echo "🛑 Press Ctrl+C to stop"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Check if running in container or locally
if [ -f "/.dockerenv" ] || [ -n "$DOCKER_CONTAINER" ]; then
    # Running in container, use docker compose
    docker compose up -d streaming
    echo "✅ Streaming service started in container"
    echo "📊 View logs: docker compose logs -f streaming"
else
    # Running locally, check for virtual environment
    if [ -d "venv" ]; then
        source venv/bin/activate
        python3 services/streaming/stream_data.py
    else
        echo "⚠️  Virtual environment not found. Starting via Docker..."
        docker compose up -d streaming
        echo "✅ Streaming service started in container"
        echo "📊 View logs: docker compose logs -f streaming"
    fi
fi
