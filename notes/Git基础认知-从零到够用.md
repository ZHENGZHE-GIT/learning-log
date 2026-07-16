---
date: 2026-07-16
tags: [Git, 版本控制, 基础概念, 进阶]
summary: "从零到够用的 Git 认知文档：add/commit/push、分支与合并、冲突解决、stash、reset/revert、rebase、远程协作"
---

# Git 认知文档：从零到够用

> 面向 Git 新手的系统认知，按学习路径从基础到进阶逐步展开

## 一、三个区域：理解 add / commit / push 的本质

Git 不是你硬盘上的文件系统——它维护着**三个独立的空间**：

```
工作目录                    暂存区                     本地仓库                    远程仓库
(你的文件)    ──add──▶    (购物车)    ──commit──▶   (本地历史)    ──push──▶   (GitHub/Gitee)

  hello.md                  hello.md                  commit A                   commit A
  (正在写)                 (已选中)                  commit B                   commit B
                                                     commit C                   commit C
```

| 操作 | 发生了什么 | 类比 |
|------|-----------|------|
| `git add` | 把修改放进**暂存区**（告诉 Git "这些改动我打算提交"） | 超市购物：把商品放进购物车 |
| `git commit` | 暂存区的内容**凝固成一个快照**，存入本地仓库 | 收银台结账：购物车变成一张不可修改的小票 |
| `git push` | 把本地仓库的新 commit **同步到远程**（GitHub 等） | 把买的东西寄到网上存档 |

`★ Insight ─────────────────────────────────────`

**commit 不是"保存文件"，而是"拍了一张整个项目的快照"。** Git 记录的不是文件之间的差异，而是整个项目在某一时刻的完整状态。

**commit 之后、push 之前，你的代码只存在于自己的电脑上。** 这就是为什么光 commit 不 push 不会影响团队——commit 是本地存档，push 是公开发布。

`─────────────────────────────────────────────────`

---

## 二、为什么不能在 master 上直接改

### 没有分支时的困境

```
master 上的提交：
  commit D: 新功能写到一半（还不能用）
  commit C: 修了个 bug
  commit B: 上线版本                   ← 稳定
  commit A: 项目初始化
```

老板说"线上出 bug，紧急修复！"——你的 master 上已经混了写到一半的新功能，没法基于稳定版本修。

### 分支解决的就是这个

```
master:     A ── B ──────────── E (紧急修复) ──── F (合并新功能)
                              /
feature:            C ── D ──
```

- 新功能在 feature 分支上随便折腾，master 保持稳定
- 紧急修复从 B 分出来干，完全不受 feature 影响
- 各自完成后合并到一起

**分支的本质是并行宇宙——创建分支不复制文件，只是建了个指针，所以瞬间完成。**

---

## 三、日常开发标准流程

```bash
# 1. 接到新任务 —— 从 master 拉一个新分支
git checkout master              # 回到主分支
git pull                         # 拉取最新代码
git checkout -b feature-xxx      # 创建并切换到新分支

# 2. 在新分支上开发
# ... 写代码 ...
git add -A
git commit -m "完成 xxx 功能"

# 3. 合并回 master
git checkout master
git merge feature-xxx
git push

# 4. 清理
git branch -d feature-xxx
```

**最简版（单人项目）：**

```bash
git checkout -b my-work
# ... 写代码 ...
git add -A && git commit -m "..."
git checkout master && git merge my-work
git branch -d my-work
```

---

## 四、合并冲突：工作中最常见的挑战

### 冲突是怎么产生的

你改了 `hello.py` 第 10 行，同事也改了 `hello.py` 第 10 行——Git 不知道该听谁的：

```
合并前：
  master:  A ── B ── E (同事改了 hello.py 第10行)
                  \
  feature:         C ── D (你也改了 hello.py 第10行)

执行 git merge feature 时：
  Auto-merging hello.py
  CONFLICT (content): Merge conflict in hello.py  ← 冲突！
```

