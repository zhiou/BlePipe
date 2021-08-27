# BluePipe

尽量屏蔽service characteristic 等概念的蓝牙通信库, 使用起来更直观简单.

### TODO

- [ ] 抽象pipe 组包解包, 允许自定义数据包完整性检查

- [ ] 修改Peripheral端接口设计, 与Central端保持一致, 尤其是port的获取和存储方式

- [ ] 抽取port和pipeEnd公用代码,形成统一的处理逻辑

- [ ] 修复内存泄漏等问题

- [ ] 尝试L2CAP相关功能并提供相应接口

- [ ] 补充代码注释

- [ ] 提供cocoapods 配置

- [ ] 完善Demo
- [ ] 配置travis-ci
