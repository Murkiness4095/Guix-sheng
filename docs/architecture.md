# 架构

按目的分层：

- packages/：软件包（kernel, u-boot, firmware, vendor libs）
- modules/：Guix 模块与 OS 片段
- services/：shepherd 服务
- scripts/：工具与工作台
- docs/：文档与交接
- tests/：系统/配置测试
- examples/：最小配置
- rooms/：按职能的异步协作通道
- shared/：共享机制（约定、状态、锁）
- workbench/：实时进度与待办工作台
