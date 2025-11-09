# Koin - Getting Started

**Pages:** 14

---

## Android - ViewModel

**URL:** https://insert-koin.io/docs/quickstart/android-viewmodel

**Contents:**
- Android - ViewModel
- Get the code​
- Gradle Setup​
- Application Overview​
- The "User" Data​
- The Koin module​
- Displaying User with ViewModel​
- Injecting ViewModel in Android​
- Start Koin​
- Koin module: classic or constructor DSL?​

This tutorial lets you write an Android application and use Koin dependency injection to retrieve your components. You need around 10 min to do the tutorial.

The source code is available at on Github

Add the Koin Android dependency like below:

The idea of the application is to manage a list of users, and display it in our MainActivity class with a Presenter or a ViewModel:

Users -> UserRepository -> (Presenter or ViewModel) -> MainActivity

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the module function to declare a Koin module. A Koin module is the place where we define all our components to be injected.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl

Let's write a ViewModel component to display a user:

UserRepository is referenced in UserViewModel`s constructor

We declare UserViewModel in our Koin module. We declare it as a viewModelOf definition, to not keep any instance in memory (avoid any leak with Android lifecycle):

The UserViewModel component will be created, resolving the UserRepository instance with it. To get it into our Activity, let's inject it with the by viewModel() delegate function:

That's it, your app is ready.

The by viewModel() function allows us to retrieve a ViewModel instances, create the associated ViewModel Factory for you and bind it to the lifecycle

We need to start Koin with our Android application. Just call the startKoin() function in the application's main entry point, our MainApplication class:

The modules() function in startKoin load the given list of modules

Here is the Koin moduel declaration for our app:

We can write it in a more compact way, by using constructors:

We can ensure that our Koin configuration is good before launching our app, by verifying our Koin configuration with a simple JUnit Test.

Add the Koin Android dependency like below:

The verify() function allow to verify the given Koin modules:

With just a JUnit test, you can ensure your definitions configuration are not missing anything!

**Examples:**

Example 1 (groovy):
```groovy
dependencies {    // Koin for Android    implementation("io.insert-koin:koin-android:$koin_version")}
```

Example 2 (groovy):
```groovy
dependencies {    // Koin for Android    implementation("io.insert-koin:koin-android:$koin_version")}
```

Example 3 (unknown):
```unknown
MainActivity
```

Example 4 (kotlin):
```kotlin
data class User(val name : String)
```

---

## Ktor

**URL:** https://insert-koin.io/docs/quickstart/ktor

**Contents:**
- Ktor
- Get the code​
- Gradle Setup​
- Application Overview​
- The "User" Data​
- The Koin module​
- The UserService Component​
- HTTP Controller​
- Declare your dependencies​
- Start and Inject​

Ktor is a framework for building asynchronous servers and clients in connected systems using the powerful Kotlin programming language. We will use Ktor here, to build a simple web application.

The source code is available at on Github

First, add the Koin dependency like below:

The idea of the application is to manage a list of users, and display it in our UserApplication class:

Users -> UserRepository -> UserService -> UserApplication

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the module function to declare a Koin module. A Koin module is the place where we define all our components to be injected.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl

Let's write the UserService component to request the default user:

UserRepository is referenced in UserPresenter`s constructor

We declare UserService in our Koin module. We declare it as a singleOf definition:

Finally, we need an HTTP Controller to create the HTTP Route. In Ktor is will be expressed through an Ktor extension function:

Check that your application.conf is configured like below, to help start the Application.main function:

Let's assemble our components with a Koin module:

Finally, let's start Koin from Ktor:

That's it! You're ready to go. Check the http://localhost:8080/hello url!

**Examples:**

Example 1 (kotlin):
```kotlin
dependencies {    // Koin for Kotlin apps    implementation("io.insert-koin:koin-ktor:$koin_version")    implementation("io.insert-koin:koin-logger-slf4j:$koin_version")}
```

Example 2 (kotlin):
```kotlin
dependencies {    // Koin for Kotlin apps    implementation("io.insert-koin:koin-ktor:$koin_version")    implementation("io.insert-koin:koin-logger-slf4j:$koin_version")}
```

Example 3 (unknown):
```unknown
UserApplication
```

Example 4 (kotlin):
```kotlin
data class User(val name : String)
```

---

## Kotlin

**URL:** https://insert-koin.io/docs/quickstart/kotlin/

**Contents:**
- Kotlin
- Get the code​
- Setup​
- Application Overview​
- The "User" Data​
- The Koin module​
- The UserService Component​
- Injecting Dependencies in UserApplication​
- Start Koin​
- Koin module: classic or constructor DSL?​

This tutorial lets you write a Kotlin application and use Koin dependency injection to retrieve your components. You need around 10 min to do the tutorial.

The source code is available at on Github

First, check that the koin-core dependency is added like below:

The idea of the application is to manage a list of users, and display it in our UserApplication class:

Users -> UserRepository -> UserService -> UserApplication

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the module function to declare a Koin module. A Koin module is the place where we define all our components to be injected.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl

Let's write the UserService component to request the default user:

UserRepository is referenced in UserPresenter`s constructor

We declare UserService in our Koin module. We declare it as a single definition:

The get() function allow to ask Koin to resolve the needed dependency.

The UserApplication class will help bootstrap instances out of Koin. It will resolve the UserService, thanks to KoinComponent interface. This allows to inject it with the by inject() delegate function:

That's it, your app is ready.

The by inject() function allows us to retrieve Koin instances, in any class that extends KoinComponent

We need to start Koin with our application. Just call the startKoin() function in the application's main entry point, our main function:

The modules() function in startKoin load the given list of modules

Here is the Koin module declaration for our app:

We can write it in a more compact way, by using constructors:

**Examples:**

Example 1 (groovy):
```groovy
dependencies {        // Koin for Kotlin apps    implementation "io.insert-koin:koin-core:$koin_version"}
```

Example 2 (groovy):
```groovy
dependencies {        // Koin for Kotlin apps    implementation "io.insert-koin:koin-core:$koin_version"}
```

Example 3 (unknown):
```unknown
UserApplication
```

Example 4 (kotlin):
```kotlin
data class User(val name : String)
```

---

## Why Koin?

**URL:** https://insert-koin.io/docs/setup/why

**Contents:**
- Why Koin?
- Koin in a nutshell​
  - Making your Kotlin development easy and productive​
  - Ready for Android​
  - Powering Kotlin Multiplatform​
  - Performances and Productivity​
- Koin: A Dependency Injection Framework​
  - Dependency Injection vs. Service Locator​
  - Koin’s Approach: A Blend of Flexibility and Best Practices​
  - Transparency and Design Overview​

Koin provides an easy and efficient way to incorporate dependency injection into any Kotlin application(Multiplatform, Android, backend ...)

The goals of Koin are:

Koin is a smart Kotlin dependency injection library to keep you focused on your app, not on your tools.

Koin gives you simple tools and API to let you build, assemble Kotlin related technologies into your application and let you scale your business with easiness.

Thanks to the Kotlin language, Koin extends the Android platform and provides new features as part of the original platform.

Koin provides easy and powerful API to retrieve your dependencies anywhere in Android components, with just using by inject() or by viewModel()

Sharing code between mobile platforms is one of the major Kotlin Multiplatform use cases. With Kotlin Multiplatform Mobile, you can build cross-platform mobile applications and share common code between Android and iOS.

Koin provides multiplatform dependency injection and help build your components across your native mobile applications, and web/backend applications.

Koin is a pure Kotlin framework, designed to be straight forward in terms of usage and execution. It easy to use and doesn't impact your compilation time, nor require any extra plugin configuration.

Koin is a popular dependency injection (DI) framework for Kotlin, offering a modern and lightweight solution for managing your application’s dependencies with minimal boilerplate code.

While Koin may appear similar to a service locator pattern, there are key differences that set it apart:

Service Locator: A service locator is essentially a registry of available services where you can request an instance of a service as needed. It is responsible for creating and managing these instances, often using a static, global registry.

Dependency Injection: In contrast, Koin is a pure dependency injection framework. With Koin, you declare your dependencies in modules, and Koin handles the creation and wiring of objects. It allows for the creation of multiple, independent modules with their own scopes, making dependency management more modular and avoiding potential conflicts.

Koin supports both DI and the Service Locator pattern, offering flexibility to developers. However, it strongly encourages the use of DI, particularly constructor injection, where dependencies are passed as constructor parameters. This approach promotes better testability and makes your code easier to reason about.

Koin’s design philosophy is centered around simplicity and ease of setup while allowing for complex configurations when necessary. By using Koin, developers can manage dependencies effectively, with DI being the recommended and preferred approach for most scenarios.

Koin is designed to be a versatile Inversion of Control (IoC) container that supports both Dependency Injection (DI) and Service Locator (SL) patterns. To provide a clear understanding of how Koin operates and to guide you in using it effectively, let’s explore the following aspects:

Koin combines elements of both DI and SL, which may influence how you use the framework:

Global Context Usage: By default, Koin provides a globally accessible component that acts like a service locator. This allows you to retrieve dependencies from a central registry using KoinComponent or inject functions.

Isolated Components: Although Koin encourages the use of Dependency Injection, particularly constructor injection, it also allows for isolated components. This flexibility means you can configure your application to use DI where it makes the most sense while still taking advantage of SL for specific cases.

SL in Android Components: In Android development, Koin often uses SL internally within components such as Application and Activity for ease of setup. From this point, Koin recommends DI, especially constructor injection, to manage dependencies in a more structured way. However, this is not enforced, and developers have the flexibility to use SL if needed.

Understanding the distinction between DI and SL helps in managing your application’s dependencies effectively:

Dependency Injection: Encouraged by Koin for its benefits in testability and maintainability. Constructor injection is preferred as it makes dependencies explicit and enhances code clarity.

Service Locator: While Koin supports SL for convenience, especially in Android components, relying solely on SL can lead to tighter coupling and reduced testability. Koin’s design provides a balanced approach, allowing you to use SL where it’s practical but promoting DI as the best practice.

To use Koin effectively:

Follow Best Practices: Use constructor injection where possible to align with best practices for dependency management. This approach improves testability and maintainability.

Leverage Koin’s Flexibility: Utilize Koin’s support for SL in scenarios where it simplifies setup, but aim to rely on DI for managing core application dependencies.

Refer to Documentation and Examples: Review Koin’s documentation and examples to understand how to configure and use DI and SL appropriately based on your project needs.

Visualize Dependency Management: Diagrams and examples can help illustrate how Koin resolves dependencies and manages them within different contexts. These visual aids can provide a clearer understanding of Koin’s internal workings.

By providing this guidance, we aim to help you navigate Koin’s features and design choices effectively, ensuring you can leverage its full potential while adhering to best practices in dependency management.

**Examples:**

Example 1 (kotlin):
```kotlin
class MyRepository()class MyPresenter(val repository : MyRepository) // just declare it val myModule = module {   singleOf(::MyPresenter)  singleOf(::MyRepository)}
```

Example 2 (kotlin):
```kotlin
class MyRepository()class MyPresenter(val repository : MyRepository) // just declare it val myModule = module {   singleOf(::MyPresenter)  singleOf(::MyRepository)}
```

Example 3 (kotlin):
```kotlin
fun main() {     // Just start Koin  startKoin {    modules(myModule)  }}
```

Example 4 (kotlin):
```kotlin
fun main() {     // Just start Koin  startKoin {    modules(myModule)  }}
```

---

## Ktor & Annotations

**URL:** https://insert-koin.io/docs/quickstart/ktor-annotations

**Contents:**
- Ktor & Annotations
- Get the code​
- Gradle Setup​
- Application Overview​
- The "User" Data​
- The Koin module​
- The UserService Component​
- HTTP Controller​
- Start and Inject​

Ktor is a framework for building asynchronous servers and clients in connected systems using the powerful Kotlin programming language. We will use Ktor here, to build a simple web application.

The source code is available at on Github

First, add the Koin dependency like below:

The idea of the application is to manage a list of users, and display it in our UserApplication class:

Users -> UserRepository -> UserService -> UserApplication

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the @Module annotation to declare a Koin module, from a given Kotlin class. A Koin module is the place where we define all our components to be injected.

The @ComponentScan("org.koin.sample") will help scan annotated classes from targeted package.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl. We tag it @Single

Let's write the UserService component to request the default user:

UserRepository is referenced in UserPresenter`s constructor

We declare UserService in our Koin module. We tag with @Single annotation:

Finally, we need an HTTP Controller to create the HTTP Route. In Ktor is will be expressed through an Ktor extension function:

Check that your application.conf is configured like below, to help start the Application.main function:

Finally, let's start Koin from Ktor:

By writing the AppModule().module we use a generated extension on AppModule class.

That's it! You're ready to go. Check the http://localhost:8080/hello url!

**Examples:**

Example 1 (kotlin):
```kotlin
plugins {    id("com.google.devtools.ksp") version kspVersion}dependencies {    // Koin for Kotlin apps    implementation("io.insert-koin:koin-ktor:$koin_version")    implementation("io.insert-koin:koin-logger-slf4j:$koin_version")    implementation("io.insert-koin:koin-annotations:$koinAnnotationsVersion")    ksp("io.insert-koin:koin-ksp-compiler:$koinAnnotationsVersion")}
```

Example 2 (kotlin):
```kotlin
plugins {    id("com.google.devtools.ksp") version kspVersion}dependencies {    // Koin for Kotlin apps    implementation("io.insert-koin:koin-ktor:$koin_version")    implementation("io.insert-koin:koin-logger-slf4j:$koin_version")    implementation("io.insert-koin:koin-annotations:$koinAnnotationsVersion")    ksp("io.insert-koin:koin-ksp-compiler:$koinAnnotationsVersion")}
```

Example 3 (unknown):
```unknown
UserApplication
```

Example 4 (kotlin):
```kotlin
data class User(val name : String)
```

---

## Kotlin Multiplatform - No shared UI

**URL:** https://insert-koin.io/docs/quickstart/kmp

**Contents:**
- Kotlin Multiplatform - No shared UI
- Get the code​
- Application Overview​
- The "User" Data​
- The Shared Koin module​
- The Shared Presenter​
- Native Component​
- Injecting in Android​
- Injecting in iOS​

This tutorial lets you write an Android application and use Koin dependency injection to retrieve your components. You need around 15 min to do the tutorial.

The source code is available at on Github

The idea of the application is to manage a list of users, and display it in our native UI, witha shared Presenter:

Users -> UserRepository -> Shared Presenter -> Native UI

All the common/shared code is located in shared Gradle project

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the module function to declare a Koin module. A Koin module is the place where we define all our components to be injected.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl

Let's write a presenter component to display a user:

UserRepository is referenced in UserPresenter`s constructor

We declare UserPresenter in our Koin module. We declare it as a factoryOf definition, to not keep any instance in memory and let the native system hold it:

The Koin module is available as function to run (appModule here), to be easily runned from iOS side, with initKoin() function.

The following native component is defined in Android and iOS:

Both get local platform implementation

All the Android app is located in androidApp Gradle project

The UserPresenter component will be created, resolving the UserRepository instance with it. To get it into our Activity, let's inject it with the koinInject compose function:

That's it, your app is ready.

The koinInject() function allows us to retrieve Koin instances, in Android Compose runtime

We need to start Koin with our Android application. Just call the KoinApplication() function in the compose application function App:

We gather Koin android configuration, from the shared KMP configuration:

We get the current Android context from Compose with LocalContext.current

And the shared KMP config:

The modules() function load the given list of modules

All the iOS app is located in iosApp folder

The UserPresenter component will be created, resolving the UserRepository instance with it. To get it into our ContentView, we need to create a function to retrieve Koin dependencies for iOS:

That's it, you can just call KoinKt.getUserPresenter().sayHello() function from iOS part.

We need to start Koin with our iOS application. In the Kotlin shared code, we can use the shared configuration with initKoin() function. Finally in the iOS main entry, we can call the KoinAppKt.doInitKoin() function that is calling our helper function above.

**Examples:**

Example 1 (unknown):
```unknown
Users -> UserRepository -> Shared Presenter -> Native UI
```

Example 2 (kotlin):
```kotlin
data class User(val name : String)
```

Example 3 (kotlin):
```kotlin
data class User(val name : String)
```

Example 4 (unknown):
```unknown
UserRepository
```

---

## Koin Annotations

**URL:** https://insert-koin.io/docs/setup/annotations

**Contents:**
- Koin Annotations
- Current Versions​
- KSP Plugin​
- Android & Ktor App KSP Setup​
- Kotlin Multiplatform Setup​

Setup Koin Annotations for your project

You can find all Koin packages on maven central.

Here are the currently available Koin Annotations versions:

We need the KSP Plugin to work (https://github.com/google/ksp). Follow the official KSP Setup documentation.

Just add the Gradle plugin:

KSP Compatibility: Latest Koin/KSP compatible version is 2.1.21-2.0.2 (KSP2)

KSP version format: [Kotlin version]-[KSP version]. Make sure your KSP version is compatible with your Kotlin version.

In a standard Kotlin/Kotlin Multiplatform project, you need to setup KSP as follow:

**Examples:**

Example 1 (kotlin):
```kotlin
plugins {    id("com.google.devtools.ksp") version "$ksp_version"}
```

Example 2 (kotlin):
```kotlin
plugins {    id("com.google.devtools.ksp") version "$ksp_version"}
```

Example 3 (unknown):
```unknown
2.1.21-2.0.2
```

Example 4 (unknown):
```unknown
[Kotlin version]-[KSP version]
```

---

## What is Koin?

**URL:** https://insert-koin.io/docs/reference/introduction

**Contents:**
- What is Koin?

Koin is a pragmatic and lightweight dependency injection framework for Kotlin developers.

Koin is a DSL, a light container and a pragmatic API

**Examples:**

Example 1 (unknown):
```unknown
Koin is a DSL, a light container and a pragmatic API
```

---

## Kotlin

**URL:** https://insert-koin.io/docs/quickstart/kotlin

**Contents:**
- Kotlin
- Get the code​
- Setup​
- Application Overview​
- The "User" Data​
- The Koin module​
- The UserService Component​
- Injecting Dependencies in UserApplication​
- Start Koin​
- Koin module: classic or constructor DSL?​

This tutorial lets you write a Kotlin application and use Koin dependency injection to retrieve your components. You need around 10 min to do the tutorial.

The source code is available at on Github

First, check that the koin-core dependency is added like below:

The idea of the application is to manage a list of users, and display it in our UserApplication class:

Users -> UserRepository -> UserService -> UserApplication

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the module function to declare a Koin module. A Koin module is the place where we define all our components to be injected.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl

Let's write the UserService component to request the default user:

UserRepository is referenced in UserPresenter`s constructor

We declare UserService in our Koin module. We declare it as a single definition:

The get() function allow to ask Koin to resolve the needed dependency.

The UserApplication class will help bootstrap instances out of Koin. It will resolve the UserService, thanks to KoinComponent interface. This allows to inject it with the by inject() delegate function:

That's it, your app is ready.

The by inject() function allows us to retrieve Koin instances, in any class that extends KoinComponent

We need to start Koin with our application. Just call the startKoin() function in the application's main entry point, our main function:

The modules() function in startKoin load the given list of modules

Here is the Koin module declaration for our app:

We can write it in a more compact way, by using constructors:

**Examples:**

Example 1 (groovy):
```groovy
dependencies {        // Koin for Kotlin apps    implementation "io.insert-koin:koin-core:$koin_version"}
```

Example 2 (groovy):
```groovy
dependencies {        // Koin for Kotlin apps    implementation "io.insert-koin:koin-core:$koin_version"}
```

Example 3 (unknown):
```unknown
UserApplication
```

Example 4 (kotlin):
```kotlin
data class User(val name : String)
```

---

## Android & Annotations

**URL:** https://insert-koin.io/docs/quickstart/android-annotations

**Contents:**
- Android & Annotations
- Get the code​
- Gradle Setup​
- Application Overview​
- The "User" Data​
- The Koin module​
- Displaying User with Presenter​
- Injecting Dependencies in Android​
- Start Koin​
- Displaying User with ViewModel​

This tutorial lets you write an Android application and use Koin dependency injection to retrieve your components. You need around 10 min to do the tutorial.

The source code is available at on Github

Let's configure the KSP Plugin like this, and the following dependencies:

See libs.versions.toml for current versions

The idea of the application is to manage a list of users, and display it in our MainActivity class with a Presenter or a ViewModel:

Users -> UserRepository -> (Presenter or ViewModel) -> MainActivity

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Let's declare a AppModule module class like below.

Let's simply add @Single on UserRepositoryImpl class to declare it as singleton:

Let's write a presenter component to display a user:

UserRepository is referenced in UserPresenter`s constructor

We declare UserPresenter in our Koin module. We declare it as a factory definition with the @Factory annotation, to not keep any instance in memory (avoid any leak with Android lifecycle):

The UserPresenter component will be created, resolving the UserRepository instance with it. To get it into our Activity, let's inject it with the by inject() delegate function:

That's it, your app is ready.

The by inject() function allows us to retrieve Koin instances, in Android components runtime (Activity, fragment, Service...)

We need to start Koin with our Android application. Just call the startKoin() function in the application's main entry point, our MainApplication class:

The Koin module is generated from AppModule with the .module extension: Just use the AppModule().module expression to get the Koin module from the annotations.

The import org.koin.ksp.generated.* import is required to allow to use generated Koin module content

Let's write a ViewModel component to display a user:

UserRepository is referenced in UserViewModel`s constructor

The UserViewModel is tagged with @KoinViewModel annotation to declare the Koin ViewModel definition, to not keep any instance in memory (avoid any leak with Android lifecycle).

The UserViewModel component will be created, resolving the UserRepository instance with it. To get it into our Activity, let's inject it with the by viewModel() delegate function:

Koin Annotations allows to check your Koin configuration at compile time. This is available by jusing the following Gradle option:

We can ensure that our Koin configuration is good before launching our app, by verifying our Koin configuration with a simple JUnit Test.

Add the Koin Android dependency like below:

The androidVerify() function allow to verify the given Koin modules:

With just a JUnit test, you can ensure your definitions configuration are not missing anything!

**Examples:**

Example 1 (groovy):
```groovy
plugins {    alias(libs.plugins.ksp)}dependencies {    // ...    implementation(libs.koin.annotations)    ksp(libs.koin.ksp)}// Compile time checkksp {    arg("KOIN_CONFIG_CHECK","true")}
```

Example 2 (groovy):
```groovy
plugins {    alias(libs.plugins.ksp)}dependencies {    // ...    implementation(libs.koin.annotations)    ksp(libs.koin.ksp)}// Compile time checkksp {    arg("KOIN_CONFIG_CHECK","true")}
```

Example 3 (unknown):
```unknown
libs.versions.toml
```

Example 4 (unknown):
```unknown
MainActivity
```

---

## Koin

**URL:** https://insert-koin.io/docs/setup/koin

**Contents:**
- Koin
- Current Versions​
- Gradle Setup​
  - Kotlin​
  - Android​
  - Jetpack Compose or Compose Multiplatform​
  - Kotlin Multiplatform​
  - Ktor​
  - Koin BOM​

All you need to setting up Koin in your project

You can find all Koin packages on Maven Central.

Here are the currently available Koin versions:

Starting from 3.5.0 you can use BOM-version to manage all Koin library versions. When using the BOM in your app, you don't need to add any version to the Koin library dependencies themselves. When you update the BOM version, all the libraries that you're using are automatically updated to their new versions.

Add koin-bom BOM and koin-core dependency to your application:

If you are using version catalogs:

Or use an old way of specifying the exact dependency version for Koin:

You are now ready to start Koin:

If you need testing capacity:

From now you can continue on Koin Tutorials to learn about using Koin: Kotlin App Tutorial

Add koin-android dependency to your Android application:

You are now ready to start Koin in your Application class:

If you need extra features, add the following needed package:

From now you can continue on Koin Tutorials to learn about using Koin: Android App Tutorial

Add koin-compose dependency to your multiplatform application, for use Koin & Compose API:

If you are using pure Android Jetpack Compose, you can go with

Add koin-core dependency to your multiplatform application, for shared Kotlin part:

From now you can continue on Koin Tutorials to learn about using Koin: Kotlin Multiplatform App Tutorial

Add koin-ktor dependency to your Ktor application:

You are now ready to install Koin feature into your Ktor application:

From now you can continue on Koin Tutorials to learn about using Koin: Ktor App Tutorial

The Koin Bill of Materials (BOM) lets you manage all of your Koin library versions by specifying only the BOM’s version. The BOM itself has links to the stable versions of the different Koin libraries, in such a way that they work well together. When using the BOM in your app, you don't need to add any version to the Koin library dependencies themselves. When you update the BOM version, all the libraries that you're using are automatically updated to their new versions.

**Examples:**

Example 1 (kotlin):
```kotlin
implementation(project.dependencies.platform("io.insert-koin:koin-bom:$koin_version"))implementation("io.insert-koin:koin-core")
```

Example 2 (kotlin):
```kotlin
implementation(project.dependencies.platform("io.insert-koin:koin-bom:$koin_version"))implementation("io.insert-koin:koin-core")
```

Example 3 (toml):
```toml
[versions]koin-bom = "x.x.x"...[libraries]koin-bom = { module = "io.insert-koin:koin-bom", version.ref = "koin-bom" }koin-core = { module = "io.insert-koin:koin-core" }...
```

Example 4 (toml):
```toml
[versions]koin-bom = "x.x.x"...[libraries]koin-bom = { module = "io.insert-koin:koin-bom", version.ref = "koin-bom" }koin-core = { module = "io.insert-koin:koin-core" }...
```

---

## Android - Jetpack Compose

**URL:** https://insert-koin.io/docs/quickstart/android-compose

**Contents:**
- Android - Jetpack Compose
- Get the code​
- Gradle Setup​
- Application Overview​
- The "User" Data​
- The Koin module​
- Displaying User with UserViewModel​
  - The UserViewModel class​
  - Injecting ViewModel in Compose​
- Displaying User with UserStateHolder​

This tutorial lets you write an Android application and use Koin dependency injection to retrieve your components. You need around 10 min to do the tutorial.

The source code is available at on Github

Add the Koin Android dependency like below:

The idea of the application is to manage a list of users, and display it in our MainActivity class with a Presenter or a ViewModel:

Users -> UserRepository -> (Presenter or ViewModel) -> Composable

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the module function to declare a Koin module. A Koin module is the place where we define all our components to be injected.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl

Let's write a ViewModel component to display a user:

UserRepository is referenced in UserViewModel's constructor

We declare UserViewModel in our Koin module. We declare it as a viewModelOf definition, to not keep any instance in memory (avoid any leak with Android lifecycle):

The get() function allow to ask Koin to resolve the needed dependency.

The UserViewModel component will be created, resolving the UserRepository instance with it. To get it into our Activity, let's inject it with the koinViewModel() function:

The koinViewModel function allows us to retrieve a ViewModel instances, create the associated ViewModel Factory for you and bind it to the lifecycle

Let's write a State holder component to display a user:

UserRepository is referenced in UserViewModel's constructor

We declare UserStateHolder in our Koin module. We declare it as a factoryOf definition, to not keep any instance in memory (avoid any leak with Android lifecycle):

The UserStateHolder component will be created, resolving the UserRepository instance with it. To get it into our Activity, let's inject it with the koinInject() function:

The koinInject function allows us to retrieve a ViewModel instances, create the associated ViewModel Factory for you and bind it to the lifecycle

We need to start Koin with our Android application. Just call the startKoin() function in the application's main entry point, our MainApplication class:

The modules() function in startKoin load the given list of modules

While starting the Compose application we need to link Koin to our current Compose application, with KoinAndroidContext:

Here is the Koin moduel declaration for our app:

We can write it in a more compact way, by using constructors:

We can ensure that our Koin configuration is good before launching our app, by verifying our Koin configuration with a simple JUnit Test.

Add the Koin Android dependency like below:

The verify() function allow to verify the given Koin modules:

With just a JUnit test, you can ensure your definitions configuration are not missing anything!

**Examples:**

Example 1 (groovy):
```groovy
dependencies {    // Koin for Android    implementation "io.insert-koin:koin-androidx-compose:$koin_version"}
```

Example 2 (groovy):
```groovy
dependencies {    // Koin for Android    implementation "io.insert-koin:koin-androidx-compose:$koin_version"}
```

Example 3 (unknown):
```unknown
MainActivity
```

Example 4 (kotlin):
```kotlin
data class User(val name : String)
```

---

## Compose Multiplatform - Shared UI

**URL:** https://insert-koin.io/docs/quickstart/cmp

**Contents:**
- Compose Multiplatform - Shared UI
- Get the code​
- Application Overview​
- The "User" Data​
- The Shared Koin module​
- The Shared ViewModel​
- Native Component​
- Injecting in Compose​
- Compose app in iOS​

This tutorial lets you write an Android application and use Koin dependency injection to retrieve your components. You need around 15 min to do the tutorial.

The source code is available at on Github

The idea of the application is to manage a list of users, and display it in our native UI, witha shared ViewModel:

Users -> UserRepository -> Shared Presenter -> Compose UI

All the common/shared code is located in shared Gradle project

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the module function to declare a Koin module. A Koin module is the place where we define all our components to be injected.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl

Let's write a ViewModel component to display a user:

UserRepository is referenced in UserPresenter`s constructor

We declare UserViewModel in our Koin module. We declare it as a viewModelOf definition, to not keep any instance in memory and let the native system hold it:

The Koin module is available as function to run (appModule here), to be easily runned from iOS side, with initKoin() function.

The following native component is defined in Android and iOS:

Both get local platform implementation

All the Common Compose app is located in commonMain from composeApp Gradle module:

The UserViewModel component will be created, resolving the UserRepository instance with it. To get it into our Activity, let's inject it with the koinViewModel or koinNavViewModel compose function:

That's it, your app is ready.

We need to start Koin with our Android application. Just call the KoinApplication() function in the compose application function App:

The modules() function load the given list of modules

All the iOS app is located in iosMain folder

The MainViewController.kt is ready to start Compose for iOS:

**Examples:**

Example 1 (unknown):
```unknown
Users -> UserRepository -> Shared Presenter -> Compose UI
```

Example 2 (kotlin):
```kotlin
data class User(val name : String)
```

Example 3 (kotlin):
```kotlin
data class User(val name : String)
```

Example 4 (unknown):
```unknown
UserRepository
```

---

## Android

**URL:** https://insert-koin.io/docs/quickstart/android

**Contents:**
- Android
- Get the code​
- Gradle Setup​
- Application Overview​
- The "User" Data​
- The Koin module​
- Displaying User with Presenter​
- Injecting Dependencies in Android​
- Start Koin​
- Koin module: classic or constructor DSL?​

This tutorial lets you write an Android application and use Koin dependency injection to retrieve your components. You need around 10 min to do the tutorial.

The source code is available at on Github

Add the Koin Android dependency like below:

The idea of the application is to manage a list of users, and display it in our MainActivity class with a Presenter or a ViewModel:

Users -> UserRepository -> (Presenter or ViewModel) -> MainActivity

We will manage a collection of Users. Here is the data class:

We create a "Repository" component to manage the list of users (add users or find one by name). Here below, the UserRepository interface and its implementation:

Use the module function to declare a Koin module. A Koin module is the place where we define all our components to be injected.

Let's declare our first component. We want a singleton of UserRepository, by creating an instance of UserRepositoryImpl

Let's write a presenter component to display a user:

UserRepository is referenced in UserPresenter`s constructor

We declare UserPresenter in our Koin module. We declare it as a factoryOf definition, to not keep any instance in memory (avoid any leak with Android lifecycle):

The get() function allow to ask Koin to resolve the needed dependency.

The UserPresenter component will be created, resolving the UserRepository instance with it. To get it into our Activity, let's inject it with the by inject() delegate function:

That's it, your app is ready.

The by inject() function allows us to retrieve Koin instances, in Android components runtime (Activity, fragment, Service...)

We need to start Koin with our Android application. Just call the startKoin() function in the application's main entry point, our MainApplication class:

The modules() function in startKoin load the given list of modules

Here is the Koin module declaration for our app:

We can write it in a more compact way, by using constructors:

We can ensure that our Koin configuration is good before launching our app, by verifying our Koin configuration with a simple JUnit Test.

Add the Koin Android dependency like below:

The verify() function allow to verify the given Koin modules:

With just a JUnit test, you can ensure your definitions configuration are not missing anything!

**Examples:**

Example 1 (groovy):
```groovy
dependencies {    // Koin for Android    implementation("io.insert-koin:koin-android:$koin_version")}
```

Example 2 (groovy):
```groovy
dependencies {    // Koin for Android    implementation("io.insert-koin:koin-android:$koin_version")}
```

Example 3 (unknown):
```unknown
MainActivity
```

Example 4 (kotlin):
```kotlin
data class User(val name : String)
```

---
