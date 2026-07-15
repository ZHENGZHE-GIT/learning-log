#!/usr/bin/env bash
# new-log.sh — 创建每日学习日志，更新 README，提交并推送
set -euo pipefail

# ---------------------------------------------------------------------------
# 配置
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$PROJECT_DIR/templates/daily-log.md"
README="$PROJECT_DIR/README.md"
DOCS_DIR="$PROJECT_DIR/docs"

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

usage() {
    cat <<EOF
Usage: new-log.sh [OPTIONS] TITLE [SLUG]

Options:
  -a, --append      打开今天已有日志继续编辑（而非新建）
  -n, --dry-run     预览模式：生成文件但跳过 git 操作
  -i, --interactive 交互模式下提示输入缺失字段
  -t, --tags TAGS   逗号分隔的标签
  -s, --summary S   一句话摘要
  -h, --help        显示此帮助信息

Arguments:
  TITLE             日志标题（中文，必填）
  SLUG              英文短 slug（可选，默认从标题提取）
EOF
    exit 0
}

# 简单的参数解析（支持长短参数）
while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--append) APPEND_MODE=true; shift ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -i|--interactive) INTERACTIVE=true; shift ;;
        -t|--tags) TAGS="$2"; shift 2 ;;
        -s|--summary) SUMMARY="$2"; shift 2 ;;
        -h|--help) usage ;;
        --) shift; break ;;
        -*) echo "未知参数: $1"; usage ;;
        *) break ;;
    esac
done

# ---------------------------------------------------------------------------
# 追加模式：打开今日已有日志
# ---------------------------------------------------------------------------
if $APPEND_MODE; then
    EXISTING=$(ls "$DOCS_DIR/$TODAY"*.md 2>/dev/null | head -1)
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

# 交互模式：提示补充 tags 和 summary
if $INTERACTIVE; then
    if [[ -z "$TAGS" ]]; then
        read -r -p "标签（逗号分隔）: " TAGS
    fi
    if [[ -z "$SUMMARY" ]]; then
        read -r -p "一句话摘要: " SUMMARY
    fi
fi

# ---------------------------------------------------------------------------
# 检查今日是否已有日志
# ---------------------------------------------------------------------------
if compgen -G "$DOCS_DIR/$TODAY"*.md >/dev/null 2>&1; then
    EXISTING=$(ls "$DOCS_DIR/$TODAY"*.md 2>/dev/null | head -1)
    echo "警告：今天已有日志文件：$EXISTING" >&2
    echo "请使用 -a 参数继续编辑：bash scripts/new-log.sh -a" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# 自动生成 slug（如果未提供）
# ---------------------------------------------------------------------------
if [[ -z "$SLUG" ]]; then
    # 提取英文或从标题生成：移除中文、特殊字符，转小写
    SLUG=$(echo "$TITLE" \
        | sed 's/[^a-zA-Z0-9[:space:]-]//g' \
        | tr '[:upper:]' '[:lower:]' \
        | tr '[:space:]' '-' \
        | sed 's/-\{2,\}/-/g' \
        | sed 's/^-//;s/-$//')
    if [[ -z "$SLUG" ]]; then
        # 纯中文标题：取标题前几个中文字的拼音近似
        SLUG="log"
    fi
fi

