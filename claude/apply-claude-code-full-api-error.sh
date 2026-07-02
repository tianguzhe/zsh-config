#!/bin/bash
#
# Claude Code Full API Error Display Patch Script
#
# PURPOSE:
#   Patch cli.js to show full formatted API error messages during retries
#   instead of folding them into generic "API error" text.
#
#   Original behavior:
#     condition ? "API error" : otherCondition ? "Usage limit reached" : n.error.formatted
#
#   Patched behavior:
#     0 ? "API error" : 0 ? "Usage limit reached" : n.error.formatted
#
#   This forces the formatted API error (e.g., "429 {"error":...}") to always
#   be displayed, making debugging API issues much easier.
#
# DETECTION STRATEGY (AST-based, name-agnostic):
#
#   Find ConditionalExpression (ternary) where:
#     - consequent is Literal "API error"
#     - alternate contains Literal "Usage limit reached"
#     - final alternate references .formatted or .error
#
#   Replace both test conditions with 0 (false) to always show formatted error.
#
# Verified: cli.js based versions
#
# Usage:
#   ./apply-claude-code-full-api-error.sh                    # Apply (auto-detect)
#   ./apply-claude-code-full-api-error.sh /path/to/cli.js   # Apply to specific file
#   ./apply-claude-code-full-api-error.sh --check           # Check only
#   ./apply-claude-code-full-api-error.sh --restore         # Restore backup
#

set -e

# ============================================================
# Configuration
# ============================================================
BACKUP_SUFFIX="backup-full-api-error"
FIX_DESCRIPTION="Show full formatted API error during retries instead of generic 'API error'"

# ============================================================
# Color output functions
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[X]${NC} $1"; }
info() { echo -e "${BLUE}[>]${NC} $1"; }

# ============================================================
# Argument parsing
# ============================================================
CHECK_ONLY=false
RESTORE=false
CLI_PATH_ARG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --check|-c) CHECK_ONLY=true; shift ;;
        --restore|-r) RESTORE=true; shift ;;
        --help|-h)
            echo "Usage: $0 [options] [cli.js path]"
            echo ""
            echo "$FIX_DESCRIPTION"
            echo ""
            echo "Arguments:"
            echo "  cli.js path    Path to cli.js file (optional, auto-detect if not provided)"
            echo ""
            echo "Options:"
            echo "  --check, -c    Check if fix is needed without making changes"
            echo "  --restore, -r  Restore original file from backup"
            echo "  --help, -h     Show help information"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Auto-detect and apply fix"
            echo "  $0 /path/to/cli.js                    # Apply fix to specific file"
            echo "  $0 --check /path/to/cli.js            # Check specific file"
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

