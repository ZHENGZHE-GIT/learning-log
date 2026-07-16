---
date: 2026-07-16
tags: [代理, 工具链, Clash Verge Rev, Claude Code, 故障排查]
summary: "诊断并修复 Clash 代理端口不匹配问题（7890 → 7897），让 Claude Code WebFetch 走代理"
---

# 代理端口修正 + Claude Code 接入代理

> 📅 2026-07-16 | 🏷️ 代理 · Claude Code · 故障排查 · 工具链

## 背景

发现 Claude Code 的 WebFetch 无法访问 openai.com（被墙），但浏览器能正常上 YouTube。怀疑代理端口配置有误。

---

## 完成事项

### 1. 代理端口诊断

**做了什么：**
- 检查 Clash 进程：`clash-verge.exe` (GUI, 端口 33331) 和 `verge-mihomo.exe` (核心, 端口 7897)
- 发现 `profiles.yaml` 里 `current: null`、`items: []`，但代理仍在工作——说明 Clash Verge Rev 的 TUN 模式绕过了传统 SOCKS/HTTP 端口层级
- 通过 `curl -x http://127.0.0.1:7897 http://httpbin.org/ip` 确认代理出口 IP 为香港

**学到了什么：**
- Clash Verge Rev 从某版本起把内核换成了 **Mihomo**（Clash Meta 社区 fork），端口从 7890 变为 7897
- Clash Verge Rev 即使 `profiles.yaml` 显示为空，只要有订阅激活，TUN 模式仍能让浏览器正常代理（不需要手动配 `HTTPS_PROXY`）
- 浏览器走 System Proxy/TUN，CLI 工具必须显式配环境变量 —— 两者是两条独立的代理路径

### 2. Claude Code 接入代理

**做了什么：**
- 在 `~/.claude/settings.json` 的 `env` 段添加了 `HTTPS_PROXY` 和 `HTTP_PROXY` 环境变量，指向 `127.0.0.1:7897`
- `~/.codex/.env` 已提前更新为 7897（无需修改）

**学到了什么：**
- settings.json 的 `env` 字段在 Claude Code 启动时注入，只影响 Claude Code 自身的 HTTP 请求（WebFetch、WebSearch、MCP 连接），不影响系统或其他应用
- 和 Codex 的 `~/.codex/.env` 是同样的机制 —— 每个 CLI 工具独立管理自己的代理配置

### 3. 回顾 Codex CLI 是否复活

端口修好后，Codex CLI + OpenRouter relay 路线仍然不可行：

| 层次 | 问题 | 端口修复能解决？ |
|------|------|:---:|
| 网络层 | 端口 7890 → 7897 | ✅ |
| 协议层 | Responses API vs Chat Completions | ❌ |
| 账号层 | OpenRouter 封锁 OpenAI 模型 | ❌ |

### 4. Day 1 日志补充

- 更新 [Day 1 日志](../journal/2025-07-15-开发环境搭建-dev-env-setup.md) 顶部，添加端口变更提示并链接本文

---

## 当前工具链总览

```
┌─────────────────────────────────────────────────┐
│  Claude Code (deepseek-v4-pro)                   │  ← 主力：DeepSeek 兼容 API
│  ├─ WebFetch → 7897 代理 → 可访问被墙页面         │
│  └─ VS Code + Continue.dev (Mistral Large)       │  ← 备选：OpenRouter 中转
├─────────────────────────────────────────────────┤
│  Clash Verge Rev (Mihomo 内核)                   │  ← 代理
│  ├─ GUI: 127.0.0.1:33331                        │
│  └─ 代理: 127.0.0.1:7897 (HTTP/SOCKS)            │
│     └─ 精灵学院 ¥8/月 30GB                       │
└─────────────────────────────────────────────────┘
```

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| WebFetch 访问 openai.com 失败 | Claude Code 没配代理 | settings.json env 加 HTTPS_PROXY |
| 以为代理端口还是 7890 | Clash Verge Rev 升级后换成 Mihomo 内核 | 用 `netstat -ano` 查出实际端口 7897 |
| `profiles.yaml` 显示为空但代理在用 | TUN 模式不依赖 profile 文件映射 | 这只是显示层面，实际内核有订阅 |

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `C:\Users\不会再相遇\.claude\settings.json` | 新增代理 env 变量 |
| `C:\Users\不会再相遇\.codex\.env` | 已提前更新 7897 |
| `C:\Users\不会再相遇\.config\clash-verge\config.yaml` | 仍写 `mixed-port: 7890`（被 Mihomo 覆盖） |

---

## 下一步计划

- [ ] 用 OpenRouter $10 余额接入 hello-agents 实验
- [ ] 考虑把 Claude Code 的 API 后端从 DeepSeek 迁移到可用代理的更强模型
- [ ] 探索 Puppeteer/Playwright MCP 实现浏览器自动化
