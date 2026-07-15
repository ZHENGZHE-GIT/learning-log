---
date: 2026-07-15
tags: [Vibe Coding, Claude Code, 插件, Memory, Git, CLAUDE.md]
summary: "系统搭建 Claude Code 协作体系：升级全局/项目 CLAUDE.md、建立 Memory 记忆系统、配置 Git hooks 自动提交、安装 4 个核心插件"
---

# Vibe Coding 协作体系搭建

> 📅 2026-07-15 | 🏷️ Vibe Coding · Claude Code · 插件 · Memory · Git · CLAUDE.md

## 背景

上午搭好了 AI 开发环境（Codex CLI、OpenRouter、Continue.dev），但发现跟 Claude Code 协作时每次都要重新解释项目背景、代码规范、工具链配置。今天的目标是建立一套高效的 AI 协作体系，让 Claude Code 在新会话中自动了解项目上下文和我的偏好。

---

## 完成事项

### 1. 升级全局 CLAUDE.md

**做了什么：**
- 在 `C:\Users\不会再相遇\.claude\CLAUDE.md` 原有沟通规范基础上，新增 4 个章节：
  - **Vibe Coding 协作原则**：主动给建议、复杂任务先 /plan、改完提醒验证
  - **技能使用**：写图表用 dataviz、不熟悉的 API 主动查、改完提醒 code-review
  - **工具使用偏好**：优先专用工具（Glob/Grep/Read）而非 Bash
  - **能力边界**：不确定别猜、被纠正就记到 Memory

**学到了什么：**
- 全局 CLAUDE.md 是所有项目的共同指令，新会话自动加载
- 它不只是"沟通规范"——可以告诉 AI 怎么做决策、怎么选工具、什么情况用什么 skill
- 大多数人只用它定义规则，更好的用法是定义"协作模式"

### 2. 搭建 Memory 记忆系统

