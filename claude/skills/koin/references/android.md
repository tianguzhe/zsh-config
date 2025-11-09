# Koin - Android

**Pages:** 8

---

## Fragment Factory

**URL:** https://insert-koin.io/docs/reference/koin-android/fragment-factory

**Contents:**
- Fragment Factory
- Fragment Factory​
- Setup Fragment Factory​
- Declare & Inject your Fragment​
- Get your Fragment​
- Fragment Factory & Koin Scopes​

Since AndroidX has released androidx.fragment packages family to extend features around Android Fragment

https://developer.android.com/jetpack/androidx/releases/fragment

Since 2.1.0-alpha-3 version, has been introduced the FragmentFactory, a class dedicated to create instance of Fragment class:

https://developer.android.com/reference/kotlin/androidx/fragment/app/FragmentFactory

Koin can bring a KoinFragmentFactory to help you inject your Fragment instances directly.

At start, in your KoinApplication declaration, use the fragmentFactory() keyword to setting up a default KoinFragmentFactory instance:

To declare a Fragment instance, just declare it as a fragment in your Koin module and use constructor injection.

Given a Fragment class:

From your host Activity class, setting up your fragment factory with setupKoinFragmentFactory():

And retrieve your Fragment with your supportFragmentManager:

Put your bundle or tag using the overloaded optional params:

If you want to use the Koin Activity's Scope, you have to declare your fragment inside your scope as a scoped definition:

and setting up your Koin Fragment Factory with your scope: setupKoinFragmentFactory(lifecycleScope)

**Examples:**

Example 1 (unknown):
```unknown
androidx.fragment
```

Example 2 (unknown):
```unknown
2.1.0-alpha-3
```

Example 3 (unknown):
```unknown
FragmentFactory
```

Example 4 (unknown):
```unknown
KoinFragmentFactory
```

---

## Android Instrumented Testing

**URL:** https://insert-koin.io/docs/reference/koin-android/instrumented-testing

**Contents:**
- Android Instrumented Testing
- Override production modules in a custom Application class​
- Override production modules with a test rule​

Unlike unit tests, where you effectively call start Koin in each test class (i.e. startKoin or KoinTestExtension), in Instrumented tests Koin is started by your Application class.

For overriding production Koin modules, loadModules and unloadModules are often unsafe because the changes are not applied immediately. Instead, the recommended approach is to add a module of your overrides to modules used by startKoin in the Application class. If you want to keep the class that extends Application of your application untouched, you can create another one inside the AndroidTest package like:

In order to use this custom Application in yours Instrumentation tests you may need to create a custom AndroidJUnitRunner like:

And then register it inside your gradle file with:

If you want more flexibility, you still have to create the custom AndroidJUnitRunner but instead of having startKoin { ... } inside the custom application, you can put it inside a custom test rule like:

In this way we can potentially override the definitions directly from our test classes, like:

**Examples:**

Example 1 (unknown):
```unknown
KoinTestExtension
```

Example 2 (unknown):
```unknown
Application
```

Example 3 (unknown):
```unknown
loadModules
```

Example 4 (unknown):
```unknown
unloadModules
```

---

## WorkManager

**URL:** https://insert-koin.io/docs/reference/koin-android/workmanager

**Contents:**
- WorkManager
- WorkManager DSL​
- Setup WorkManager​
- Declare ListenableWorker​
  - Creating extra work manager factories​
- A few assumptions​
  - Add manifest changes in koin lib itself​
  - DSL Improvement option:​

The koin-androidx-workmanager project is dedicated to bring Android WorkManager features.

At start, in your KoinApplication declaration, use the workManagerFactory() keyword to a setup custom WorkManager instance:

It's also important that you edit your AndroidManifest.xml to prevent Android initializing its default WorkManagerFactory, as shown in https://developer.android.com/topic/libraries/architecture/workmanager/advanced/custom-configuration#remove-default . Failing to do so will make the app crash.

You can also write a WorkManagerFactory and hand it over to Koin. It will be added as a delegate.

In case both Koin and workFactory1 provided WorkManagerFactory can instantiate a ListenableWorker, the factory provided by Koin will be the one used.

We can make it one step less for application developers if koin-androidx-workmanager's own manifest disables the default work manager. However, it can be confusing since if the app developer don't initialize koin's work manager infrastructure, he'll end up having no usable work manager factories.

That's something that checkModules could help: if any class in the project implements ListenableWorker we inspect both manifest and code and make sure they make sense?

then have koin internals do something like

**Examples:**

Example 1 (unknown):
```unknown
koin-androidx-workmanager
```

Example 2 (unknown):
```unknown
workManagerFactory()
```

