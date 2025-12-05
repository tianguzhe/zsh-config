# Android 常见异常类型参考

## Java/Kotlin 运行时异常

### NullPointerException

**描述**：尝试在空引用上调用方法或访问属性

**常见场景**：
- 未初始化的变量
- findViewById 返回 null
- Intent extras 为空
- 网络响应数据为空

**堆栈示例**：
```
Fatal Exception: java.lang.NullPointerException
Attempt to invoke virtual method 'void android.widget.TextView.setText(java.lang.CharSequence)' on a null object reference
    at com.example.app.MainActivity.updateUI(MainActivity.kt:85)
    at com.example.app.MainActivity.onDataLoaded(MainActivity.kt:72)
```

**修复模式**：
```kotlin
// 使用安全调用操作符
textView?.text = data

// 使用 let 进行空值检查
data?.let {
    processData(it)
}

// 使用 Elvis 操作符提供默认值
val name = user?.name ?: "Unknown"

// 使用 requireNotNull 明确断言
val view = requireNotNull(findViewById<TextView>(R.id.text)) {
    "TextView not found in layout"
}
```

---

### IllegalStateException

**描述**：对象状态不允许执行请求的操作

**常见场景**：
- Fragment 未附加到 Activity
- 在错误的生命周期阶段操作
- RecyclerView 未设置 LayoutManager
- 重复提交 Fragment 事务

**堆栈示例**：
```
Fatal Exception: java.lang.IllegalStateException
Fragment MyFragment not attached to a context.
    at androidx.fragment.app.Fragment.requireContext(Fragment.java:900)
    at com.example.app.MyFragment.loadData(MyFragment.kt:45)
```

**修复模式**：
```kotlin
// 检查 Fragment 是否附加
if (isAdded && context != null) {
    // 安全操作
}

// 使用 viewLifecycleOwner
viewLifecycleOwner.lifecycleScope.launch {
    // 自动处理生命周期
}

// 检查 Activity 是否正在销毁
if (!isFinishing && !isDestroyed) {
    showDialog()
}
```

---

### IndexOutOfBoundsException

**描述**：访问数组或集合时索引超出范围

**常见场景**：
- 空列表访问
- 并发修改导致索引失效
- RecyclerView 数据不同步

**堆栈示例**：
```
Fatal Exception: java.lang.IndexOutOfBoundsException
Index: 5, Size: 3
    at java.util.ArrayList.get(ArrayList.java:437)
    at com.example.app.adapter.MyAdapter.onBindViewHolder(MyAdapter.kt:28)
```

**修复模式**：
```kotlin
// 使用 getOrNull 安全访问
val item = list.getOrNull(index)

// 使用 getOrElse 提供默认值
val item = list.getOrElse(index) { defaultItem }

// 检查索引范围
if (index in list.indices) {
    val item = list[index]
}

// 使用 firstOrNull/lastOrNull
val first = list.firstOrNull()
```

---

### ConcurrentModificationException

**描述**：在迭代集合时修改集合

**堆栈示例**：
```
Fatal Exception: java.util.ConcurrentModificationException
    at java.util.ArrayList$Itr.next(ArrayList.java:860)
    at com.example.app.DataManager.processItems(DataManager.kt:34)
```

**修复模式**：
```kotlin
// 使用 Iterator 的 remove 方法
val iterator = list.iterator()
while (iterator.hasNext()) {
    val item = iterator.next()
    if (shouldRemove(item)) {
        iterator.remove()
    }
}

// 使用 removeAll/removeIf
list.removeAll { shouldRemove(it) }

// 使用 toList() 创建副本
list.toList().forEach { item ->
    if (shouldRemove(item)) {
        list.remove(item)
    }
}

// 使用线程安全集合
val safeList = CopyOnWriteArrayList<Item>()
```

---

### OutOfMemoryError

**描述**：JVM 无法分配足够内存

**常见场景**：
- 加载大图片
- 内存泄漏
- 大量数据缓存
- Bitmap 未回收

**堆栈示例**：
```
Fatal Exception: java.lang.OutOfMemoryError
Failed to allocate a 40000012 byte allocation with 16777216 free bytes
    at dalvik.system.VMRuntime.newNonMovableArray(VMRuntime.java)
    at android.graphics.Bitmap.nativeCreate(Bitmap.java)
```

