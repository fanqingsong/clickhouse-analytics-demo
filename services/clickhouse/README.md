# ClickHouse Configuration

ClickHouse 数据库配置和初始化脚本。

## 目录说明

- `config/` - ClickHouse 配置文件
  - `users.xml` - 用户认证配置
- `init-scripts/` - 数据库初始化脚本
  - `01-create-tables.sql` - 创建表结构
  - `02-alter-tables.sql.example` - 表结构变更示例（可按需创建实际文件）

## 配置

- 数据库名：demo_db
- 用户名：demo_user
- 密码：demo_password

## 端口

- 8123 - HTTP 接口
- 9000 - Native 客户端端口