Git 会在文件里标记出来：

```python
<<<<<<< HEAD
print("master 分支的版本 — 同事的改动")
=======
print("feature 分支的版本 — 你的改动")
>>>>>>> feature
```

### 解决冲突的步骤

```bash
# 1. 打开冲突文件，搜索 "<<<<<<< " 找到所有冲突点
# 2. 手动决定保留谁的版本（或组合两者），删掉标记符
# 3. 标记为已解决
git add hello.py

# 4. 完成合并
git commit -m "merge: 解决 hello.py 冲突，保留了两边的改动"
```

### 三个决策原则

| 情况 | 怎么做 |
|------|--------|
| 你们两个实现的是同一个需求 | 谁的逻辑更完整就用谁的 |
| 你们解决的是不同问题 | **两边都保留**，把代码合并在一起 |
| 你看不懂同事的代码 | 别猜，直接问对方这个改动是干嘛的 |

### 实用的冲突规避技巧

- **经常 pull**，不要攒一周再同步——冲突范围越小越好解决
- `git merge` 之前先 `git fetch`，预判会不会冲突
- 不确定时用 `git merge --abort` 撤销合并，重新来

---

## 五、stash：写到一半需要切换任务

### 场景

你在 feature 分支上改了 5 个文件，还没 commit。这时线上出 bug 要紧急修复，你需要切到 master，但 Git 不让你切——因为有未提交的修改：

```bash
$ git checkout master
error: Your local changes to the following files would be overwritten...
```

### stash 的用法

```bash
# 把当前所有未提交的改动"暂存"起来
git stash

# 现在可以安全切分支了
git checkout master
# ... 修 bug, commit ...

# 回来继续干活，把刚才暂存的改动拿出来
git checkout feature
git stash pop        # 恢复暂存的改动
```

### stash 的常用操作

```bash
git stash                     # 暂存所有改动
git stash save "描述文字"      # 暂存并写备注（方便后面找）
git stash list                # 查看所有暂存
git stash pop                 # 恢复最近一次暂存，并删除记录
git stash apply stash@{1}     # 恢复指定暂存，不删除记录
git stash drop stash@{1}      # 删除指定暂存
```

`★ Insight ─────────────────────────────────────`

**stash 存的是"还没到 commit 级别的草稿"。** 它就像一个临时抽屉——你正在写的东西不想丢，但又没到能正式存档的程度，先塞进去，干完别的事再拿出来继续。

**commit 和 stash 的选择：** 如果只是切出去 5 分钟修个小 bug → stash。如果要切出去干半天 → 直接 commit（哪怕 commit message 写 "WIP: xxx"），commit 比 stash 安全得多。

`─────────────────────────────────────────────────`

---

## 六、reset 和 revert：学会"后悔"

Git 的后悔药分两种：**还没 push 的**（用 reset）和**已经 push 的**（用 revert）。

### reset：还没 push，想撤销

```bash
# 情况1：commit message 写错了，只想改说明文字
git commit --amend -m "新的 commit message"

# 情况2：漏了加一个文件
git add 漏掉的文件
git commit --amend --no-edit   # 把漏的文件补进上一个 commit

# 情况3：commit 的代码有问题，想回到"暂存区"状态（改动保留）
git reset --soft HEAD~1        # 撤销 commit，改动回到暂存区

# 情况4：commit 的代码有问题，想回到"工作目录"状态（改动保留）
git reset HEAD~1               # 撤销 commit + add，改动留在文件里
# 等价于 git reset --mixed HEAD~1

# 情况5：commit 彻底不要了（改动也丢掉）
git reset --hard HEAD~1        # ⚠️ 危险！改动被永久删除
```

| 参数 | commit 记录 | 暂存区 | 你写的代码 |
|------|:---:|:---:|:---:|
| `--soft` | 删掉 | 保留 | 保留 |
| `--mixed`（默认）| 删掉 | 清空 | 保留 |
| `--hard` | 删掉 | 清空 | **删掉** |

