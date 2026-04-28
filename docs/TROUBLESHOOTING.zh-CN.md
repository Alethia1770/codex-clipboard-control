# 故障排查

Codex Clipboard Control 只做一件事：截图后，在受支持的终端里按 `Cmd+V`，应该粘贴出 Agent CLI 能读取的图片文件路径。

## 快速检查

1. 打开 `~/Applications/Codex Clipboard Control.app`。
2. 确认状态显示监听器正在运行。
3. 用你原来的截图软件重新截一张图。
4. 把 Terminal、iTerm2、Warp、Ghostty、Codex CLI 或其他受支持终端切到前台。
5. 按 `Cmd+V`。

如果仍然失败，先在控制面板里点 `重启`，然后重新截一张图再试。

## 运行诊断

```bash
zsh scripts/diagnose.sh
```

反馈时请一起提供：

- macOS 版本
- 终端 App 名称
- 截图软件名称
- 在 Notes、微信、飞书、浏览器等普通应用里是否还能正常粘贴图片

## 常见问题

### 终端里没有任何反应

确认这张截图是在监听器启动之后截的。旧剪贴板内容不一定会被转换。

### 终端里粘贴出来的仍然是图片，或者什么都没有

当前前台 App 可能还没有被识别为受支持终端。运行：

```bash
~/.local/bin/codex-frontmost-app
```

把输出发回来，后续可以把这个终端加入识别列表。

### 普通应用里粘贴出来的是文件路径，不是图片

切离终端后稍等一下。后台 helper 会在普通 App 位于前台时，把剪贴板恢复成原始图片。

如果一直没有恢复，点控制面板里的 `重启`。

### LaunchAgent 没有运行

重新安装：

```bash
zsh scripts/install.sh
```

或者打开控制面板，点击 `启用`。

## 日志位置

主日志：

```text
/tmp/codex-auto-paste.log
```

错误日志：

```text
/tmp/codex-auto-paste.stderr.log
```

临时图片目录：

```text
/tmp/codex-clipboard-media
```
