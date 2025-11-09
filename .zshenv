# ============================================
# Environment Variables (loaded in all shells)
# ============================================

# Development Environments
export HOMEBREW="/opt/homebrew"
export LOCAL_TOOL="$HOME/.local"
export BUN_INSTALL="$HOME/.bun"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
# export ANDROID_NDK_HOME=$HOME/Library/Android/sdk/ndk/28.2.13676358

# PATH Configuration
export PATH="$LOCAL_TOOL/bin:$HOMEBREW/opt/curl/bin:$HOMEBREW/bin:$BUN_INSTALL/bin:$JAVA_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"
