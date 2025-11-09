#!/bin/bash

################################################################################
# Claude Code 状态栏脚本
# 功能：显示模型信息、成本、上下文使用量、Token统计、IP信息、会话时长、Git分支等
#
# 主要功能：
# - 模型名称和成本统计
# - 对话轮数和上下文使用率（带进度条）
# - Token 详情（输入/输出/缓存命中率）
# - IP 地理位置信息（带缓存）
# - 会话时长统计
# - Git 分支信息
################################################################################

# ==============================================================================
# 配置常量
# ==============================================================================

# IP 缓存配置（避免频繁网络请求）
readonly IP_CACHE_FILE="/tmp/.claude_ip_cache"
readonly IP_CACHE_DURATION=300  # 5分钟缓存

# 上下文配置
readonly CONTEXT_MAX_TOKENS=200000  # 200k tokens

# 颜色配置（RGB格式）
readonly COLOR_RED="248;18;81"              # 警告红色
readonly COLOR_YELLOW="252;228;43"          # 警告黄色
readonly COLOR_GREEN="165;254;0"            # 正常绿色
readonly COLOR_BLUE="100;149;237"           # Input tokens
readonly COLOR_LIGHT_GREEN="144;238;144"    # Output tokens
readonly COLOR_PURPLE="186;85;211"          # Cache hit rate
readonly COLOR_SKY_BLUE="120;220;255"       # 用户名（明亮的青蓝色）
readonly COLOR_GRAY="128;128;128"           # 分隔符
readonly COLOR_MEDIUM_PURPLE="147;112;219"  # 对话轮数

# ==============================================================================
# 工具函数 - 系统检查
# ==============================================================================

# 检查系统必需依赖
check_system_dependencies() {
    local missing_deps=()

    command -v jq &> /dev/null || missing_deps+=("jq")
    command -v curl &> /dev/null || missing_deps+=("curl")

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "缺少必要工具：${missing_deps[*]}" >&2
        echo "请安装这些工具后重新运行脚本" >&2
        return 1
    fi

    return 0
}

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
    local percentage="$1"
    local bar_length=10
    local filled=$((percentage * bar_length / 100))
    local empty=$((bar_length - filled))

    local bar=""
    [ $filled -gt 0 ] && bar=$(printf '█%.0s' $(seq 1 $filled))
    [ $empty -gt 0 ] && bar="${bar}$(printf '░%.0s' $(seq 1 $empty))"

    echo "$bar"
}

# ==============================================================================
# 核心功能 - 对话信息提取
# ==============================================================================

