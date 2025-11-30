# ClickHouse 表结构变更指南

## 概述

ClickHouse 支持通过 `ALTER TABLE` 语句动态修改表结构，包括添加列、修改列、删除列等操作。

## 支持的操作

### 1. 添加列（ADD COLUMN）

```sql
-- 基本语法
ALTER TABLE table_name ADD COLUMN column_name column_type [DEFAULT default_value];

-- 示例：添加带默认值的列
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number String DEFAULT '';

-- 示例：添加可空列
ALTER TABLE events ADD COLUMN IF NOT EXISTS user_agent String NULL;

-- 示例：添加多个列
ALTER TABLE users 
    ADD COLUMN IF NOT EXISTS last_login_date Date DEFAULT today(),
    ADD COLUMN IF NOT EXISTS login_count UInt32 DEFAULT 0;
```

**注意事项：**
- 使用 `IF NOT EXISTS` 可以避免重复添加列的错误
- 对于 MergeTree 引擎，新增列是**异步操作**，会应用到所有现有分区
- 新列在现有数据中会使用默认值（如果指定了 DEFAULT）
- 如果没有指定 DEFAULT，新列在现有数据中会是该类型的零值（0, '', 等）

### 2. 修改列（MODIFY COLUMN）

```sql
-- 修改列类型
ALTER TABLE users MODIFY COLUMN total_spent Decimal(12,2);

-- 修改默认值
ALTER TABLE users MODIFY COLUMN is_premium UInt8 DEFAULT 0;
```

**注意事项：**
- 修改列类型需要兼容，否则可能失败
- 对于数值类型，通常可以扩大精度（如 Decimal(10,2) -> Decimal(12,2)）

### 3. 删除列（DROP COLUMN）

```sql
-- 删除列
ALTER TABLE users DROP COLUMN IF EXISTS phone_number;
```

**注意事项：**
- ⚠️ **危险操作**：删除列会永久丢失该列的所有数据
- 使用 `IF EXISTS` 可以避免列不存在时的错误

### 4. 重命名列（RENAME COLUMN）

```sql
-- 重命名列
ALTER TABLE users RENAME COLUMN old_name TO new_name;
```

## 在项目中的实现方式

### 方式一：通过初始化脚本（推荐用于新环境）

1. 创建新的 SQL 脚本文件，文件名使用数字前缀确保执行顺序：
   ```
   services/clickhouse/init-scripts/
   ├── 01-create-tables.sql      # 创建表
   ├── 02-alter-tables.sql       # 添加列（新建）
   └── 03-add-indexes.sql        # 添加索引（如果需要）
   ```

2. 在 `02-alter-tables.sql` 中添加 ALTER TABLE 语句：
   ```sql
   USE demo_db;
   
   ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number String DEFAULT '';
   ALTER TABLE events ADD COLUMN IF NOT EXISTS user_agent String NULL;
   ```

3. 重启 ClickHouse 容器，脚本会自动执行：
   ```bash
   docker compose restart clickhouse
   ```

**注意：** 这种方式只在**新环境**或**重建容器**时有效。对于已有数据的生产环境，需要使用方式二。

### 方式二：手动执行（用于已有数据的生产环境）

1. 连接到 ClickHouse：
   ```bash
   docker compose exec clickhouse clickhouse-client \
       --user demo_user \
       --password demo_password \
       --database demo_db
   ```

2. 执行 ALTER TABLE 语句：
   ```sql
   ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number String DEFAULT '';
   ```

3. 验证变更：
   ```sql
   DESCRIBE users;
   ```

### 方式三：通过 Python 脚本（用于程序化变更）

可以在 `generate_data.py` 或创建新的迁移脚本中执行：

```python
def add_column_to_table(client: ClickHouseClient, table: str, column_name: str, 
                       column_type: str, default_value: str = None):
    """添加列到表"""
    query = f"ALTER TABLE {table} ADD COLUMN IF NOT EXISTS {column_name} {column_type}"
    if default_value:
        query += f" DEFAULT {default_value}"
    
    try:
        client.execute(query)
        print(f"Successfully added column {column_name} to {table}")
    except Exception as e:
        print(f"Error adding column: {e}")
        raise
```

## 最佳实践

1. **使用 IF NOT EXISTS / IF EXISTS**
   - 避免重复执行时的错误
   - 使脚本具有幂等性

2. **设置合理的默认值**
   - 对于非空列，必须指定 DEFAULT
   - 考虑现有数据的影响

3. **测试变更**
   - 先在测试环境验证
   - 检查现有查询是否受影响

4. **记录变更**
   - 维护变更日志
   - 记录变更原因和时间

5. **备份数据**
   - 重要变更前备份数据
   - 使用 `docker compose down` 前确保数据卷已备份

## 常见问题

### Q: 新增列会影响现有数据吗？
A: 不会。新列在现有数据中会使用默认值或零值，不会影响已有数据。

### Q: ALTER TABLE 操作是同步还是异步？
A: 对于 MergeTree 引擎，ADD COLUMN 是异步操作，但通常很快完成。

### Q: 可以回滚 ALTER TABLE 操作吗？
A: 可以。删除列可以回滚（如果数据还在），但修改列类型可能无法完全回滚。

### Q: 如何检查 ALTER TABLE 是否完成？
A: 可以查询 `system.mutations` 表查看 ALTER TABLE 的执行状态。

## 示例：完整的表结构变更流程

```sql
-- 1. 添加新列
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number String DEFAULT '';

-- 2. 验证列已添加
DESCRIBE users;

-- 3. 更新现有数据（如果需要）
-- UPDATE users SET phone_number = '123-456-7890' WHERE user_id = 1;
-- 注意：ClickHouse 的 UPDATE 是异步操作，需要启用 mutations

-- 4. 检查变更状态
SELECT * FROM system.mutations WHERE table = 'users' ORDER BY create_time DESC LIMIT 5;
```

## 参考文档

- [ClickHouse ALTER TABLE 文档](https://clickhouse.com/docs/en/sql-reference/statements/alter/table)
- [ClickHouse 数据类型](https://clickhouse.com/docs/en/sql-reference/data-types/)

