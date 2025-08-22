#!/usr/bin/env python3
"""
AI Chat Service for ClickHouse Analytics
Uses Llama 3.1-8B via Ollama to answer questions about the data
"""

import os
import json
import requests
from flask import Flask, request, jsonify, render_template_string
from clickhouse_driver import Client
import time

app = Flask(__name__)

# Configuration
OLLAMA_HOST = os.getenv('OLLAMA_HOST', 'ollama')
OLLAMA_PORT = int(os.getenv('OLLAMA_PORT', '11434'))
CLICKHOUSE_HOST = os.getenv('CLICKHOUSE_HOST', 'clickhouse')
CLICKHOUSE_PORT = int(os.getenv('CLICKHOUSE_PORT', '9000'))
CLICKHOUSE_USER = os.getenv('CLICKHOUSE_USER', 'demo_user')
CLICKHOUSE_PASSWORD = os.getenv('CLICKHOUSE_PASSWORD', 'demo_password')
CLICKHOUSE_DB = os.getenv('CLICKHOUSE_DB', 'demo_db')

def get_clickhouse_client():
    """Get ClickHouse client"""
    return Client(
        host=CLICKHOUSE_HOST,
        port=CLICKHOUSE_PORT,
        user=CLICKHOUSE_USER,
        password=CLICKHOUSE_PASSWORD,
        database=CLICKHOUSE_DB
    )

def get_schema_info():
    """Get database schema information for the AI"""
    client = get_clickhouse_client()
    
    schema_info = """
ClickHouse Database Schema:

1. users table:
   - user_id (UInt64): Unique user identifier
   - username (String): User's username
   - email (String): User's email address
   - age (UInt8): User's age
   - country (String): User's country (US, UK, DE, FR, CA, AU, JP, BR, IN, RU)
   - registration_date (Date): When user registered
   - registration_timestamp (DateTime): Exact registration time
   - is_premium (UInt8): 1 if premium user, 0 if not
   - total_spent (Decimal): Total amount spent by user

2. events table:
   - event_id (UInt64): Unique event identifier
   - user_id (UInt64): User who performed the event
   - event_type (String): Type of event (page_view, click, search, login, logout, purchase, add_to_cart, remove_from_cart, signup, download)
   - event_timestamp (DateTime): When event occurred
   - event_date (Date): Date of event (materialized from timestamp)
   - page_url (String): URL of the page
   - session_id (String): Session identifier
   - device_type (String): Device used (desktop, mobile, tablet)
   - browser (String): Browser used (Chrome, Firefox, Safari, Edge, Opera)
   - country (String): Country where event occurred
   - duration_seconds (UInt32): How long the event lasted
   - revenue (Decimal): Revenue generated from this event

3. products table:
   - product_id (UInt64): Unique product identifier
   - product_name (String): Name of the product
   - category (String): Product category (Electronics, Clothing, Books, Home & Garden, Sports, Beauty, Toys, Automotive, Health, Food)
   - price (Decimal): Product price
   - created_date (Date): When product was created
   - is_active (UInt8): 1 if active, 0 if inactive

4. orders table:
   - order_id (UInt64): Unique order identifier
   - user_id (UInt64): User who made the order
   - product_id (UInt64): Product that was ordered
   - quantity (UInt32): Quantity ordered
   - order_date (Date): Date of order
   - order_timestamp (DateTime): Exact time of order
   - total_amount (Decimal): Total order amount
   - status (String): Order status (completed, pending, cancelled, refunded)
   - payment_method (String): Payment method used

5. Views available:
   - user_analytics: Aggregated user statistics
   - daily_user_activity: Daily user activity summary (materialized view)

Sample data ranges:
- ~15,000 users from various countries
- ~1,500 products across 10 categories
- ~100+ orders with realistic transaction data
- ~200+ events tracking user interactions
- Data spans recent months with live streaming updates
"""
    
    return schema_info

def call_ollama(prompt: str, model: str = "llama3") -> str:
    """Call Ollama API to get response from Llama model"""
    try:
        url = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/generate"
        payload = {
            "model": model,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.1,
                "top_p": 0.9,
                "max_tokens": 1000
            }
        }
        
        response = requests.post(url, json=payload, timeout=60)
        response.raise_for_status()
        
        result = response.json()
        return result.get('response', 'No response generated')
        
    except requests.exceptions.RequestException as e:
        return f"Error calling Ollama: {str(e)}"
    except Exception as e:
        return f"Unexpected error: {str(e)}"

