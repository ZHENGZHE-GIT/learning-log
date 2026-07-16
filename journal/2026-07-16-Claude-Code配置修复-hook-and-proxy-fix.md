---
date: 2026-07-16
tags: [Claude Code, 代理, 配置修复, hooks, NO_PROXY]
summary: "修复 SessionEnd hook 结构 + 让 API 连接绕过代理，解决 Clash 未启动时 ConnectionRefused 问题"
---

# Claude Code 配置修复：Hook 结构 + API 代理隔离

> 📅 2026-07-16 | 🏷️ Claude Code · 代理 · 配置修复 · hooks · NO_PROXY

## 背景

两个问题：
1. 项目级 `SessionEnd` hook 结构不正确，缺少 `hooks` 数组层级
2. 全局 `settings.json` 的 `HTTPS_PROXY` 让**所有** HTTP 流量（包括 DeepSeek API 调用）都走 Clash 代理，一旦 Clash 没开就 `ConnectionRefused`

## 完成事项

### 1. 修复 SessionEnd hook 结构

**做了什么：**
- `E:\code\learning-log\.claude\settings.json` 中的 hook 条目缺少 `hooks` 数组和 `type: "command"`，直接从 `matcher + command` 扁平结构改为 `matcher + hooks[{type, command}]` 嵌套结构

**学到了什么：**
- Claude Code hooks 结构是 `{ event: [{ matcher, hooks: [{ type, command }] }] }`，三层嵌套
- 错误结构（扁平 `command`）不会报解析错误，但 hook 不会执行

### 2. 让 API 连接绕过代理（核心修复）

**做了什么：**
- 在 `~/.claude/settings.json` 的 `env` 段添加 `"NO_PROXY": "api.deepseek.com"`
- DeepSeek API 是国内直连域名，不需要走代理

**学到了什么：**
- `HTTPS_PROXY` 作用于 Claude Code 的**所有**出站请求（API + WebFetch + WebSearch + MCP）
- `NO_PROXY` 可以排除特定域名，让它们绕过代理直连
- `api.deepseek.com` 在国内直连更快更稳定，本就不该走代理
- Codex 早就配了 `no_proxy=127.0.0.1,localhost`（避免本地 relay 被代理劫持），这个最佳实践也适用于 Claude Code

### 3. 设计思路演变

初始方案是加 `SessionStart` hook 检测代理存活状态 → 用户指出"API 就不该依赖代理" → 改为用 `NO_PROXY` 从根本上隔离。Hook 方案治标，`NO_PROXY` 治本。

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| 没有代理时 API 连接 ConnectionRefused | `HTTPS_PROXY` 让所有请求走 7897，端口无人监听 | 加 `NO_PROXY=api.deepseek.com` 让 API 直连 |
| SessionEnd 自动提交不触发 | hook 结构缺少 `hooks` 数组和 `type` 字段 | 补全 `{ matcher, hooks: [{ type, command }] }` |

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `E:\code\learning-log\.claude\settings.json` | 修复 SessionEnd hook 结构 |
| `C:\Users\不会再相遇\.claude\settings.json` | 新增 `NO_PROXY=api.deepseek.com` |

---

## 下一步计划

- [ ] 后续考虑加 `NO_PROXY=127.0.0.1,localhost`（参考 Codex 最佳实践，本地 MCP server 避免被代理劫持）
- [ ] 考虑用 `SessionStart` hook 做 Clash 存活检测，仅针对需要代理的 WebFetch/WebSearch 场景
