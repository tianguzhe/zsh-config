# ANR (Application Not Responding) 分析指南

## ANR 概述

ANR 发生在应用主线程被阻塞超过系统阈值时：
- **输入事件**：5 秒无响应
- **BroadcastReceiver**：前台 10 秒，后台 60 秒
- **Service**：前台 20 秒，后台 200 秒

## ANR 报告结构

### 典型 ANR 报告格式

```
ANR in com.example.app (com.example.app/.MainActivity)
PID: 12345
Reason: Input dispatching timed out (Waiting to send non-key event because the touched window has not finished processing certain input events that were delivered to it over 500.0ms ago.)
Parent: com.example.app/.MainActivity
Load: 2.5 / 1.8 / 1.2
CPU usage from 0ms to 5000ms later:
  45% 12345/com.example.app: 40% user + 5% kernel / faults: 1234 minor
  15% 1234/system_server: 10% user + 5% kernel
  ...

"main" prio=5 tid=1 Blocked
  | group="main" sCount=1 dsCount=0 flags=1 obj=0x12345678 self=0x87654321
  | sysTid=12345 nice=-10 cgrp=default sched=0/0 handle=0xabcdef00
  | state=S schedstat=( 1234567890 987654321 12345 ) utm=100 stm=50 core=0 HZ=100
  | stack=0x7fff0000-0x7fff2000 stackSize=8192KB
  at com.example.app.DataManager.loadData(DataManager.java:45)
  - waiting to lock <0x12345678> (a java.lang.Object) held by thread 15
  at com.example.app.MainActivity.onCreate(MainActivity.java:30)
```

## ANR 原因分类

### 1. 主线程 I/O 操作

**特征**：堆栈显示文件读写、数据库操作

```
"main" prio=5 tid=1 Native
  at android.database.sqlite.SQLiteConnection.nativeExecuteForChangedRowCount(Native Method)
  at android.database.sqlite.SQLiteConnection.executeForChangedRowCount(SQLiteConnection.java:904)
  at com.example.app.DatabaseHelper.updateData(DatabaseHelper.java:123)
```

**解决方案**：
```kotlin
// 将数据库操作移到后台线程
viewModelScope.launch(Dispatchers.IO) {
    database.updateData(data)
}

// 使用 Room 的 suspend 函数
@Dao
interface UserDao {
    @Insert
    suspend fun insert(user: User)

    @Query("SELECT * FROM users")
    fun getAllUsers(): Flow<List<User>>
}
```

### 2. 网络操作

**特征**：堆栈显示网络相关调用

```
"main" prio=5 tid=1 Native
  at java.net.SocketInputStream.socketRead0(Native Method)
  at java.net.SocketInputStream.read(SocketInputStream.java:150)
  at okhttp3.internal.http1.Http1ExchangeCodec.readResponseHeaders(Http1ExchangeCodec.kt:178)
```

**解决方案**：
```kotlin
// 使用协程进行网络请求
viewModelScope.launch {
    try {
        val result = withContext(Dispatchers.IO) {
            apiService.fetchData()
        }
        handleResult(result)
    } catch (e: Exception) {
        handleError(e)
    }
}
```

### 3. 锁竞争

**特征**：堆栈显示 "waiting to lock" 或 "Blocked"

```
"main" prio=5 tid=1 Blocked
  at com.example.app.CacheManager.getData(CacheManager.java:45)
  - waiting to lock <0x12345678> (a java.lang.Object) held by thread 15
```

**解决方案**：
```kotlin
// 使用细粒度锁
class CacheManager {
    private val locks = ConcurrentHashMap<String, Any>()

    fun getData(key: String): Data? {
        val lock = locks.getOrPut(key) { Any() }
        synchronized(lock) {
            return cache[key]
        }
    }
}

// 使用读写锁
class ThreadSafeCache {
    private val lock = ReentrantReadWriteLock()
    private val cache = mutableMapOf<String, Data>()

    fun get(key: String): Data? = lock.read { cache[key] }
    fun put(key: String, value: Data) = lock.write { cache[key] = value }
}

// 使用无锁数据结构
private val cache = ConcurrentHashMap<String, Data>()
```

### 4. 死锁

**特征**：多个线程互相等待对方持有的锁

```
"main" prio=5 tid=1 Blocked
  - waiting to lock <0xA> held by thread 15

"Thread-15" prio=5 tid=15 Blocked
  - waiting to lock <0xB> held by thread 1
```

**解决方案**：
```kotlin
// 统一锁获取顺序
class ResourceManager {
    private val lockA = Any()
    private val lockB = Any()

    // 始终按相同顺序获取锁
    fun operation() {
        synchronized(lockA) {
            synchronized(lockB) {
                // 操作
            }
        }
    }
}

// 使用 tryLock 避免死锁
val lockA = ReentrantLock()
val lockB = ReentrantLock()

fun safeOperation(): Boolean {
    if (lockA.tryLock(100, TimeUnit.MILLISECONDS)) {
        try {
            if (lockB.tryLock(100, TimeUnit.MILLISECONDS)) {
                try {
                    // 操作
                    return true
                } finally {
                    lockB.unlock()
                }
            }
        } finally {
            lockA.unlock()
        }
    }
    return false
}
```

### 5. Binder 调用阻塞

**特征**：堆栈显示 Binder 事务

