# Firebase Crashlytics 参考文档索引

## 文档目录

### Android 异常参考
**文件:** `android-exceptions.md`

包含常见 Java/Kotlin 运行时异常的详细分析：
- NullPointerException
- IllegalStateException
- IndexOutOfBoundsException
- ConcurrentModificationException
- OutOfMemoryError
- SecurityException
- ClassCastException
- NetworkOnMainThreadException
- TransactionTooLargeException
- BadTokenException

### ANR 分析指南
**文件:** `anr-analysis.md`

包含 ANR 问题的完整分析流程：
- ANR 报告结构解析
- 常见 ANR 原因分类
- 主线程 I/O 操作
- 锁竞争与死锁
- Binder 调用阻塞
- ANR 预防最佳实践
- ANR 监控方案

## 快速参考

### 崩溃类型速查

| 崩溃类型 | 参考文档 | 关键特征 |
|---------|---------|---------|
| Java/Kotlin 异常 | android-exceptions.md | `java.lang.*Exception` |
| ANR | anr-analysis.md | `ANR in`, `Input dispatching timed out` |

### 常用分析命令

```bash
# 查看 logcat 崩溃日志
adb logcat -b crash

# 获取 ANR traces
adb pull /data/anr/traces.txt

# 启用 StrictMode 检测
adb shell setprop debug.strictmode.visual 1
```

## 外部资源

- [Firebase Crashlytics 文档](https://firebase.google.com/docs/crashlytics)
- [Android 崩溃分析](https://developer.android.com/topic/performance/vitals/crash)
- [Android ANR 分析](https://developer.android.com/topic/performance/vitals/anr)