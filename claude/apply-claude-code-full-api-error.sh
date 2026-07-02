#!/bin/bash
# Patch cli.js to show full API error messages instead of generic "API error"
# Usage: ./apply-claude-code-full-api-error.sh [--check|--restore] [cli.js path]

set -e

BACKUP_SUFFIX="backup-full-api-error"

# Catppuccin Mocha colors
RST='\033[0m'
BOLD='\033[1m'

RED='\033[38;2;243;139;168m'
GREEN='\033[38;2;166;227;161m'
BLUE='\033[38;2;137;180;250m'
PEACH='\033[38;2;250;179;135m'
TEAL='\033[38;2;148;226;213m'
SURFACE1='\033[38;2;69;71;90m'
OVERLAY='\033[38;2;108;112;134m'
SUBTEXT='\033[38;2;166;173;200m'
TEXT='\033[38;2;205;214;244m'

success() { echo -e "${GREEN}${BOLD}[✔] $1${RST}"; }
error()   { echo -e "${RED}${BOLD}[✘] $1${RST}"; }
info()    { echo -e "${BLUE}${BOLD}[ℹ] $1${RST}"; }
warn()    { echo -e "${PEACH}${BOLD}[⚠] $1${RST}"; }

log_path()    { echo -e "${SURFACE1}  [>]${RST} ${SUBTEXT}path${RST}    ${TEXT}${BOLD}$1${RST}"; }
log_version() { echo -e "${SURFACE1}  [#]${RST} ${SUBTEXT}version${RST} ${TEAL}${BOLD}$1${RST}"; }
log_before()  { echo -e "${SURFACE1}  [-]${RST} ${SUBTEXT}before${RST}  ${OVERLAY}$1${RST}"; }
log_after()   { echo -e "${SURFACE1}  [+]${RST} ${SUBTEXT}after${RST}   ${GREEN}${BOLD}$1${RST}"; }

# Argument parsing
CHECK_ONLY=false
RESTORE=false
CLI_PATH_ARG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --check|-c) CHECK_ONLY=true; shift ;;
        --restore|-r) RESTORE=true; shift ;;
        --help|-h)
            echo "Usage: $0 [--check|-c] [--restore|-r] [cli.js path]"
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            exit 1
            ;;
        *)
            if [[ -z "$CLI_PATH_ARG" ]]; then
                CLI_PATH_ARG="$1"
            else
                error "Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

find_cli_path() {
    local locations=(
        "$HOME/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js"
        "$HOME/.claude/local/node_modules/@cometix/claude-code/cli.js"
        "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js"
        "/usr/local/lib/node_modules/@cometix/claude-code/cli.js"
        "/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js"
        "/opt/homebrew/lib/node_modules/@cometix/claude-code/cli.js"
    )
    if command -v npm &> /dev/null; then
        local npm_root=$(npm root -g 2>/dev/null || true)
        [[ -n "$npm_root" ]] && locations+=("$npm_root/@anthropic-ai/claude-code/cli.js" "$npm_root/@cometix/claude-code/cli.js")
    fi
    for path in "${locations[@]}"; do
        [[ -f "$path" ]] && echo "$path" && return 0
    done
    return 1
}

if [[ -n "$CLI_PATH_ARG" ]]; then
    [[ -f "$CLI_PATH_ARG" ]] || { error "File not found: $CLI_PATH_ARG"; exit 1; }
    CLI_PATH="$CLI_PATH_ARG"
else
    CLI_PATH=$(find_cli_path) || { error "Claude Code cli.js not found. Specify path: $0 /path/to/cli.js"; exit 1; }
fi

CLI_DIR=$(dirname "$CLI_PATH")

# Restore backup
if $RESTORE; then
    LATEST_BACKUP=$(ls -t "$CLI_DIR"/cli.js.${BACKUP_SUFFIX}-* 2>/dev/null | head -1)
    [[ -n "$LATEST_BACKUP" ]] || { error "No backup found"; exit 1; }
    cp "$LATEST_BACKUP" "$CLI_PATH"
    success "Restored from: $LATEST_BACKUP"
    exit 0
fi

# Download acorn if needed
ACORN_PATH="/tmp/acorn-claude-fix.js"
if [[ ! -f "$ACORN_PATH" ]]; then
    curl -sL "https://unpkg.com/acorn@8.16.0/dist/acorn.js" -o "$ACORN_PATH" || { error "Failed to download acorn"; exit 1; }
fi

PATCH_SCRIPT=$(mktemp)
cat > "$PATCH_SCRIPT" << 'PATCH_EOF'
const fs = require('fs');
const acorn = require(process.argv[2]);
const cliPath = process.argv[3];
const checkOnly = process.argv[4] === '--check';
const backupSuffix = process.env.BACKUP_SUFFIX || 'backup';

let code = fs.readFileSync(cliPath, 'utf-8');
let shebang = '';
if (code.startsWith('#!')) {
    const idx = code.indexOf('\n');
    shebang = code.slice(0, idx + 1);
    code = code.slice(idx + 1);
}

let version = 'unknown';
const headerMatch = code.slice(0, 1000).match(/Version:\s*([\d.]+)/);
if (headerMatch) version = headerMatch[1];
else try { version = JSON.parse(fs.readFileSync(require('path').join(require('path').dirname(cliPath), 'package.json'), 'utf-8')).version || version; } catch {}

