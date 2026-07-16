---
date: 2025-07-15
tags: [环境搭建, 工具链, 代理, Codex, OpenRouter, Continue.dev]
summary: "从零搭建完整的 AI 开发工具链：Clash 代理配置、OpenRouter 探索、Codex CLI 尝试与放弃、最终选择 Continue.dev"
---

> ⚠️ **更新（2026-07-16）**：Clash Verge Rev 升级为 Mihomo 内核，代理端口从 7890 变为 **7897**。详见 [代理端口修正日志](../troubleshooting/2026-07-16-代理端口修正-clash-port-fix.md)。`~/.codex/.env` 已同步更新为 7897。另外给 Claude Code 的 `settings.json` 也加了代理，WebFetch 现在能访问被墙页面。

# AI 开发环境从零搭建

> 📅 2025-07-15 | 🏷️ 环境搭建 · 工具链 · 代理 · Codex

## 背景

零基础开始学习 AI 应用开发，目标是找实习和准备秋招。今天从零搭建了完整的 AI 开发工具链。

---

## 完成事项

### 1. 网络代理：Clash Verge Rev

**做了什么：**
- 检查电脑发现 Clash Verge 已被卸载，只残留配置文件和 WebView 缓存
- 从 GitHub Releases 下载最新版 **Clash Verge Rev v2.5.1**
- 旧配置文件 `~/.config/clash-verge/clash-verge.yaml` 仍保留，端口配置：HTTP/SOCKS5 → `7890`，控制器 → `9090`

**学到了什么：**
- Clash Verge 原版已归档，社区继续维护的是 **Clash Verge Rev**（包名 `top.gydi.clashverge`）
- 三个代理模式的区别：
  - **规则模式**：国内直连、国外走代理（日常推荐）
  - **全局模式**：所有流量走代理
  - **直连模式**：全部不走代理
- 免费 Clash 订阅链接不稳定，GitHub Raw 地址经常 404，需准备多个备选

### 2. 付费机场：精灵学院

**做了什么：**
- 测试了两个 GitHub 免费订阅链接全部 404
- 搜索对比多家付费机场，最终选择 **精灵学院**（¥8/月，30GB 流量）
- 成功导入 Clash Verge，节点连通正常

**学到了什么：**
- 免费节点不稳定、速度慢，不适合长期开发使用
- Watt Toolkit（Steam++）无法加速 OpenAI——它通过 DNS 反代解决域名阻断，但 OpenAI 是 IP 级别封锁，必须走代理
- 30GB 流量纯写代码 + 网页浏览足够，但不能看视频（YouTube 1080p ≈ 3GB/小时）
- 流量耗尽时选"重置流量"比重新买套餐便宜

### 3. Codex CLI 安装与代理配置

**做了什么：**
- 通过 npm 全局安装 Codex CLI：`npm install -g @openai/codex`
- 安装版本：**v0.144.4**
- 创建 `~/.codex/.env` 配置代理：

```
https_proxy="http://127.0.0.1:7890"
http_proxy="http://127.0.0.1:7890"
all_proxy="socks5://127.0.0.1:7890"
```

**学到了什么：**
- Codex CLI 通过标准环境变量 `HTTP_PROXY` / `HTTPS_PROXY` 走代理
- `~/.codex/.env` 是社区验证的持久化配置方式
- Codex 首次启动需要 OpenAI API Key 或 ChatGPT 账号登录
- Codex 桌面端无法自定义安装路径（Microsoft Store 限制）

### 4. OpenAI 账号注册与 API Key

**做了什么：**
- 注册 OpenAI 账号（`platform.openai.com`），选择 Free Plan
- 创建第一个 API Key 供 Codex 使用
- 了解 API 按量付费模式：GPT-4o mini $0.15/百万 token，GPT-4o $2.50/百万 token

**学到了什么：**
- 注册 OpenAI 需要海外手机号验证（淘宝"openai 验证码" ¥3-8）
- API 充值 $5 起步，轻量使用一个月用不完
- Plan（Free/Plus/Pro）影响调用频率上限，不影响模型质量
- 中文路径不影响 Codex 使用

### 5. VS Code Codex 插件

**做了什么：**
- 安装 VS Code 官方 Codex 扩展（ID：`openai.chatgpt`）
- 了解三种工作模式和使用策略

**学到了什么：**