# 从转录文件获取对话轮数
get_message_count() {
    local transcript_path="$1"

    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        grep -c '"message"' "$transcript_path" 2>/dev/null || echo "0"
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

    # 读取最后几行，寻找最新的 usage 信息
    local last_usage=$(tail -20 "$transcript_path" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            local usage=$(echo "$line" | jq -c '.message.usage // empty' 2>/dev/null)
            [ -n "$usage" ] && echo "$usage"
        fi
    done | tail -1)

    if [ -z "$last_usage" ]; then
        echo "0|0|0|0"
        return
    fi

    # 一次性提取所有 token 字段
    eval "$(echo "$last_usage" | jq -r '@sh "
        input_tokens=\(.input_tokens // 0)
        output_tokens=\(.output_tokens // 0)
        cache_read=\(.cache_read_input_tokens // 0)
        cache_creation=\(.cache_creation_input_tokens // 0)"' \
        2>/dev/null || echo 'input_tokens=0; output_tokens=0; cache_read=0; cache_creation=0')"

    # 计算总上下文长度和缓存命中率
    local context_length=$((input_tokens + cache_read + cache_creation))
    local total_input=$((input_tokens + cache_read + cache_creation))
    local cache_hit_rate=0

    [ $total_input -gt 0 ] && cache_hit_rate=$((cache_read * 100 / total_input))

    echo "${context_length}|${input_tokens}|${output_tokens}|${cache_hit_rate}"
}

# ==============================================================================
# 核心功能 - IP 信息获取（带缓存）
# ==============================================================================

# 获取 IP 和地区信息
get_ip_info() {
    # 检查缓存是否有效
    if [ -f "$IP_CACHE_FILE" ]; then
        local cache_age=$(($(date +%s) - $(stat -f%m "$IP_CACHE_FILE" 2>/dev/null || echo 0)))
        if [ $cache_age -lt $IP_CACHE_DURATION ]; then
            cat "$IP_CACHE_FILE"
            return
        fi
    fi

    # 请求 IP 信息（使用 curl 内置超时）
    local ip_json=$(curl -s --max-time 3 --connect-timeout 2 https://ipinfo.io/json 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$ip_json" ]; then
        return
    fi

    # 提取 IP 相关字段
    local ip=$(echo "$ip_json" | jq -r '.ip // ""' 2>/dev/null)
    local city=$(echo "$ip_json" | jq -r '.city // ""' 2>/dev/null)
    local region=$(echo "$ip_json" | jq -r '.region // ""' 2>/dev/null)
    local country=$(echo "$ip_json" | jq -r '.country // ""' 2>/dev/null)

    if [ -z "$ip" ]; then
        return
    fi

    # IP 脱敏：隐藏最后一段
    local masked_ip=$(echo "$ip" | sed -E 's/\.[0-9]+$/.***/g')

    # 选择最具体的地理位置信息
    local location=""
    [ -n "$city" ] && location="$city"
    [ -z "$location" ] && [ -n "$region" ] && location="$region"
    [ -z "$location" ] && [ -n "$country" ] && location="$country"

    # 组装结果
    local result="$masked_ip"
    [ -n "$location" ] && result="$masked_ip - $location"

    # 保存到缓存
    echo "$result" > "$IP_CACHE_FILE"
    echo "$result"
}

# ==============================================================================
# 核心功能 - 工作目录格式化
# ==============================================================================

# 格式化工作目录（保留最后两级目录）
format_working_directory() {
    local cwd="$1"

    if [ -z "$cwd" ] || [ "$cwd" = "null" ]; then
        echo ""
        return
    fi

    # 去除末尾斜杠
    cwd="${cwd%/}"

    # 统计目录层级数
    local dir_count=$(echo "$cwd" | grep -o "/" | wc -l | tr -d ' ')

    # 如果层级小于等于2，直接返回
    if [ "$dir_count" -le 2 ]; then
        echo "$cwd"
        return
    fi

    # 提取最后两级目录
    local last_two=$(echo "$cwd" | awk -F'/' '{print $(NF-1)"/"$NF}')
    echo "<</${last_two}"
}

# ==============================================================================
# 核心功能 - Git 分支获取
# ==============================================================================

# 获取当前 Git 分支名
get_git_branch() {
    local cwd="$1"

    if [ -z "$cwd" ] || [ ! -d "$cwd" ]; then
        echo ""
        return
    fi

    # 切换到工作目录并获取分支名
    (cd "$cwd" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null) || echo ""
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
        result="${result}\033[38;2;${COLOR_PURPLE}mCache ⚡${cache_rate}%\033[0m"
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

    # 根据使用率选择颜色
    local color="$COLOR_GREEN"
    [ "$percentage" -ge 50 ] && color="$COLOR_YELLOW"
    [ "$percentage" -ge 90 ] && color="$COLOR_RED"
    [ "$exceeds" = "true" ] && color="$COLOR_RED"

    local progress_bar=$(generate_progress_bar "$percentage")
    echo $'\033[38;2;'"${color}"'m'"Ctx ${percentage}% ${progress_bar}"$'\033[0m'
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

# 为模型名称生成橙-黄渐变色
generate_model_gradient() {
    local text="$1"
    local gradient=""
    local colors=(
        "255;165;0" "255;175;0" "255;185;0" "255;195;0" "255;205;0"
        "255;215;0" "255;225;0" "255;235;0" "255;245;0" "255;255;0"
        "255;255;0" "255;255;0" "255;255;0" "255;255;0" "255;255;0"
        "255;255;0" "255;255;0" "255;255;0" "255;255;0" "255;255;0"
    )

    for i in $(seq 0 $((${#text} - 1))); do
        local char="${text:$i:1}"
        local color_index=$((i % ${#colors[@]}))
        local color="${colors[$color_index]}"
        gradient="${gradient}\033[38;2;${color}m${char}"
    done

    echo "${gradient}\033[0m"
}

# 为 IP 信息生成青蓝-薄荷绿渐变色（与用户名色调协调）
generate_ip_gradient() {
    local text="$1"
    local gradient=""
    local length=${#text}

    for i in $(seq 0 $((length - 1))); do
        local char="${text:$i:1}"
        local progress=$((i * 100 / length))
        # 从青蓝 (120,220,255) 渐变到薄荷绿 (120,255,220)
        local r=120
        local g=$((220 + (255 - 220) * progress / 100))
        local b=$((255 - (255 - 220) * progress / 100))
        gradient="${gradient}\033[38;2;${r};${g};${b}m${char}"
    done

    echo "${gradient}\033[0m"
}

# ==============================================================================
# 主程序入口
# ==============================================================================

# 读取 JSON 输入
input=$(cat)

# 检查系统依赖（警告但不阻止运行）
check_system_dependencies 2>/dev/null || echo "警告：某些功能可能无法正常工作" >&2

# --- 提取模型信息 ---
model_name=$(echo "$input" | jq -r '.model.display_name' 2>/dev/null || echo "")
model_id=$(echo "$input" | jq -r '.model.id' 2>/dev/null || echo "")
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd' 2>/dev/null || echo "0.00")
transcript_path=$(echo "$input" | jq -r '.transcript_path' 2>/dev/null || echo "")
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens' 2>/dev/null || echo "false")

# 设置默认值
[ -z "$model_name" ] || [ "$model_name" = "null" ] && model_name="Sonnet 4"
[ -z "$total_cost" ] || [ "$total_cost" = "null" ] && total_cost="0.00"

# --- 判断模型上下文容量 ---
has_1m_context=false
if [[ "$model_name" == *"[1m]"* ]] || [[ "$model_name" == *"1m"* ]] || \
   [[ "$model_id" == *"1m"* ]] || [[ "$model_id" == *"-1m-"* ]]; then
    has_1m_context=true
fi

# 构建模型名称（包含上下文标注）
model_name_display="$model_name"
if [ "$has_1m_context" = true ] && [[ "$model_name" != *"(with 1M token context)"* ]]; then
    model_name_display="${model_name} (with 1M token context)"
fi

# --- 提取对话统计信息 ---
message_count=$(get_message_count "$transcript_path")
token_details=$(get_token_details "$transcript_path")

# 解析 Token 详情
context_tokens=$(echo "$token_details" | cut -d'|' -f1)
input_tokens=$(echo "$token_details" | cut -d'|' -f2)
output_tokens=$(echo "$token_details" | cut -d'|' -f3)
cache_hit_rate=$(echo "$token_details" | cut -d'|' -f4)

# --- 提取工作目录 ---
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)

# --- 格式化工作目录 ---
formatted_cwd=$(format_working_directory "$cwd")

# --- 提取 Git 分支信息 ---
git_branch=$(get_git_branch "$cwd")

# --- 计算上下文使用率 ---
context_percentage=0
if [ "$context_tokens" -gt 0 ]; then
    context_percentage=$((context_tokens * 100 / CONTEXT_MAX_TOKENS))
    [ "$context_percentage" -gt 100 ] && context_percentage=100
fi

# --- 获取 IP 信息 ---
ip_info=$(get_ip_info)

# --- 格式化显示元素 ---
formatted_cost=$(printf "%.2f" "$total_cost")
cost_display="\033[38;2;255;165;0m\$${formatted_cost}\033[0m"

model_gradient=$(generate_model_gradient "$model_name_display")
token_info=$(format_token_details "$input_tokens" "$output_tokens" "$cache_hit_rate")
context_display=$(format_context_display "$context_percentage" "$exceeds_200k")
message_count_display=$(format_message_count "$message_count")

# 用户名 + IP 信息
name="yikwing"
if [ -n "$ip_info" ]; then
    ip_gradient=$(generate_ip_gradient "$ip_info")
    name_display="\033[1;38;2;${COLOR_SKY_BLUE}m${name}\033[0m \033[38;2;${COLOR_GRAY}m(\033[0m${ip_gradient}\033[38;2;${COLOR_GRAY}m)\033[0m"
else
    name_display="\033[1;38;2;${COLOR_SKY_BLUE}m${name}\033[0m"
fi

# ==============================================================================
# 输出状态栏
# 格式：用户名 (IP) • 工作目录 • 🌿分支 • ✨ 模型名 · $成本 · #轮数 · 上下文% · Token详情
# ==============================================================================

separator="\033[38;2;${COLOR_GRAY}m·\033[0m"
bullet="\033[38;2;${COLOR_GRAY}m•\033[0m"

# 构建输出（根据可用信息动态组合）
output_parts=("$name_display" "$bullet")

# 添加工作目录（如果有）
if [ -n "$formatted_cwd" ]; then
    output_parts+=("📁 \033[38;2;${COLOR_YELLOW}m${formatted_cwd}\033[0m" "$bullet")
fi

# 添加 Git 分支（如果有）
if [ -n "$git_branch" ]; then
    output_parts+=("🌿 \033[38;2;${COLOR_GREEN}m${git_branch}\033[0m" "$bullet")
fi

# 添加模型和成本
output_parts+=("✨ $model_gradient" "$separator" "$cost_display")

# 添加对话轮数（如果有）
[ -n "$message_count_display" ] && output_parts+=("$separator" "$message_count_display")

# 添加上下文显示
output_parts+=("$separator" "$context_display")

# 添加 Token 详情（如果有）
[ -n "$token_info" ] && output_parts+=("$separator" "$token_info")

# 输出最终结果
printf "%b\n" "${output_parts[*]}"