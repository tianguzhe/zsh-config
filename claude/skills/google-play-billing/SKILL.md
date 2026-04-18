---
name: google-play-billing
description: "Google Play Billing Library (PBL 8.x) for Android in-app purchases and subscriptions. Use when: (1) implementing IAP in Android apps, (2) setting up subscriptions, (3) handling purchase flows, (4) validating transactions, (5) managing subscription lifecycle, (6) migrating between PBL versions, (7) testing billing implementations."
---

# Google Play Billing

Android 应用内购买和订阅的 Google Play 结算库集成指南。

## 添加依赖 (PBL 8.x)

```kotlin
// build.gradle.kts
dependencies {
    val billing_version = "8.3.0"
    implementation("com.android.billingclient:billing:$billing_version")
    // Kotlin 扩展（可选）
    implementation("com.android.billingclient:billing-ktx:$billing_version")
}
```

## 初始化 BillingClient

```kotlin
private lateinit var billingClient: BillingClient

billingClient = BillingClient.newBuilder(context)
    .setListener(purchasesUpdatedListener)
    .enablePendingPurchases(
        PendingPurchasesParams.newBuilder()
            .enableOneTimeProducts()
            .enablePrepaidPlans()
            .build()
    )
    .build()

// 连接 Google Play
billingClient.startConnection(object : BillingClientStateListener {
    override fun onBillingSetupFinished(billingResult: BillingResult) {
        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
            // Ready to query purchases and products
        }
    }
    override fun onBillingServiceDisconnected() {
        // Retry connection
    }
})
```

## 核心流程

### 1. 查询商品

```kotlin
val productList = listOf(
    QueryProductDetailsParams.Product.newBuilder()
        .setProductId("premium_upgrade")
        .setProductType(BillingClient.ProductType.INAPP) // or SUBS
        .build()
)

billingClient.queryProductDetailsAsync(
    QueryProductDetailsParams.newBuilder().setProductList(productList).build()
) { billingResult, productDetailsList ->
    // Process result
}
```

### 2. 发起购买

```kotlin
val billingFlowParams = BillingFlowParams.newBuilder()
    .setProductDetailsParamsList(listOf(
        BillingFlowParams.ProductDetailsParams.newBuilder()
            .setProductDetails(productDetails)
            .build()
    ))
    .build()

billingClient.launchBillingFlow(activity, billingFlowParams)
```

### 3. 处理购买结果

```kotlin
private val purchasesUpdatedListener = PurchasesUpdatedListener { billingResult, purchases ->
    when (billingResult.responseCode) {
        BillingClient.BillingResponseCode.OK -> purchases?.forEach { handlePurchase(it) }
        BillingClient.BillingResponseCode.USER_CANCELED -> { /* User canceled */ }
        else -> { /* Handle error */ }
    }
}
```

### 4. 确认购买（必须！）

```kotlin
// 3 天内必须确认，否则自动退款
if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED && !purchase.isAcknowledged) {
    billingClient.acknowledgePurchase(
        AcknowledgePurchaseParams.newBuilder()
            .setPurchaseToken(purchase.purchaseToken)
            .build()
    ) { /* Handle result */ }
}
```

### 5. 消耗商品（消耗型）

```kotlin
billingClient.consumeAsync(
    ConsumeParams.newBuilder()
        .setPurchaseToken(purchase.purchaseToken)
        .build()
) { billingResult, purchaseToken -> /* Handle result */ }
```

## 关键概念

| 概念 | 说明 |
|------|------|
| **INAPP** | 一次性购买（消耗型/非消耗型） |
| **SUBS** | 订阅（自动续订/预付费） |
| **PENDING** | 待处理（如现金支付） |
| **PURCHASED** | 已完成 |

## 重要规则

1. **3 天内确认购买**，否则自动退款
2. **消耗型商品**授权后必须消耗
3. **后端验证购买**确保安全
4. **处理待处理购买**支持延迟付款地区

## 响应码速查

| Code | 含义 |
|------|------|
| OK (0) | 成功 |
| USER_CANCELED (1) | 用户取消 |
| SERVICE_UNAVAILABLE (2) | 网络问题 |
| BILLING_UNAVAILABLE (3) | 结算 API 不可用 |
| ITEM_ALREADY_OWNED (7) | 已购买 |
| NETWORK_ERROR (12) | 网络连接问题 |

## 参考文档

详细文档按主题组织在 `references/` 目录：

- **getting_started.md** - 设置、依赖、初始配置
- **library.md** - 版本迁移指南 (PBL 5→6→7→8)
- **products.md** - 一次性商品配置
- **subscriptions.md** - 订阅设置、基础方案、优惠
- **purchases.md** - 购买处理、安全、防欺诈
- **testing.md** - 测试购买、许可测试
- **other.md** - 替代结算、外部优惠、高级主题
