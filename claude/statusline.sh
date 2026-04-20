#!/bin/bash

################################################################################
# Claude Code 状态栏脚本
# 第1行：路径 • 分支 • 模型 · 成本 · 轮数 · Context · Token
# 第2行：Usage 进度条 + 重置时间（订阅用户专属）
################################################################################

# ==============================================================================
# 配置常量
# ==============================================================================

# 上下文配置
readonly CONTEXT_MAX_TOKENS=200000  # 200k tokens

# 颜色配置（RGB格式）- Catppuccin Mocha
readonly COLOR_RED="243;139;168"            # 警告红（Flamingo）
readonly COLOR_YELLOW="249;226;175"         # 警告黄（Yellow）
readonly COLOR_GREEN="166;227;161"          # 正常绿（Green）
readonly COLOR_BLUE="116;199;236"           # Input tokens（Sapphire）
readonly COLOR_LIGHT_GREEN="148;226;213"    # Output tokens（Teal）
readonly COLOR_PURPLE="203;166;247"         # Cache / 模型名（Mauve）
readonly COLOR_GRAY="108;112;134"           # 分隔符（Overlay1）
readonly COLOR_MEDIUM_PURPLE="180;190;254"  # 对话轮数（Lavender）
readonly COLOR_MILK="245;224;220"           # 第2行标签（Rosewater）
readonly COLOR_DIRTY="235;160;172"          # dirty 分支（Maroon）
readonly COLOR_PATH="250;179;135"           # 路径（Peach）
readonly COLOR_COST="249;226;175"           # 费用（Yellow）
readonly COLOR_DIV="88;91;112"             # 区块分隔 │（Overlay0）

# ==============================================================================
# 工具函数 - 数字格式化
# ==============================================================================

# 格式化数字为可读单位（k/M）
format_number() {
    local num="$1"

    if [ "$num" -lt 1000 ]; then
        echo "$num"
    elif [ "$num" -lt 1000000 ]; then
        # 转换为 k，保留1位小数
        local k=$((num * 10 / 1000))
        local integer=$((k / 10))
        local decimal=$((k % 10))
        [ "$decimal" -eq 0 ] && echo "${integer}k" || echo "${integer}.${decimal}k"
    else
        # 转换为 M，保留1位小数
        local m=$((num * 10 / 1000000))
        local integer=$((m / 10))
        local decimal=$((m % 10))
        [ "$decimal" -eq 0 ] && echo "${integer}M" || echo "${integer}.${decimal}M"
    fi
}

# ==============================================================================
# 工具函数 - 进度条生成
# ==============================================================================

# 生成进度条（10格宽度）
generate_progress_bar() {
    local percentage="$1" bar="" i
    local filled=$((percentage * 10 / 100))
    for ((i=0; i<filled; i++));    do bar+="█"; done
    for ((i=filled; i<10; i++)); do bar+="░"; done
    echo "$bar"
}

# ==============================================================================
# 核心功能 - 对话信息提取
# ==============================================================================

# 从转录文件获取对话轮数
get_message_count() {
    local transcript_path="$1"

    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        jq -c 'select(has("message"))' "$transcript_path" 2>/dev/null | wc -l | xargs
    else
        echo "0"
    fi
}

