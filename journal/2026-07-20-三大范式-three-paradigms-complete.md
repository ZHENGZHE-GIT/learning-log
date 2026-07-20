---
date: 2026-07-20
tags: [Agent范式, ReAct, Plan-and-Solve, Reflection, hello-agents]
summary: "完成 hello-agents 项目三大 Agent 范式的学习：ReAct、Plan-and-Solve、Reflection。转入低代码平台（Dify、Coze）学习阶段"
---

# 三大范式学习完成

> 📅 2026-07-20 | 🏷️ Agent范式 · ReAct · Plan-and-Solve · Reflection · hello-agents

## 背景

hello-agents 项目第 4 章涵盖了 AI Agent 的三种核心范式。学习目标：逐行读懂每个 Agent 的源码实现，理解其控制流设计、提示词工程和适用场景。三个 Agent 共享同一个 `HelloAgentsLLM` 底座，差异全在**控制流架构**——这正好验证了"Agent = LLM + 循环逻辑"的核心公式。

---

## 完成事项

### 1. ReAct 范式（Reasoning + Acting）

**做了什么：**
- 逐行读通 `agents/ReActAgent.py`（约 250 行），理解 Thought → Action → Observation 主循环
- 跟踪了一次完整的工具调用链路：用户问题 → prompt 组装 → LLM 返回 → 正则解析 Thought/Action → 工具执行 → Observation 回填 history → 下一轮循环
- 运行示例：`"华为最新的手机是哪一款？"`，观察 Agent 如何调用 Search 工具获取实时信息

**学到了什么：**
- **正则解析是 ReAct 的工程核心**：用 `Thought:` / `Action:` 固定格式约束 LLM 输出，然后用 `re.search` 提取结构化信息。这本质是"穷人的 function calling"——不需要 OpenAI 的 tool_use API，靠 prompt engineering 就能实现工具调用
- **history 是 LLM 的"记忆"**：LLM 本身无状态，每轮都必须把之前的 Action/Observation 拼回 prompt。history 字符串就是 Agent 唯一的"情景记忆"
- **max_steps 是安全阀**：防止 Agent 陷入"反复搜索但找不到答案"的死循环，同时控制 API 调用成本
- **ReAct 适合"边想边做"**：需要外部信息（搜索、API 调用）的任务用 ReAct，每步都能根据新信息调整策略

### 2. Plan-and-Solve 范式（先规划再执行）

**做了什么：**
- 逐行读通 `agents/Plan_and_solve.py`（约 270 行），理解 Planner → Executor 两段式管道
- 重点研究了 `ast.literal_eval` 的安全解析：为什么不用 `eval()`（LLM 可能输出恶意代码），`literal_eval` 只解析字面量，安全且够用
- 运行示例：水果店卖苹果的数学题，观察计划生成 → 逐步执行的全过程

**学到了什么：**
- **两段式设计是"关注点分离"的经典案例**：Planner 只管宏观分解，Executor 只管逐步执行，职责清晰
- **Plan-and-Solve 不走工具调用**：纯靠 LLM 自身推理能力，适合数学题、逻辑推理、行程规划等不需要外部信息的任务
- **history 的累积方式不同**：ReAct 是 Action/Observation 交替追加，Plan-and-Solve 是步骤结果顺序拼接——两种 history 设计反映了不同的信息流
- **成本可控**：步骤数由 Planner 预先确定，不依赖运行时的动态决策，总 API 调用次数可预测

### 3. Reflection 范式（自我反思迭代优化）

**做了什么：**
- 逐行读通 `agents/reflection.py`（约 275 行），理解 Coder → Reviewer → Refiner 三角色轮转
- 学习了 Memory 类的设计：用 `records` 列表存储 execution/reflection 两类记录，`get_last_execution()` 总是返回最新代码
- 运行示例：找素数函数，观察试除法 → 评审指出 O(n√n) → 优化为埃拉托色尼筛法 O(n log log n)

**学到了什么：**
- **三角色分离是 Reflection 的精髓**：Coder 只管写、Reviewer 只管审、Refiner 只管改——三个角色的 prompt 模板完全不同，但都由同一个 LLM 实例扮演
- **停止条件简单但有效**：用字符串匹配 `"无需改进"` 判断收敛，不需要额外 NLP——因为 prompt 中明确约定了这个信号词
- **Memory 是"草稿本"模式**：不是持久化存储，而是当前任务的短期记忆。执行记录和评审反馈交替排列，形成完整的"上下文链"
- **Reflection 专注产出质量**：不涉及工具调用（ReAct）也不涉及任务分解（Plan-and-Solve），适合代码生成、文章写作等需要多轮打磨的场景

### 三大范式对比

| 维度 | ReAct | Plan-and-Solve | Reflection |
|------|-------|---------------|------------|
| 决策方式 | 每步动态决定下一步 | 提前规划全部步骤 | 每轮基于反馈改进 |
| 工具调用 | ✅ 核心能力 | ❌ 纯 LLM 推理 | ❌ 纯 LLM 推理 |
| 适用场景 | 需要外部信息的任务 | 数学/逻辑推理 | 代码/内容生成 |
| 核心循环 | Thought→Action→Observation | Plan→Execute | Generate→Review→Refine |
| 停止条件 | Finish[答案] 或 max_steps | 计划执行完毕 | "无需改进" 或 max_iterations |
| 成本特征 | 较高，步数不可预测 | 可控，步骤预先确定 | 中等，迭代次数可控 |

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| ReAct 正则解析偶尔失败 | LLM 输出的 Thought/Action 格式不严格符合预期（多出空行、中文标点干扰） | 正则用 `re.DOTALL` 让 `.` 匹配换行，`(.*?)` 非贪婪匹配 |
| Plan-and-Solve 的 `ast.literal_eval` 报错 | LLM 输出的 Python 列表语法有小错误（单引号不匹配、多余空格） | 加 try/except 兜底，`isinstance(plan, list)` 二次校验 |
| Reflection 评审空洞（只说"可以优化"但不给具体方向）| prompt 没有限制 Reviewer 必须给出"算法层面"的具体建议 | prompt 中加入"请分析该代码的时间复杂度"和"提出具体的改进算法建议" |

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `E:\code\hello-agents\agents\ReActAgent.py` | ReAct Agent 完整实现（~250 行，含详尽中文注释） |
| `E:\code\hello-agents\agents\Plan_and_solve.py` | Plan-and-Solve Agent（~270 行，Planner + Executor） |
| `E:\code\hello-agents\agents\reflection.py` | Reflection Agent（~275 行，三角色轮转 + Memory） |
| `E:\code\hello-agents\cores\HelloAgentsLLM.py` | 三个 Agent 共享的 LLM 客户端底座 |
| `E:\code\hello-agents\tools.py` | ToolExecutor + 搜索工具（ReAct 用） |

---

## 下一步计划

- [ ] Dify 平台入门：注册账号、了解 Workflow/Chatflow/Agent 三种应用类型
- [ ] Coze 平台入门：注册账号、创建第一个 Bot、了解插件生态
- [ ] Dify vs Coze 对比分析：各自优势、适用场景、底层架构差异
- [ ] 用 Dify 搭建一个知识库问答机器人，对比手写 ReAct Agent 的开发效率
- [ ] 理解低代码平台的 Agent 实现与手写 Agent 的异同