```
"main" prio=5 tid=1 Native
  at android.os.BinderProxy.transactNative(Native Method)
  at android.os.BinderProxy.transact(BinderProxy.java:540)
  at android.app.IActivityManager$Stub$Proxy.getRunningAppProcesses(IActivityManager.java:5678)
```

**解决方案**：
```kotlin
// 将系统服务调用移到后台
viewModelScope.launch(Dispatchers.Default) {
    val processes = withContext(Dispatchers.IO) {
        activityManager.runningAppProcesses
    }
    // 处理结果
}
```

### 6. SharedPreferences 同步写入

**特征**：堆栈显示 SharedPreferences commit

```
"main" prio=5 tid=1 Waiting
  at java.lang.Object.wait(Native Method)
  at android.app.SharedPreferencesImpl$EditorImpl$1.run(SharedPreferencesImpl.java:366)
```

**解决方案**：
```kotlin
// 使用 apply() 替代 commit()
sharedPreferences.edit()
    .putString("key", "value")
    .apply() // 异步写入

// 使用 DataStore
val dataStore = context.createDataStore(name = "settings")

suspend fun saveValue(value: String) {
    dataStore.edit { preferences ->
        preferences[KEY] = value
    }
}
```

### 7. 布局过于复杂

**特征**：堆栈显示 measure/layout 操作

```
"main" prio=5 tid=1 Runnable
  at android.view.View.measure(View.java:25012)
  at android.widget.LinearLayout.measureVertical(LinearLayout.java:1012)
  at android.widget.LinearLayout.onMeasure(LinearLayout.java:721)
```

**解决方案**：
```kotlin
// 使用 ConstraintLayout 减少嵌套
// 使用 ViewStub 延迟加载
<ViewStub
    android:id="@+id/stub"
    android:layout="@layout/heavy_layout"
    android:inflatedId="@+id/heavy_content" />

// 代码中按需加载
val stub = findViewById<ViewStub>(R.id.stub)
stub.inflate()

// 使用 RecyclerView 替代 ScrollView + LinearLayout
```

## ANR 分析工具

### 1. 使用 StrictMode 检测

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        if (BuildConfig.DEBUG) {
            StrictMode.setThreadPolicy(
                StrictMode.ThreadPolicy.Builder()
                    .detectDiskReads()
                    .detectDiskWrites()
                    .detectNetwork()
                    .penaltyLog()
                    .penaltyFlashScreen()
                    .build()
            )
            StrictMode.setVmPolicy(
                StrictMode.VmPolicy.Builder()
                    .detectLeakedSqlLiteObjects()
                    .detectLeakedClosableObjects()
                    .penaltyLog()
                    .build()
            )
        }
    }
}
```

### 2. 使用 Systrace 分析

```bash
# 捕获 trace
python systrace.py -o trace.html sched freq idle am wm gfx view

# 分析关键指标
# - 主线程执行时间
# - 锁等待时间
# - Binder 调用耗时
```

### 3. 使用 Perfetto 分析

```bash
# 捕获 trace
adb shell perfetto -o /data/misc/perfetto-traces/trace.perfetto-trace -t 10s sched freq idle am wm gfx view

# 拉取并分析
adb pull /data/misc/perfetto-traces/trace.perfetto-trace
# 在 ui.perfetto.dev 中打开
```

## ANR 预防最佳实践

### 1. 主线程规则

```kotlin
// 主线程只做 UI 操作
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // UI 初始化
        setupViews()

        // 数据加载在 ViewModel 中处理
        viewModel.loadData()
    }
}

// ViewModel 处理后台操作
class MainViewModel : ViewModel() {
    fun loadData() {
        viewModelScope.launch {
            val data = withContext(Dispatchers.IO) {
                repository.fetchData()
            }
            _uiState.value = data
        }
    }
}
```

### 2. 使用 WorkManager 处理后台任务

```kotlin
class SyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            syncData()
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}

// 调度任务
val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(
    15, TimeUnit.MINUTES
).setConstraints(
    Constraints.Builder()
        .setRequiredNetworkType(NetworkType.CONNECTED)
        .build()
).build()

WorkManager.getInstance(context).enqueue(syncRequest)
```

### 3. BroadcastReceiver 优化

```kotlin
class MyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // 快速返回，将耗时操作交给 Service 或 WorkManager
        val pendingResult = goAsync()

        CoroutineScope(Dispatchers.IO).launch {
            try {
                processIntent(intent)
            } finally {
                pendingResult.finish()
            }
        }
    }
}
```

## ANR 监控

### 自定义 ANR 检测

```kotlin
class ANRWatchDog(private val timeoutMs: Long = 5000) : Thread() {

    private val mainHandler = Handler(Looper.getMainLooper())
    private var tick = 0L
    private var reported = false

    private val ticker = Runnable {
        tick = System.currentTimeMillis()
        reported = false
    }

    override fun run() {
        while (!isInterrupted) {
            tick = 0
            mainHandler.post(ticker)

            Thread.sleep(timeoutMs)

            if (tick == 0L && !reported) {
                reported = true
                // 报告 ANR
                val stackTrace = Looper.getMainLooper().thread.stackTrace
                reportANR(stackTrace)
            }
        }
    }

    private fun reportANR(stackTrace: Array<StackTraceElement>) {
        // 上报到 Crashlytics 或自定义服务
        Firebase.crashlytics.log("ANR detected")
        Firebase.crashlytics.recordException(ANRException(stackTrace))
    }
}
```