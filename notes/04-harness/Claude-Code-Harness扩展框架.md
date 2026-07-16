---
date: 2026-07-16
tags: [Harness, Claude Code, CLAUDE.md, Memory, Skills, Hooks, Plugins, 架构]
summary: "Claude Code 的 Harness 7 层扩展框架 —— 从 CLAUDE.md 到 Subagents，理解每层的定位和使用场景"
---

# Claude Code Harness 扩展框架

## 7 层架构

```
⑦ Subagents（子代理）      ← 独立上下文，并行干活
⑥ MCP Servers              ← 连接外部工具与数据源
⑤ LSP（语言服务器）         ← IDE 级代码导航
④ Plugins                  ← Skills+Hooks+MCP 打包分发
③ Skills                   ← 按需加载的专业知识包
② Hooks                    ← 会话生命周期钩子
① CLAUDE.md                ← 项目上下文文件
─────────────────────────
   模型本身（地板）
```

> **核心原则**：模型能力是地板，配置质量才是天花板。花时间把 Harness 配置做好，比追最新模型版本更有实际收益。

---

## ① CLAUDE.md — 三级记忆体系

| 层 | 路径 | 加载方式 | 谁维护 |
|----|------|---------|--------|
| ① CLAUDE.md（三级） | 全局→项目→文件夹 | 会话启动全量加载 | 你手动 |
| ② Auto Memory | cc 自动记录 | 先读索引→按需读子文件 | cc 写，你校对 |
| ③ 参考文档 | 自建 `docs/xxx.md` | cc 遇到对应任务才读 | 你手动 |

**一句话区分**：CLAUDE.md 是**第一优先级、全量注入的明规则**；Auto Memory 是**第二优先级、按需注入的隐规则**。

### CLAUDE.md 应该包含什么

全局 CLAUDE.md：沟通方式、协作原则、工具偏好、能力边界——所有项目的共同指令。

项目 CLAUDE.md：回答"AI 新会话开局想知道什么"：
- 目录结构和各目录定位
- 编码规范、命名约定
- 常用命令和自动化脚本
- 外部依赖路径和 API 限制
- 工作流（任务开始→执行→收尾）

> CLAUDE.md 控制在 200 行以内——超过后 AI 合规率下降。

### Memory 系统

Memory 用 YAML frontmatter 标注类型（user / project / feedback / reference），每次新对话 AI 自动加载 MEMORY.md 索引。

**Memory vs CLAUDE.md 的选择**：
- CLAUDE.md：全量注入，适合固定规范和工作流
- Memory：按需加载，适合动态信息（偏好、踩坑、决策原因）

---

## ② Hooks — 会话生命周期钩子

### 结构

```json
{
  "EventName": [
    {
      "matcher": "正则匹配（可选）",
      "hooks": [
        {
          "type": "command",
          "command": "要执行的命令"
        }
      ]
    }
  ]
}
```

三层嵌套：`Event → [{ matcher, hooks: [{ type, command }] }]`。扁平结构不会报错但不会执行。

### 常用事件

| 事件 | 用途 |
|------|------|
| `SessionStart` | 注入上下文（inbox 状态、上次日志），不强制行为 |
| `SessionEnd` | 自动保存、自动 commit（加 `[auto-save]` 前缀区分于手动提交） |
| `PreToolUse` | 工具调用前的检查/拦截 |
| `PostToolUse` | 工具调用后的后处理 |

### 设计原则

- Hooks 是**确定性执行**（100%），CLAUDE.md 是**建议性指导**——两者定位不同
- SessionStart 只注入上下文，不强制行为——过度自动化增加认知负担
- 关键操作（push、删除）通过全局 settings.json 的 permissions deny 保护

---

## ③ Skills — 可复用的标准操作流程

### 目录结构

```
skill-xxx/
├── SKILL.md          ← 必选：核心指令（YAML frontmatter + 正文）
├── scripts/          ← 可选：辅助脚本
├── resources/        ← 可选：模板、示例、配置（"生产材料"）
└── references/       ← 可选：参考文档（"参考书"）
```

### Skill vs 单次 Prompt

| 维度 | 单次 Prompt | Skill |
|------|-----------|-------|
| 性质 | 一次性指令 | 可复用标准流程 |
| 一致性 | 每次可能不同 | 每次同样标准 |
| 维护 | 用完即弃 | 可版本管理、持续优化 |

> **识别 Skill 化时机**：同样类型的 Prompt 写了 3 次，就该把它变成 Skill。DRY 原则同样适用于 Prompt。

### Skills 是给 AI 写的"标准操作手册"

不是给人类看的文档，而是给 AI 执行的标准流程。写好 Skill 的关键：
- 明确触发条件（什么时候用这个 Skill）
- 分步骤指令（每一步做什么、用什么工具）
- 预期输出格式

---

## ④ Plugins — 打包分发

插件可以包含多种扩展：skills（斜杠命令）、agents（子代理）、hooks（事件触发）、LSP servers（语言服务）。

安装方式：`/plugin install 插件名@claude-plugins-official`，`/reload-plugins` 生效。

---

## ⑤-⑦ LSP / MCP / Subagents

- **LSP**：集成语言服务器（如 pyright），提供 IDE 级代码导航和类型检查
- **MCP**：连接外部工具与数据源（GitHub、数据库、Jira），扩展 Agent 的能力边界
- **Subagents**：独立上下文，并行干活——调研类任务不占主会话上下文

---

## 关键认知

- Harness 的每一层解决不同的问题：CLAUDE.md 解决"不了解项目"，Memory 解决"记不住偏好"，Skills 解决"重复写同样 prompt"，Hooks 解决"忘了做某件事"
- 配置是投资——今天花 10 分钟写好 Skill，未来每次用都省 10 分钟
- 不需要一次性配齐所有层——从 CLAUDE.md 开始，需要什么加什么

---
来源:
- journal/2026-07-15-尚硅谷教程知识蒸馏-shangguigu-distillation.md
- journal/2026-07-15-协作体系搭建-vibe-coding-setup.md
- journal/2026-07-16-Claude-Code配置修复-hook-and-proxy-fix.md
- journal/2026-07-16-工作流改善-workflow-improvement.md