**做了什么：**
- 在 `C:\Users\不会再相遇\.claude\projects\E--code-learning-log\memory\` 下创建了 4 个记忆文件：
  - `user-profile.md` — 角色、技术栈、学习目标
  - `project-learning-log.md` — 项目规范、命名约定、Git 格式
  - `toolchain.md` — 工具链配置路径、OpenRouter 可用模型与价格
  - `feedback-preferences.md` — 沟通风格、Git 偏好、代码质量偏好
- 创建 `MEMORY.md` 索引文件，指向所有记忆

**学到了什么：**
- Memory 是 Claude Code 的跨会话持久化机制——每次新对话 AI 会自动加载 MEMORY.md 索引
- 记忆文件用 YAML frontmatter 标注类型（user / project / feedback / reference）
- 以后说"记住这个"就能自动写入新记忆
- Memory 比 CLAUDE.md 更适合存动态信息（偏好、踩坑、决策原因）

### 3. 补强项目 CLAUDE.md

**做了什么：**
- `E:\code\learning-log\CLAUDE.md` 新增 3 个章节：
  - **外部依赖与相关项目**：hello-agents 项目、Continue.dev 配置、OpenRouter 限制
  - **写作规范**：中英混用规则、表格/代码块约定
  - **日常工作流**：从学习到提交的 5 步流程

**学到了什么：**
- 项目 CLAUDE.md 应该回答"AI 新会话开局想知道什么"：目录结构、编码规范、常用命令、外部依赖
- 大多数项目 CLAUDE.md 太空泛，关键信息（配置路径、API 限制）容易被省略

### 4. 配置 Git 自动提交

**做了什么：**
- 创建 `E:\code\learning-log\.claude\settings.json`，配置 `preSessionEnd` hook
- 每次会话结束时自动执行 `git add -A && git commit`

**学到了什么：**
- Claude Code 的 hooks 系统可以在特定事件触发自定义命令
- `preSessionEnd` 钩子适合做自动保存、自动提交这类收尾工作
- 项目级 settings.json 只影响当前项目，不污染全局配置
- push 仍是手动操作（全局 settings.json deny 了 `git push`），安全可控

### 5. 安装 Claude Code 插件

**做了什么：**
- 探索了官方插件市场（38 个内置 + 17 个第三方）
- 安装了 4 个插件：

| 插件 | 作用 | 加载内容 |
|------|------|---------|
| **learning-output-style** | 学习模式：关键点让你自己写代码 | 6 agents |
| **pyright-lsp** | Python 类型检查 + 代码智能 | 1 LSP server |
| **explanatory-output-style** | 新会话自动解释设计决策 | 1 hook |
| **commit-commands** | `/commit`、`/commit-push-pr`、`/clean_gone` | 3 skills |

**学到了什么：**
- `/plugin install 插件名@claude-plugins-official` 安装，`/reload-plugins` 生效
- 插件可以包含多种扩展：skills（斜杠命令）、agents（子代理）、hooks（事件触发）、LSP servers（语言服务）
- **learning-output-style** 对学习阶段最有用——AI 会问"这段你想自己写吗？"而不是直接代劳
- **commit-commands** 让你 `/commit` 一句完成 git add/commit/push
- pyright-lsp 需要额外 `npm install -g pyright` 安装本体

### 6. 学习 Vibe Coding 核心技巧

**学到了什么：**

| 技巧 | 反面例子 | 正面例子 |
|------|----------|----------|
| **用 /plan 启动** | "帮我写个脚本" | "/plan：我要做 XXX，先探索再出方案" |
| **给上下文** | "修一下 bug" | "运行 XX 报错 exit 1，相关文件是 YY，帮我排查" |
| **用 Memory 积累** | 每次重复解释偏好 | 说"记住：commit 用英文" |
| **分步骤迭代** | 一次提 10 个需求 | 先模板→再脚本→最后测试 |
| **用 skill 检查** | 写完就提交 | 先 `/code-review` 再提交 |

---

## 当前工具链总览

```
┌─────────────────────────────────────────┐
│  VS Code + Continue.dev (Mistral Large)  │  ← 主力：OpenRouter 中转
│  Claude Code (DeepSeek v4-pro)           │  ← 编程协作
├─────────────────────────────────────────┤
│  Clash Verge Rev v2.5.1                  │  ← 代理
│  └─ 精灵学院 ¥8/月 30GB                  │
├─────────────────────────────────────────┤
│  Claude Code 协作体系                     │
│  ├─ 全局 CLAUDE.md（协作原则+工具偏好）    │
│  ├─ 项目 CLAUDE.md（结构+规范+依赖）      │
│  ├─ Memory ×4（用户画像/项目/工具链/偏好） │
│  ├─ Git hooks（会话结束自动 commit）       │
│  └─ 插件 ×4（学习/类型检查/解释/提交）     │
└─────────────────────────────────────────┘
```

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| 全局 CLAUDE.md 太简陋 | 之前只写了沟通规则，没写协作模式 | 新增"协作原则""工具偏好""能力边界"章节 |
| Memory 目录存在但全空 | 不知道这个功能，从未使用 | 创建 4 个记忆文件 + MEMORY.md 索引 |
| 每次新会话 AI 不了解项目 | 项目 CLAUDE.md 缺外部依赖和常用命令 | 补充相关项目路径、API 配置、工作流 |
| 插件太多不知道怎么选 | 38 内置 + 大量第三方，没有引导 | 按 Tier 分级筛选：学习阶段先装 3 个核心的 |
| /plugin 命令不生效 | 输入内容被当作普通文本，不是命令 | 确保在聊天框直接输入（非粘贴到代码块），回车执行 |

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `C:\Users\不会再相遇\.claude\CLAUDE.md` | 全局 CLAUDE.md（已升级） |
| `E:\code\learning-log\CLAUDE.md` | 项目 CLAUDE.md（已补强） |
| `E:\code\learning-log\.claude\settings.json` | 项目 hooks 配置（preSessionEnd） |
| `C:\Users\不会再相遇\.claude\projects\E--code-learning-log\memory\` | Memory 记忆目录（4 个文件） |
| `C:\Users\不会再相遇\.claude\plugins\marketplaces\claude-plugins-official\` | 官方插件市场 |
| `E:\code\learning-log\templates\daily-log.md` | 日志模板 |
| `E:\code\learning-log\README.md` | 项目索引（已加锚点和标签索引） |

---

## 下一步计划

- [ ] 在新会话中验证 Memory 系统是否正常加载
- [ ] 体验 learning-output-style 的学习模式效果
- [ ] 用 `/commit` 完成一次完整的 git 工作流
- [ ] 学习 hello-agents 项目的 ReAct Agent 实现
- [ ] 安装 Tier 2 插件（agent-sdk-dev、pydantic-ai、feature-dev）
