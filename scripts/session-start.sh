#!/usr/bin/env bash
# session-start.sh — SessionStart hook 调用的学习进度仪表盘
# 从现有 markdown 文件实时提取数据，零维护负担
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# ═══════════════════════════════════════════════════════════════════
# 学习阶段定义（索引数组保序）
# ═══════════════════════════════════════════════════════════════════
PHASE_DIRS=(
  "01-foundations"
  "02-agent-loop"
  "03-tools-rag"
  "04-harness"
  "05-multi-agent"
  "06-protocols"
  "07-evals-safety"
  "08-projects"
)

PHASE_DESCS=(
  "LLM 原理 / Transformer / RLHF"
  "ReAct / 工具调用 / 最小 Agent"
  "工具设计 / 检索增强 / 向量数据库"
  "真实 Agent 系统源码分析"
  "多 Agent 协作模式"
  "MCP / A2A / Skills"
  "评估体系 / 安全边界"
  "项目实战"
)

echo ""
echo "═══════════════════════════════════════════"
echo "          📊 Learning Progress"
echo "═══════════════════════════════════════════"

# ── 阶段进度 ──────────────────────────────────────────────
done_count=0
total=${#PHASE_DIRS[@]}

for i in "${!PHASE_DIRS[@]}"; do
  dir="${PHASE_DIRS[$i]}"
  desc="${PHASE_DESCS[$i]}"
  phase_path="notes/$dir"

  if [ -d "$phase_path" ]; then
    note_count=$(find "$phase_path" -maxdepth 1 -name "*.md" ! -name ".gitkeep" 2>/dev/null | wc -l)
  else
    note_count=0
  fi

  if [ "$note_count" -gt 0 ]; then
    done_count=$((done_count + 1))
    printf "  %-18s  ✅  (%d 篇笔记)  %s\n" "$dir" "$note_count" "$desc"
  else
    printf "  %-18s  ⬜              %s\n" "$dir" "$desc"
  fi
done

echo "───────────────────────────────────────────"
echo "  进度: $done_count/$total 阶段有内容"
echo "───────────────────────────────────────────"

# ── 下一步 ───────────────────────────────────────────────
echo ""
echo "  📋 下一步:"
if [ -f "_status.md" ]; then
  unchecked=$(awk '/^## 下一步/{found=1; next} /^## /{found=0} found && /^- \[ \]/' _status.md | head -5)
  if [ -n "$unchecked" ]; then
    echo "$unchecked" | while IFS= read -r line; do
      task=$(echo "$line" | sed 's/^- \[ \] //')
      echo "    ☐ $task"
    done
  else
    echo "    (无待办任务)"
  fi
else
  echo "    (_status.md 不存在)"
fi

# ── Inbox ─────────────────────────────────────────────────
echo ""
if [ -f "_inbox.md" ]; then
  in_count=$(awk '/^## 待处理/{found=1; next} /^## /{found=0} found && /^- /' _inbox.md | wc -l)
  echo "  📥 Inbox: ${in_count} 条待处理"
else
  echo "  📥 Inbox: (无 _inbox.md)"
fi

# ── 最近日志 ─────────────────────────────────────────────
echo ""
echo "  📝 最近日志:"
recent=$(ls -t journal/2*.md 2>/dev/null | head -3)
if [ -n "$recent" ]; then
  echo "$recent" | while IFS= read -r f; do
    base=$(basename "$f" .md)
    date_part=$(echo "$base" | cut -c6-10)  # MM-DD
    # 提取标题：跳过 YAML frontmatter (--- ... ---)，取第一个 # 标题行
    title=$(awk 'BEGIN{in_fm=0} /^---$/{if(in_fm==0){in_fm=1; next}else{in_fm=0; next}} !in_fm && /^# /{print substr($0,3); exit}' "$f" 2>/dev/null)
    if [ -z "$title" ]; then
      title=$(basename "$f" .md | cut -d- -f4- | sed 's/-/ /g')
    fi
    printf "    %s  %s\n" "$date_part" "$title"
  done
else
  echo "    (无日志)"
fi

echo ""
echo "───────────────────────────────────────────"
echo ""
