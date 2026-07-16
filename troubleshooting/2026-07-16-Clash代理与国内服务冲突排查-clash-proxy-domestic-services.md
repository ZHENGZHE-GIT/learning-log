---
date: 2026-07-16
tags: [Clash, 代理, Codex, npm]
summary: "Clash 代理路由国内服务导致 npm ECONNRESET 与 Codex SSE 流断连,直连规则解决"
---

# Clash 代理与国内服务冲突排查

> 📅 2026-07-16 | 🏷️ Clash · 代理 · Codex · npm · 故障排查

## 背景

同一天遇到两个看似无关的网络报错,排查后发现是同一个根因:

1. **npm 更新 Codex 失败**:`npm install -g @openai/codex` 报 `ECONNRESET`(TLS 握手中断)
2. **Codex 流式请求断连**:开启 Clash 后,Codex 报 `stream disconnected before completion: Transport error: error decoding response body`

共同根因:**国内可直连的服务被 Clash 代理路由到境外节点**。npm 源指向国内镜像 `cdn.npmmirror.com`,Codex 的 API 中转站 `subrouter.ai` 也是国内可直连——这类流量走境外节点反而不稳定,长连接(SSE 流)尤其容易被中途掐断。

---

## 排查过程

### 1. npm ECONNRESET:直连 vs 走代理对比

**做了什么：**
- `npm config get registry` 确认源是 `registry.npmmirror.com`
- 检查环境变量:`HTTPS_PROXY=http://127.0.0.1:7897` 生效中(npm 会读取这些变量)
- 用 curl 做对照实验:

```bash
curl --noproxy '*' https://cdn.npmmirror.com/             # 直连 → TLS 握手成功
curl -x http://127.0.0.1:7897 https://cdn.npmmirror.com/  # 走代理 → exit 35 (TLS 失败)
```

**学到了什么：**
- `curl --noproxy '*'` vs `curl -x <proxy>` 的对照实验是定位"代理 vs 网络"问题的最快手段
- 根路径返回 403 不代表不通——TLS 握手成功、拿到 HTTP 状态码就说明链路正常

### 2. Codex 流断连:沿请求链路逐跳定位

**做了什么：**
- 读 `~/.codex/config.toml`,发现 `base_url = "http://127.0.0.1:15721/v1"`——Codex 并不直连中转站
- `netstat -ano | grep 15721` + `tasklist` 确认 15721 端口是 `cc-switch.exe`(CC Switch 本地转发服务)
- 读 `~/.cc-switch/logs/cc-switch.log`,找到真正的故障点:

```
[FWD-003] Provider SubRouter 请求失败: 请求转发失败: Failed to read response body: error decoding response body
```

- 查注册表确认代理机制:`enable_tun_mode: false`,"开启 Clash" 实际是开启系统代理(WinINET `ProxyServer=127.0.0.1:7897`),CC Switch 作为常规 Windows 应用跟随系统代理
- curl 对照:subrouter.ai 直连和走代理**短请求都正常(200)**——但 LLM 响应是持续几十秒的 SSE 长连接,境外节点中途掐断,`reqwest` 解码响应体到一半失败

**学到了什么：**
- 报错出现在哪一层 ≠ 故障在哪一层:Codex 显示的错误其实是 CC Switch 转发上游失败后透传回来的,**沿链路逐跳看日志**才能定位
- SSE 长连接比短请求对网络质量敏感得多:短请求测试通过不代表流式可用
- Windows 下"开代理"有三种机制(环境变量 / 系统代理 WinINET / TUN),影响的应用范围不同:CLI 工具看环境变量,GUI 应用跟随系统代理,TUN 劫持一切

### 3. 解决:Clash 直连规则(一次配置,两个问题都覆盖)

**做了什么：**
- 在 Clash Verge Rev「全局扩展配置」(Merge)中添加:

```yaml
prepend-rules:
  - DOMAIN-SUFFIX,subrouter.ai,DIRECT
```

- npm 场景当时用了临时方案(关闭 Clash 后更新成功);长期方案是 `npm config set noproxy "registry.npmmirror.com,cdn.npmmirror.com"`(未采用,留作备忘)

**学到了什么：**
- 必须用 `prepend-rules` 而不是 `append-rules`:Clash 规则从上到下匹配,append 会排在订阅的 `MATCH` 兜底规则之后,永远不生效
- Merge 配置比直接改订阅更持久——订阅更新不会覆盖它
- 验证方法:Clash「连接」面板中 subrouter.ai 的链路显示 **DIRECT** 而非节点名

---

## 请求链路总览

```
┌──────────┐  http://127.0.0.1:15721/v1  ┌───────────┐  https://subrouter.ai  ┌───────────┐
│  Codex   │ ──────────────────────────→ │ CC Switch │ ─────────────────────→ │ SubRouter │
└──────────┘      (本地,不经代理)         └───────────┘    ↑ 故障点在这一跳      └───────────┘
                                               │
                                  开启系统代理后,这一跳被路由进
                                  Clash (7897) → 境外节点 → SSE 长连接被掐断
```

---

## 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| npm 更新 Codex 报 ECONNRESET | 国内镜像 cdn.npmmirror.com 被代理路由到境外,TLS 中断 | 关闭 Clash(临时);npm noproxy 或 Clash 直连规则(长期) |
| Codex 报 stream disconnected | CC Switch → subrouter.ai 走系统代理,SSE 长连接被境外节点掐断 | Clash Merge 加 `DOMAIN-SUFFIX,subrouter.ai,DIRECT` |
| npm 升级时 EPERM 清理警告 | 在 Codex 内自更新,运行中的 codex.exe 被 Windows 文件锁占用 | 无害;残留临时目录关闭 Codex 后手动删除 |
| cmd 里 `rm` 不可用 | `rm`/`$VAR` 是 Git Bash 语法,cmd 用 `rmdir /s /q`/`%VAR%` | 区分 shell 再敲命令 |
| new-log.sh 中英混合标题被截断 | 脚本处理混合编码标题时文件名截断且退出码 1 | 手动重命名;待修脚本 |

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `~/.codex/config.toml` | Codex base_url 指向 CC Switch 本地端口 15721 |
| `~/.cc-switch/logs/cc-switch.log` | 定位故障跳的关键日志 |
| Clash Verge「全局扩展配置」(Merge) | 添加 prepend-rules 直连规则 |
| `~/.codex/.env` | CLI 代理环境变量(no_proxy 已含 127.0.0.1) |

---

## 下一步计划

- [ ] 修复 `scripts/new-log.sh` 中英混合标题截断 bug(文件名生成 + 退出码 1)
- [ ] 其它国内直连服务(DeepSeek API 等)按需补充 Clash 直连规则
- [ ] 考虑用 SessionStart hook 做 Clash 存活检测(已在 _status 待办中)