### revert：已经 push 了，不能 reset

一旦 push 到远程，就不能 reset 了——因为别人可能已经基于你的 commit 在开发。这时用 revert，**创造一个反向 commit** 来抵消之前的改动：

```bash
# 查看历史，找到要撤销的 commit
git log --oneline

# 撤销指定 commit（创造一个"反向操作"的新 commit）
git revert abc1234

# Git 会打开编辑器让你写 commit message，保存即可
# 效果：改动被取消，但历史记录里保留了两条（原始 + 撤销）
```

| 操作 | 使用场景 | 是否改变历史 |
|------|----------|:---:|
| `git reset` | 还没 push，只有你一个人知道 | ✅ 改写历史 |
| `git revert` | 已经 push，团队其他人可能基于它开发 | ❌ 追加历史 |

`★ Insight ─────────────────────────────────────`

**reset 是"时光机"，revert 是"道歉信"。** reset 让你假装那个 commit 没发生过（回到过去）。revert 是承认"我犯错了"，同时追加一个新的 commit 来修正——历史保留，诚实且安全。

**--hard 之前先 stash。** 养成肌肉记忆：不确定的时候先 `git stash` 把当前改动存起来，再做 reset --hard。这样即使 reset 错了，stash 里的代码还在。

`─────────────────────────────────────────────────`

---

## 七、rebase：整理提交历史

### 为什么要 rebase

你开发一个功能，中途 commit 了 8 次：

```
feature: 完成功能 ← 第8次
         修一个拼写错误 ← 第7次
         又修了一个拼写错误 ← 第6次
         加注释 ← 第5次
         修 bug ← 第4次
         改配置 ← 第3次
         第一次尝试 ← 第2次
         开始写功能 ← 第1次
```

合并回 master 后，master 的历史会包含这些乱七八糟的 commit。rebase 让你在合并前**把这些 commit 整理干净**。

### rebase -i（交互式变基）

```bash
# 整理最近 4 个 commit
git rebase -i HEAD~4
```

Git 会打开编辑器，列出这 4 个 commit，让你对每个选择操作：

```
pick abc1234 开始写功能
pick def5678 修了一个 bug
pick ghi9012 修拼写错误
pick jkl3456 完成功能

# Commands:
# p, pick   = 保留这个 commit
# r, reword = 保留但修改 commit message
# s, squash = 合并到上一个 commit（保留说明）
# f, fixup  = 合并到上一个 commit（丢弃说明）
# d, drop   = 删除这个 commit
```

实际操作——把后 3 个合并到第 1 个：

```
pick abc1234 开始写功能
f def5678 修了一个 bug
f ghi9012 修拼写错误
f jkl3456 完成功能
```

保存退出后，4 个 commit 变成了 1 个干净的大 commit。

### 什么时候 rebase

| 场景 | 用 rebase 还是 merge |
|------|---------------------|
| 把 master 的最新代码同步到你的 feature 分支 | `git rebase master`（保持历史线性） |
| 整理自己分支上的杂乱 commit | `git rebase -i HEAD~N` |
| 把 feature 合并到 master | `git merge`（保留分支结构） |

### ⚠️ rebase 的黄金法则

> **永远不要 rebase 已经 push 到远程的 commit。**

原因：rebase 会改写 commit 的 ID（哈希值）。如果别人已经基于你的原始 commit 开发，你 rebase 后 push，他们的仓库就乱了。

---

## 八、远程协作：fetch / pull / 远程分支

### 本地分支和远程分支的关系

```
你的电脑                     GitHub
  master ──────────跟踪────────▶ origin/master
  feature                        origin/feature
```

`origin/master` 是**你本地保存的一份远程分支的快照**，名字里的 `origin` 是远程仓库的默认名称。

### fetch vs pull

