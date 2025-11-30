# AI Chat Service

AI 聊天服务，使用 Azure OpenAI 通过自然语言查询 ClickHouse 数据。

## 文件说明

- `chat_service.py` - Flask 聊天服务主文件
- `Dockerfile.chat` - Docker 镜像构建文件
- `requirements.txt` - Python 依赖

## 功能

- 自然语言查询转换 SQL
- 执行 ClickHouse 查询
- 返回格式化的结果

## 端口

- 5001 - 聊天服务接口

## 依赖服务

- ClickHouse 数据库
- Azure OpenAI API（需要配置）

## 环境变量配置

需要设置以下环境变量：

- `AZURE_OPENAI_ENDPOINT` - Azure OpenAI 端点 URL（必需）
- `AZURE_OPENAI_API_KEY` - Azure OpenAI API 密钥（必需）
- `AZURE_OPENAI_DEPLOYMENT_NAME` - 部署名称（可选，默认为 gpt-4）
- `AZURE_OPENAI_API_VERSION` - API 版本（可选，默认为 2024-02-15-preview）

## 使用示例

```bash
export AZURE_OPENAI_ENDPOINT='https://your-resource.openai.azure.com'
export AZURE_OPENAI_API_KEY='your-api-key'
export AZURE_OPENAI_DEPLOYMENT_NAME='gpt-4'

docker compose up -d chat
```

