---
date: 2026-07-16
tags: [AI编程, 模型选型, Vibe Coding, Token, LLM]
summary: "AI 编程发展四阶段、三种编程范式、Token 基础认知、模型选型决策框架、国内用户配置"
---

# AI 编程认知与模型选型

## AI 编程四个发展阶段

| 阶段 | 时期 | 代表产品 | 核心能力 |
|------|------|---------|---------|
| 智能补全 | 2020-2022 | GitHub Copilot | 行级/函数级补全 |
| 对话式编程 | 2023-2024 | ChatGPT、Claude.ai | 自然语言→代码块 |
| **智能体编程** | **2024至今** | **Claude Code、Cursor Agent** | 自主规划+执行+验证 |
| 协作工程 | 2025-未来 | 多Agent协同 | 人类=架构师+审查者 |

> 当前处于第三阶段——AI 从"回答问题"进化到"完成任务"。

## 三种编程范式

| 范式 | 一句话定义 | 适用场景 |
|------|-----------|---------|
| **Vibe Coding** | 描述意图而非细节，快速迭代，"跟着感觉走" | 原型、小项目、前端 |
| **Agentic Engineering** | 系统化方法，多Agent协作、任务分解 | 大型项目、团队协作 |
| **SDD（规范驱动开发）** | 先写 PRD（做什么）+ SPEC（怎么做），再让 AI 执行 | 需要精准控制质量时 |

**演进关系**：Vibe Coding → 项目变大 → Agentic Engineering → 需要精准"合同" → SDD。三种范式不是互斥的，同一项目的不同阶段可能用不同范式。

## Token 基础

- `1 Token ≈ 4 英文字符 ≈ 1-2 中文字符`
- `费用 = 输入Token × 单价 + 输出Token × 单价`
- 上下文窗口 = AI 的"工作记忆"，越大越好（但并非越大越便宜）
- Temperature: 0 = 确定性输出（代码生成），1 = 随机性（创意写作）

## 模型选型决策

### Claude 家族定位

| 模型 | 上下文 | 定位 |
|------|--------|------|
| Haiku 4.5 | 200K | 轻量任务（补全、格式化） |
| **Sonnet 4.6** | 1M | **日常开发主力** |
| Opus 4.7 | 1M | 复杂架构、疑难Bug |

### 决策树

```
简单任务（补全、格式化）    → Haiku / DeepSeek Flash
日常开发（功能实现、Bug）   → Sonnet / DeepSeek V4 Pro
复杂任务（架构、算法）      → Opus / GPT-5.5
超长代码库分析             → Gemini Pro（1M上下文）
国内直连                   → DeepSeek / 千问 / GLM
离线/隐私                   → Ollama 本地模型
```

### 国内用户 Anthropic 兼容端点

| 厂商 | 端点 | 备注 |
|------|------|------|
| **DeepSeek** | `api.deepseek.com/anthropic` | 主力推荐，V4 Pro 用于复杂任务 |
| **智谱 GLM** | `open.bigmodel.cn/api/anthropic` | GLM-4.7 / GLM-4.5-Air |
| **Kimi** | `api.moonshot.ai/anthropic` | 三个槽位都用 `kimi-k2.5` |

> 三个环境变量：`ANTHROPIC_AUTH_TOKEN` + `ANTHROPIC_BASE_URL` + 三级槽位映射

## 关键认知

- **模型能力是地板，配置质量才是天花板**——花时间把配置做好，比追最新模型版本更有实际收益
- 分层使用模型（简单→Haiku, 日常→Sonnet, 复杂→Opus）可节省 30-50% 费用
- 为当前模型写的指令，在下一代模型上可能适得其反——每 3-6 个月审查 CLAUDE.md / settings.json / hooks / skills

---
来源: journal/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md