| 模式 | 行为 | 使用场景 |
|------|------|----------|
| Chat | 只聊天，不修改文件 | 理解代码、问方案 |
| Agent | 自动读写文件 | 日常开发 |
| Agent (Full Access) | 全自动免审批 | 批处理，用完切回 |

**核心使用原则：**
- 先 Chat 后 Agent：确认方案再执行
- 改代码前先 git commit，改坏了能回滚
- 简单任务用 mini 模型省钱，复杂任务切高端模型
- `/model gpt-4o-mini` 或 `/model gpt-5.6-sol` 随时切换

### 6. OpenRouter 中转探索与最终方案

Codex + OpenAI 直连能工作，但 GPT-5.6 Sol 按量付费较贵。想通过 OpenRouter 中转降低成本，结果踩了一系列坑。

#### 6.1 OpenRouter 地区封锁

测试了 OpenRouter 上所有主流模型厂商：

| 模型厂商 | 结果 | 原因 |
|----------|------|------|
| OpenAI (GPT-4o-mini, GPT-4o) | ❌ 403 | provider ToS violation |
| Anthropic (Claude Sonnet, Haiku) | ❌ 403 | 同上 |
| Google (Gemini) | ❌ 403 | 同上 |
| **Mistral (mistral-large)** | ✅ 可用 | 法国公司，无限制 |
| **Meta (Llama 4 Maverick)** | ✅ 可用 | 通过 DigitalOcean/Novita |
| **Moonshot (Kimi K2)** | ✅ 可用 | 中国公司 |

**结论：OpenRouter 对中国区账号封锁了 OpenAI/Anthropic/Google 模型。只有欧洲和国产模型可用。**

#### 6.2 codex-relay 尝试

Codex 使用 Responses API，而 OpenRouter 只支持 Chat Completions API，需要中间层做协议转换。官方社区提供了 `codex-relay`（Rust 编译的 .exe），但实际测试发现两个 Bug：

**Bug 1：API Key 被截断** — 环境变量只传了 key 前 16 位，完整 key 有 70+ 位。OpenRouter 收到残缺 key → 401 → relay 转成 502。

**Bug 2：二进制 relay 翻译有 bug** — 即使 key 正确，GET /v1/models 能通（加载 343 个模型），但 POST /v1/responses 始终 401。

放弃原版 relay，用 Python 自建 `simple_relay.py`（约 200 行）：

```
Codex (Responses API) → simple_relay → OpenRouter (Chat Completions API)
```

解决的关键问题：
- **协议转换**：Responses API `input` → Chat Completions `messages`
- **模型映射**：`gpt-5.6-sol` → `mistralai/mistral-large`
- **SSE 流式**：非流式 JSON → SSE 事件流（`response.created`, `output_text.delta`, `response.completed`）
- **代理拦截**：`.env` 里 `http_proxy` 导致 localhost 连接也被劫持 → 加 `no_proxy=127.0.0.1,localhost`

#### 6.3 放弃 Codex CLI + relay

relay 能处理简单对话，但 Codex Agent 模式发来的请求太复杂（含 tools、多轮历史、大 context），OpenRouter 返回 400。继续搞下去收益递减，决定放弃 Codex CLI + relay 路线。

#### 6.4 最终方案：Continue.dev

| 对比维度 | Codex + relay | Continue.dev |
|----------|---------------|------|
| API | 需要 Responses API（只有 OpenAI 官方支持）| Chat Completions API（所有服务商都支持）|
| 配置 | config.toml + relay + proxy 绕行 | 一个 config.json |
| 稳定性 | 折腾很久没搞定 Agent 模式 | 开箱即用 |
| 价格 | 免费工具，付费 API | 同左 |
| 模型选择 | 被 OpenRouter 地区锁限制 | Mistral Large / Llama 4 / Kimi K2 |

**安装：**
```bash
code --install-extension Continue.continue
```

**配置文件 `~/.continue/config.json`：**
```json
{
  "models": [
    {
      "title": "Mistral Large",
      "provider": "openrouter",
      "model": "mistralai/mistral-large"
    },
    {
      "title": "Llama 4 Maverick",
      "provider": "openrouter",
      "model": "meta-llama/llama-4-maverick"
    },
    {
      "title": "Kimi K2",
      "provider": "openrouter",
      "model": "moonshotai/kimi-k2"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Llama 4 (Fast)",
    "provider": "openrouter",
    "model": "meta-llama/llama-4-maverick"
  }
}
```