**修复模式**：
```kotlin
// 使用图片加载库 (Coil/Glide)
imageView.load(url) {
    size(ViewSizeResolver(imageView))
}

// 手动缩放 Bitmap
fun decodeSampledBitmap(path: String, reqWidth: Int, reqHeight: Int): Bitmap {
    val options = BitmapFactory.Options().apply {
        inJustDecodeBounds = true
    }
    BitmapFactory.decodeFile(path, options)

    options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight)
    options.inJustDecodeBounds = false

    return BitmapFactory.decodeFile(path, options)
}

// 及时回收 Bitmap
bitmap?.recycle()
bitmap = null

// 使用 WeakReference 避免泄漏
private val callback = WeakReference(listener)
```

---

### SecurityException

**描述**：缺少必要的权限

**常见场景**：
- 未申请运行时权限
- 权限被用户拒绝
- 访问受保护的内容提供者

**堆栈示例**：
```
Fatal Exception: java.lang.SecurityException
Permission Denial: reading com.android.providers.contacts.ContactsProvider2
requires android.permission.READ_CONTACTS
    at android.os.Parcel.createException(Parcel.java:2074)
```

**修复模式**：
```kotlin
// 检查并请求权限
private val requestPermission = registerForActivityResult(
    ActivityResultContracts.RequestPermission()
) { isGranted ->
    if (isGranted) {
        performAction()
    } else {
        showPermissionDeniedMessage()
    }
}

fun checkAndRequestPermission() {
    when {
        ContextCompat.checkSelfPermission(
            this, Manifest.permission.READ_CONTACTS
        ) == PackageManager.PERMISSION_GRANTED -> {
            performAction()
        }
        shouldShowRequestPermissionRationale(Manifest.permission.READ_CONTACTS) -> {
            showRationale()
        }
        else -> {
            requestPermission.launch(Manifest.permission.READ_CONTACTS)
        }
    }
}
```

---

### ClassCastException

**描述**：尝试将对象转换为不兼容的类型

**堆栈示例**：
```
Fatal Exception: java.lang.ClassCastException
java.lang.String cannot be cast to java.lang.Integer
    at com.example.app.DataParser.parse(DataParser.kt:23)
```

**修复模式**：
```kotlin
// 使用安全转换
val number = value as? Int

// 使用 is 检查类型
if (value is Int) {
    processNumber(value)
}

// 使用 when 表达式
when (value) {
    is Int -> processInt(value)
    is String -> processString(value)
    else -> handleUnknown(value)
}
```

---

### NetworkOnMainThreadException

**描述**：在主线程执行网络操作

**堆栈示例**：
```
Fatal Exception: android.os.NetworkOnMainThreadException
    at android.os.StrictMode$AndroidBlockGuardPolicy.onNetwork(StrictMode.java:1513)
    at com.example.app.ApiClient.fetchData(ApiClient.kt:45)
```

**修复模式**：
```kotlin
// 使用协程
viewModelScope.launch {
    val result = withContext(Dispatchers.IO) {
        apiClient.fetchData()
    }
    updateUI(result)
}

// 使用 Retrofit + Coroutines
interface ApiService {
    @GET("data")
    suspend fun getData(): Response<Data>
}
```

---

### TransactionTooLargeException

**描述**：Intent 或 Bundle 数据过大

**堆栈示例**：
```
Fatal Exception: android.os.TransactionTooLargeException
data parcel size 1048576 bytes
    at android.os.BinderProxy.transactNative(BinderProxy.java)
```

**修复模式**：
```kotlin
// 避免传递大数据，使用 ID 或缓存
intent.putExtra("item_id", item.id)
// 而不是
// intent.putExtra("item", item) // 大对象

// 使用 ViewModel 共享数据
class SharedViewModel : ViewModel() {
    val selectedItem = MutableLiveData<Item>()
}

// 使用数据库或文件缓存
fun saveToCache(data: LargeData): String {
    val cacheKey = UUID.randomUUID().toString()
    cacheManager.put(cacheKey, data)
    return cacheKey
}
```

---

### BadTokenException

**描述**：尝试在无效的窗口令牌上显示对话框

**堆栈示例**：
```
Fatal Exception: android.view.WindowManager$BadTokenException
Unable to add window -- token android.os.BinderProxy@xxx is not valid
    at android.view.ViewRootImpl.setView(ViewRootImpl.java:951)
```

**修复模式**：
```kotlin
// 检查 Activity 状态
fun showDialog() {
    if (!isFinishing && !isDestroyed) {
        AlertDialog.Builder(this)
            .setMessage("Message")
            .show()
    }
}

// 使用 DialogFragment
class MyDialogFragment : DialogFragment() {
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        return AlertDialog.Builder(requireContext())
            .setMessage("Message")
            .create()
    }
}
```