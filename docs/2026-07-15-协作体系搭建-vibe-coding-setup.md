---
date: 2026-07-15
day: 2
tags: [Vibe Coding, Claude Code, 插件, Memory, Git, CLAUDE.md, AI Coding教程, 知识蒸馏]
summary: "系统搭建 Claude Code 协作体系（升级 CLAUDE.md、Memory、Git hooks、插件）+ 阅读尚硅谷 AI Coding 教程并提取核心知识体系"
---

# Day 2：Vibe Coding 协作体系搭建

> 📅 2026-07-15 | 🏷️ Vibe Coding · Claude Code · 插件 · Memory · Git · CLAUDE.md · AI Coding教程

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

### 7. 阅读尚硅谷 AI Coding 教程并提取核心知识点

**做了什么：**
- 完整阅读了 300KB+ 的《尚硅谷 AI Coding 零基础实战教程》，涵盖从环境搭建到项目实战的 7 个部分
- 提取蒸馏出核心知识体系，形成快速参考手册

**学到了什么：**
- AI 编程已经从"对话式"进入"智能体时代"——Claude Code 的核心是 LLM Loop（思考→行动→观察→再思考）
- Harness 7 层扩展框架是理解 cc 能力的钥匙：CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents
- 模型能力是地板，配置质量才是天花板
- Skills 是给 AI 写的"标准操作手册"，DRY 原则同样适用于 Prompt

---

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
| `E:\code\learning-log\docs\尚硅谷AI Coding教程.md` | 尚硅谷 AI Coding 零基础实战教程（300KB+） |

---

---

## 尚硅谷 AI Coding 教程 — 核心知识蒸馏

> 来源：`docs/尚硅谷AI Coding教程.md`（300KB+ 完整教程）  
> 提取原则：只保留可操作的核心认知和决策框架，跳过安装步骤和项目代码细节

### 一、AI 编程认知框架

#### 四个发展阶段

| 阶段 | 时期 | 代表产品 | 核心能力 |
|------|------|---------|---------|
| 智能补全 | 2020-2022 | GitHub Copilot | 行级/函数级补全 |
| 对话式编程 | 2023-2024 | ChatGPT、Claude.ai | 自然语言→代码块 |
| **智能体编程** | **2024至今** | **Claude Code、Cursor Agent** | 自主规划+执行+验证 |
| 协作工程 | 2025-未来 | 多Agent协同 | 人类=架构师+审查者 |

> 我们现在处于第三阶段——AI 从"回答问题"进化到"完成任务"。

#### 三个核心概念

| 概念 | 一句话定义 | 适用场景 |
|------|-----------|---------|
| **Vibe Coding** | 描述意图而非细节，快速迭代，"跟着感觉走" | 原型、小项目、前端 |
| **Agentic Engineering** | 系统化方法，多Agent协作、任务分解 | 大型项目、团队协作 |
| **SDD（规范驱动开发）** | 先写 PRD（做什么）+ SPEC（怎么做），再让 AI 执行 | 需要精准控制质量时 |

**三者关系**：Vibe Coding → 项目变大 → Agentic Engineering → 需要精准"合同" → SDD

#### Token 基础认知

```
1 Token ≈ 4 英文字符 ≈ 1-2 个中文字符
费用 = 输入Token × 单价 + 输出Token × 单价
上下文窗口 = AI 的"工作记忆"，越大越好
Temperature: 0=确定性（代码），1=随机性（创意）
```

---

### 二、模型选型决策框架

#### Claude 家族定位

| 模型 | 上下文 | 速度 | 费用 | 定位 |
|------|--------|------|------|------|
| Haiku 4.5 | 200K | 极快 | $ | 轻量任务 |
| **Sonnet 4.6** | 1M | 快 | $$ | **日常开发主力** |
| Opus 4.7 | 1M | 中等 | $$$ | 复杂架构/疑难Bug |

#### 选型决策树

```
简单任务（补全、格式化）    → Haiku / DeepSeek Flash
日常开发（功能实现、Bug）   → Sonnet / DeepSeek V4 Pro
复杂任务（架构、算法）      → Opus / GPT-5.5
超长代码库分析             → Gemini Pro（1M上下文）
国内直连                   → DeepSeek / 千问 / GLM
离线/隐私                   → Ollama 本地模型
```

#### 国内用户模型配置速查

| 厂商 | Anthropic 兼容端点 | 模型映射 |
|------|-------------------|---------|
| **DeepSeek** | `api.deepseek.com/anthropic` | `deepseek-v4-pro[1m]` + `deepseek-v4-flash` |
| **智谱 GLM** | `open.bigmodel.cn/api/anthropic` | 默认 GLM-4.7 / GLM-4.5-Air |
| **Kimi** | `api.moonshot.ai/anthropic` | 三个槽位都用 `kimi-k2.5` |