使用方式：VS Code 内 `Ctrl+I` 打开面板，底部下拉切换模型。

**核心结论：OpenRouter 目前只能通过 VSCode 插件（Continue.dev）使用，CLI/relay 路线不可行。**

#### 6.5 可用模型与成本

$10 OpenRouter 余额可用的模型：

| 模型 | 用途 | 输入价格 | 输出价格 |
|------|------|----------|----------|
| `mistralai/mistral-large` | 主力，写代码强 ≈ GPT-4o | $2/M | $6/M |
| `meta-llama/llama-4-maverick` | 备选，速度快 | $0.20/M | $0.60/M |
| `moonshotai/kimi-k2` | 备选，中文好 | $0.60/M | $1.50/M |

中度使用（日均 3-5 万 token）约 $0.20-0.50/天，$10 够用 1-2 个月。

---

## 当前工具链总览

```
┌─────────────────────────────────────────┐
│  VS Code + Continue.dev (Mistral Large)  │  ← 主力：OpenRouter 中转
│  VS Code + Codex 插件 (GPT-5.6 Sol)      │  ← 备选：OpenAI 直连
├─────────────────────────────────────────┤
│  Codex CLI (v0.144.4, 暂不使用)           │  ← 需 OpenAI Key，已弃用
│  simple_relay.py                         │  ← 自建中转（已废弃，代码参考）
├─────────────────────────────────────────┤
│  Clash Verge Rev (v2.5.1)                │  ← 代理
│  └─ 精灵学院 ¥8/月 30GB                  │
│     └─ HTTP/SOCKS5: 127.0.0.1:7890       │
├─────────────────────────────────────────┤
│  hello-agents 项目                        │  ← AI Agent 教学框架
│  ├─ cores/HelloAgentsLLM.py              │
│  ├─ agents/ReActAgent.py                 │
│  ├─ agents/Plan_and_solve.py             │
│  ├─ agents/reflection.py                 │
│  ├─ tools.py                             │
│  └─ simple_relay.py                      │
└─────────────────────────────────────────┘
```

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| Clash 免费订阅链接 404 | GitHub Raw 地址被墙或失效 | 准备多个备选链接，最终用付费机场 |
| `winget` 命令不可用 | Windows 未安装 App Installer | 改用 curl 直接下载安装包 |
| Watt Toolkit 不能加速 OpenAI | 它只解决 DNS 污染，OpenAI 是 IP 封锁 | 必须用代理/VPN |
| Codex 桌面端无法自定义路径 | Microsoft Store 应用限制 | 接受默认路径，或用 VS Code 插件代替 |
| OpenRouter 返回 403 | 中国区账号封锁主流美国模型 | 换成 Mistral/Llama/Kimi |
| codex-relay 502 | API Key 截断 + relay 二进制 bug | 自建 Python relay |
| relay 收不到 Codex 请求 | `.env` 代理劫持了 localhost | 加 `no_proxy` |
| Codex "stream disconnected" | relay 返回 JSON 但 Codex 等 SSE | relay 加 SSE 格式输出 |
| Codex Agent 模式 400 | Mistral 不兼容 Codex 复杂 Agent 格式 | 放弃 Codex，换 Continue.dev |
| relay emoji 崩溃 | Windows GBK 终端无法输出 emoji | `sys.stdout` 重定向为 utf-8 |

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `E:\code\hello-agents\simple_relay.py` | 自建协议转换器（已废弃，代码可参考）|
| `C:\Users\不会再相遇\.continue\config.json` | Continue.dev 配置 |
| `C:\Users\不会再相遇\.codex\config.toml` | Codex 配置（暂不用）|
| `C:\Users\不会再相遇\.codex\.env` | 加了 `no_proxy=127.0.0.1,localhost` |

---

## 下一步计划

- [ ] 用 Continue.dev 辅助完成 hello-agents 项目学习
- [ ] 逐行读懂 hello-agents 项目的三个 Agent 实现（ReAct、Plan-and-Solve、Reflection）
- [ ] 手写一个 Mini ReAct Agent
- [ ] 学习 Prompt Engineering 基础
- [ ] 整理 AI Agent 面试常见知识点
