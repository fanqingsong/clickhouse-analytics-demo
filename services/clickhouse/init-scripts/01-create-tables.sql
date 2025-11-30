-- Create database
CREATE DATABASE IF NOT EXISTS demo_db;

-- Switch to demo database
USE demo_db;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    user_id UInt64,
    username String,
    email String,
    age UInt8,
    country String,
    registration_date Date,
    registration_timestamp DateTime,
    is_premium UInt8,
    total_spent Decimal(10,2)
) ENGINE = MergeTree()
ORDER BY user_id;

-- Create events table for user activity tracking
CREATE TABLE IF NOT EXISTS events (
    event_id UInt64,
    user_id UInt64,
    event_type String,
    event_timestamp DateTime,
    event_date Date MATERIALIZED toDate(event_timestamp),
    page_url String,
    session_id String,
    device_type String,
    browser String,
    country String,
    duration_seconds UInt32,
    revenue Decimal(10,2) DEFAULT 0
) ENGINE = MergeTree()
PARTITION BY event_date
ORDER BY (event_date, user_id, event_timestamp);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    product_id UInt64,
    product_name String,
    category String,
    price Decimal(10,2),
    created_date Date,
    is_active UInt8
) ENGINE = MergeTree()
ORDER BY product_id;

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id UInt64,
    user_id UInt64,
    product_id UInt64,
    quantity UInt32,
    order_date Date,
    order_timestamp DateTime,
    total_amount Decimal(10,2),
    status String,
    payment_method String
) ENGINE = MergeTree()
PARTITION BY order_date
ORDER BY (order_date, user_id, order_timestamp);

-- Create materialized view for daily user activity summary
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_user_activity
ENGINE = SummingMergeTree()
ORDER BY (event_date, user_id)
AS SELECT
    event_date,
    user_id,
    count() as total_events,
    sum(duration_seconds) as total_duration,
    sum(revenue) as total_revenue,
    uniq(session_id) as unique_sessions
FROM events
GROUP BY event_date, user_id;

-- Create view for user analytics
CREATE VIEW IF NOT EXISTS user_analytics AS
SELECT 
    u.user_id,
    u.username,
    u.country,
    u.age,
    u.is_premium,
    u.total_spent,
    u.registration_date,
    count(e.event_id) as total_events,
    count(DISTINCT e.session_id) as unique_sessions,
    sum(e.duration_seconds) as total_time_spent,
    count(DISTINCT e.event_date) as active_days,
    avg(e.duration_seconds) as avg_session_duration
FROM users u
LEFT JOIN events e ON u.user_id = e.user_id
GROUP BY u.user_id, u.username, u.country, u.age, u.is_premium, u.total_spent, u.registration_date;
