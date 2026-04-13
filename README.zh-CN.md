# Codex Clipboard Control

[English](./README.md) | [简体中文](./README.zh-CN.md)

让 macOS 上的截图粘贴，更符合终端/Codex 用户的使用习惯：

- 在 Terminal / Codex 里，截图粘贴会自动变成文件路径
- 在微信、飞书、浏览器、笔记等普通应用里，同一份剪贴板会恢复成真正的图片
- 内置一个更讲究的 SwiftUI 控制面板，可以启停、查看缓存、查看日志、切换主题，并在中文和英文界面之间切换

![Codex Clipboard Control 控制面板](./docs/assets/control-panel.png)

## 解决了什么问题

很多终端聊天客户端不能直接接收系统剪贴板里的原始图片，只能接收文件路径或拖拽文件。这个项目会在后台监听剪贴板，并完成下面这条链路：

1. 发现剪贴板变成图片
2. 仅在受支持的终端位于前台时，把图片保存成临时文件并改写为路径
3. 当你切回普通 GUI 应用时，再把剪贴板恢复为真正的图片

## 环境要求

- macOS 13+
- `swiftc`
- `osacompile`
- `launchctl`

这些工具在安装了 Xcode Command Line Tools 的正常 macOS 开发环境里都可以拿到。

## 安装

```bash
zsh scripts/install.sh
```

安装完成后会放置这些内容：

- helper 二进制：`~/.local/share/codex-clipboard-control/bin`
- 命令包装脚本：`~/.local/bin`
- app bundle：`~/Applications`
- LaunchAgent：`~/Library/LaunchAgents`

## 日常使用

安装并运行后：

1. 正常截图，继续用 iShot 或别的截图工具都可以
2. 回到 Terminal / Codex
3. 按 `Cmd+V`

如果你是在普通 GUI 应用里粘贴，剪贴板会自动恢复成图片。

## 常用命令

```bash
codex-clipboard-control-ui
codex-paste-image
```

- `codex-clipboard-control-ui`：打开图形控制面板
- `codex-paste-image`：手动把当前剪贴板图片保存成文件，并把路径粘贴出去

## 生成发布压缩包

```bash
zsh scripts/package.sh
```

会在 `dist/` 目录下生成一个可分发的源码压缩包。

## 当前支持的终端识别

自动转换逻辑目前识别：

- Terminal.app
- iTerm2
- Warp
- Ghostty

## 项目结构

- `src/swift`：Swift helper 二进制和 SwiftUI 控制面板
- `src/jxa`：JXA applet，用于后台自动化和图形启动器
- `templates/launchd`：LaunchAgent 模板
- `scripts/install.sh`：本地安装脚本
- `scripts/uninstall.sh`：本地卸载脚本

## 卸载

```bash
zsh scripts/uninstall.sh
```

## 故障排查

- 自动粘贴失效：先在控制面板里重启后台监听器
- 其他应用仍然粘贴成文本：确认这次截图发生时，后台监听器是运行中的
- 需要看日志：检查 `/tmp/codex-auto-paste.log`

## 许可证

MIT
