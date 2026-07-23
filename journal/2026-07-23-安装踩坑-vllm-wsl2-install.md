---
date: 2026-07-23
tags: [vLLM, WSL2, 环境搭建, 踩坑]
summary: "在 WSL2 Ubuntu 中安装 vLLM，解决 Windows 不兼容和临时目录空间不足等问题"
---

# vLLM WSL2 安装踩坑

## 背景

hello-agents 第七章要求安装 vLLM。在 Windows 上 `pip install vllm` 失败（Windows 长路径限制 + 官方不支持），最终在 WSL2 Ubuntu 中成功安装。

## 完成事项

### vLLM 在 WSL2 中安装

**做了什么：**
1. 在 WSL2 Ubuntu 26.04 中创建 Python 虚拟环境
2. 通过 `pip install --no-cache-dir vllm` 安装 vLLM 0.22.1
3. 解决安装过程中的 `/tmp` 空间不足问题

**学到了什么：**
- **vLLM 官方只支持 Linux/macOS**，Windows 上社区 fork（SystemPanic/vllm-windows）功能不全
- **WSL2 的 `/tmp` 是 tmpfs 内存盘**（大小 = 物理内存的一半），安装大型 Python 包时容易爆
- `export TMPDIR=/path/to/disk` + `--no-cache-dir` 可以让 pip 的临时文件走到磁盘分区

### WSL2 用户名修改

**做了什么：**
将 WSL2 Ubuntu 的默认用户从 `docker`（易与 Docker 服务混淆）改为 `zhengzhe`

**学到了什么：**
- WSL 默认用户由两个机制控制：`/etc/wsl.conf` 的 `[user]` 段 + Windows 侧的 `ubuntu config --default-user`
- `wsl -l -v` 查看所有发行版，`wsl -d 发行版名` 指定进入

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| Windows `pip install vllm` 报长路径错误 | vLLM 不支持 Windows，且 GPU 型号名太长 | 改用 WSL2 |
| `wsl` 进入后提示符为 `docker@` | 默认发行版被 Docker Desktop 改为 `docker-desktop` | `wsl -d Ubuntu` 指定发行版 |
| `ubuntu config --default-user` 命令不存在 | `ubuntu.exe` 不在 Windows PATH 中 | 直接在 `/etc/wsl.conf` 中写 `[user]\ndefault=zhengzhe` |
| `pip install vllm` 报 `No space left on device` | WSL2 的 `/tmp` 是 tmpfs 内存盘，仅 3.9G | `export TMPDIR=/home/zhengzhe/tmp` + `--no-cache-dir` |
| `new-log.sh` 脚本执行失败 | 日志标签/摘要中的 `/tmp` 导致 sed 替换语法错误 | 手动创建日志文件 |

## 关键文件

- `E:\code\hello-agents\.venv-linux` — WSL2 中的 Python 虚拟环境
- vLLM 版本：`0.22.1`

## 理解要点

- **WSL2**：Windows 内嵌的 Linux 子系统，共享 GPU（通过 NVIDIA WSL 驱动），性能几乎无损
- **vLLM**：大模型推理引擎，核心优化是 PagedAttention（动态内存管理），吞吐量可达 Ollama 的 10-20 倍
- **vLLM vs Ollama**：Ollama 定位"简单好用"，适合个人手动使用；vLLM 定位"高性能基础设施"，提供 OpenAI 兼容 API，适合 Agent 高频调用

## 下一步计划

- [ ] 在 vLLM 上加载模型并测试推理
- [ ] 配置 vLLM 的 OpenAI 兼容 API
- [ ] 继续 hello-agents 第七章学习
