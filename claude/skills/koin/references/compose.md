# Koin - Compose

**Pages:** 2

---

## Koin for Jetpack Compose and Compose Multiplatform

**URL:** https://insert-koin.io/docs/reference/koin-compose/compose

**Contents:**
- Koin for Jetpack Compose and Compose Multiplatform
- Koin Compose Multiplatform vs Koin Android Jetpack Compose​
  - What Koin package for Compose?​
- Starting over an existing Koin context​
- Starting Koin with a Compose App - KoinApplication​
- Compose Preview with KoinApplicationPreview​
- Injecting into a @Composable​
  - Injecting into a @Composable with Parameters​
- ViewModel for @Composable​
  - Shared Activity ViewModel (4.1 - Android)​

This page describe how you can inject your dependencies for your Android Jetpack Compose or your Multiplaform Compose apps.

Since mid-2024, Compose applications can be done with the Koin Multiplatform API. All APIs are identical between Koin Jetpack Compose (koin-androidx-compose) and Koin Compose Multiplatform (koin-compose).

For a pure Android app that uses only the Android Jetpack Compose API, use the following packages:

For an Android/Multiplatform app, use the following packages:

By using the startKoin function previous to your Compose application, your application is ready to welcome Koin injection. Nothing is required anymore to setup your Koin context with Compose.

KoinContext and KoinAndroidContext are deprecated

If you don't have access to a space where you can run the startKoin function, you can relay on Compose and Koin to start your Koin configuration.

The compose function KoinApplication helps to create a Koin application instance, as a Composable:

The KoinApplication function will handle the start and stop of your Koin context, regarding the cycle of the Compose context. This function starts and stops a new Koin application context.

In an Android Application, the KoinApplication will handle any need to stop/restart Koin context regarding configuration changes or drop of Activities.

(Experimental API) You can use the KoinMultiplatformApplication to replace a multiplatform entry point: it's the same as KoinApplication but injects automatically androidContext and androidLogger for you.

The KoinApplicationPreview compose function is dedicated to preview a Composable:

While writing your composable function, you gain access to the following Koin API: koinInject(), to inject instance from Koin container

For a module that declares a 'MyService' component:

We can get your instance like that:

To keep aligned on the functional aspect of Jetpack Compose, the best writing approach is to inject instances directly into functions parameters. This way allow to have default implementation with Koin, but keep open to inject instances how you want.

While you request a new dependency from Koin, you may need to inject parameters. To do this you can use parameters parameter of the koinInject function, with the parametersOf() function like this:

You can use parameters with lambda injection like koinInject<MyService>{ parametersOf("a_string") }, but this can have a performance impact if your recomposing a lot around. This version with lambda needs to unwrap your parameters on call, to help avoid remembering your parameters.

From version 4.0.2 of Koin, koinInject(Qualifier,Scope,ParametersHolder) is introduced to let you use parameters in the most efficient way

The same way you have access to classical single/factory instances, you gain access to the following Koin ViewModel API:

For a module that declares a 'MyViewModel' component:

We can get your instance like that:

We can get your instance in the function parameters:

Lazy API are not supported with updates of Jetpack Compose

You can now use the koinActivityViewModel() to inject a ViewModel from the same ViewModel host: Activity.

You can have a SavedStateHandle constructor parameter, which will be injected regarding the Compose environment (Navigation BackStack or ViewModel). Either it's injected via ViewModel CreationExtras or via Navigation BackStackEntry:

More details about SavedStateHandle injection difference: https://github.com/InsertKoinIO/koin/issues/1935#issuecomment-2362335705

Koin Compose Naviation has now a NavBackEntry.sharedKoinViewModel() function, to allow to retrieve ViewModel already stored in current NavBackEntry. Inside your navigation part, just use sharedKoinViewModel:

Koin offers you a way to load specific modules for a given Composable function. The rememberKoinModules function load Koin modules and remember on current Composable:

You can use one of the abandon function, to unload module on 2 aspects:

For this use unloadOnForgotten or unloadOnAbandoned argument for rememberKoinModules.

The composable function rememberKoinScope and KoinScope allow to handle Koin Scope in a Composable, follow-up current to close scope once Composable is ended.

this API is still unstable for now

**Examples:**

Example 1 (unknown):
```unknown
koin-androidx-compose
```

Example 2 (unknown):
```unknown
koin-androidx-compose-navigation
```

Example 3 (unknown):
```unknown
koin-compose
```

Example 4 (unknown):
```unknown
koin-compose-viewmodel
```

---

## Isolated Context with Compose Applications

**URL:** https://insert-koin.io/docs/reference/koin-compose/isolated-context

**Contents:**
- Isolated Context with Compose Applications
- Define isolated context​
- Setup isolated context with Compose​

With a Compose application, you can work the same way with an isolated context to deal with SDK or white label application, in order to not mix your Koin definitions with an end user's one.

First let's declare our isolated context holder, in order to store our isolated Koin instance in memory. This can be done with a simple Object class like this. The MyIsolatedKoinContext class is holding our Koin instance:

Adapt the MyIsolatedKoinContext class according your need of initialization

Now that you have defined an isolated Koin context, we can seting up it up to Compose to use it and override all the API. Just use the KoinIsolatedContext at the root Compose function. This will propagate your Koin context in all child composables.

All Koin Compose APIs will use your Koi isolated context after the use of KoinIsolatedContext

**Examples:**

Example 1 (unknown):
```unknown
MyIsolatedKoinContext
```

Example 2 (kotlin):
```kotlin
object MyIsolatedKoinContext {    val koinApp = koinApplication {        // declare used modules        modules(sdkAppModule)    }}
```

Example 3 (kotlin):
```kotlin
object MyIsolatedKoinContext {    val koinApp = koinApplication {        // declare used modules        modules(sdkAppModule)    }}
```

Example 4 (unknown):
```unknown
MyIsolatedKoinContext
```

---
