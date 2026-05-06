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
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "${#num}" -gt 12 ]; then
        num=0
    fi

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
    local percentage="$1"
    [[ "$percentage" =~ ^[0-9]+$ ]] || percentage=0
    [ "${#percentage}" -gt 3 ] && percentage=100
    [ "$percentage" -lt 0 ] && percentage=0
    [ "$percentage" -gt 100 ] && percentage=100

    local filled=$((percentage * 10 / 100))
    local tmpl="██████████░░░░░░░░░░"
    echo "${tmpl:$((10 - filled)):10}"
}

# 判断是否为非负整数
is_uint() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# 正整数兜底
positive_int_or_default() {
    local value="$1"
    local default="$2"
    if is_uint "$value" && [ "${#value}" -le 9 ] && [ "$value" -gt 0 ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# 百分比四舍五入并限制到 0-100
clamp_percentage() {
    local value="$1"
    local rounded

    if ! [[ "$value" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
        echo 0
        return
    fi

    local integer_part="${value%%.*}"
    local integer_digits="${integer_part#-}"
    if [ "${#integer_digits}" -gt 3 ]; then
        [[ "$integer_part" == -* ]] && echo 0 || echo 100
        return
    fi

    rounded=$(LC_ALL=C printf "%.0f" "$value" 2>/dev/null) || rounded=0
    [[ "$rounded" =~ ^-?[0-9]+$ ]] || rounded=0
    if [ "${#rounded}" -gt 3 ]; then
        [[ "$rounded" == -* ]] && rounded=0 || rounded=100
    fi

    [ "$rounded" -lt 0 ] && rounded=0
    [ "$rounded" -gt 100 ] && rounded=100
    echo "$rounded"
}

# 费用格式化兜底
format_cost() {
    local value="$1"
    local formatted

    formatted=$(LC_ALL=C printf "%.2f" "$value" 2>/dev/null) || formatted="0.00"
    echo "$formatted"
}

# 将 reset 时间格式化为剩余时间；异常或过远时间不显示
format_reset_time() {
    local reset_epoch="$1"
    is_uint "$reset_epoch" || return
    [ "${#reset_epoch}" -gt 13 ] && return

    # 兼容毫秒时间戳
    if [ "$reset_epoch" -gt 9999999999 ]; then
        reset_epoch=$((reset_epoch / 1000))
    fi

    local now remaining_secs remaining_mins h m
    now=$(date +%s)
    remaining_secs=$((reset_epoch - now))

    # five-hour 窗口的 reset 不应离当前时间特别远；过远通常是坏输入
    if [ "$remaining_secs" -le 0 ] || [ "$remaining_secs" -gt 604800 ]; then
        return
    fi

    remaining_mins=$((remaining_secs / 60))
    if [ "$remaining_mins" -ge 60 ]; then
        h=$((remaining_mins / 60))
        m=$((remaining_mins % 60))
        echo "${h}h ${m}m"
    else
        echo "${remaining_mins}m"
    fi
}

# ==============================================================================
# 核心功能 - 对话信息提取
# ==============================================================================

# 从转录文件一次性获取对话轮数和 Token 使用详情
# 返回格式：message_count|context_length|input_tokens|output_tokens|cache_hit_rate
get_transcript_stats() {
    local transcript_path="$1"

    if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
        echo "0|0|0|0|0"
        return
    fi

    local cnt input_tokens output_tokens cache_read cache_creation tsv_raw
    tsv_raw=$(jq -rn '
            reduce inputs as $item (
                {cnt: 0, usage: {}};
                (if ($item | has("message")) then .cnt += 1 else . end) |
                (if ($item.message.usage? != null) then .usage = $item.message.usage else . end)
            ) |
            [.cnt,
             (.usage.input_tokens // 0), (.usage.output_tokens // 0),
             (.usage.cache_read_input_tokens // 0), (.usage.cache_creation_input_tokens // 0)] |
            @tsv' "$transcript_path" 2>/dev/null)
    # Use explicit IFS=$'\t' to avoid caller IFS='|' pollution on tab-separated jq output
    IFS=$'\t' read -r cnt input_tokens output_tokens cache_read cache_creation <<< "$tsv_raw"
    cnt=${cnt:-0}
    input_tokens=${input_tokens:-0}
    output_tokens=${output_tokens:-0}
    cache_read=${cache_read:-0}
    cache_creation=${cache_creation:-0}

    is_uint "$cnt" || cnt=0
    is_uint "$input_tokens" || input_tokens=0
    is_uint "$output_tokens" || output_tokens=0
    is_uint "$cache_read" || cache_read=0
    is_uint "$cache_creation" || cache_creation=0

    local context_length=$((input_tokens + cache_read + cache_creation))
    local cache_hit_rate=0
    [ "$context_length" -gt 0 ] && cache_hit_rate=$((cache_read * 100 / context_length))

    echo "${cnt}|${context_length}|${input_tokens}|${output_tokens}|${cache_hit_rate}"
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

# 获取 Git 信息：分支、dirty、ahead/behind、stash
# 返回格式：branch<US>dirty<US>ahead<US>behind<US>stash
get_git_info() {
    local cwd="$1"
    local sep=$'\037'

    if [ -z "$cwd" ] || [ ! -d "$cwd" ]; then
        printf "%s%s0%s0%s0\n" "$sep" "$sep" "$sep" "$sep"
        return
    fi

    command -v git &>/dev/null || {
        printf "%s%s0%s0%s0\n" "$sep" "$sep" "$sep" "$sep"
        return
    }

    git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        printf "%s%s0%s0%s0\n" "$sep" "$sep" "$sep" "$sep"
        return
    }

    local branch dirty="" ahead=0 behind=0 stash=0
    local ab_raw status_raw

    branch=$(git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null)
    [ -n "$branch" ] || branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

    status_raw=$(git -C "$cwd" status --porcelain 2>/dev/null)
    [ -n "$status_raw" ] && dirty="*"

    ab_raw=$(git -C "$cwd" rev-list --left-right --count HEAD...@{u} 2>/dev/null)
    IFS=$'\t' read -r ahead behind <<< "$ab_raw"
    is_uint "$ahead" || ahead=0
    is_uint "$behind" || behind=0

    if git -C "$cwd" rev-parse --verify refs/stash >/dev/null 2>&1; then
        stash=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')
        is_uint "$stash" || stash=0
    fi

    printf "%s%s%s%s%s%s%s%s%s\n" "$branch" "$sep" "$dirty" "$sep" "$ahead" "$sep" "$behind" "$sep" "$stash"
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
    local exceeds_capacity="$2"
    local capacity_label="$3"

    percentage=$(clamp_percentage "$percentage")

    local color="$COLOR_GREEN"
    [ "$percentage" -ge 60 ] && color="$COLOR_YELLOW"
    [ "$percentage" -ge 75 ] && color="$COLOR_RED"
    [ "$exceeds_capacity" = "true" ] && color="$COLOR_RED"

    local progress_bar=$(generate_progress_bar "$percentage")
    local suffix="${percentage}%"
    [ -n "$capacity_label" ] && suffix="${suffix}/${capacity_label}"
    echo $'\033[38;2;'"${color}"'m'"Ctx ${progress_bar} ${suffix}"$'\033[0m'
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
model_name="Sonnet 4"
model_id=""
total_cost="0.00"
transcript_path=""
exceeds_200k="false"
cwd=""
context_native_pct=""
context_window_size=""
five_hour_pct=""
seven_day_pct=""
five_hour_reset=""
effort_level=""
thinking_enabled="false"

parsed_input=$(printf "%s" "$input" | jq -r '
    [
        (.model.display_name // "Sonnet 4"),
        (.model.id // ""),
        (.cost.total_cost_usd // "0.00"),
        (.transcript_path // ""),
        (.exceeds_200k_tokens // false),
        (.cwd // ""),
        (.context_window.used_percentage // ""),
        (.context_window.context_window_size // ""),
        (.rate_limits.five_hour.used_percentage // ""),
        (.rate_limits.seven_day.used_percentage // ""),
        (.rate_limits.five_hour.resets_at // ""),
        (.effort.level // ""),
        (.thinking.enabled // false)
    ] | map(tostring) | join("\u001f")' 2>/dev/null)

if [ -n "$parsed_input" ]; then
    IFS=$'\037' read -r model_name model_id total_cost transcript_path exceeds_200k cwd \
        context_native_pct context_window_size five_hour_pct seven_day_pct \
        five_hour_reset effort_level thinking_enabled <<< "$parsed_input"
fi

# --- 1M 上下文标注 ---
model_name_display="$model_name"
if [[ "$model_id" == *"1m"* ]] || [[ "$model_id" == *"-1m-"* ]]; then
    model_name_display="${model_name} (1M)"
fi

# --- 对话统计 ---
IFS='|' read -r message_count context_tokens input_tokens output_tokens cache_hit_rate \
    <<< "$(get_transcript_stats "$transcript_path")"
is_uint "$message_count" || message_count=0
is_uint "$context_tokens" || context_tokens=0
is_uint "$input_tokens" || input_tokens=0
is_uint "$output_tokens" || output_tokens=0
is_uint "$cache_hit_rate" || cache_hit_rate=0

# --- 工作目录 + Git ---
formatted_cwd=$(format_working_directory "$cwd")
IFS=$'\037' read -r git_branch git_dirty git_ahead git_behind git_stash <<< "$(get_git_info "$cwd")"

# --- 上下文使用率（优先 stdin 原生百分比，v2.1.6+）---
context_percentage=0
if [ -n "$context_native_pct" ]; then
    context_percentage=$(clamp_percentage "$context_native_pct")
elif [ "${context_tokens:-0}" -gt 0 ]; then
    effective_max=$(positive_int_or_default "$context_window_size" "$CONTEXT_MAX_TOKENS")
    context_percentage=$((context_tokens * 100 / effective_max))
    [ "$context_percentage" -gt 100 ] && context_percentage=100
fi

# --- 格式化显示元素 ---
formatted_cost=$(format_cost "$total_cost")

model_display=$(format_model_name "$model_name_display")
token_info=$(format_token_details "$input_tokens" "$output_tokens" "$cache_hit_rate")

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
    if [ -n "$git_dirty" ]; then
        branch_name="$git_branch"
        block1="${block1}\033[38;2;${COLOR_DIRTY}m⎇ ${branch_name} *\033[0m"
    else
        block1="${block1}\033[38;2;${COLOR_GREEN}m⎇ ${git_branch}\033[0m"
    fi
    # ahead / behind
    [ "${git_ahead:-0}" -gt 0 ] && block1="${block1} \033[38;2;${COLOR_BLUE}m↑${git_ahead}\033[0m"
    [ "${git_behind:-0}" -gt 0 ] && block1="${block1} \033[38;2;${COLOR_YELLOW}m↓${git_behind}\033[0m"
    # stash
    [ "${git_stash:-0}" -gt 0 ] && block1="${block1} \033[38;2;${COLOR_GRAY}m≡${git_stash}\033[0m"
fi

# 区块2：模型 + 轮次 + 费用
cost_display="\033[38;2;${COLOR_COST}m\$${formatted_cost}\033[0m"

# thinking / effort 标签
model_tags=""
if [ "$thinking_enabled" = "true" ]; then
    model_tags=" \033[38;2;${COLOR_LIGHT_GREEN}m[T]\033[0m"
else
    model_tags=" \033[38;2;${COLOR_GRAY}m[N]\033[0m"
fi
case "$effort_level" in
    low)    model_tags="${model_tags} \033[38;2;${COLOR_GRAY}m[low]\033[0m" ;;
    high)   model_tags="${model_tags} \033[38;2;${COLOR_YELLOW}m[high]\033[0m" ;;
    xhigh)  model_tags="${model_tags} \033[38;2;${COLOR_PATH}m[xhigh]\033[0m" ;;
    max)    model_tags="${model_tags} \033[38;2;${COLOR_RED}m[max]\033[0m" ;;
esac

if [ "$message_count" -gt 0 ]; then
    count_part="\033[38;2;${COLOR_MEDIUM_PURPLE}m#${message_count}\033[0m"
    block2="${model_display}${model_tags}${sep}${count_part}${sep}${cost_display}"
else
    block2="${model_display}${model_tags}${sep}${cost_display}"
fi

# 区块3：上下文 + token 详情
effective_max=$(positive_int_or_default "$context_window_size" "$CONTEXT_MAX_TOKENS")
capacity_label=$(format_number "$effective_max")
context_exceeds_capacity="false"
if [ "$context_percentage" -ge 100 ]; then
    context_exceeds_capacity="true"
elif [ "$exceeds_200k" = "true" ] && [ "$effective_max" -le "$CONTEXT_MAX_TOKENS" ]; then
    context_exceeds_capacity="true"
fi
block3=$(format_context_display "$context_percentage" "$context_exceeds_capacity" "$capacity_label")
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
    five_int=$(clamp_percentage "$five_hour_pct")
    if [ -n "$five_int" ]; then
        usage_color="\033[38;2;${COLOR_GREEN}m"
        [ "$five_int" -ge 70 ] && usage_color="\033[38;2;${COLOR_YELLOW}m"
        [ "$five_int" -ge 90 ] && usage_color="\033[38;2;${COLOR_RED}m"

        usage_bar=$(generate_progress_bar "$five_int")
        line2="${milk}Usage  \033[0m${usage_color}${usage_bar}  ${five_int}%\033[0m"

        # 重置剩余时间
        reset_label=$(format_reset_time "$five_hour_reset")
        if [ -n "$reset_label" ]; then
            line2="${line2}  \033[38;2;${COLOR_GRAY}m(${reset_label} / 5h)\033[0m"
        fi

        # 7天（>= 80% 才显示）
        if [ -n "$seven_day_pct" ]; then
            seven_int=$(clamp_percentage "$seven_day_pct")
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
