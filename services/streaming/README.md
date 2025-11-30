# Streaming Service

实时数据流服务，持续生成新的测试数据。

## 文件说明

- `stream_data.py` - 数据流生成脚本
- `Dockerfile.streaming` - Docker 镜像构建文件
- `requirements.txt` - Python 依赖

## 功能

- 每 30 秒生成新的用户事件和订单
- 自动管理数据库大小
- 优雅关闭支持

## 配置

- 流间隔：30 秒
- 最大事件数：10,000
- 最大订单数：1,000
- 每批事件数：10
- 每批订单数：3

