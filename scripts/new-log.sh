#!/usr/bin/env bash
# new-log.sh — 创建学习日志，更新 README，提交
# 支持三种类型：journal（默认）、troubleshooting、notes
set -euo pipefail

# ---------------------------------------------------------------------------
# 配置
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$PROJECT_DIR/templates/daily-log.md"
README="$PROJECT_DIR/README.md"

TODAY=$(date +%Y-%m-%d)

# ---------------------------------------------------------------------------
# 参数解析
# ---------------------------------------------------------------------------
APPEND_MODE=false
DRY_RUN=false
INTERACTIVE=false
TAGS=""
SUMMARY=""
TITLE=""
SLUG=""
LOG_TYPE="journal"
SUBDIR=""

usage() {
    cat <<EOF
Usage: new-log.sh [OPTIONS] TITLE [SLUG]

Options:
  -a, --append         打开今天已有日志继续编辑（仅 journal 类型）
  -n, --dry-run        预览模式：生成文件但跳过 git 操作
  -i, --interactive    交互模式下提示输入缺失字段
  -t, --tags TAGS      逗号分隔的标签
  -s, --summary S      一句话摘要
  --type TYPE          日志类型：journal（默认）、troubleshooting、notes
  --subdir DIR         notes 子目录（仅 --type notes 时有效）
                       可选：01-foundations 02-agent-loop 03-tools-rag
                             04-harness 05-multi-agent 06-protocols
                             07-evals-safety 08-projects
  -h, --help           显示此帮助信息

Arguments:
  TITLE                标题（中文，必填）
  SLUG                 英文短 slug（可选，默认从标题提取）

Examples:
  bash scripts/new-log.sh "搭建开发环境" "dev-env-setup"
  bash scripts/new-log.sh --type troubleshooting "代理端口修正" "proxy-port-fix"
  bash scripts/new-log.sh --type notes --subdir 02-agent-loop "ReAct 模式实现" "react-pattern"
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--append) APPEND_MODE=true; shift ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -i|--interactive) INTERACTIVE=true; shift ;;
        -t|--tags) TAGS="$2"; shift 2 ;;
        -s|--summary) SUMMARY="$2"; shift 2 ;;
        --type) LOG_TYPE="$2"; shift 2 ;;
        --subdir) SUBDIR="$2"; shift 2 ;;
        -h|--help) usage ;;
        --) shift; break ;;
        -*) echo "未知参数: $1"; usage ;;
        *) break ;;
    esac
done

# ---------------------------------------------------------------------------
# 校验 --type 参数
# ---------------------------------------------------------------------------
case "$LOG_TYPE" in
    journal|troubleshooting|notes) ;;
    *) echo "错误：--type 必须是 journal、troubleshooting 或 notes，当前值: $LOG_TYPE" >&2; exit 1 ;;
esac

# 确定输出目录
case "$LOG_TYPE" in
    journal)        OUTPUT_DIR="$PROJECT_DIR/journal" ;;
    troubleshooting) OUTPUT_DIR="$PROJECT_DIR/troubleshooting" ;;
    notes)
        if [[ -n "$SUBDIR" ]]; then
            OUTPUT_DIR="$PROJECT_DIR/notes/$SUBDIR"
            if [[ ! -d "$OUTPUT_DIR" ]]; then
                echo "错误：notes 子目录不存在：$SUBDIR" >&2
                echo "可用子目录：01-foundations 02-agent-loop 03-tools-rag 04-harness 05-multi-agent 06-protocols 07-evals-safety 08-projects" >&2
                exit 1
            fi
        else
            OUTPUT_DIR="$PROJECT_DIR/notes"
        fi
        ;;
esac

# ---------------------------------------------------------------------------
# 追加模式：仅 journal 类型
# ---------------------------------------------------------------------------
if $APPEND_MODE; then
    if [[ "$LOG_TYPE" != "journal" ]]; then
        echo "错误：-a 追加模式仅支持 journal 类型" >&2
        exit 1
    fi
    EXISTING=$(ls "$OUTPUT_DIR/$TODAY"*.md 2>/dev/null | head -1)
    if [[ -z "$EXISTING" ]]; then
        echo "错误：今天没有日志文件，无法使用 -a 模式" >&2
        echo "请先创建新日志：bash scripts/new-log.sh \"标题\" \"slug\"" >&2
        exit 1
    fi
    echo "打开已有日志：$EXISTING"
    if [[ -n "${EDITOR:-}" ]]; then
        "$EDITOR" "$EXISTING"
    elif command -v code &>/dev/null; then
        code "$EXISTING"
    else
        notepad "$EXISTING"
    fi
    exit 0
fi

