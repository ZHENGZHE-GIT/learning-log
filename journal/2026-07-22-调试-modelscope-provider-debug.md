---
date: 2026-07-22
tags: [ModelScope, 流式响应, 踩坑, Provider, Python]
summary: "ModelScope 自定义 Provider 调试：模型 ID 不可用 + 流式空 choices 崩溃"
---

# ModelScope Provider 调试

> 📅 2026-07-22 | 🏷️ ModelScope, 流式响应, 踩坑, Provider, Python

## 背景

在 hello-agents 项目中自定义 ModelScope LLM Provider（`cores/my_llm.py`），继承 `HelloAgentsLLM`，接入 ModelScope 的 Serverless 推理 API。调试过程中遇到两个问题。

---

## 完成事项

### 1. 模型 ID 不可用 —— `has no provider supported`

**做了什么：**
- 初始默认模型设为 `Qwen/Qwen2.5-VL-72B-Instruct`，去掉 `VL` 改为 `Qwen/Qwen2.5-72B-Instruct` 后仍然报 400
- 查 ModelScope API 实际可用模型列表，发现并非所有开源模型都有 Serverless 部署实例
- 最终改为 `Qwen/Qwen3.5-35B-A3B`，调通

**学到了什么：**
- ModelScope 的 Serverless 推理 API（`api-inference.modelscope.cn/v1/`）只覆盖带有「蓝绿色闪电」标识的模型
- Qwen2.5 系列只有 Coder 变体可用，Qwen3/3.5 才是主力支持的
- `has no provider supported` = 后台没有该模型的部署实例，不是权限问题

### 2. 流式响应结束时空 choices 导致 IndexError

**做了什么：**
- 模型调通后流式输出正常，但结束时崩溃：`IndexError: list index out of range`
- 定位到父类 `HelloAgentsLLM.think()` 第 288 行：`chunk.choices[0].delta.content` 不检查空数组
- ModelScope API 流结束时返回 `{"choices": []}`，而 OpenAI 官方不会这样
- 覆写 `think()` 方法，加一行守卫：`if not chunk.choices: continue`

**学到了什么：**
- 不同厂商的 OpenAI 兼容 API 在边界行为上不完全一致——空 choices 是 ModelScope 特有的
- Python 的 `or ""` 兜底只处理"值为空"，不处理"计算过程抛异常"——因为从左往右求值，`choices[0]` 先炸了
- 子类覆写是处理第三方框架 bug 的安全方式——不改 venv 里的安装包，不会被 `pip install` 覆盖

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| `has no provider supported` (400) | 模型 ID 在 ModelScope Serverless API 上没有部署实例 | 换为实际可用的 `Qwen/Qwen3.5-35B-A3B` |
| `IndexError: list index out of range` | 流结束时 ModelScope 返回 `choices: []`，父类直接取 `[0]` | 覆写 `think()`，加 `if not chunk.choices: continue` |
| `UnicodeEncodeError: 'gbk' codec can't encode '\U0001f9e0'` | Windows 终端 GBK 编码不支持 emoji | 用纯文本 `[ModelScope]` 标签替代 |

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `E:\code\hello-agents\cores\my_llm.py` | 自定义 ModelScope Provider，覆写 `think()` 处理空 choices |
| `E:\code\hello-agents\agents\my_main.py` | 测试入口 |

---

## 下一步计划

- [ ] 测试其他 ModelScope 可用模型（`deepseek-ai/DeepSeek-V3.1`、`moonshotai/Kimi-K2.5`）
- [ ] 向 hello-agents 框架提 issue/PR 修复父类的空 choices 处理
- [ ] 研究 ModelScope SDK 方式调用 VL 多模态模型
