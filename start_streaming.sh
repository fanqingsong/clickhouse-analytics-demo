#!/bin/bash

# Start ClickHouse data streaming
echo "🚀 Starting ClickHouse Real-time Data Streaming..."
echo "📊 This will add new data every 30 seconds"
echo "🛑 Press Ctrl+C to stop"
echo ""

cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Start streaming
python3 stream_data.py