Example 3 (kotlin):
```kotlin
class MainApplication : Application(), KoinComponent {    override fun onCreate() {        super.onCreate()        startKoin {            // setup a WorkManager instance            workManagerFactory()            modules(...)        }        setupWorkManagerFactory()}
```

Example 4 (kotlin):
```kotlin
class MainApplication : Application(), KoinComponent {    override fun onCreate() {        super.onCreate()        startKoin {            // setup a WorkManager instance            workManagerFactory()            modules(...)        }        setupWorkManagerFactory()}
```

---

## Injecting in Android

**URL:** https://insert-koin.io/docs/reference/koin-android/get-instances

**Contents:**
- Injecting in Android
- Ready for Android Classes​
- Using the Android Context in a Definition​
- Android Scope & Android Context resolution​

Once you have declared some modules, and you have started Koin, how can you retrieve your instances in your Android Activity Fragments or Services?

Activity, Fragment & Service are extended with the KoinComponents extension. Any ComponentCallbacks class is accessible for the Koin extensions.

You gain access for the Kotlin extensions:

We can declare a property as lazy injected:

Or we can just directly get an instance:

if your class doesn't have extensions, just implement the KoinComponent interface in it to inject() or get() an instance from another class.

Once your Application class configures Koin you can use the androidContext function to inject Android Context so that it can be resolved later when you need it in modules:

In your definitions, The androidContext() & androidApplication() functions allows you to get the Context instance in a Koin module, to help you simply write expression that requires the Application instance.

While you have a scope that is binding the Context type, you may need to resolve the Context but from different level.

To resolve the right type in MyPresenter, use the following:

**Examples:**

Example 1 (unknown):
```unknown
ComponentCallbacks
```

Example 2 (unknown):
```unknown
by inject()
```

Example 3 (kotlin):
```kotlin
module {    // definition of Presenter    factory { Presenter() }}
```

Example 4 (kotlin):
```kotlin
module {    // definition of Presenter    factory { Presenter() }}
```

---

## Android ViewModel & Navigation

**URL:** https://insert-koin.io/docs/reference/koin-android/viewmodel

**Contents:**
- Android ViewModel & Navigation
- Injecting your ViewModel​
- Activity Shared ViewModel​
- Passing Parameters to the Constructor​
- SavedStateHandle Injection (3.3.0)​
- Navigation Graph ViewModel​
- ViewModel Scope API​
- ViewModel Generic API​
- ViewModel API - Java Compat​

The koin-android Gradle module introduces a new viewModel DSL keyword that comes in complement of single and factory, to help declare a ViewModel component and bind it to an Android Component lifecycle. The viewModelOf keyword is also available, to let you declare a ViewModel with its constructor.

Your declared component must at least extends the android.arch.lifecycle.ViewModel class. You can specify how you inject the constructor of the class and use the get() function to inject dependencies.

The viewModel/viewModelOf keyword helps to declare a factory instance of ViewModel. This instance will be handled by internal ViewModelFactory and reattach ViewModel instance if needed. It also will let inject parameters.

To inject a ViewModel in an Activity, Fragment or Service use:

ViewModel key is calculated against Key and/or Qualifier

One ViewModel instance can be shared between Fragments and their host Activity.

To inject a shared ViewModel in a Fragment use:

The sharedViewModel is deprecated in favor of activityViewModel() functions. The naming of this last one is more explicit.

Just declare the ViewModel only once:

Note: a qualifier for a ViewModel will be handled as a ViewModel's Tag

And reuse it in Activity and Fragments:

The viewModel keyword API is compatible with injection parameters.

From the injection call site:

Add a new property typed SavedStateHandle to your constructor to handle your ViewModel state:

In Koin module, just resolve it with get() or with parameters:

or with Constructor DSL:

To inject a state ViewModel in a Activity,Fragment use:

All stateViewModel functions are deprecated. You can just use the regular viewModel function to inject a SavedStateHandle

You can scope a ViewModel instance to your Navigation graph. Just retrieve with by koinNavGraphViewModel(). You just need your graph id.

see all API to be used for ViewModel and Scopes: ViewModel Scope

Koin provides some "under the hood" API to directly tweak your ViewModel instance. The available functions are viewModelForClass for ComponentActivity and Fragment:

This function is still using state: BundleDefinition, but will convert it to CreationExtras

Note that you can have access to the top level function, callable from anywhere:

Java compatibility must be added to your dependencies:

You can inject the ViewModel instance to your Java codebase by using viewModel() or getViewModel() static functions from ViewModelCompat:

**Examples:**

Example 1 (unknown):
```unknown
koin-android
```

Example 2 (unknown):
```unknown
viewModelOf
```

Example 3 (kotlin):
```kotlin
val appModule = module {    // ViewModel for Detail View    viewModel { DetailViewModel(get(), get()) }    // or directly with constructor    viewModelOf(::DetailViewModel)}
```

