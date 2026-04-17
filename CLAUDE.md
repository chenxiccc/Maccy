# Maccy

macOS 剪贴板管理器，SwiftUI + NSPanel 架构，基于 2.6.1 版本构建。

## 构建命令

```bash
# 构建（必须禁用签名，否则报错）
# Build (signing must be disabled, otherwise it errors)
xcodebuild -scheme Maccy -configuration Debug -derivedDataPath build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

# 构建产物路径 / Build output path
# build/Build/Products/Debug/Maccy.app

# 杀进程并部署 / Kill process and deploy
killall Maccy 2>/dev/null; cp -R build/Build/Products/Debug/Maccy.app /Applications/
```

## 架构概览

- `Maccy/MaccyApp.swift` — 入口，注册 AppDelegate
- `Maccy/AppDelegate.swift` — 管理 FloatingPanel 生命周期、全局热键
- `Maccy/FloatingPanel.swift` — NSPanel 子类，主弹窗
- `Maccy/Observables/` — `@Observable` 状态类（History、HistoryItemDecorator 等）
- `Maccy/Views/` — SwiftUI 视图层
- `Maccy/Models/` — SwiftData 模型（HistoryItem、HistoryItemContent）
- `MaccyTests/` — 单元测试（XCTest）
- `MaccyUITests/` — UI 测试

## 关键 Gotcha

- **预览 popover 动画**：`ContentView.swift` 中 `popover.animates = false` 禁用了 NSPopover 原生动画，但 SwiftUI `.popover()` 仍有内置缩放+淡入过渡（约 0.2s），需用 `withAnimation` 控制
- **签名**：本地 Debug 构建必须加 `CODE_SIGN_IDENTITY=""` 等 flag，否则报 "No signing certificate" 错误
- **功能分支**：`feature/smart-preview-position` 基于 2.6.1 tag，实现了预览弹窗智能左右定位 + 动态图片尺寸

## 2.6.1 vs Master 核心差异
// 2.6.1 is the base for the feature branch; master has a significantly different preview architecture
// 2.6.1 是功能分支的基础版本；master 的预览架构差异较大

| 维度 | 2.6.1（当前功能分支基础） | Master（最新上游） |
|------|--------------------------|-------------------|
| **预览系统** | 每个 `HistoryItemView` 挂 `.popover()` | 全局 `SlideoutController` + 侧滑面板 |
| **状态管理** | `HistoryItemDecorator.isSelected` didSet + `Throttler` | `NavigationManager` 集中管理，`leadHistoryItem` 触发 `autoOpen` |
| **图片加载** | 同步加载，popover 出现时生成 | `AsyncView` 泛型异步加载，支持 loading/error/loaded 三态 |
| **布局** | 浮层 popover，尺寸固定 | HStack 双面板，支持拖拽 resize divider |
| **窗口联动** | 无 | `FloatingPanel.windowWillResize` 与 `SlideoutController` 联动 |
| **额外功能** | 无 | PasteStack 预览、ToolbarView |

**选择 2.6.1 作为基础的原因**：架构简单，popover 方案易于理解和局部修改；我们在此基础上补充了智能定位和动态尺寸。

## 测试

```bash
xcodebuild test -scheme Maccy -destination 'platform=macOS'
```