def execute_clickhouse_query(query: str):
    """Execute ClickHouse query safely"""
    try:
        client = get_clickhouse_client()
        
        # Basic safety checks
        query_lower = query.lower().strip()
        if any(dangerous in query_lower for dangerous in ['drop', 'delete', 'insert', 'update', 'create', 'alter']):
            return {"error": "Only SELECT queries are allowed for safety"}
        
        if not query_lower.startswith('select'):
            return {"error": "Query must start with SELECT"}
        
        result = client.execute(query)
        return {"success": True, "data": result, "query": query}
        
    except Exception as e:
        return {"error": f"Query execution failed: {str(e)}"}

def create_ai_prompt(user_question: str, schema_info: str) -> str:
    """Create a prompt for the AI to generate ClickHouse SQL"""
    prompt = f"""You are an expert ClickHouse SQL analyst. Your job is to help users analyze their e-commerce data by writing SQL queries.

DATABASE SCHEMA:
{schema_info}

USER QUESTION: {user_question}

Please provide:
1. A clear, efficient ClickHouse SQL query to answer the question
2. A brief explanation of what the query does
3. Expected insights from the results

IMPORTANT RULES:
- Only write SELECT queries (no INSERT, UPDATE, DELETE, DROP, etc.)
- Use proper ClickHouse syntax and functions
- Optimize for performance with appropriate aggregations
- Use meaningful column aliases
- Include LIMIT clauses for large result sets
- Use date functions like toDate(), toStartOfMonth(), etc. for time-based analysis
- For "recent" data, use time ranges like "WHERE event_timestamp >= now() - INTERVAL 30 DAY"

Format your response as:
```sql
[Your SQL Query Here]
```

Explanation: [Your explanation here]

Expected insights: [What insights this query will provide]"""

    return prompt

@app.route('/')
def chat_interface():
    """Main chat interface"""
    return render_template_string("""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ClickHouse AI Chat Assistant</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .chat-container { max-width: 800px; margin: 20px auto; background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .chat-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 15px 15px 0 0; }
        .chat-messages { height: 400px; overflow-y: auto; padding: 20px; border-bottom: 1px solid #eee; }
        .message { margin-bottom: 15px; display: flex; }
        .message.user { justify-content: flex-end; }
        .message.ai { justify-content: flex-start; }
        .message-content { max-width: 70%; padding: 10px 15px; border-radius: 20px; }
        .message.user .message-content { background: #007bff; color: white; }
        .message.ai .message-content { background: #f8f9fa; color: #333; border: 1px solid #e9ecef; }
        .chat-input { padding: 20px; }
        .query-result { background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 8px; padding: 15px; margin-top: 10px; font-family: monospace; font-size: 0.9em; }
        .loading { text-align: center; color: #6c757d; font-style: italic; }
        .suggestions { padding: 10px 20px; background: #f8f9fa; border-top: 1px solid #e9ecef; }
        .suggestion-chip { display: inline-block; background: #e9ecef; color: #495057; padding: 5px 10px; margin: 2px; border-radius: 15px; cursor: pointer; font-size: 0.9em; }
        .suggestion-chip:hover { background: #007bff; color: white; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="chat-container">
            <div class="chat-header">
                <h3><i class="fas fa-robot me-2"></i>ClickHouse AI Assistant</h3>
                <p class="mb-0">Ask questions about your e-commerce data using natural language!</p>
            </div>
            
            <div class="suggestions">
                <strong>Try asking:</strong>
                <span class="suggestion-chip" onclick="askQuestion('What are the top 5 countries by revenue?')">Top countries by revenue</span>
                <span class="suggestion-chip" onclick="askQuestion('Show me daily user activity for the last week')">Recent user activity</span>
                <span class="suggestion-chip" onclick="askQuestion('Which products are most popular?')">Popular products</span>
                <span class="suggestion-chip" onclick="askQuestion('How many premium vs regular users do we have?')">User segments</span>
            </div>
            
            <div id="chat-messages" class="chat-messages">
                <div class="message ai">
                    <div class="message-content">
                        <strong>👋 Hello!</strong> I'm your ClickHouse AI assistant. I can help you analyze your e-commerce data by writing SQL queries. Just ask me questions in plain English!
                        <br><br>
                        <strong>Examples:</strong>
                        <ul>
                            <li>"What's our total revenue this month?"</li>
                            <li>"Show me the most active users"</li>
                            <li>"Which product categories perform best?"</li>
                            <li>"How many orders were placed yesterday?"</li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="chat-input">
                <div class="input-group">
                    <input type="text" id="user-input" class="form-control" placeholder="Ask about your data..." onkeypress="handleKeyPress(event)">
                    <button class="btn btn-primary" onclick="sendMessage()">
                        <i class="fas fa-paper-plane"></i> Send
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function addMessage(content, isUser = false) {
            const messagesDiv = document.getElementById('chat-messages');
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${isUser ? 'user' : 'ai'}`;
            
            const messageContent = document.createElement('div');
            messageContent.className = 'message-content';
            messageContent.innerHTML = content;
            
            messageDiv.appendChild(messageContent);
            messagesDiv.appendChild(messageDiv);
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }

        function addLoading() {
            addMessage('<i class="fas fa-spinner fa-spin"></i> Thinking and querying data...', false);
        }

        function removeLoading() {
            const messages = document.getElementById('chat-messages');
            const lastMessage = messages.lastElementChild;
            if (lastMessage && lastMessage.innerHTML.includes('fa-spinner')) {
                messages.removeChild(lastMessage);
            }
        }

        async function sendMessage() {
            const input = document.getElementById('user-input');
            const question = input.value.trim();
            
            if (!question) return;
            
            addMessage(question, true);
            input.value = '';
            addLoading();
            
            try {
                const response = await fetch('/api/chat', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ question: question })
                });
                
                const data = await response.json();
                removeLoading();
                
                if (data.error) {
                    addMessage(`❌ Error: ${data.error}`, false);
                } else {
                    let responseHtml = `<strong>📊 Analysis:</strong><br>${data.explanation}`;
                    
                    if (data.query) {
                        responseHtml += `<div class="query-result"><strong>SQL Query:</strong><br><code>${data.query}</code></div>`;
                    }
                    
                    if (data.results) {
                        responseHtml += `<div class="query-result"><strong>Results:</strong><br>`;
                        if (data.results.length === 0) {
                            responseHtml += 'No data found.';
                        } else {
                            responseHtml += '<table class="table table-sm table-striped mt-2"><tbody>';
                            data.results.slice(0, 10).forEach(row => {
                                responseHtml += '<tr>';
                                row.forEach(cell => {
                                    responseHtml += `<td>${cell}</td>`;
                                });
                                responseHtml += '</tr>';
                            });
                            responseHtml += '</tbody></table>';
                            if (data.results.length > 10) {
                                responseHtml += `<small class="text-muted">Showing first 10 of ${data.results.length} results</small>`;
                            }
                        }
                        responseHtml += '</div>';
                    }
                    
                    addMessage(responseHtml, false);
                }
            } catch (error) {
                removeLoading();
                addMessage(`❌ Connection error: ${error.message}`, false);
            }
        }

        function handleKeyPress(event) {
            if (event.key === 'Enter') {
                sendMessage();
            }
        }

        function askQuestion(question) {
            document.getElementById('user-input').value = question;
            sendMessage();
        }
    </script>
</body>
</html>
    """)