# ---------------------------------------------------------------------------
# 确定 Day 编号
# ---------------------------------------------------------------------------
get_next_day() {
    local max_day=0
    local d
    for f in "$DOCS_DIR"/*.md; do
        [[ -f "$f" ]] || continue
        # 从 YAML frontmatter 中提取 day:
        d=$(sed -n '/^---$/,/^---$/p' "$f" | grep -i '^day:' | awk '{print $2}' | tr -d ' ')
        if [[ -z "$d" ]]; then
            # 回退：从标题中提取 Day N
            d=$(head -1 "$f" | grep -oE 'Day[[:space:]]+[0-9]+' | grep -oE '[0-9]+')
        fi
        [[ -n "$d" ]] && [[ "$d" -gt "$max_day" ]] && max_day="$d"
    done
    echo $((max_day + 1))
}

DAY_NUM=$(get_next_day)

# ---------------------------------------------------------------------------
# 提取中文前缀用于文件名
# ---------------------------------------------------------------------------
# 移除 ASCII 字符（字母/数字/空格/标点），保留中文等 CJK 字符
ZH_PART=$(echo "$TITLE" | sed 's/[a-zA-Z0-9[:space:][:punct:]]//g' | head -c 12 | tr -d '\n')

# 构造文件名
if [[ -n "$ZH_PART" ]]; then
    FILENAME="$DOCS_DIR/${TODAY}-${ZH_PART}-${SLUG}.md"
else
    FILENAME="$DOCS_DIR/${TODAY}-${SLUG}.md"
fi

# ---------------------------------------------------------------------------
# 从模板生成日志文件
# ---------------------------------------------------------------------------
if [[ ! -f "$TEMPLATE" ]]; then
    echo "错误：模板文件不存在：$TEMPLATE" >&2
    exit 1
fi

sed \
    -e "s/{{DATE}}/$TODAY/g" \
    -e "s/{{DAY_NUM}}/$DAY_NUM/g" \
    -e "s/{{TITLE}}/$TITLE/g" \
    -e "s/{{TAGS}}/$TAGS/g" \
    -e "s/{{SUMMARY}}/$SUMMARY/g" \
    "$TEMPLATE" > "$FILENAME"

echo "✓ 已创建日志：$FILENAME"
echo "  Day: $DAY_NUM"

# ---------------------------------------------------------------------------
# 更新 README.md 目录表格
# ---------------------------------------------------------------------------
update_readme() {
    local rel_path="docs/$(basename "$FILENAME")"

    # 1) 生成新的表格行（从所有日志文件的 frontmatter 收集）
    local table_tmp="$PROJECT_DIR/.table_new.md"
    printf "| 日期 | 主题 | 标签 |\n|------|------|------|\n" > "$table_tmp"
    for f in "$DOCS_DIR"/*.md; do
        [[ -f "$f" ]] || continue
        local fname f_rel f_date f_tags f_title
        fname=$(basename "$f")
        f_rel="docs/$fname"

        f_date=$(sed -n '/^---$/,/^---$/p' "$f" | grep '^date:' | sed 's/^date:\s*//' | tr -d ' ')
        f_tags=$(sed -n '/^---$/,/^---$/p' "$f" | grep '^tags:' | sed 's/^tags:\s*\[//;s/\]$//;s/"//g' | tr -d ' ')
        f_tags=$(echo "$f_tags" | sed 's/, */ · /g')

        f_title=$(head -5 "$f" | grep '^# ' | sed 's/^# //' | sed 's/^Day [0-9]*：//')

        [[ -z "$f_date" ]] && f_date=$(echo "$fname" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
        [[ -z "$f_title" ]] && f_title="（无标题）"

        printf "| [%s](./%s) | %s | %s |\n" "$f_date" "$f_rel" "$f_title" "$f_tags" >> "$table_tmp"
    done

    # 2) 收集标签 → 写临时文件
    local tags_tmp="$PROJECT_DIR/.tags_new.md"
    > "$tags_tmp"

    declare -A TAG_MAP
    for f in "$DOCS_DIR"/*.md; do
        [[ -f "$f" ]] || continue
        local f_tags_line f_day f_rel
        f_tags_line=$(sed -n '/^---$/,/^---$/p' "$f" | grep '^tags:' | sed 's/^tags:\s*\[//;s/\]$//;s/"//g')
        f_day=$(sed -n '/^---$/,/^---$/p' "$f" | grep '^day:' | awk '{print $2}' | tr -d ' ')
        f_rel="docs/$(basename "$f")"

        IFS=',' read -ra TAGS_ARR <<< "$f_tags_line"
        for tag in "${TAGS_ARR[@]}"; do
            tag=$(echo "$tag" | xargs)
            [[ -z "$tag" ]] && continue
            if [[ -n "${TAG_MAP[$tag]:-}" ]]; then
                TAG_MAP[$tag]="${TAG_MAP[$tag]}、[Day $f_day](./$f_rel)"
            else
                TAG_MAP[$tag]="[Day $f_day](./$f_rel)"
            fi
        done
    done

    for tag in $(echo "${!TAG_MAP[@]}" | tr ' ' '\n' | sort); do
        printf -- "- **%s** — %s\n" "$tag" "${TAG_MAP[$tag]}" >> "$tags_tmp"
    done

    # 3) Python 脚本：读取临时文件，替换锚点区域
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

COMMIT_MSG="docs: Day ${DAY_NUM} - ${TITLE}"
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