> 三个环境变量搞定：`ANTHROPIC_AUTH_TOKEN` + `ANTHROPIC_BASE_URL` + 三级槽位映射

---

### 三、LLM Loop：Claude Code 为什么是 Agent 不是聊天框

这是理解 cc 本质的**最关键认知**：

```
传统 ChatGPT：你问一句 → 它答一句 → 结束
Claude Code：你给目标 → 它拆解步骤 → 调工具 → 看结果 → 决定下一步 → ... 循环到完成
```

这个"思考→行动→观察→再思考"的循环就是 **LLM Loop**。cc 是一套"程序+模型"的组合——Loop 机制 + Harness 工程才是它强大的原因，底层模型是可以替换的。

---

### 四、Harness 7 层扩展框架（核心架构认知）

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

> **模型能力是地板，配置质量才是天花板。** 花时间把配置做好，比追最新模型版本更有实际收益。

---

### 五、CLAUDE.md 三层记忆体系

| 层 | 路径 | 加载方式 | 谁维护 |
|----|------|---------|--------|
| ① CLAUDE.md（三级） | 全局→项目→文件夹 | 会话启动全量加载 | 你手动 |
| ② Auto Memory | cc 自动记录 | 先读索引→按需读子文件 | cc 写，你校对 |
| ③ 参考文档 | 自建 `docs/xxx.md` | cc 遇到对应任务才读 | 你手动 |

**一句话区分**：CLAUDE.md 是**第一优先级、全量注入的明规则**；Auto Memory 是**第二优先级、按需注入的隐规则**。

> **本质认知**：Agent 的所有"记忆"，本质上都是在合适的时候向大模型注入压缩过的上下文。

---

### 六、核心命令速查

| 命令 | 作用 | 何时用 |
|------|------|--------|
| `/plan` | 只读规划模式 | **复杂任务起手必用** |
| `/compact` | 压缩上下文为摘要 | 上下文 > 60%，AI 变慢/变笨 |
| `/clear` | 彻底清空对话 | 一个独立任务结束，开始新任务 |
| `/context` | 查看上下文占比 | 诊断 token 消耗来源 |
| `/rewind` | 回滚 cc 的修改 | 代码被改坏了 |
| `/init` | 自动生成 CLAUDE.md | 新项目第一件事 |
| `/review` | AI 代码审查 | 每个功能模块完成后 |
| `/security-review` | 安全检查 | 认证模块 + 上线前 |
| `/model` | 切换模型 | 按任务复杂度选模型 |
| `/cost` | 查看当前会话费用 | 监控开销 |
| `/memory` | 管理记忆/开启 Auto Memory | 长期偏好记录 |
| `!命令` | 在 cc 里执行 Bash | `!npm run dev` |
| `@文件` | 给 cc 精准文件引用 | 节省 cc 探路的 token |

#### 三种权限模式

| 模式 | 行为 | 切换方式 |
|------|------|---------|
| Normal | 每次修改/命令都确认 | 默认 |
| Auto-Accept | 自动执行 | `Shift+Tab` ×1 |
| Plan Mode | 全面只读 | `Shift+Tab` ×2 或 `/plan` |

> 推荐工作流：Plan Mode 探索+规划 → 审核方案 → 切出 Plan Mode → Auto-Accept 执行 → 完成后 `/review`

---

### 七、Prompt 编写 4 条黄金法则

1. **具体不模糊**：❌"帮我做登录" → ✅"在 `/api/auth/` 下创建 POST login，接受 email+password，用 bcrypt 验证，返回 JWT"
2. **引用已有代码**：`参考 /api/bookmarks/route.ts 的风格创建 /api/tags/`
3. **先让 AI 出计划**：❌ 直接写代码 → ✅"请先分析需改哪些文件，列计划，确认后再实现"
4. **一次只做一件事**：❌"同时加搜索、标签、认证" → ✅ 逐个功能来

> **反直觉认知**：指令越短，AI 反而可能花越多 token——因为它要多费力探索项目才能猜到你的意图。描述越具体 + @文件，成本反而低。

---

### 八、Skills 系统

#### 目录结构

```
skill-xxx/
├── SKILL.md          ← 必选：核心指令（YAML frontmatter + 正文）
├── scripts/          ← 可选：辅助脚本
├── resources/        ← 可选：模板、示例、配置（"生产材料"）
└── references/       ← 可选：参考文档（"参考书"）
```

#### Skill vs 单次 Prompt