@app.route('/api/chat', methods=['POST'])
def chat():
    """Handle chat requests"""
    try:
        data = request.get_json()
        question = data.get('question', '').strip()
        
        if not question:
            return jsonify({'error': 'Question cannot be empty'})
        
        # Get schema information
        schema_info = get_schema_info()
        
        # Create AI prompt
        prompt = create_ai_prompt(question, schema_info)
        
        # Get AI response
        ai_response = call_ollama(prompt)
        
        # Extract SQL query from response
        sql_query = None
        explanation = ai_response
        
        if '```sql' in ai_response:
            parts = ai_response.split('```sql')
            if len(parts) > 1:
                sql_part = parts[1].split('```')[0].strip()
                sql_query = sql_part
                
                # Extract explanation
                remaining = ai_response.split('```sql')[0] + ai_response.split('```')[1] if '```' in parts[1] else ai_response.split('```sql')[0]
                explanation = remaining.strip()
        
        response_data = {
            'explanation': explanation,
            'query': sql_query
        }
        
        # Execute query if we have one
        if sql_query:
            query_result = execute_clickhouse_query(sql_query)
            if 'error' in query_result:
                response_data['query_error'] = query_result['error']
            else:
                response_data['results'] = query_result['data']
        
        return jsonify(response_data)
        
    except Exception as e:
        return jsonify({'error': f'Internal error: {str(e)}'})

@app.route('/health')
def health():
    """Health check endpoint"""
    try:
        # Test ClickHouse connection
        client = get_clickhouse_client()
        client.execute("SELECT 1")
        ch_status = "healthy"
    except:
        ch_status = "unhealthy"
    
    try:
        # Test Ollama connection
        response = requests.get(f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/tags", timeout=5)
        ollama_status = "healthy" if response.status_code == 200 else "unhealthy"
    except:
        ollama_status = "unhealthy"
    
    return jsonify({
        'clickhouse': ch_status,
        'ollama': ollama_status,
        'status': 'healthy' if ch_status == 'healthy' and ollama_status == 'healthy' else 'partial'
    })

if __name__ == '__main__':
    import logging
    logging.basicConfig(level=logging.INFO)
    app.run(host='0.0.0.0', port=5001, debug=True)