# ---------------------------------------------------------------------------
# 标题和 slug
# ---------------------------------------------------------------------------
TITLE="${1:-}"
SLUG="${2:-}"

if [[ -z "$TITLE" ]]; then
    echo "错误：缺少标题" >&2
    usage
fi

if $INTERACTIVE; then
    if [[ -z "$TAGS" ]]; then
        read -r -p "标签（逗号分隔）: " TAGS
    fi
    if [[ -z "$SUMMARY" ]]; then
        read -r -p "一句话摘要: " SUMMARY
    fi
fi

# ---------------------------------------------------------------------------
# 自动生成 slug（如果未提供）
# ---------------------------------------------------------------------------
if [[ -z "$SLUG" ]]; then
    SLUG=$(echo "$TITLE" \
        | sed 's/[^a-zA-Z0-9[:space:]-]//g' \
        | tr '[:upper:]' '[:lower:]' \
        | tr '[:space:]' '-' \
        | sed 's/-\{2,\}/-/g' \
        | sed 's/^-//;s/-$//')
    if [[ -z "$SLUG" ]]; then
        SLUG="log"
    fi
fi

# ---------------------------------------------------------------------------
# 构造文件名
# ---------------------------------------------------------------------------
if [[ "$LOG_TYPE" == "notes" ]]; then
    # notes：无日期前缀，概念名作为文件名
    FILENAME="$OUTPUT_DIR/${TITLE}-${SLUG}.md"
else
    # journal / troubleshooting：日期前缀
    ZH_PART=$(echo "$TITLE" | sed 's/[a-zA-Z0-9[:space:][:punct:]]//g' | head -c 12 | tr -d '\n')
    if [[ -n "$ZH_PART" ]]; then
        FILENAME="$OUTPUT_DIR/${TODAY}-${ZH_PART}-${SLUG}.md"
    else
        FILENAME="$OUTPUT_DIR/${TODAY}-${SLUG}.md"
    fi
fi

# ---------------------------------------------------------------------------
# journal 类型：检查今日是否已有日志
# ---------------------------------------------------------------------------
if [[ "$LOG_TYPE" == "journal" ]]; then
    if compgen -G "$OUTPUT_DIR/$TODAY"*.md >/dev/null 2>&1; then
        EXISTING=$(ls "$OUTPUT_DIR/$TODAY"*.md 2>/dev/null | head -1)
        echo "警告：今天已有日志文件：$EXISTING" >&2
        echo "请使用 -a 参数继续编辑：bash scripts/new-log.sh -a" >&2
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# 从模板生成文件
# ---------------------------------------------------------------------------
if [[ ! -f "$TEMPLATE" ]]; then
    echo "错误：模板文件不存在：$TEMPLATE" >&2
    exit 1
fi

sed \
    -e "s/{{DATE}}/$TODAY/g" \
    -e "s/{{DAY_NUM}}//g" \
    -e "s/{{TITLE}}/$TITLE/g" \
    -e "s/{{TAGS}}/$TAGS/g" \
    -e "s/{{SUMMARY}}/$SUMMARY/g" \
    "$TEMPLATE" > "$FILENAME"

echo "✓ 已创建日志：$FILENAME"
echo "  类型: $LOG_TYPE"

