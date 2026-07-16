---
date: 2026-07-16
tags: [LLM Loop, Agent, ReAct, 工具调用, Agentic Search]
summary: "LLM Loop 是 Agent 区别于聊天框的核心机制——思考→行动→观察的自主循环；Agentic Search 用实时探索替代预索引"
---

# LLM Loop 与 Agent 工作原理

## LLM Loop：Agent vs 聊天框的本质区别

```
传统 ChatGPT：你问一句 → 它答一句 → 结束
Claude Code：你给目标 → 它拆解步骤 → 调工具 → 看结果 → 决定下一步 → ... 循环到完成
```

这个"**思考→行动→观察→再思考**"的循环就是 LLM Loop。每次循环是一次独立的 LLM 调用，上下文在调用间累积传递。

**核心洞察**：Claude Code 的本质是一套"程序+模型"的组合——Loop 机制 + Harness 工程才是它强大的原因，底层模型是可以替换的。这意味着：
- 换一个更强的模型 → Agent 更聪明（但不是唯一变量）
- 优化 Harness 配置 → Agent 更高效（往往收益更大）

## Agentic Search：如何"读懂"代码库

Claude Code **不需要预先索引代码库**。工作方式和人类工程师冷启动项目完全一样：

```
你的需求 → 浏览目录结构 → 读取关键文件 → grep 搜索 → 追踪引用 → 理解代码 → 执行
```

**vs 传统 RAG**：
- RAG：依赖预先构建的向量索引，可能过期
- Agentic Search：始终读实时代码，天生适合活跃开发中的项目
- 代价：每次都要"重新读"，消耗更多 token

## 工具调用（Tool Use）是 Loop 的"手"

没有工具，Agent 只能聊天。Claude Code 的工具集包括：
- **读**：Read、Glob、Grep——理解代码
- **写**：Write、Edit——修改代码
- **执行**：Bash——运行命令、测试
- **编排**：Agent、Task——管理子任务

> Agent 的自主性来自"能用工具 + 会判断何时用哪个工具"。

## 核心认知

- Agent 的所有"记忆"，本质上都是在合适的时候向大模型注入压缩过的上下文
- Loop 不是魔法——每次循环都是一次独立的 API 调用，只是上下文在累积
- 上下文窗口有限 → Loop 次数有上限 → 需要在合适的时候 `/compact` 或 `/clear`

---
来源: journal/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md
