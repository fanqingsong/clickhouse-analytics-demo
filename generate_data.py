#!/usr/bin/env python3
"""
Data generation script for ClickHouse demo
Generates realistic test data for users, events, products, and orders
"""

import random
import time
from datetime import datetime, timedelta, date
from typing import List, Dict
import requests
import json
from faker import Faker
import uuid

fake = Faker()

# ClickHouse connection settings
CLICKHOUSE_HOST = "localhost"
CLICKHOUSE_PORT = 8123
CLICKHOUSE_USER = "demo_user"
CLICKHOUSE_PASSWORD = "demo_password"
CLICKHOUSE_DB = "demo_db"

class ClickHouseClient:
    def __init__(self, host: str, port: int, user: str, password: str, database: str):
        self.base_url = f"http://{host}:{port}"
        self.auth = (user, password)
        self.database = database
    
    def execute(self, query: str) -> requests.Response:
        """Execute a query against ClickHouse"""
        params = {"database": self.database}
        response = requests.post(
            self.base_url,
            params=params,
            data=query,
            auth=self.auth,
            headers={"Content-Type": "text/plain"}
        )
        response.raise_for_status()
        return response
    
    def insert_data(self, table: str, data: List[Dict]) -> None:
        """Insert data into a table using JSON format"""
        if not data:
            return
        
        try:
            json_data = "\n".join([json.dumps(row) for row in data])
            query = f"INSERT INTO {table} FORMAT JSONEachRow\n{json_data}"
            response = self.execute(query)
            print(f"Inserted {len(data)} rows into {table}")
        except Exception as e:
            print(f"Error inserting data into {table}: {e}")
            # Print the first row to debug
            if data:
                print(f"Sample data: {json.dumps(data[0], indent=2)}")
            raise

def generate_users(count: int = 10000) -> List[Dict]:
    """Generate user data"""
    users = []
    countries = ['US', 'UK', 'DE', 'FR', 'CA', 'AU', 'JP', 'BR', 'IN', 'RU']
    
    for i in range(1, count + 1):
        registration_date = fake.date_between(start_date='-2y', end_date='today')
        users.append({
            'user_id': i,
            'username': fake.user_name(),
            'email': fake.email(),
            'age': random.randint(18, 80),
            'country': random.choice(countries),
            'registration_date': registration_date.strftime('%Y-%m-%d'),
            'registration_timestamp': fake.date_time_between(
                start_date=registration_date, 
                end_date=registration_date + timedelta(days=1)
            ).strftime('%Y-%m-%d %H:%M:%S'),
            'is_premium': random.choices([0, 1], weights=[0.8, 0.2])[0],
            'total_spent': round(random.uniform(0, 5000), 2)
        })
    
    return users

def generate_products(count: int = 1000) -> List[Dict]:
    """Generate product data"""
    products = []
    categories = ['Electronics', 'Clothing', 'Books', 'Home & Garden', 'Sports', 
                 'Beauty', 'Toys', 'Automotive', 'Health', 'Food']
    
    for i in range(1, count + 1):
        products.append({
            'product_id': i,
            'product_name': fake.catch_phrase(),
            'category': random.choice(categories),
            'price': round(random.uniform(5, 500), 2),
            'created_date': fake.date_between(start_date='-1y', end_date='today').strftime('%Y-%m-%d'),
            'is_active': random.choices([0, 1], weights=[0.1, 0.9])[0]
        })
    
    return products

def generate_events(user_count: int = 10000, events_per_user: int = 50) -> List[Dict]:
    """Generate event data - this will be the largest dataset"""
    events = []
    event_types = ['page_view', 'click', 'search', 'login', 'logout', 'purchase', 
                  'add_to_cart', 'remove_from_cart', 'signup', 'download']
    device_types = ['desktop', 'mobile', 'tablet']
    browsers = ['Chrome', 'Firefox', 'Safari', 'Edge', 'Opera']
    countries = ['US', 'UK', 'DE', 'FR', 'CA', 'AU', 'JP', 'BR', 'IN', 'RU']
    
    event_id = 1
    batch_size = 1000
    
    for user_id in range(1, user_count + 1):
        # Generate varying number of events per user
        num_events = random.randint(10, events_per_user * 2)
        
        for _ in range(num_events):
            # Generate event timestamp within last 6 months
            event_timestamp = fake.date_time_between(start_date='-6M', end_date='now')
            session_id = str(uuid.uuid4())
            
            # Some events generate revenue
            event_type = random.choice(event_types)
            revenue = 0
            if event_type == 'purchase':
                revenue = round(random.uniform(10, 200), 2)
            elif event_type == 'add_to_cart':
                revenue = round(random.uniform(0, 50), 2)
            
            events.append({
                'event_id': event_id,
                'user_id': user_id,
                'event_type': event_type,
                'event_timestamp': event_timestamp.strftime('%Y-%m-%d %H:%M:%S'),
                'page_url': f"/page/{random.randint(1, 100)}",
                'session_id': session_id,
                'device_type': random.choice(device_types),
                'browser': random.choice(browsers),
                'country': random.choice(countries),
                'duration_seconds': random.randint(5, 600),
                'revenue': revenue
            })
            
            event_id += 1
        
        # Print progress every 1000 users
        if user_id % 1000 == 0:
            print(f"Generated events for {user_id}/{user_count} users")
    
    return events