# ---------------------------------------------------------------------------
# 更新 README.md 目录表格
# ---------------------------------------------------------------------------
update_readme() {
    # 生成相对路径的目录前缀
    local dir_prefix
    case "$LOG_TYPE" in
        journal)        dir_prefix="journal" ;;
        troubleshooting) dir_prefix="troubleshooting" ;;
        notes)
            if [[ -n "$SUBDIR" ]]; then
                dir_prefix="notes/$SUBDIR"
            else
                dir_prefix="notes"
            fi
            ;;
    esac

    # 1) 生成新的表格行（扫描所有内容目录）
    local table_tmp="$PROJECT_DIR/.table_new.md"
    printf "| 日期 | 主题 | 标签 |\n|------|------|------|\n" > "$table_tmp"

    # 收集所有内容目录中的 .md 文件
    local all_files=()
    local content_dirs=("journal" "troubleshooting" "notes" "references")
    for dir in "${content_dirs[@]}"; do
        local full_dir="$PROJECT_DIR/$dir"
        if [[ -d "$full_dir" ]]; then
            while IFS= read -r -d '' f; do
                all_files+=("$f")
            done < <(find "$full_dir" -maxdepth 2 -name "*.md" -print0 2>/dev/null || true)
        fi
    done

    for f in "${all_files[@]}"; do
        [[ -f "$f" ]] || continue
        local fname f_rel f_date f_tags f_title
        fname=$(basename "$f")

        # 计算相对路径（相对于 PROJECT_DIR）
        f_rel="${f#$PROJECT_DIR/}"

        f_date=$(sed -n '/^---$/,/^---$/p' "$f" | grep '^date:' | sed 's/^date:\s*//' | tr -d ' ')
        f_tags=$(sed -n '/^---$/,/^---$/p' "$f" | grep '^tags:' | sed 's/^tags:\s*\[//;s/\]$//;s/"//g' | tr -d ' ')
        f_tags=$(echo "$f_tags" | sed 's/, */ · /g')

        f_title=$(head -5 "$f" | grep '^# ' | sed 's/^# //' | sed 's/^Day [0-9]*：//')

        # 回退：从文件名提取日期
        [[ -z "$f_date" ]] && f_date=$(echo "$fname" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
        [[ -z "$f_title" ]] && f_title="（无标题）"

        # 跳过没有日期的笔记（不列入时间索引表）
        [[ -z "$f_date" ]] && continue

        printf "| [%s](./%s) | %s | %s |\n" "$f_date" "$f_rel" "$f_title" "$f_tags" >> "$table_tmp"
    done

    # 2) 收集标签 → 写临时文件
    local tags_tmp="$PROJECT_DIR/.tags_new.md"
    > "$tags_tmp"

    declare -A TAG_MAP
    for f in "${all_files[@]}"; do
        [[ -f "$f" ]] || continue
        local f_tags_line f_rel f_day
        f_tags_line=$(sed -n '/^---$/,/^---$/p' "$f" | grep '^tags:' | sed 's/^tags:\s*\[//;s/\]$//;s/"//g')
        [[ -z "$f_tags_line" ]] && continue

        f_rel="${f#$PROJECT_DIR/}"

        # 从文件名提取日期用于标签显示
        f_day=$(basename "$f" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
        local f_link_text
        if [[ -n "$f_day" ]]; then
            f_link_text="[$f_day](./$f_rel)"
        else
            f_link_text="[$(basename "$f" .md)](./$f_rel)"
        fi

        IFS=',' read -ra TAGS_ARR <<< "$f_tags_line"
        for tag in "${TAGS_ARR[@]}"; do
            tag=$(echo "$tag" | xargs)
            [[ -z "$tag" ]] && continue
            if [[ -n "${TAG_MAP[$tag]:-}" ]]; then
                TAG_MAP[$tag]="${TAG_MAP[$tag]}、$f_link_text"
            else
                TAG_MAP[$tag]="$f_link_text"
            fi
        done
    done

    for tag in $(echo "${!TAG_MAP[@]}" | tr ' ' '\n' | sort); do
        printf -- "- **%s** — %s\n" "$tag" "${TAG_MAP[$tag]}" >> "$tags_tmp"
    done

    # 3) Python 脚本：替换锚点区域
    python -c "
import re

readme_path = r'$README'
table_path = r'$table_tmp'
tags_path = r'$tags_tmp'

with open(table_path, 'r', encoding='utf-8') as f:
    table_content = f.read()
with open(tags_path, 'r', encoding='utf-8') as f:
    tags_content = f.read()
with open(readme_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(
    r'<!-- INDEX_TABLE_START -->.*?<!-- INDEX_TABLE_END -->',
    '<!-- INDEX_TABLE_START -->\n' + table_content + '<!-- INDEX_TABLE_END -->',
    content, flags=re.DOTALL
)
content = re.sub(
    r'<!-- TAGS_START -->.*?<!-- TAGS_END -->',
    '<!-- TAGS_START -->\n' + tags_content + '<!-- TAGS_END -->',
    content, flags=re.DOTALL
)

with open(readme_path, 'w', encoding='utf-8') as f:
    f.write(content)
"

    rm -f "$table_tmp" "$tags_tmp"
    echo "✓ 已更新 README.md"
}

update_readme

# ---------------------------------------------------------------------------
# Git 操作
# ---------------------------------------------------------------------------
if $DRY_RUN; then
    echo "  预览模式：跳过 git 操作"
    echo "---"
    echo "文件预览："
    echo "---"
    head -20 "$FILENAME"
    echo "..."
    exit 0
fi

cd "$PROJECT_DIR"

git add -A

if git diff --cached --quiet; then
    echo "  没有需要提交的变更"
    exit 0
fi

COMMIT_MSG="docs: ${TITLE}"
git commit -m "$COMMIT_MSG"

echo "✓ 已提交：$COMMIT_MSG"

# 推送（如果远程存在）
if git remote | grep -q .; then
    git push origin master
    echo "✓ 已推送到 GitHub"
else
    echo "  提示：未配置远程仓库，跳过推送"
fi

echo "---"
echo "完成！日志：$FILENAME"