Example 4 (kotlin):
```kotlin
val appModule = module {    // ViewModel for Detail View    viewModel { DetailViewModel(get(), get()) }    // or directly with constructor    viewModelOf(::DetailViewModel)}
```

---

## Start Koin on Android

**URL:** https://insert-koin.io/docs/reference/koin-android/start

**Contents:**
- Start Koin on Android
- From your Application class​
- Extra Configurations​
  - Koin Logging for Android​
  - Loading Properties​
- Start Koin with Androidx Startup (4.0.1) [Experimental]​
- Startup Dependency with Koin​

The koin-android project is dedicated to provide Koin powers to Android world. See the Android setup section for more details.

From your Application class you can use the startKoin function and inject the Android context with androidContext as follows:

You can also start Koin from anywhere if you don't want to start it from your Application class.

If you need to start Koin from another Android class, you can use the startKoin function and provide your Android Context instance with just like:

From your Koin configuration (in startKoin { } block code), you can also configure several parts of Koin.

Within your KoinApplication instance, we have an extension androidLogger which uses the AndroidLogger() class. This logger is an Android implementation of the Koin logger.

Up to you to change this logger if it doesn't suit to your needs.

You can use Koin properties in the assets/koin.properties file, to store keys/values:

By using Gradle packge koin-androidx-startup, we can use KoinStartup interface to declare your Koin configuration your Application class:

This replaces the startKoin function that is usally used in onCreate. The koinConfiguration function is returning a KoinConfiguration instance.

KoinStartup avoid blocking main thread at for startup time, and offers better performances.

You can make your Initializer depend on KoinInitializer if you need Koin to be setup, and allow to inject dependencies:

**Examples:**

Example 1 (unknown):
```unknown
koin-android
```

Example 2 (unknown):
```unknown
Application
```

Example 3 (unknown):
```unknown
androidContext
```

Example 4 (kotlin):
```kotlin
class MainApplication : Application() {    override fun onCreate() {        super.onCreate()        startKoin {            // Log Koin into Android logger            androidLogger()            // Reference Android context            androidContext(this@MainApplication)            // Load modules            modules(myAppModules)        }    }}
```

---

## Multiple Koin Modules in Android

**URL:** https://insert-koin.io/docs/reference/koin-android/modules-android

**Contents:**
- Multiple Koin Modules in Android
- Using several modules​
- Module Includes (since 3.2)​
- Reducing Startup time with background module loading​

By using Koin, you describe definitions in modules. In this section we will see how to declare, organize & link your modules.

Components don't have to be necessarily in the same module. A module is a logical space to help you organize your definitions, and can depend on definitions from another module. Definitions are lazy, and they are resolved only when a component requests them.

Let's take an example, with linked components in separate modules:

We just have to declare list of used modules when we start our Koin container:

Up to you to organise your self per Gradle module, and gather several Koin modules.

Check Koin Modules Section for more details

A new function includes() is available in the Module class, which lets you compose a module by including other modules in an organized and structured way.

The two prominent use cases of the new feature are:

How does it work? Let's take some modules, and we include modules in parentModule:

Notice we do not need to set up all modules explicitly: by including parentModule, all the modules declared in the includes will be automatically loaded (childModule1 and childModule2). In other words, Koin is effectively loading: parentModule, childModule1 and childModule2.

An important detail to observe is that you can use includes to add internal and private modules too - that gives you flexibility over what to expose in a modularized project.

Module loading is now optimized to flatten all your module graphs and avoid duplicated definitions of modules.

Finally, you can include multiple nested or duplicates modules, and Koin will flatten all the included modules removing duplicates:

Notice that all modules will be included only once: dataModule, domainModule, featureModule1, featureModule2.

You can now declare "lazy" Koin module, to avoid trigger any pre allocation of resources and load them in background with Koin start. This can help avoid to block Android starting process, by passing lazy modules to be loaded in background.

A good example is always better to understand:

**Examples:**

Example 1 (kotlin):
```kotlin
// ComponentB <- ComponentAclass ComponentA()class ComponentB(val componentA : ComponentA)val moduleA = module {    // Singleton ComponentA    single { ComponentA() }}val moduleB = module {    // Singleton ComponentB with linked instance ComponentA    single { ComponentB(get()) }}
```

Example 2 (kotlin):
```kotlin
// ComponentB <- ComponentAclass ComponentA()class ComponentB(val componentA : ComponentA)val moduleA = module {    // Singleton ComponentA    single { ComponentA() }}val moduleB = module {    // Singleton ComponentB with linked instance ComponentA    single { ComponentB(get()) }}
```