| 维度 | 单次 Prompt | Skill |
|------|-----------|-------|
| 性质 | 一次性指令 | 可复用标准流程 |
| 一致性 | 每次可能不同 | 每次同样标准 |
| 维护 | 用完即弃 | 可版本管理、持续优化 |

> **识别 Skill 化时机**：同样类型的 Prompt 写了 3 次，就该把它变成 Skill。

#### 生态资源

| 来源 | 地址 | 规模 |
|------|------|------|
| Anthropic 官方 | `github.com/anthropics/skills` | 文档/设计/开发 |
| Vercel 官方 | `github.com/vercel-labs/skills` | 前端生态 |
| skills.sh | skills.sh | 48,000+ |
| SkillsMP | skillsmp.com/zh | 900,000+ |
| 社区精选 | alirezarezvani/claude-skills | 235+ |

---

### 九、核心最佳实践

#### Git 黄金法则

```
在让 AI 做大修改之前，先 git commit 存档
改好了 → commit 新版本
改坏了 → git checkout . 回到存档点
```

> `/rewind` 只能撤销 cc 编辑的文件，跑过的终端命令撤不了。真正靠谱的"后悔药"还是 Git。

#### 上下文管理决策表

| 观察到的现象 | 原因 | 该做什么 |
|-------------|------|---------|
| 响应变慢、质量下降 | 上下文快满了 | `/context` → 高于 60% 就 `/compact` |
| AI 开始"遗忘"早期约定 | 早期信息被挤出窗口 | 立即 `/compact` |
| 要切换到完全不同的任务 | 避免上一个任务污染 | `/clear` 开新会话 |

> **核心心法**：宁可多 `/clear` 几次重新介绍背景，也不要一直聊一直聊。

#### 费用控制 5 策略

| 策略 | 节省比例 |
|------|---------|
| 分层使用（简单→Haiku, 日常→Sonnet, 复杂→Opus） | 30-50% |
| 精准描述（减少来回修改） | 20-30% |
| 及时 `/compact`（避免重复发送长上下文） | 10-20% |
| `/cost` 实时监控 | - |
| 设置月度预算上限 | - |

#### 大型代码库 6 条实践

1. **`/init` + 手工补充**：补充目录地图、禁区、团队约定
2. **任务粒度小**：每个任务 ≤ 5 个文件 / 200 行改动
3. **频繁重置上下文**：任务结束就 `/clear`
4. **Plan Mode 优先**：复杂任务先勘探后动手
5. **Subagents 卸载长任务**：调研类不占主会话上下文
6. **接入 MCP/LSP**：GitHub/数据库/Jira 集成

#### 配置定期审查

> 为当前模型写的指令，在下一代模型上可能适得其反。**每 3-6 个月审查 CLAUDE.md / settings.json / hooks / skills**。

---

### 十、Agentic Search：cc 如何"读懂"代码库

Claude Code **不需要预先索引代码库**。工作方式和一个人类工程师冷启动项目完全一样：

```
你的需求 → 浏览目录结构 → 读取关键文件 → grep 搜索 → 追踪引用 → 理解代码 → 执行
```

**vs 传统 RAG**：不依赖过期索引，始终读实时代码，天生适合活跃开发中的项目。

---

### 十一、项目实战清单（从教程中提取的练手项目）

| 级别 | 项目 | 周期 | 练什么 |
|------|------|------|--------|
| 初级 | 番茄钟 + 任务记录 | 1-2天 | 状态管理、计时器 |
| 初级 | 个人记账工具 | 3-5天 | CRUD、图表、数据建模 |
| 初级 | 习惯追踪器 | 3-5天 | 日历视图、连续打卡 |
| 初级 | Markdown 笔记应用 | 3-5天 | 编辑器、预览、导出 |
| 初级 | 个人作品集网站 | 3-7天 | 响应式、部署 |
| 中级 | 团队任务看板 | 1-2周 | 拖拽、权限、协作 |
| 中级 | 博客/CMS 系统 | 1-2周 | 内容模型、MDX、后台 |
| 中级 | URL 短链接服务 | 3-7天 | API、数据库、统计 |
| 中级 | AI 知识库问答 | 2-3周 | RAG、向量检索 |
| 中级 | 小型电商 MVP | 2-4周 | 全栈业务、订单流程 |

> 选项目三原则：① 需求能一句话说清 ② 有可视化结果 ③ 边界不太大（3天-2周）

---

## 下一步计划

- [ ] 在新会话中验证 Memory 系统是否正常加载
- [ ] 体验 learning-output-style 的学习模式效果
- [ ] 用 `/commit` 完成一次完整的 git 工作流
- [ ] 学习 hello-agents 项目的 ReAct Agent 实现
- [ ] 安装 Tier 2 插件（agent-sdk-dev、pydantic-ai、feature-dev）