# 从转录文件获取 Token 使用详情
# 返回格式：context_length|input_tokens|output_tokens|cache_hit_rate
get_token_details() {
    local transcript_path="$1"

    if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
        echo "0|0|0|0"
        return
    fi

    local input_tokens output_tokens cache_read cache_creation
    read -r input_tokens output_tokens cache_read cache_creation < <(
        jq -rn '[inputs | select(.message.usage).message.usage] | (last? // {}) |
            [(.input_tokens // 0), (.output_tokens // 0),
             (.cache_read_input_tokens // 0), (.cache_creation_input_tokens // 0)] |
            @tsv' "$transcript_path" 2>/dev/null
    )
    input_tokens=${input_tokens:-0}
    output_tokens=${output_tokens:-0}
    cache_read=${cache_read:-0}
    cache_creation=${cache_creation:-0}

    local context_length=$((input_tokens + cache_read + cache_creation))
    local cache_hit_rate=0
    [ $context_length -gt 0 ] && cache_hit_rate=$((cache_read * 100 / context_length))

    echo "${context_length}|${input_tokens}|${output_tokens}|${cache_hit_rate}"
}

# ==============================================================================
# 核心功能 - 工作目录格式化
# ==============================================================================

# 格式化工作目录（保留最后两级目录）
format_working_directory() {
    local cwd="${1%/}"
    [[ -z "$cwd" || "$cwd" == "null" ]] && return

    local stripped="${cwd//\//}"
    local slash_count=$(( ${#cwd} - ${#stripped} ))

    if (( slash_count <= 2 )); then
        echo "$cwd"
    else
        local parent="${cwd%/*}"
        echo "…/${parent##*/}/${cwd##*/}"
    fi
}

# ==============================================================================
# 核心功能 - Git 分支获取
# ==============================================================================

# 获取当前 Git 分支名（含 dirty 标记）
get_git_branch() {
    local cwd="$1"

    if [ -z "$cwd" ] || [ ! -d "$cwd" ]; then
        echo ""
        return
    fi

    local branch dirty=""
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null) || return
    git -C "$cwd" status --porcelain 2>/dev/null | grep -q . && dirty="*"
    echo "${branch}${dirty}"
}

# ==============================================================================
# 格式化函数 - Token 详情
# ==============================================================================

# 格式化 Token 详情显示（输入、输出、缓存命中率）
format_token_details() {
    local input="$1"
    local output="$2"
    local cache_rate="$3"
    local result=""

    # Input tokens（蓝色，下箭头）
    if [ "$input" -gt 0 ]; then
        local formatted_input=$(format_number "$input")
        result="\033[38;2;${COLOR_BLUE}m↓${formatted_input}\033[0m"
    fi

    # Output tokens（绿色，上箭头）
    if [ "$output" -gt 0 ]; then
        [ -n "$result" ] && result="${result} "
        local formatted_output=$(format_number "$output")
        result="${result}\033[38;2;${COLOR_LIGHT_GREEN}m↑${formatted_output}\033[0m"
    fi

    # Cache hit rate（紫色，闪电图标）
    if [ "$cache_rate" -gt 0 ]; then
        [ -n "$result" ] && result="${result} "
        result="${result}\033[38;2;${COLOR_PURPLE}m⚡${cache_rate}%\033[0m"
    fi

    echo "$result"
}

# ==============================================================================
# 格式化函数 - 上下文显示
# ==============================================================================

# 格式化上下文使用情况（百分比 + 进度条 + 颜色预警）
format_context_display() {
    local percentage="$1"
    local exceeds="$2"
    local capacity_label="$3"

    local color="$COLOR_GREEN"
    [ "$percentage" -ge 60 ] && color="$COLOR_YELLOW"
    [ "$percentage" -ge 75 ] && color="$COLOR_RED"
    [ "$exceeds" = "true" ] && color="$COLOR_RED"

    local progress_bar=$(generate_progress_bar "$percentage")
    local suffix="${percentage}%"
    [ -n "$capacity_label" ] && suffix="${suffix}/${capacity_label}"
    echo $'\033[38;2;'"${color}"'m'"Ctx ${progress_bar} ${suffix}"$'\033[0m'
}

# ==============================================================================
# 格式化函数 - 对话轮数
# ==============================================================================

# 格式化对话轮数显示
format_message_count() {
    local count="$1"
    [ "$count" -gt 0 ] && echo "\033[38;2;${COLOR_MEDIUM_PURPLE}m#${count}\033[0m" || echo ""
}

# ==============================================================================
# 格式化函数 - 渐变色生成
# ==============================================================================

# 模型名称着色（Mauve 实色）
format_model_name() {
    echo "\033[38;2;${COLOR_PURPLE}m${1}\033[0m"
}

# ==============================================================================
# 主程序入口
# ==============================================================================

# 读取 JSON 输入
input=$(cat)

command -v jq &>/dev/null || { echo "缺少 jq" >&2; exit 1; }

# --- 一次性提取所有 stdin 字段 ---
eval "$(echo "$input" | jq -r '@sh "
    model_name=\(.model.display_name // "Sonnet 4")
    model_id=\(.model.id // "")
    total_cost=\(.cost.total_cost_usd // "0.00")
    transcript_path=\(.transcript_path // "")
    exceeds_200k=\(.exceeds_200k_tokens // "false")
    cwd=\(.cwd // "")
    context_native_pct=\(.context_window.used_percentage // "")
    context_window_size=\(.context_window.context_window_size // "")
    five_hour_pct=\(.rate_limits.five_hour.used_percentage // "")
    seven_day_pct=\(.rate_limits.seven_day.used_percentage // "")
    five_hour_reset=\(.rate_limits.five_hour.resets_at // "")"' 2>/dev/null)"

# --- 1M 上下文标注 ---
model_name_display="$model_name"
if [[ "$model_id" == *"1m"* ]] || [[ "$model_id" == *"-1m-"* ]]; then
    model_name_display="${model_name} (1M)"
fi

# --- 对话统计 ---
message_count=$(get_message_count "$transcript_path")
IFS='|' read -r context_tokens input_tokens output_tokens cache_hit_rate \
    <<< "$(get_token_details "$transcript_path")"

# --- 工作目录 + Git ---
formatted_cwd=$(format_working_directory "$cwd")
git_branch=$(get_git_branch "$cwd")

# --- 上下文使用率（优先 stdin 原生百分比，v2.1.6+）---
context_percentage=0
if [ -n "$context_native_pct" ]; then
    context_percentage=$(printf "%.0f" "$context_native_pct" 2>/dev/null || echo 0)
    [ "$context_percentage" -gt 100 ] && context_percentage=100
elif [ "${context_tokens:-0}" -gt 0 ]; then
    effective_max=${context_window_size:-$CONTEXT_MAX_TOKENS}
    context_percentage=$((context_tokens * 100 / effective_max))
    [ "$context_percentage" -gt 100 ] && context_percentage=100
fi

# --- 格式化显示元素 ---
formatted_cost=$(printf "%.2f" "$total_cost")

model_display=$(format_model_name "$model_name_display")
token_info=$(format_token_details "$input_tokens" "$output_tokens" "$cache_hit_rate")
message_count_display=$(format_message_count "$message_count")

# ==============================================================================
# 输出状态栏（两行）
# 第1行：路径 • Git分支 • 模型 · 成本 · 轮数 · Token详情
# 第2行：Context █████░░░░░ 45% │ Usage ██░░░░░░░░ 25% (1h 30m / 5h)  [奶白色]
# ==============================================================================

sep="\033[38;2;${COLOR_GRAY}m · \033[0m"
div="\033[38;2;${COLOR_DIV}m  │  \033[0m"
milk="\033[38;2;${COLOR_MILK}m"

# --- 第1行：[path ⎇ branch]  │  [model (#32) · cost]  │  [Ctx █ · tokens] ---

# 区块1：位置
block1=""
if [ -n "$formatted_cwd" ]; then
    block1="\033[38;2;${COLOR_PATH}m${formatted_cwd}\033[0m"
fi
if [ -n "$git_branch" ]; then
    [ -n "$block1" ] && block1="${block1}\033[38;2;${COLOR_GRAY}m · \033[0m"
    if [[ "$git_branch" == *"*" ]]; then
        branch_name="${git_branch%\*}"
        block1="${block1}\033[38;2;${COLOR_DIRTY}m⎇ ${branch_name} *\033[0m"
    else
        block1="${block1}\033[38;2;${COLOR_GREEN}m⎇ ${git_branch}\033[0m"
    fi
fi

# 区块2：模型 + 轮次 + 费用
cost_display="\033[38;2;${COLOR_COST}m\$${formatted_cost}\033[0m"
if [ "$message_count" -gt 0 ]; then
    count_part="\033[38;2;${COLOR_MEDIUM_PURPLE}m#${message_count}\033[0m"
    block2="${model_display} ${count_part}${sep}${cost_display}"
else
    block2="${model_display}${sep}${cost_display}"
fi

# 区块3：上下文 + token 详情
effective_max=${context_window_size:-$CONTEXT_MAX_TOKENS}
capacity_label=$(format_number "$effective_max")
context_display=$(format_context_display "$context_percentage" "$exceeds_200k" "$capacity_label")
block3="${context_display}"
[ -n "$token_info" ] && block3="${block3}${sep}${token_info}"

# 拼接三块
if [ -n "$block1" ]; then
    line1="${block1}${div}${block2}${div}${block3}"
else
    line1="${block2}${div}${block3}"
fi

printf "%b\n" "$line1"

# --- 第2行：Usage ███░░░░░░░ 38% (1h 29m / 5h) 7d:████████░░ 82%（订阅用户专属）---
if [ -n "$five_hour_pct" ]; then
    five_int=$(printf "%.0f" "$five_hour_pct" 2>/dev/null)
    if [ -n "$five_int" ]; then
        usage_color="\033[38;2;${COLOR_GREEN}m"
        [ "$five_int" -ge 70 ] && usage_color="\033[38;2;${COLOR_YELLOW}m"
        [ "$five_int" -ge 90 ] && usage_color="\033[38;2;${COLOR_RED}m"

        usage_bar=$(generate_progress_bar "$five_int")
        line2="${milk}Usage  \033[0m${usage_color}${usage_bar}  ${five_int}%\033[0m"

        # 重置剩余时间
        if [ -n "$five_hour_reset" ] && [ "$five_hour_reset" -gt 0 ] 2>/dev/null; then
            now=$(date +%s)
            remaining_secs=$((five_hour_reset - now))
            if [ "$remaining_secs" -gt 0 ]; then
                remaining_mins=$((remaining_secs / 60))
                if [ "$remaining_mins" -ge 60 ]; then
                    h=$((remaining_mins / 60)); m=$((remaining_mins % 60))
                    reset_label="${h}h ${m}m"
                else
                    reset_label="${remaining_mins}m"
                fi
                line2="${line2}  \033[38;2;${COLOR_GRAY}m(${reset_label} / 5h)\033[0m"
            fi
        fi

        # 7天（>= 80% 才显示）
        if [ -n "$seven_day_pct" ]; then
            seven_int=$(printf "%.0f" "$seven_day_pct" 2>/dev/null)
            if [ -n "$seven_int" ] && [ "$seven_int" -ge 80 ]; then
                seven_color="\033[38;2;${COLOR_YELLOW}m"
                [ "$seven_int" -ge 90 ] && seven_color="\033[38;2;${COLOR_RED}m"
                seven_bar=$(generate_progress_bar "$seven_int")
                line2="${line2}  ${milk}7d:  \033[0m${seven_color}${seven_bar}  ${seven_int}%\033[0m"
            fi
        fi

        printf "%b\n" "$line2"
    fi
fi