Example 3 (kotlin):
```kotlin
class MainApplication : Application() {    override fun onCreate() {        super.onCreate()        startKoin {            // ...            // Load modules            modules(moduleA, moduleB)        }            }}
```

Example 4 (kotlin):
```kotlin
class MainApplication : Application() {    override fun onCreate() {        super.onCreate()        startKoin {            // ...            // Load modules            modules(moduleA, moduleB)        }            }}
```

---

## Android Scopes

**URL:** https://insert-koin.io/docs/reference/koin-android/scope

**Contents:**
- Android Scopes
- Working with the Android lifecycle​
- Scope for Android Components (since 3.2.1)​
  - Declare an Android Scope​
  - Android Scope Classes​
  - Android Scope API​
  - AndroidScopeComponent and handling Scope closing​
  - Scope Archetypes (4.1.0)​
  - ViewModel Scope (updated in 4.1.0)​
- Scope Links​

Android components are mainly managed by their lifecycle: we can't directly instantiate an Activity nor a Fragment. The system make all creation and management for us, and make callbacks on methods: onCreate, onStart...

That's why we can't describe our Activity/Fragment/Service in a Koin module. We need then to inject dependencies into properties and also respect the lifecycle: Components related to the UI parts must be released on soon as we don't need them anymore.

Long live components can be easily described as single definitions. For medium and short live components we can have several approaches.

In the case of MVP architecture style, the Presenter is a short live component to help/support the UI. The presenter must be created each time the screen is showing, and dropped once the screen is gone.

A new Presenter is created each time

We can describe it in a module:

Most of Android memory leaks come from referencing a UI/Android component from a non Android component. The system keeps a reference on it and can't totally drop it via garbage collection.

To scope dependencies on an Android component, you have to declare a scope section with the scope block like follow:

Koin offers ScopeActivity, RetainedScopeActivity and ScopeFragment classes to let you use directly a declared scope for Activity or Fragment:

Under the hood, Android scopes needs to be used with AndroidScopeComponent interface to implement scope field like this:

We need to use the AndroidScopeComponent interface and implement the scope property. This will setting up the default scope used by your class.

To create a Koin scope bound to an Android component, just use the following functions:

Those functions are available as delegate, to implement different kind of scope:

We can also to setting up a retained scope (backed by a ViewModel lifecycle) with the following:

If you don't want to use Android Scope classes, you can work with your own and use AndroidScopeComponent with the Scope creation API

You can run code before Koin Scope is destroyed, by overriding the onCloseScope function from AndroidScopeComponent:

If you try to access Scope from onDestroy() function, the scope will already be closed.

As a new feature, you can now declare scope by archetype: you don't need to define a scope against a specific type, but for an "archetype" (a kind of scope class). You can declare a scope for "Activity", "Fragment", or "ViewModel". You can now use the following DSL sections:

This allows for better reuse of definitions between scopes easily. No need to use a specific type like scope<>{ }, apart from if you need scope on a precise object.

See Android Scope API to see how to use by activityScope(), by activityRetainedScope(), and by fragmentScope() functions to activate your Android scope. Those functions will trigger scope archetypes.

For example, you can easily scope a defintion to an activity like that, with Scope Archetypes:

ViewModel is only created against the root scope to avoid any leaking (leaking Activity or Fragment ...). This guards for the visibility problem, where the ViewModel could have access to incompatible scopes.

:::warn ViewModel can't access to Activity or Fragment scope. Why? Because ViewModel is lasting long than Activity and Fragment, and then it would leak dependencies outside of proper scopes. If you need to bridge a dependency from outside a ViewModel scope, you can use "injected parameters" to pass some objects to your ViewModel: viewModel { p -> } :::

Declare your ViewModel scope as follows, tied to your ViewModel class or using the viewModelScope DSL section:

Once you have declared your ViewModel and your scoped components, you can choose between:

Now just call your ViewModel from your Activity or Fragment:

Scope links allow sharing instances between components with custom scopes. By default, Fragment's scope are linked to parent Activity scope.

In a more extended usage, you can use a Scope instance across components. For example, if we need to share a UserSession instance.

First, declare a scope definition:

When needed to begin use a UserSession instance, create a scope for it:

Then use it anywhere you need it:

**Examples:**

Example 1 (kotlin):
```kotlin
class DetailActivity : AppCompatActivity() {    // injected Presenter    override val presenter : Presenter by inject()
```

Example 2 (kotlin):
```kotlin
class DetailActivity : AppCompatActivity() {    // injected Presenter    override val presenter : Presenter by inject()
```

Example 3 (unknown):
```unknown
by inject()
```

Example 4 (kotlin):
```kotlin
val androidModule = module {    // Factory instance of Presenter    factory { Presenter() }}
```

---