def generate_orders(user_count: int = 10000, product_count: int = 1000, order_count: int = 25000) -> List[Dict]:
    """Generate order data"""
    orders = []
    statuses = ['completed', 'pending', 'cancelled', 'refunded']
    payment_methods = ['credit_card', 'paypal', 'bank_transfer', 'apple_pay', 'google_pay']
    
    for i in range(1, order_count + 1):
        user_id = random.randint(1, user_count)
        product_id = random.randint(1, product_count)
        quantity = random.randint(1, 5)
        order_date = fake.date_between(start_date='-1y', end_date='today')
        
        # Create order timestamp within the same day
        order_timestamp = fake.date_time_between(
            start_date=order_date,
            end_date=order_date + timedelta(days=1)
        )
        
        orders.append({
            'order_id': i,
            'user_id': user_id,
            'product_id': product_id,
            'quantity': quantity,
            'order_date': order_date.strftime('%Y-%m-%d'),
            'order_timestamp': order_timestamp.strftime('%Y-%m-%d %H:%M:%S'),
            'total_amount': float(round(random.uniform(10, 1000), 2)),  # Ensure it's a float
            'status': random.choice(statuses),
            'payment_method': random.choice(payment_methods)
        })
        
        # Print progress
        if i % 5000 == 0:
            print(f"Generated {i}/{order_count} orders")
    
    return orders

def insert_data_in_batches(client: ClickHouseClient, table: str, data: List[Dict], batch_size: int = 1000):
    """Insert data in batches to avoid memory issues"""
    total_batches = len(data) // batch_size + (1 if len(data) % batch_size > 0 else 0)
    
    for i in range(0, len(data), batch_size):
        batch = data[i:i + batch_size]
        client.insert_data(table, batch)
        print(f"Batch {i // batch_size + 1}/{total_batches} completed for {table}")
        time.sleep(0.1)  # Small delay to avoid overwhelming the server

def main():
    """Main function to generate and insert all test data"""
    print("Starting data generation for ClickHouse demo...")
    
    # Initialize ClickHouse client
    client = ClickHouseClient(
        CLICKHOUSE_HOST, CLICKHOUSE_PORT, 
        CLICKHOUSE_USER, CLICKHOUSE_PASSWORD, CLICKHOUSE_DB
    )
    
    # Wait for ClickHouse to be ready
    print("Waiting for ClickHouse to be ready...")
    max_retries = 30
    for attempt in range(max_retries):
        try:
            client.execute("SELECT 1")
            print("ClickHouse is ready!")
            break
        except Exception as e:
            if attempt == max_retries - 1:
                print(f"Failed to connect to ClickHouse after {max_retries} attempts: {e}")
                return
            print(f"Attempt {attempt + 1}/{max_retries}: ClickHouse not ready yet, waiting...")
            time.sleep(2)
    
    # Generate data
    print("\n1. Generating users data...")
    users = generate_users(10000)
    insert_data_in_batches(client, "users", users)
    
    print("\n2. Generating products data...")
    products = generate_products(1000)
    insert_data_in_batches(client, "products", products)
    
    print("\n3. Generating orders data...")
    orders = generate_orders(10000, 1000, 25000)
    insert_data_in_batches(client, "orders", orders, batch_size=500)  # Smaller batch size
    
    print("\n4. Generating events data (this will take a while)...")
    events = generate_events(10000, 50)  # 500K+ events
    insert_data_in_batches(client, "events", events, batch_size=5000)
    
    print("\nData generation completed!")
    
    # Show some statistics
    print("\n=== Data Statistics ===")
    tables = ['users', 'products', 'orders', 'events']
    for table in tables:
        try:
            response = client.execute(f"SELECT count() FROM {table}")
            count = response.text.strip()
            print(f"{table}: {count} rows")
        except Exception as e:
            print(f"Error getting count for {table}: {e}")

if __name__ == "__main__":
    main()
