# Data Initialization Service

数据初始化服务，生成初始测试数据。

## 文件说明

- `generate_data.py` - 数据生成脚本
- `Dockerfile.init-data` - Docker 镜像构建文件
- `requirements.txt` - Python 依赖

## 功能

生成以下测试数据：
- 10,000 用户
- 500,000+ 事件
- 1,000 产品
- 25,000 订单

## 使用

此服务在首次启动时自动运行，或通过以下命令手动运行：

```bash
docker compose up init-data
```