let ast;
try { ast = acorn.parse(code, { ecmaVersion: 'latest', sourceType: 'module' }); }
catch (e) { console.error('PARSE_ERROR:' + e.message); process.exit(1); }

function findNodes(node, pred, results = []) {
    if (!node || typeof node !== 'object') return results;
    if (pred(node)) results.push(node);
    for (const key in node) {
        if (key === 'start' || key === 'end' || key === 'type') continue;
        if (node[key] && typeof node[key] === 'object') {
            if (Array.isArray(node[key])) node[key].forEach(child => findNodes(child, pred, results));
            else findNodes(node[key], pred, results);
        }
    }
    return results;
}
const src = (node) => code.slice(node.start, node.end);

let replacements = [], patchCount = 0;

const ternaries = findNodes(ast, n =>
    n.type === 'ConditionalExpression' && n.consequent.type === 'Literal' && n.consequent.value === 'API error'
);

let target = null;
for (const t of ternaries) {
    let cur = t.alternate, found = false, depth = 0;
    while (cur && cur.type === 'ConditionalExpression' && depth < 5) {
        if (cur.alternate && (src(cur.alternate).includes('.formatted') || src(cur.alternate).includes('.error'))) { found = true; break; }
        cur = cur.alternate; depth++;
    }
    if (!found && cur && (src(cur).includes('.formatted') || src(cur).includes('.error'))) found = true;
    if (found) { target = t; break; }
}

if (!target) {
    if (/0\s*\?\s*"API error"/.test(code)) { console.log('ALREADY_PATCHED'); process.exit(0); }
    console.error('NOT_FOUND:API error ternary not found'); process.exit(1);
}
if (src(target).startsWith('0?')) { console.log('ALREADY_PATCHED'); process.exit(0); }

replacements.push({ start: target.test.start, end: target.test.end, replacement: '0' });
patchCount++;
if (target.alternate?.type === 'ConditionalExpression') {
    const nested = target.alternate;
    if (nested.consequent.type === 'Literal' && nested.consequent.value === 'Usage limit reached') {
        replacements.push({ start: nested.test.start, end: nested.test.end, replacement: '0' });
        patchCount++;
    }
}

if (checkOnly) { console.log('NEEDS_PATCH:' + patchCount); process.exit(1); }

replacements.sort((a, b) => b.start - a.start);
let newCode = code;
for (const r of replacements) newCode = newCode.slice(0, r.start) + r.replacement + newCode.slice(r.end);

try { acorn.parse(newCode, { ecmaVersion: 'latest', sourceType: 'module' }); }
catch (e) { console.error('VERIFY_FAILED:' + e.message); process.exit(1); }
if (!/0\s*\?\s*"API error"/.test(newCode)) { console.error('VERIFY_FAILED:pattern not found'); process.exit(1); }

const ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
fs.copyFileSync(cliPath, cliPath + '.' + backupSuffix + '-' + ts);

// Output before/after for display
const beforeSample = code.slice(target.test.start, Math.min(target.test.end + 60, code.length)).split('\n')[0];
const afterSample = newCode.slice(target.test.start, Math.min(target.test.end + 60, newCode.length)).split('\n')[0];
console.log('VERSION:' + version);
console.log('BEFORE:' + beforeSample);
console.log('AFTER:' + afterSample);

fs.writeFileSync(cliPath, shebang + newCode);
console.log('SUCCESS:' + patchCount);
PATCH_EOF

# Execute patch
CHECK_ARG=""
$CHECK_ONLY && CHECK_ARG="--check"

echo ""
log_path "$CLI_PATH"

export BACKUP_SUFFIX
OUTPUT=$(node "$PATCH_SCRIPT" "$ACORN_PATH" "$CLI_PATH" "$CHECK_ARG" 2>&1) || true
EXIT_CODE=$?
rm -f "$PATCH_SCRIPT"

# Process output
VERSION="" BEFORE="" AFTER=""
while IFS= read -r line; do
    case "$line" in
        ALREADY_PATCHED) success "Already patched"; exit 0 ;;
        PARSE_ERROR:*) error "Parse error: ${line#PARSE_ERROR:}"; exit 1 ;;
        NOT_FOUND:*) error "${line#NOT_FOUND:}"; exit 1 ;;
        NEEDS_PATCH:*) warn "Need to patch ${line#NEEDS_PATCH:} location(s). Run without --check to apply"; exit 1 ;;
        VERSION:*) VERSION="${line#VERSION:}" ;;
        BEFORE:*) BEFORE="${line#BEFORE:}" ;;
        AFTER:*) AFTER="${line#AFTER:}" ;;
        SUCCESS:*)
            [[ -n "$VERSION" ]] && log_version "$VERSION"
            echo ""
            log_before "$BEFORE"
            log_after "$AFTER"
            echo ""
            success "Patched ${line#SUCCESS:} location(s). Restart Claude Code to apply."
            exit 0
            ;;
        VERIFY_FAILED:*) error "Verify failed: ${line#VERIFY_FAILED:}"; exit 1 ;;
    esac
done <<< "$OUTPUT"

exit $EXIT_CODE
