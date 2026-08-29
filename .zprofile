# ============================================
# PATH Configuration (after system path_helper)
# ============================================

# Development Environments
if [[ $(uname -m) == "arm64" ]]; then
    export HOMEBREW="/opt/homebrew"
else
    export HOMEBREW="/usr/local"
fi
export LOCAL_TOOL="$HOME/.local"
export BUN_INSTALL="$HOME/.bun"
export GOPATH="$HOME/go"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"

# PATH Configuration - set after path_helper to ensure correct priority
export PATH="$LOCAL_TOOL/bin:$HOMEBREW/opt/curl/bin:$HOMEBREW/bin:$BUN_INSTALL/bin:$GOPATH/bin:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"
