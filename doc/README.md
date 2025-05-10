# 从Android自定义View到Flutter自定义视图：彩带飘落效果

本项目包含了彩带飘落效果的Android原生和Flutter实现，以及相关的技术分享文档，从Android自定义View出发引出Flutter自定义视图的实现。

## 文件结构

- `/doc/彩带飘落效果技术分享.md` - 详细的技术分享文档，包含代码实现分析和性能优化考量
- `/doc/彩带飘落效果演示幻灯片.md` - 用于线下分享的幻灯片内容
- `/lib/animation/falling_confett.dart` - Flutter实现的彩带飘落效果
- `/android/app/src/main/kotlin/com/sinyu/uianimations/flutter_100_ui_animations/view/FallingConfettiView.kt` - Android原生实现的彩带飘落效果自定义View
- `/android/app/src/main/kotlin/com/sinyu/uianimations/flutter_100_ui_animations/ConfettiActivity.kt` - 用于展示Android彩带效果的Activity

## 如何使用

### Android原生实现

1. 打开Android应用
2. 启动ConfettiActivity查看效果
3. 使用底部滑块调整彩带数量

### Flutter实现

1. 打开Flutter应用
2. 导航到"彩带飘落"页面查看效果

## 技术分享内容

本技术分享内容适合约30-40分钟的线下演讲，主要内容包括：

1. 彩带飘落效果的实现原理
2. Android自定义View基础知识
3. Android自定义View实现方式
4. Flutter实现方式与对比分析
5. 性能优化策略和注意事项
6. 实际应用场景和扩展思考

## 演示效果

彩带飘落效果在以下应用场景中可以增强用户体验：

- 应用启动欢迎页面
- 成就达成庆祝界面
- 节日或特殊活动主题
- 游戏胜利或完成关卡画面 