```bash
# fetch：只下载远程更新到本地快照，不改你的工作目录
git fetch origin

# pull：下载远程更新并自动合并到你的当前分支
git pull
# 等价于 git fetch + git merge

# 推荐做法：先 fetch，看清楚了再决定怎么合并
git fetch origin
git log --oneline master..origin/master   # 看看远程多了哪些 commit
git merge origin/master                    # 确认没问题再合并
```

| 操作 | 会改你的代码吗 | 什么时候用 |
|------|:---:|------|
| `git fetch` | 不会 | 先看看远程有什么变化 |
| `git pull` | 会 | 确定要同步，直接合并 |
| `git pull --rebase` | 会 | 同步但保持线性历史（推荐） |

### 日常远程操作

```bash
# 把本地分支推送到远程（首次需要设置上游）
git push -u origin feature-xxx

# 后续直接 push
git push

# 删除远程分支
git push origin --delete feature-xxx

# 清理本地已失效的远程分支引用
git remote prune origin

# 查看远程仓库地址
git remote -v
```

### 协作场景实战

```
场景：同事昨天在你的 feature 分支上加了代码，你今天要继续开发

早上：  git checkout feature
       git pull --rebase          # 把同事的代码同步到本地

白天：  # ... 写代码 ...
       git add -A
       git commit -m "完成功能"

提交前：git fetch
       git rebase origin/master   # 确保你的改动基于最新的 master

提交：  git push
```

`★ Insight ─────────────────────────────────────`

**origin/master 不是远程仓库本身，是"你最后一次 fetch 时远程仓库的样子"。** 如果你 fetch 之后同事 push 了新代码，你的 origin/master 是过期的——这就是为什么要 push 前先 fetch。

**`git pull --rebase` 是大多数团队的默认选择。** 它避免了一堆无意义的 merge commit（"Merge branch 'master' of github.com..."），让提交历史保持干净可读。

`─────────────────────────────────────────────────`

---

## 九、reflog：终极后悔药

如果你 `git reset --hard` 之后发现删错了，`git log` 里已经看不到那个 commit 了——怎么办？

```bash
git reflog
```

reflog 记录了**你在这个仓库做过的所有操作**（即使 commit 已经从历史中删除）：

```
abc1234 HEAD@{0}: reset: moving to HEAD~1       ← 刚才的 reset
def5678 HEAD@{1}: commit: 完成功能               ← 这个就是被删掉的！
ghi9012 HEAD@{2}: commit: 修 bug
```

```bash
# 回到 HEAD@{1}，也就是被误删的那个 commit
git reset --hard HEAD@{1}
# 或
git checkout def5678           # 临时看看那个 commit 的内容
```

> reflog 默认保留 90 天，是你在 Git 里真正的最后防线。

---

## 十、学习路径总结

```
第一周：add / commit / push / branch / merge    ← 先练熟这些
         ↓
第二周：stash / reset / revert                   ← 学会"后悔"
         ↓
第三周：故意制造冲突，反复练习解决               ← 实战能力
         ↓
第四周：rebase -i / fetch / pull --rebase        ← 团队协作必备
         ↓
之后：  reflog / cherry-pick / bisect            ← 按需学习
```

---

## 命令速查表

| 场景 | 命令 |
|------|------|
| 创建并切换分支 | `git checkout -b <name>` |
| 合并分支 | `git merge <name>` |
| 暂存未提交的改动 | `git stash` |
| 恢复暂存的改动 | `git stash pop` |
| 修改最近一次 commit | `git commit --amend` |
| 撤销 commit（保留代码）| `git reset HEAD~1` |
| 撤销 commit（丢弃代码）| `git reset --hard HEAD~1` |
| 撤销已 push 的 commit | `git revert <commit-id>` |
| 整理 commit 历史 | `git rebase -i HEAD~N` |
| 拉取远程更新 | `git pull --rebase` |
| 查看远程状态 | `git fetch && git status` |
| 删除远程分支 | `git push origin --delete <name>` |
| 终极恢复 | `git reflog` |
| 可视化历史 | `git log --oneline --graph --all` |
