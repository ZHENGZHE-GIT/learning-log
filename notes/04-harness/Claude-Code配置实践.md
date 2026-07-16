---
date: 2026-07-16
tags: [Claude Code, 代理, 配置, NO_PROXY, hooks, settings.json]
summary: "Claude Code 代理配置、Hook 结构修复、NO_PROXY 隔离 API 流量、settings.json 管理最佳实践"
---

# Claude Code 配置实践

## 代理配置：HTTPS_PROXY + NO_PROXY 隔离

### 问题

`HTTPS_PROXY` 作用于 Claude Code 的**所有**出站请求（API + WebFetch + WebSearch + MCP），一旦代理不可用全部瘫痪。

### 解决：NO_PROXY 排除直连域名

```json
{
  "env": {
    "HTTPS_PROXY": "http://127.0.0.1:7897",
    "NO_PROXY": "api.deepseek.com,127.0.0.1,localhost"
  }
}
```

**设计思路**：
- API 流量（DeepSeek 国内直连域名）→ `NO_PROXY` 排除，绕过代理直连
- WebFetch/WebSearch（需要翻墙的 URL）→ 走 `HTTPS_PROXY` 代理
- 本地 MCP server（127.0.0.1, localhost）→ `NO_PROXY` 排除，避免被代理劫持（参考 Codex 最佳实践）

> **核心认知**：不是所有流量都需要代理。API 直连更快更稳定，只让需要翻墙的流量走代理。

---

## Hook 结构：三层嵌套

### 正确结构

```json
{
  "SessionEnd": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "cd \"${CLAIDE_PROJECT_DIR}\" && git add -A && git commit -m \"chore: auto-save [auto-save]\""
        }
      ]
    }
  ]
}
```

### 常见错误

- **扁平结构**（缺少 `hooks` 数组）：直接 `matcher + command`，不会报语法错误但 hook 不执行
- **事件名拼写**：`preSessionEnd`（不存在）→ 正确是 `SessionEnd`。错误信息中列出的就是全部有效事件名

### 设计实践

- 自动提交加 `[auto-save]` 前缀：`git log` 一眼区分"AI 自动保存"和"任务正式提交"
- SessionStart 钩子：注入 inbox 状态 + 上次日志文件名，只通知，不强制行为
- push 仍是手动操作：通过全局 permissions deny 保护

---

## settings.json 分层管理

| 层级 | 路径 | 作用域 |
|------|------|--------|
| 全局 | `~/.claude/settings.json` | 所有项目（代理、权限、全局 hooks） |
| 项目 | `<project>/.claude/settings.json` | 当前项目（项目特定 hooks） |

- 全局配置管"怎么连"（代理、认证）
- 项目配置管"做什么"（自动提交、上下文注入）
- 权限 deny（如 `git push`）放全局，一劳永逸

---

## 踩坑教训

| 问题 | 原因 | 解决 |
|------|------|------|
| 无代理时 API ConnectionRefused | `HTTPS_PROXY` 让所有请求走 7897，端口无人监听 | `NO_PROXY=api.deepseek.com` 让 API 直连 |
| SessionEnd 自动提交不触发 | hook 缺少 `hooks` 数组和 `type` 字段 | 补全三层嵌套结构 |
| Hook 事件名拼写错误 | 用了不存在的 `preSessionEnd` | 查错误信息中的有效事件名列表 |

---
来源:
- journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md
- journal/2026-07-15-协作体系搭建-vibe-coding-setup.md
- journal/2026-07-16-工作流改善-workflow-improvement.md