# ============================================================
# Find Claude Code cli.js path
# ============================================================
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
        local npm_root
        npm_root=$(npm root -g 2>/dev/null || true)
        if [[ -n "$npm_root" ]]; then
            locations+=("$npm_root/@anthropic-ai/claude-code/cli.js")
            locations+=("$npm_root/@cometix/claude-code/cli.js")
        fi
    fi
    for path in "${locations[@]}"; do
        if [[ -f "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

if [[ -n "$CLI_PATH_ARG" ]]; then
    if [[ -f "$CLI_PATH_ARG" ]]; then
        CLI_PATH="$CLI_PATH_ARG"
        info "Using specified cli.js: $CLI_PATH"
    else
        error "Specified file not found: $CLI_PATH_ARG"
        exit 1
    fi
else
    CLI_PATH=$(find_cli_path) || {
        error "Claude Code cli.js not found"
        echo ""
        echo "Searched locations:"
        echo "  ~/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js"
        echo "  ~/.claude/local/node_modules/@cometix/claude-code/cli.js"
        echo "  /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js"
        echo "  \$(npm root -g)/@anthropic-ai/claude-code/cli.js"
        echo ""
        echo "Tip: You can specify the path directly:"
        echo "  $0 /path/to/cli.js"
        exit 1
    }
    info "Found Claude Code: $CLI_PATH"
fi

CLI_DIR=$(dirname "$CLI_PATH")

# ============================================================
# Restore backup
# ============================================================
if $RESTORE; then
    LATEST_BACKUP=$(ls -t "$CLI_DIR"/cli.js.${BACKUP_SUFFIX}-* 2>/dev/null | head -1)
    if [[ -n "$LATEST_BACKUP" ]]; then
        cp "$LATEST_BACKUP" "$CLI_PATH"
        success "Restored from backup: $LATEST_BACKUP"
        exit 0
    else
        error "No backup file found (cli.js.${BACKUP_SUFFIX}-*)"
        exit 1
    fi
fi

echo ""

# ============================================================
# Download acorn parser if needed
# ============================================================
ACORN_PATH="/tmp/acorn-claude-fix.js"
if [[ ! -f "$ACORN_PATH" ]]; then
    info "Downloading acorn parser..."
    curl -sL "https://unpkg.com/acorn@8.16.0/dist/acorn.js" -o "$ACORN_PATH" || {
        error "Failed to download acorn parser"
        exit 1
    }
fi

# ============================================================
# Node.js patch script
# ============================================================
PATCH_SCRIPT=$(mktemp)
cat > "$PATCH_SCRIPT" << 'PATCH_EOF'
const fs = require('fs');
const acorn = require(process.argv[2]);
const cliPath = process.argv[3];
const checkOnly = process.argv[4] === '--check';
const backupSuffix = process.env.BACKUP_SUFFIX || 'backup';

let code = fs.readFileSync(cliPath, 'utf-8');

// Preserve shebang
let shebang = '';
if (code.startsWith('#!')) {
    const idx = code.indexOf('\n');
    shebang = code.slice(0, idx + 1);
    code = code.slice(idx + 1);
}

// Version info — try comment header first, then sibling package.json
let version = 'unknown';
const headerMatch = code.slice(0, 1000).match(/Version:\s*([\d.]+)/);
if (headerMatch) {
    version = headerMatch[1];
} else {
    const path = require('path');
    try {
        const pkg = JSON.parse(fs.readFileSync(path.join(path.dirname(cliPath), 'package.json'), 'utf-8'));
        if (pkg.version) version = pkg.version;
    } catch {}
}
console.log('VERSION:' + version);

// ============================================================
// Parse AST
// ============================================================
let ast;
try {
    ast = acorn.parse(code, { ecmaVersion: 'latest', sourceType: 'module' });
} catch (e) {
    console.error('PARSE_ERROR:' + e.message);
    process.exit(1);
}

// AST helpers
function findNodes(node, predicate, results = []) {
    if (!node || typeof node !== 'object') return results;
    if (predicate(node)) results.push(node);
    for (const key in node) {
        if (key === 'start' || key === 'end' || key === 'type') continue;
        if (node[key] && typeof node[key] === 'object') {
            if (Array.isArray(node[key])) {
                node[key].forEach(child => findNodes(child, predicate, results));
            } else {
                findNodes(node[key], predicate, results);
            }
        }
    }
    return results;
}

const src = (node) => code.slice(node.start, node.end);

function replaceAt(str, s, e, repl) {
    return str.slice(0, s) + repl + str.slice(e);
}

// Collect all replacements; apply from end to start to preserve offsets
let replacements = [];
let patchCount = 0;

// ============================================================
// Phase 1: Find the API error display ternary expression
//
// Pattern: condition ? "API error" : ... : n.error.formatted
//
// We look for ConditionalExpression where:
//   - consequent is Literal "API error"
//   - The expression chain ends with a MemberExpression accessing .formatted
//
// Strategy: Find all ConditionalExpressions with "API error" as consequent,
// then check if the final alternate references .formatted or .error
// ============================================================
console.log('STEP:1 - Finding API error display ternary expression');

// Find all ConditionalExpressions where consequent is "API error"
const apiErrorTernaries = findNodes(ast, n =>
    n.type === 'ConditionalExpression' &&
    n.consequent.type === 'Literal' &&
    n.consequent.value === 'API error'
);

console.log('FOUND:' + apiErrorTernaries.length + ' ternary expression(s) with "API error" as consequent');

// Filter to find the one that has .formatted in its alternate chain
let targetTernary = null;
let ternaryName = '(unknown)';

for (const ternary of apiErrorTernaries) {
    // Check if this ternary's alternate chain eventually references .formatted
    // The pattern could be:
    //   test1 ? "API error" : test2 ? "Usage limit reached" : expr.formatted
    //   OR
    //   test1 ? "API error" : expr.formatted

    let current = ternary.alternate;
    let hasFormatted = false;
    let depth = 0;

    // Walk through nested ternaries in the alternate
    while (current && current.type === 'ConditionalExpression' && depth < 5) {
        // Check if this ternary's alternate has .formatted
        if (current.alternate) {
            const alternateSrc = src(current.alternate);
            if (alternateSrc.includes('.formatted') || alternateSrc.includes('.error')) {
                hasFormatted = true;
                break;
            }
        }
        current = current.alternate;
        depth++;
    }

    // Also check direct alternate (non-nested case)
    if (!hasFormatted && current) {
        const finalSrc = src(current);
        if (finalSrc.includes('.formatted') || finalSrc.includes('.error')) {
            hasFormatted = true;
        }
    }

    if (hasFormatted) {
        targetTernary = ternary;
        // Get surrounding context for identification
        const contextStart = Math.max(0, ternary.start - 50);
        const contextEnd = Math.min(code.length, ternary.end + 50);
        ternaryName = code.slice(contextStart, contextEnd).replace(/\n/g, ' ').slice(0, 80);
        console.log('FOUND:target ternary at offset ' + ternary.start + ': ' + ternaryName);
        break;
    }
}

let apiErrorPatched = false;

if (!targetTernary) {
    // Check if already patched: look for 0?"API error"
    const alreadyPatchedPattern = /0\s*\?\s*"API error"/;
    if (alreadyPatchedPattern.test(code)) {
        console.log('FOUND:already patched (0?"API error" found in code)');
        apiErrorPatched = true;
    } else {
        console.error('NOT_FOUND:Cannot find API error ternary expression with .formatted reference');
        console.error('  This may indicate a different code structure or version.');
        process.exit(1);
    }
}

if (!apiErrorPatched && targetTernary) {
    // Check if already patched
    const ternarySrc = src(targetTernary);
    if (ternarySrc.startsWith('0?')) {
        console.log('FOUND:ternary already patched (starts with 0?)');
        apiErrorPatched = true;
    } else {
        // We need to replace the test expression(s) with 0
        // The structure is: test1 ? "API error" : [test2 ? "Usage limit reached" : ...]
        // We want to replace test1 with 0

        // Strategy: Replace the entire ternary's test with 0
        replacements.push({
            start: targetTernary.test.start,
            end: targetTernary.test.end,
            replacement: '0',
            label: 'API error ternary test → 0 (forces formatted error display)'
        });
        patchCount++;

        // Also check if there's a nested ternary for "Usage limit reached"
        if (targetTernary.alternate && targetTernary.alternate.type === 'ConditionalExpression') {
            const nestedTernary = targetTernary.alternate;
            if (nestedTernary.consequent.type === 'Literal' &&
                nestedTernary.consequent.value === 'Usage limit reached') {
                replacements.push({
                    start: nestedTernary.test.start,
                    end: nestedTernary.test.end,
                    replacement: '0',
                    label: '"Usage limit reached" ternary test → 0'
                });
                patchCount++;
            }
        }
    }
}

// ============================================================
// Phase 2: Also look for minified pattern variants
//
// In minified code, the pattern might be:
//   A?"API error":u?"Usage limit reached":n.error.formatted
//   or similar with different variable names
// ============================================================
if (!apiErrorPatched && replacements.length === 0) {
    console.log('STEP:2 - Looking for minified pattern variants');

    // Use regex to find the pattern in minified code
    const patterns = [
        // Pattern: var?"API error":var?"Usage limit reached":expr.formatted
        /(\w+)\s*\?\s*"API error"\s*:\s*(\w+)\s*\?\s*"Usage limit reached"\s*:\s*([^.]+\.formatted)/,
        // Pattern: var?"API error":expr.formatted
        /(\w+)\s*\?\s*"API error"\s*:\s*([^.]+\.formatted)/,
    ];

    let matchFound = false;
    for (const pattern of patterns) {
        const match = code.match(pattern);
        if (match) {
            const matchIndex = match.index;
            const matchEnd = matchIndex + match[0].length;
            console.log('FOUND:minified pattern at offset ' + matchIndex);

            // Replace the first variable/test with 0
            const firstVar = match[1];
            replacements.push({
                start: matchIndex,
                end: matchIndex + firstVar.length,
                replacement: '0',
                label: 'minified pattern: ' + firstVar + ' → 0'
            });
            patchCount++;

            // If there's a second variable (Usage limit reached), replace it too
            if (match[2] && match[2] !== match[1]) {
                const secondVarStart = match[0].indexOf(match[2], firstVar.length);
                if (secondVarStart !== -1) {
                    replacements.push({
                        start: matchIndex + secondVarStart,
                        end: matchIndex + secondVarStart + match[2].length,
                        replacement: '0',
                        label: 'minified pattern: ' + match[2] + ' → 0'
                    });
                    patchCount++;
                }
            }

            matchFound = true;
            break;
        }
    }

    if (!matchFound) {
        console.error('NOT_FOUND:Could not find API error pattern in any form');
        process.exit(1);
    }
}

// ============================================================
// All already patched?
// ============================================================
if (apiErrorPatched) {
    console.log('ALREADY_PATCHED');
    process.exit(2);
}

if (replacements.length === 0) {
    console.log('ALREADY_PATCHED');
    process.exit(2);
}

// ============================================================
// Check-only mode
// ============================================================
if (checkOnly) {
    console.log('NEEDS_PATCH');
    console.log('PATCH_COUNT:' + patchCount);
    process.exit(1);
}

// ============================================================
// Phase 3: Apply all replacements (end-to-start order)
// ============================================================
console.log('STEP:3 - Applying ' + replacements.length + ' replacement(s)');

replacements.sort((a, b) => b.start - a.start);

let newCode = code;
for (const r of replacements) {
    newCode = replaceAt(newCode, r.start, r.end, r.replacement);
    console.log('PATCH:' + r.label);
}

// ============================================================
// Phase 4: Verify
// ============================================================

// 4a. Re-parse to confirm syntax is valid
let newAst;
try {
    newAst = acorn.parse(newCode, { ecmaVersion: 'latest', sourceType: 'module' });
    console.log('VERIFY:AST re-parse confirms valid syntax');
} catch (e) {
    console.error('VERIFY_FAILED:Patched code fails to parse: ' + e.message);
    process.exit(1);
}

// 4b. Verify the ternary is now 0?"API error"...
const verifyPattern = /0\s*\?\s*"API error"/;
if (!verifyPattern.test(newCode)) {
    console.error('VERIFY_FAILED:Patched code does not contain 0?"API error" pattern');
    process.exit(1);
}
console.log('VERIFY:API error ternary now uses 0 as test condition');

// 4c. Verify .formatted is still accessible
if (!newCode.includes('.formatted')) {
    console.error('VERIFY_FAILED:.formatted reference lost after patch');
    process.exit(1);
}
console.log('VERIFY:.formatted reference preserved');

// ============================================================
// Backup and write
// ============================================================
const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
const backupPath = cliPath + '.' + backupSuffix + '-' + timestamp;
fs.copyFileSync(cliPath, backupPath);
console.log('BACKUP:' + backupPath);

fs.writeFileSync(cliPath, shebang + newCode);
console.log('SUCCESS:' + patchCount);
PATCH_EOF

# ============================================================
# Execute patch script
# ============================================================
CHECK_ARG=""
if $CHECK_ONLY; then
    CHECK_ARG="--check"
fi

export BACKUP_SUFFIX
OUTPUT=$(node "$PATCH_SCRIPT" "$ACORN_PATH" "$CLI_PATH" "$CHECK_ARG" 2>&1) || true
EXIT_CODE=$?

rm -f "$PATCH_SCRIPT"

# ============================================================
# Process output
# ============================================================
while IFS= read -r line; do
    case "$line" in
        ALREADY_PATCHED)
            success "Already patched (API error display already shows formatted error)"
            exit 0
            ;;
        PARSE_ERROR:*)
            error "Failed to parse cli.js: ${line#PARSE_ERROR:}"
            exit 1
            ;;
        NOT_FOUND:*)
            error "Target code not found: ${line#NOT_FOUND:}"
            exit 1
            ;;
        VERSION:*)
            info "Claude Code version: ${line#VERSION:}"
            ;;
        STEP:*)
            info "Step ${line#STEP:}"
            ;;
        FOUND:*)
            info "Found: ${line#FOUND:}"
            ;;
        VERIFY:*)
            info "Verify: ${line#VERIFY:}"
            ;;
        PATCH:*)
            info "  ${line#PATCH:}"
            ;;
        NEEDS_PATCH)
            echo ""
            warning "Patch needed - run without --check to apply"
            ;;
        PATCH_COUNT:*)
            info "Need to patch ${line#PATCH_COUNT:} location(s)"
            exit 1
            ;;
        BACKUP:*)
            echo ""
            echo "Backup: ${line#BACKUP:}"
            ;;
        SUCCESS:*)
            echo ""
            success "Fix applied successfully! Patched ${line#SUCCESS:} location(s)"
            echo ""
            echo "  Changed: API error display now shows full formatted error"
            echo "  Before:  'API error' (generic message)"
            echo "  After:   '429 {"error":{"type":"error","message":"..."}' (full details)"
            echo ""
            echo "  This makes it much easier to debug API rate limits, auth issues,"
            echo "  and other errors that were previously hidden behind generic messages."
            echo ""
            warning "Restart Claude Code for changes to take effect"
            ;;
        VERIFY_FAILED:*)
            error "Verification failed: ${line#VERIFY_FAILED:}"
            exit 1
            ;;
    esac
done <<< "$OUTPUT"

exit $EXIT_CODE
