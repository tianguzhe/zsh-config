# Koin - Core Concepts

**Pages:** 19

---

## Koin Annotations Inventory

**URL:** https://insert-koin.io/docs/reference/koin-annotations/annotations-inventory

**Contents:**
- Koin Annotations Inventory
- Table of Contents​
- Definition Annotations​
  - @Single​
  - @Factory​
  - @Scoped​
- Scope Annotations​
  - @Scope​
  - @ViewModelScope​
  - @ActivityScope​

This document provides a comprehensive inventory of all Koin annotations, their parameters, behaviors, and usage examples.

Package: org.koin.core.annotation

Target: CLASS, FUNCTION

Description: Declares a type or function as a single (singleton) definition in Koin. A single instance is created and shared across the application.

Behavior: All dependencies are filled by constructor injection.

With explicit binding:

With creation at start:

Package: org.koin.core.annotation

Target: CLASS, FUNCTION

Description: Declares a type or function as a factory definition in Koin. A new instance is created each time it is requested.

Behavior: All dependencies are filled by constructor injection. Each request creates a new instance.

Package: org.koin.core.annotation

Target: CLASS, FUNCTION

Description: Declares a type or function as a scoped definition in Koin. Must be associated with @Scope annotation. Instance is shared within a specific scope.

Behavior: Creates a scoped instance that lives within the defined scope's lifetime.

Package: org.koin.core.annotation

Target: CLASS, FUNCTION

Description: Declares a class in a Koin scope. Scope name is described by either value (class) or name (string). By default, declares a scoped definition. Can be overridden with @Scoped, @Factory, @KoinViewModel annotations for explicit bindings.

Behavior: Creates a scope definition associated with the specified scope type or name.

Example with string name:

Package: org.koin.core.annotation

Target: CLASS, FUNCTION

Description: Declares a class in a ViewModelScope Koin scope. This is a scope archetype for components that should live within a ViewModel's lifecycle.

Behavior: Creates a scoped definition within the viewModelScope.

Usage: The tagged class is meant to be used with ViewModel and viewModelScope function to activate the scope.

Package: org.koin.android.annotation

Target: CLASS, FUNCTION

Description: Declares a class in an Activity Koin Scope.

Behavior: Creates a scoped definition within the activityScope.

Usage: The tagged class is meant to be used with Activity and activityScope function to activate the scope.

Package: org.koin.android.annotation

Target: CLASS, FUNCTION

Description: Declares a class in an Activity Koin scope, but retained across configuration changes.

Behavior: Creates a scoped definition within the activityRetainedScope.

Usage: The tagged class is meant to be used with Activity and activityRetainedScope function to activate the scope.

Package: org.koin.android.annotation

Target: CLASS, FUNCTION

Description: Declares a class in a Fragment Koin scope.

Behavior: Creates a scoped definition within the fragmentScope.

Usage: The tagged class is meant to be used with Fragment and fragmentScope function to activate the scope.

Package: org.koin.core.annotation

Target: VALUE_PARAMETER

Description: Annotates a parameter from class constructor or function to request resolution for a given scope with Scope ID.

Behavior: Resolves the dependency from a specific scope identified by type or name.

Example with string name:

Package: org.koin.android.annotation

Target: CLASS, FUNCTION

Description: ViewModel annotation for Koin definition. Declares a type or function as a viewModel definition in Koin.

Behavior: All dependencies are filled by constructor injection. Creates a ViewModel instance managed by Koin. Works across all platforms including Android, iOS, Desktop, and Web when using Compose Multiplatform.

Example (Android/CMP):

Example (KMP/CMP shared):

Package: org.koin.android.annotation

Target: CLASS, FUNCTION

Description: Worker annotation for Koin Definition. Declares a type as a worker definition for WorkManager workers.

Behavior: Creates a worker definition for Android WorkManager integration.

Package: org.koin.core.annotation

Target: CLASS, FUNCTION, VALUE_PARAMETER

Description: Defines a qualifier for a given definition. Generates StringQualifier("...") or type-based qualifier.

Behavior: Used to distinguish between multiple definitions of the same type.

Package: org.koin.core.annotation

Target: CLASS, FUNCTION, VALUE_PARAMETER

Description: Defines a qualifier for a given definition. Similar to @Named but with reversed parameter priority.

Behavior: Used to distinguish between multiple definitions of the same type.

Package: org.koin.core.annotation

Target: VALUE_PARAMETER

Description: Annotates a constructor parameter or function parameter to resolve as a Koin property.

Behavior: Resolves the parameter value from Koin properties instead of dependency injection.

Package: org.koin.core.annotation

Description: Annotates a field value that will be a Property default value.

Behavior: Defines a default value for a property that can be used when the property is not found.

Package: org.koin.core.annotation

Description: Class annotation to help gather definitions inside a Koin module. Each function can be annotated with a Koin definition annotation.

Behavior: Gathers all annotated functions and classes within the module.

Package: org.koin.core.annotation

Description: Gathers definitions declared with Koin definition annotations. Scans current package or explicit package names.

Behavior: Scans specified packages for annotated classes. Supports both exact package names and glob patterns.

Glob Pattern Support:

Exact package names (no wildcards):

Multi-level scan including root:

Multi-level scan excluding root:

Single-level wildcard:

Example - scan current package:

Example - scan specific packages:

Example - with glob patterns:

Package: org.koin.core.annotation

Description: Applied to @Module class to associate it with one or more configurations (tags/flavors).

Behavior: Modules can be grouped into configurations for conditional loading.

Default Configuration:

This module is part of the "default" configuration.

Multiple Configurations:

This module is available in both "prod" and "test" configurations.

Available in default and test configurations.

Note: @Configuration("default") is equivalent to @Configuration

Package: org.koin.core.annotation

Description: Tags a class as a Koin application entry point. Generates Koin application bootstrap with startKoin() or koinApplication() functions.

Behavior: Generates bootstrap functions that scan for configurations and included modules.

Example - default configuration:

Example - specific configurations:

Example - with modules:

Usage with custom configuration:

Package: org.koin.core.annotation

Target: CLASS, FUNCTION

Description: Marks a class or function for automatic monitoring and performance tracing through Kotzilla Platform, the official tooling platform for Koin.

Since: Kotzilla 1.2.1

These annotations are for internal use only by the Koin compiler and code generation.

Package: org.koin.meta.annotations

Target: CLASS, FIELD, FUNCTION

Description: Internal usage for components discovery in generated package.

Package: org.koin.meta.annotations

Target: CLASS, FUNCTION, PROPERTY

Description: Meta Definition annotation to help represent definition metadata.

Package: org.koin.meta.annotations

Description: Meta Module annotation to help represent module metadata.

Package: org.koin.meta.annotations

Description: Meta Application annotation to help represent application metadata.

Package: org.koin.core.annotation

Status: DEPRECATED - ERROR level

Replacement: Use @Singleton from koin-jsr330 package instead

Description: Same as @Single but deprecated in favor of JSR-330 compliance.

Document Version: 1.0 Last Updated: 20-10-2025 Koin Annotations Version: 2.2.x+

**Examples:**

Example 1 (unknown):
```unknown
org.koin.core.annotation
```

Example 2 (unknown):
```unknown
binds: Array<KClass<*>> = [Unit::class]
```

Example 3 (unknown):
```unknown
createdAtStart: Boolean = false
```

Example 4 (kotlin):
```kotlin
@Singleclass MyClass(val d : MyDependency)
```

---

## Starting with Koin Annotations

**URL:** https://insert-koin.io/docs/reference/koin-annotations/start

**Contents:**
- Starting with Koin Annotations
- Getting Started​
  - Basic Module Setup​
  - Configuration-based Module Setup​
- KSP Options​
  - Compile Safety - check your Koin config at compile time (since 1.3.0)​
  - Bypass Compile Safety with @Provided (since 1.4.0)​
  - Default Module (Deprecated since 1.3.0)​
  - Kotlin KMP Setup​
  - Pro-Guard​

The goal of the Koin Annotations project is to help declare Koin definitions in a fast and intuitive way, and generate all underlying Koin DSL for you. The goal is to help developers experience scaling and go fast 🚀, thanks to Kotlin Compilers.

Not familiar with Koin? First, take a look at Koin Getting Started

Tag your components with definition & module annotations, and use the regular Koin API.

Now you can start your Koin application with @KoinApplication and explicitly specify the modules to use:

Alternatively, you can use @Configuration to create modules that are automatically loaded:

With configuration, you don't need to specify modules explicitly:

That's it, you can use your new definitions in Koin with the regular Koin API

The Koin compiler offers some options to configure. Following the official doc, you can add the following options to your project: Ksp Quickstart Doc

Koin Annotations allows the compiler plugin to verify your Koin configuration at compile time. This can be activated with the following Ksp options, to add to your Gradle module:

The compiler will check that all dependencies used in your configuration are declared, and all used modules are accessible.

Among the ignored types from the Compiler (Android common types), the compiler plugin can verify your Koin configuration at compile time. If you want to exclude a parameter from being checked, you can use @Provided on a parameter to indicate that this type is provided externally to the current Koin Annotations config.

The following indicates that MyProvidedComponent is already declared in Koin:

The default module approach is deprecated since Annotations 1.3.0. We recommend using explicit modules with @Module and @Configuration annotations for better organization and clarity.

Previously, the Koin compiler would detect any definition not bound to a module and put it in a "default module". This approach is now deprecated in favor of using @Configuration and @KoinApplication annotations.

Deprecated approach (avoid using):

Recommended approach: Use explicit module organization as shown in the examples above with @Configuration and @KoinApplication.

Please follow the KSP setup as described in the official documentation: KSP with Kotlin Multiplatform

You can also check the Hello Koin KMP project with a basic setup for Koin Annotations.

If you intend to embed the Koin Annotations application as an SDK, take a look at those pro-guard rules:

**Examples:**

Example 1 (kotlin):
```kotlin
// Tag your component to declare a definition@Singleclass MyComponent
```

Example 2 (kotlin):
```kotlin
// Tag your component to declare a definition@Singleclass MyComponent
```

Example 3 (kotlin):
```kotlin
// Declare a module and scan for annotations@Moduleclass MyModule
```

Example 4 (kotlin):
```kotlin
// Declare a module and scan for annotations@Moduleclass MyModule
```

---

## Koin Component

**URL:** https://insert-koin.io/docs/reference/koin-core/koin-component

**Contents:**
- Koin Component
- Create a Koin Component​
- Unlock the Koin API with KoinComponents​
- Retrieving definitions with get & inject​
- Resolving instance from its name​

Koin is a DSL to help describe your modules & definitions, a container to make definition resolution. What we need now is an API to retrieve our instances outside the container. That's the goal of Koin components.

The KoinComponent interface is here to help you retrieve instances directly from Koin. Be careful, this links your class to the Koin container API. Avoid to use it on classes that you can declare in modules, and prefer constructor injection

To give a class the capacity to use Koin features, we need to tag it with KoinComponent interface. Let's take an example.

A module to define MyService instance

we start Koin before using definition.

Start Koin with myModule

Here is how we can write our MyComponent to retrieve instances from Koin container.

Use get() & by inject() to inject MyService instance

Once you have tagged your class as KoinComponent, you gain access to:

Koin offers two ways of retrieving instances from the Koin container:

The lazy inject form is better to define property that need lazy evaluation.

If you need you can specify the following parameter with get() or by inject()

Example of module using definitions names:

We can make the following resolutions:

**Examples:**

Example 1 (unknown):
```unknown
KoinComponent
```

Example 2 (unknown):
```unknown
KoinComponent
```

Example 3 (kotlin):
```kotlin
class MyServiceval myModule = module {    // Define a singleton for MyService    single { MyService() }}
```

Example 4 (kotlin):
```kotlin
class MyServiceval myModule = module {    // Define a singleton for MyService    single { MyService() }}
```

---

## Constructor DSL

**URL:** https://insert-koin.io/docs/reference/koin-core/dsl-update

**Contents:**
- Constructor DSL
- Available Keywords​
- DSL Options​
- Injected Parameters​
- Reflection Based DSL (Deprecated since 3.2)​

Koin now offer a new kind of DSL keyword that allow you to target a class constructor directly, and avoid to have type your definition within a lambda expression.

For a given class ClassA with following dependencies:

you can now declare those components, directly targeting the class constructor:

No need to specify dependencies in constructor anymore with get() function! 🎉

Be sure to use :: before your class name, to target your class constructor

Your constructor is filled automatically with all get(). Avoid using any default value as Koin will try to find it in the current graph.

If you need to retrieve a "named" definition, you need to use the standard DSL with lambda and get() to specify the qualifier

The following keywords are available to build your definition from constructor:

Be sure to not use any default value in your constructor, as Koin will try to fill every parameter with it.

Any Constructor DSL Definition, can also open some option within a lambda:

Usual options and DSL keywords are available in this lambda:

You can also use bind or binds operator, without any need of lambda:

With such kind of declaration, you can still use injected parameters. Koin will look in injected parameters and current dependencies to try to inject your constructor.

declared with Constructor DSL:

can be injected like this:

Koin Reflection DSL is now deprecated. Please Use Koin Constructor DSL above

**Examples:**

Example 1 (kotlin):
```kotlin
class ClassA(val b : ClassB, val c : ClassC)class ClassB()class ClassC()
```

Example 2 (kotlin):
```kotlin
class ClassA(val b : ClassB, val c : ClassC)class ClassB()class ClassC()
```

Example 3 (unknown):
```unknown
class constructor
```

Example 4 (kotlin):
```kotlin
module {    singleOf(::ClassA)    singleOf(::ClassB)    singleOf(::ClassC)}
```

---

## Definitions

**URL:** https://insert-koin.io/docs/reference/koin-core/definitions

**Contents:**
- Definitions
- Writing a module​
- Defining a singleton​
- Defining your component within a lambda​
- Defining a factory​
- Resolving & injecting dependencies​
- Definition: binding an interface​
- Additional type binding​
- Definition: naming & default bindings​
- Declaring injection parameters​

By using Koin, you describe definitions in modules. In this section we will see how to declare, organize & link your modules.

A Koin module is the space to declare all your components. Use the module function to declare a Koin module:

In this module, you can declare components as described below.

Declaring a singleton component means that Koin container will keep a unique instance of your declared component. Use the single function in a module to declare a singleton:

single, factory & scoped keywords help you declare your components through a lambda expression. this lambda describe the way that you build your component. Usually we instantiate components via their constructors, but you can also use any expression.

single { Class constructor // Kotlin expression }

The result type of your lambda is the main type of your component

A factory component declaration is a definition that will provide you a new instance each time you ask for this definition (this instance is not retained by Koin container, as it won't inject this instance in other definitions later). Use the factory function with a lambda expression to build a component.

Koin container doesn't retain factory instances as it will give a new instance each time the definition is asked.

Now that we can declare components definitions, we want to link instances with dependency injection. To resolve an instance in a Koin module, just use the get() function to request the needed component instance. This get() function is usually used into constructor, to inject constructor values.

To make dependency injection with Koin container, we have to write it in constructor injection style: resolve dependencies in class constructors. This way, your instance will be created with injected instances from Koin.

Let's take an example with several classes:

A single or a factory definition use the type from their given lambda definition i.e: single { T } The matched type of the definition is the only matched type from this expression.

Let's take an example with a class and implemented interface:

In a Koin module we can use the as cast Kotlin operator as follows:

You can also use the inferred type expression:

This 2nd way of style declaration is preferred and will be used for the rest of the documentation.

In some cases, we want to match several types from just one definition.

Let's take an example with a class and interface:

To make a definition bind additional types, we use the bind operator with a class:

Note here, that we would resolve the Service type directly with get(). But if we have multiple definitions binding Service, we have to use the bind<>() function.

You can specify a name to your definition, to help you distinguish two definitions about the same type:

Just request your definition with its name:

get() and by inject() functions let you specify a definition name if needed. This name is a qualifier produced by the named() function.

By default, Koin will bind a definition by its type or by its name, if the type is already bound to a definition.

In any definition, you can use injection parameters: parameters that will be injected and used by your definition:

In contrary to resolved dependencies (resolved with get()), injection parameters are parameters passed through the resolution API. This means that those parameters are values passed with get() and by inject(), with the parametersOf function:

Further reading in the Injection Parameters Section

You can use the onClose function, to add on a definition, the callback once definition closing is called:

Koin DSL also proposes some flags.

A definition or a module can be flagged as CreatedAtStart, to be created at start (or when you want). First set the createdAtStart flag on your module or on your definition.

CreatedAtStart flag on a definition

CreatedAtStart flag on a module:

The startKoin function will automatically create definitions instances flagged with createdAtStart.

if you need to load some definition at a special time (in a background thread instead of UI for example), just get/inject the desired components.

Koin definitions doesn't take in accounts generics type argument. For example, the module below tries to define 2 definitions of List:

Koin won't start with such definitions, understanding that you want to override one definition for the other.

To allow you, use the 2 definitions you will have to differentiate them via their name, or location (module). For example:

**Examples:**

Example 1 (kotlin):
```kotlin
val myModule = module {   // your dependencies here}
```

Example 2 (kotlin):
```kotlin
val myModule = module {   // your dependencies here}
```

Example 3 (kotlin):
```kotlin
class MyService()val myModule = module {    // declare single instance for MyService class    single { MyService() }}
```

Example 4 (kotlin):
```kotlin
class MyService()val myModule = module {    // declare single instance for MyService class    single { MyService() }}
```

---

## Kotlin Multiplatform - Definitions and Modules Annotations

**URL:** https://insert-koin.io/docs/reference/koin-annotations/kmp

**Contents:**
- Kotlin Multiplatform - Definitions and Modules Annotations
- KSP Setup​
- Defining Definitions and Modules in Common Code​
- Sharing Patterns​
  - Sharing Definitions for native implementations​
    - Scanning for Expect/Actual definitions​
    - Declaring Expect/Actual function definitions​
  - Sharing Definitions with different native contracts​
  - Safely Sharing across platforms with Platform Wrapper​
  - Sharing Expect/Actual Module - rely on Native Module Scanning​

Please follow the KSP setup as described in the official documentation: KSP with Kotlin Multiplatform

You can also check the Hello Koin KMP project with a basic setup for Koin Annotations.

Use the annotations library in the common API:

And don't forget to configure KSP on the right sourceSet:

In your commonMain sourceSet, declare your Module, scan for definitions, or define functions as regular Kotlin Koin declarations. See Definitions and Modules.

In this section, we will see together several ways to share components with definitions and modules.

In a Kotlin Multiplatform application, some components must be implemented specifically per platform. You can share those components at the definition level, with expected/actual on the given class (definition or module). You can share a definition with expect/actual implementation, or a module with expect/actual.

Please look at Multiplatform Expect & Actual Rules documentation for general Kotlin guidance.

Expect/Actual classes can't have different constructors per platform. You need to respect the current constructor contract designed in common space

We target sharing with a Common Module + Expect/Actual Class Definition

For this first classic pattern, you can use both definitions scanning with @ComponentScan or declare a definition as a module class function.

Be aware that to use expect/actual definitions, you will use the same constructor (either the default or a custom one). This constructor has to be the same on all platforms.

In native sources, implement our actual classes:

In native sources, implement our actual classes:

We target Expect/Actual common Module + common Interface + native implementations

In some cases, you need different constructor arguments on each native implementation. Then Expect/Actual class is not your solution. You need to go with an interface to implement on each platform, and a Expect/Actual class module to allow a module to define your right platform implementation:

In native sources, implement our actual classes:

Each time you use manual access to Koin scope, you are doing dynamic wiring. Compile safety doesn't cover such wiring.

Wrap a specific platform component, as a "platform wrapper"

You can wrap a specific platform component, as a "platform wrapper", to help you minimize dynamic injection.

For example, we can do a ContextWrapper that lets us inject Android Context when needed, but doesn't impact the iOS side.

In native sources, implement our actual classes:

This way, you minimize the dynamic platform wiring to one definition, and inject safely in your entire system.

You can now use your ContextWrapper from common code, and easily pass it in your Expect/Actual classes:

In native sources, implement our actual classes:

Rely on a native module from a common module

In some cases, you don't want to have constraints, and scan for components on each native side. Define an empty module class in the common source set, and define your implementation on each platform.

If you define an empty module in the common side, each native module implementation will be generated from each native target, allowing to scan native only components for example.

In native source sets:

**Examples:**

Example 1 (kotlin):
```kotlin
plugins {    alias(libs.plugins.ksp)}
```

Example 2 (kotlin):
```kotlin
plugins {    alias(libs.plugins.ksp)}
```

Example 3 (kotlin):
```kotlin
sourceSets {    commonMain.dependencies {        implementation(libs.koin.core)        api(libs.koin.annotations)        // ...    }}
```

Example 4 (kotlin):
```kotlin
sourceSets {    commonMain.dependencies {        implementation(libs.koin.core)        api(libs.koin.annotations)        // ...    }}
```

---

## Constructor DSL for Android

**URL:** https://insert-koin.io/docs/reference/koin-android/dsl-update

**Contents:**
- Constructor DSL for Android
- New Constructor DSL (Since 3.2)​
  - An Android example​
- Android Reflection DSL (Deprecated since 3.2)​

Koin now offer a new kind of DSL keyword that allow you to target a class constructor directly, and avoid to have type your definition within a lambda expression.

Check the new Constructor DSL section for more details.

For Android, this implies the following new constructor DSL Keyword:

Be sure to use :: before your class name, to target your class constructor

Given an Android application with the following components:

we can declare them like this:

Koin Reflection DSL is now deprecated. Please Use Koin Constructor DSL above

**Examples:**

Example 1 (unknown):
```unknown
viewModelOf()
```

Example 2 (unknown):
```unknown
viewModel { }
```

Example 3 (unknown):
```unknown
fragmentOf()
```

Example 4 (unknown):
```unknown
fragment { }
```

---

## CheckModules - Check Koin configuration (Deprecated)

**URL:** https://insert-koin.io/docs/reference/koin-test/checkmodules

**Contents:**
- CheckModules - Check Koin configuration (Deprecated)
  - Koin Dynamic Check - CheckModules()​
    - CheckModule DSL​
    - Allow mocking with a Junit rule​
    - Verifying modules with dynamic behavior (3.1.3+)​
    - Checking Modules for Android (3.1.3)​
    - Providing Default Values (3.1.4)​
    - Providing ParametersOf values (3.1.4)​
    - Providing Scope Links​

This API is now deprecated - since Koin 4.0

Koin allows you to verify your configuration modules, avoiding discovering dependency injection issues at runtime.

Invoke the checkModules() function within a simple JUnit test. This will launch your modules and try to run each possible definition for you.

also possible to use checkKoinModules:

For any definition that is using injected parameters, properties or dynamic instances, the checkModules DSL allows to specify how to work with the following case:

withInstance(value) - will add value instance to Koin graph (can be used in dependency or parameter)

withInstance<MyType>() - will add a mocked instance of MyType. Use MockProviderRule. (can be used in dependency or parameter)

withParameter<Type>(qualifier){ qualifier -> value } - will add value instance to be injected as parameter

withParameter<Type>(qualifier){ qualifier -> parametersOf(...) } - will add value instance to be injected as parameter

withProperty(key,value) - add property to Koin

To use mocks with checkModules, you need to provide a MockProviderRule

To verify a dynamic behavior like following, let's use the CheckKoinModules DSL to provide the missing instance data to our test:

You can verify it with the following:

This way, FactoryPresenter definition will be injected with "_my_id_value" define above.

You can also use mocked instances, to fill up your graph. You can notice that we need a MockProviderRule declaration to allow Koin mock any injected definition

Here below is how you can test your graph for a typical Android app:

also possible to use checkKoinModules:

If you need, you can set a default value for all type in the checked modules. For example, we can override all injected string values:

Let's use the withInstance() function in checkModules block, to define a default value for all definitions:

All injected definition that are using an injected String parameter, will receive "_ID_":

You can define a default value to be injected for one specific definition, with withParameter or withParameters functions:

You can link scopes by using withScopeLink function incheckModules block to inject instances from another scope's definitions:

**Examples:**

Example 1 (unknown):
```unknown
checkModules()
```

Example 2 (kotlin):
```kotlin
class CheckModulesTest : KoinTest {    @Test    fun verifyKoinApp() {                koinApplication {            modules(module1,module2)            checkModules()        }    }}
```

Example 3 (kotlin):
```kotlin
class CheckModulesTest : KoinTest {    @Test    fun verifyKoinApp() {                koinApplication {            modules(module1,module2)            checkModules()        }    }}
```

Example 4 (unknown):
```unknown
checkKoinModules
```

---

## Koin DSL

**URL:** https://insert-koin.io/docs/reference/koin-core/dsl

**Contents:**
- Koin DSL
- Application & Module DSL​
- Application DSL​
- KoinApplication instance: Global vs Local​
- Starting Koin​
- Module DSL​
  - Writing a module​
  - withOptions - DSL Options (since 3.2)​

Thanks to the power of Kotlin language, Koin provides a DSL to help you describe your app instead of annotate it or generate code for it. With its Kotlin DSL, Koin offers a smart functional API to achieve to prepare your dependency injection.

Koin offers several keywords to let you describe the elements of a Koin Application:

A KoinApplication instance is a Koin container instance configuration. This will let you configure logging, properties loading and modules.

To build a new KoinApplication, use the following functions:

To configure your KoinApplication instance, you can use any of the following functions :

As you can see above, we can describe a Koin container configuration in 2 ways: koinApplication or startKoin function.

By registering your container configuration into the GlobalContext, the global API can use it directly. Any KoinComponent refers to a Koin instance. By default, we use the one from GlobalContext.

Check chapters about Custom Koin instance for more information.

Starting Koin means run a KoinApplication instance into the GlobalContext.

To start Koin container with modules, we can just use the startKoin function like that:

A Koin module gather definitions that you will inject/combine for your application. To create a new module, just use the following function:

To describe your content in a module, you can use the following functions:

Note: the named() function allow you to give a qualifier either by a string, an enum or a type. It is used to name your definitions.

A Koin module is the space to declare all your components. Use the module function to declare a Koin module:

In this module, you can declare components as described below.

Like for new Constructor DSL definitions, you can specify definition options on "regular" definitions with the withOptions operator:

Within this option lambda, you can specify the following options:

**Examples:**

Example 1 (unknown):
```unknown
KoinApplication
```

Example 2 (unknown):
```unknown
KoinApplication
```

Example 3 (unknown):
```unknown
koinApplication { }
```

Example 4 (unknown):
```unknown
KoinApplication
```

---

## Verifying your Koin configuration

**URL:** https://insert-koin.io/docs/reference/koin-test/verify

**Contents:**
- Verifying your Koin configuration
- Koin Configuration check with Verify() - JVM Only [3.3]​
- Verifying with Injected Parameters - JVM Only [4.0]​
- Type White-Listing​
- Core Annotations - Automatically declare safe types​

Koin allows you to verify your configuration modules, avoiding discovering dependency injection issues at runtime.

Use the verify() extension function on a Koin Module. That's it! Under the hood, This will verify all constructor classes and crosscheck with the Koin configuration to know if there is a component declared for this dependency. In case of failure, the function will throw a MissingKoinDefinitionException.

Launch the JUnit test and you're done! ✅

As you may see, we use the extra Types parameter to list types used in the Koin configuration but not declared directly. This is the case for SavedStateHandle and WorkerParameters types, that are used as injected parameters. The Context is declared by androidContext() function at start.

The verify() API is ultra light to run and doesn't require any kind of mock/stub to run on your configuration.

When you have a configuration that implies injected obects with parametersOf, the verification will fail because there is no definition of the parameter's type in your configuration. However you can define a parameter type, to be injected with given definition definition<Type>(Class1::class, Class2::class ...).

We can add types as "white-listed". This means that this type is considered as present in the system for any definition. Here is how it goes:

We also introduced annotations in the main Koin project (under the koin-core-annotations module), extracted from Koin annotations. Those avoid verbose declarations by using @InjectedParam and @Provided to help Koin infer injection contracts and validate configurations. Instead of having a complex DSL configuration, this helps identify those elements. Those annotations are used only with the verify API for now.

This helps prevent subtle issues during testing or runtime without writing custom verification logic.

**Examples:**

Example 1 (kotlin):
```kotlin
val niaAppModule = module {    includes(        jankStatsKoinModule,        dataKoinModule,        syncWorkerKoinModule,        topicKoinModule,        authorKoinModule,        interestsKoinModule,        settingsKoinModule,        bookMarksKoinModule,        forYouKoinModule    )    viewModelOf(::MainActivityViewModel)}
```

Example 2 (kotlin):
```kotlin
val niaAppModule = module {    includes(        jankStatsKoinModule,        dataKoinModule,        syncWorkerKoinModule,        topicKoinModule,        authorKoinModule,        interestsKoinModule,        settingsKoinModule,        bookMarksKoinModule,        forYouKoinModule    )    viewModelOf(::MainActivityViewModel)}
```

Example 3 (kotlin):
```kotlin
class NiaAppModuleCheck {    @Test    fun checkKoinModule() {        // Verify Koin configuration        niaAppModule.verify()    }}
```

Example 4 (kotlin):
```kotlin
class NiaAppModuleCheck {    @Test    fun checkKoinModule() {        // Verify Koin configuration        niaAppModule.verify()    }}
```

---

## Kotlin Multiplatform Dependency Injection

**URL:** https://insert-koin.io/docs/reference/koin-mp/kmp

**Contents:**
- Kotlin Multiplatform Dependency Injection
- Source Project​
- Gradle Dependencies​
- Shared Koin Module​
- Android App​
- iOS App​
  - Calling Koin​
  - Injected Classes​
  - New Native Memory Management​

You can find the Kotlin Multiplatform project here: https://github.com/InsertKoinIO/hello-kmp

Koin is a pure Kotlin library and can be used in your shared Kotlin project. Just add the core dependency:

Add koin-core in common project, declare your dependency: https://github.com/InsertKoinIO/hello-kmp/tree/main/buildSrc

Platform specific components can be declared here, and be used later in Android or iOS (declared directly with actual classes or even actual module)

You can find the shared module sources here: https://github.com/InsertKoinIO/hello-kmp/tree/main/shared

Koin modules need to be gathered via a function:

You can keep using koin-android features and reuse the common modules/classes.

The code for the Android app can be found here: https://github.com/InsertKoinIO/hello-kmp/tree/main/androidApp

The code for the iOS App can be found here: https://github.com/InsertKoinIO/hello-kmp/tree/main/iosApp

Let’s prepare a wrapper to our Koin function (in our shared code):

We can initialize it in our Main app entry:

Let’s call a Kotlin class instance from swift.

Our Kotlin component:

Activate experimental with root gradle.properties.

**Examples:**

Example 1 (kotlin):
```kotlin
// Dependencies.ktobject Versions {    const val koin = "3.2.0"}object Deps {    object Koin {        const val core = "io.insert-koin:koin-core:${Versions.koin}"        const val test = "io.insert-koin:koin-test:${Versions.koin}"        const val android = "io.insert-koin:koin-android:${Versions.koin}"    }}
```

Example 2 (kotlin):
```kotlin
// Dependencies.ktobject Versions {    const val koin = "3.2.0"}object Deps {    object Koin {        const val core = "io.insert-koin:koin-core:${Versions.koin}"        const val test = "io.insert-koin:koin-test:${Versions.koin}"        const val android = "io.insert-koin:koin-android:${Versions.koin}"    }}
```

Example 3 (kotlin):
```kotlin
// platform Moduleval platformModule = module {    singleOf(::Platform)}// KMP Class Definitionexpect class Platform() {    val name: String}// iOSactual class Platform actual constructor() {    actual val name: String =        UIDevice.currentDevice.systemName() + " " + UIDevice.currentDevice.systemVersion}// Androidactual class Platform actual constructor() {    actual val name: String = "Android ${android.os.Build.VERSION.SDK_INT}"}
```

Example 4 (kotlin):
```kotlin
// platform Moduleval platformModule = module {    singleOf(::Platform)}// KMP Class Definitionexpect class Platform() {    val name: String}// iOSactual class Platform actual constructor() {    actual val name: String =        UIDevice.currentDevice.systemName() + " " + UIDevice.currentDevice.systemVersion}// Androidactual class Platform actual constructor() {    actual val name: String = "Android ${android.os.Build.VERSION.SDK_INT}"}
```

---

## Passing Parameters - Injected Parameters

**URL:** https://insert-koin.io/docs/reference/koin-core/injection-parameters

**Contents:**
- Passing Parameters - Injected Parameters
- Passing values to inject​
- Defining an "injected parameter"​
- Resolving injected parameters in order​
- Resolving injected parameters from graph​
- Injected parameters: indexed values or set (3.4.3)​

In any definition, you can use injection parameters: parameters that will be injected and used by your definition.

Given a definition, you can pass parameters to that definition:

Parameters are sent to your definition with the parametersOf() function (each value separated by comma):

Below is an example of injection parameters. We established that we need a view parameter to build of Presenter class. We use the params function argument to help retrieve our injected parameters:

You can also write your injected parameters directly with the parameters object, as destructured declaration:

Even if the "destructured" declaration is more convenient and readable, it's not type safe. Kotlin won't detect that passed type are in good orders if you have several values

Instead of using get() to resolve a parameter, if you have several parameters of the same type you can use the index as follows get(index) (also same as [ ] operator):

Koin graph resolution (main tree of resolution of all definitions) also let you find your injected parameter. Just use the usual get() function:

In addition to parametersOf, the following API are accessible:

The default function parametersOf is working with both index & set of values:

You can "cascade" parameter injection with parametersOf or parameterArrayOf, to consume value based on index. Or use parametersOf or parameterSetOf to cascading based on type to resolve.

**Examples:**

Example 1 (kotlin):
```kotlin
class Presenter(val a : A, val b : B)val myModule = module {    single { params -> Presenter(a = params.get(), b = params.get()) }}
```

Example 2 (kotlin):
```kotlin
class Presenter(val a : A, val b : B)val myModule = module {    single { params -> Presenter(a = params.get(), b = params.get()) }}
```

Example 3 (unknown):
```unknown
parametersOf()
```

Example 4 (kotlin):
```kotlin
class MyComponent : View, KoinComponent {    val a : A ...    val b : B ...     // inject this as View value    val presenter : Presenter by inject { parametersOf(a, b) }}
```

---

## Modules

**URL:** https://insert-koin.io/docs/reference/koin-core/modules

**Contents:**
- Modules
- What is a module?​
- Using several modules​
- Overriding definition or module (3.1.0+)​
- Sharing Modules​
- Overriding definition or module (before 3.1.0)​
- Linking modules strategies​
- Module Includes (since 3.2)​

By using Koin, you describe definitions in modules. In this section we will see how to declare, organize & link your modules.

A Koin module is a "space" to gather Koin definition. It's declared with the module function.

Components doesn't have to be necessarily in the same module. A module is a logical space to help you organize your definitions, and can depend on definitions from other module. Definitions are lazy, and they are resolved only when a component is requesting them.

Let's take an example, with linked components in separate modules:

Koin doesn't have any import concept. Koin definitions are lazy: a Koin definition is started with Koin container but is not instantiated. An instance is created only when a request for its type has been done.

We just have to declare list of used modules when we start our Koin container:

Koin will then resolve dependencies from all given modules.

New Koin override strategy allow to override any definition by default. You don't need to specify override = true anymore in your module.

If you have 2 definitions in different modules, that have the same mapping, the last will override the current definition.

You can check in Koin logs, about definition mapping override.

You can specify to not allow overriding in your Koin application configuration with allowOverride(false):

In the case of disabling override, Koin will throw an DefinitionOverrideException exception on any attempt of override.

When using the module { } function, Koin preallocate all instance factories. If you need to share a module, please consider return your module with a function.

This way, you share the definitions and avoid preallocating factories in a value.

Koin won't allow you to redefine an already existing definition (type,name,path ...). You will get an error if you try this:

To allow definition overriding, you have to use the override parameter:

Order matters when listing modules and overriding definitions. You must have your overriding definitions in last of your module list.

As definitions between modules are lazy, we can use modules to implement different strategy implementation: declare an implementation per module.

Let's take an example, of a Repository and Datasource. A repository need a Datasource, and a Datasource can be implemented in 2 ways: Local or Remote.

We can declare those components in 3 modules: Repository and one per Datasource implementation:

Then we just need to launch Koin with the right combination of modules:

A new function includes() is available in the Module class, which lets you compose a module by including other modules in an organized and structured way.

The two prominent use cases of the new feature are:

How does it work? Let's take some modules, and we include modules in parentModule:

Notice we do not need to set up all modules explicitly: by including parentModule, all the modules declared in the includes will be automatically loaded (childModule1 and childModule2). In other words, Koin is effectively loading: parentModule, childModule1 and childModule2.

An important detail to observe is that you can use includes to add internal and private modules too - that gives you flexibility over what to expose in a modularized project.

Module loading is now optimized to flatten all your module graphs and avoid duplicated definitions of modules.

Finally, you can include multiple nested or duplicates modules, and Koin will flatten all the included modules removing duplicates:

Notice that all modules will be included only once: dataModule, domainModule, featureModule1, featureModule2.

If you have any compiling issue while including modules from the same file, either use get() Kotlin attribute operator on your module or separate each module in files. See https://github.com/InsertKoinIO/koin/issues/1341 workaround

**Examples:**

Example 1 (kotlin):
```kotlin
val myModule = module {    // Your definitions ...}
```

Example 2 (kotlin):
```kotlin
val myModule = module {    // Your definitions ...}
```

Example 3 (kotlin):
```kotlin
// ComponentB <- ComponentAclass ComponentA()class ComponentB(val componentA : ComponentA)val moduleA = module {    // Singleton ComponentA    single { ComponentA() }}val moduleB = module {    // Singleton ComponentB with linked instance ComponentA    single { ComponentB(get()) }}
```

Example 4 (kotlin):
```kotlin
// ComponentB <- ComponentAclass ComponentA()class ComponentB(val componentA : ComponentA)val moduleA = module {    // Singleton ComponentA    single { ComponentA() }}val moduleB = module {    // Singleton ComponentB with linked instance ComponentA    single { ComponentB(get()) }}
```

---

## Dependency Injection in Ktor

**URL:** https://insert-koin.io/docs/reference/koin-ktor/ktor

**Contents:**
- Dependency Injection in Ktor
- Install Koin Plugin​
  - Compatible with Ktor's DI (4.1)​
- Inject in Ktor​
  - Resolve from Ktor Request Scope (since 4.1)​
  - Declare Koin modules in Ktor module (4.1)​
  - Ktor Events​

The koin-ktor module is dedicated to bringing dependency injection for Ktor.

To start a Koin container in Ktor, just install the Koin plugin as follows:

Koin 4.1 fully supports new Ktor 3.2!

We extracted CoreResolver to abstract resolution rules for Koin and allow extension with ResolutionExtension. We added new KtorDIExtension as Ktor ResolutionExtension to help Koin resolve Ktor default DI instance.

Koin Ktor plugin is automatically setting up Ktor DI integration. Below, see how you can consume Ktor dependencies from Koin:

Koin inject() and get() functions are available from Application, Route, and Routing classes:

You can declare components to live within the Ktor request scope timeline. For this, you just need to declare your component inside a requestScope section. Given a ScopeComponent class to instantiate on the Ktor web request scope, let's declare it:

And from your HTTP call, simply call call.scope.get() to resolve the right dependency:

This allows your scoped dependency to resolve ApplicationCall as scope's source of your resolution. You can inject it directly into constructor:

For each new request, the scope will be recreated. This creates and drops scope instances for each request

Use Application.koinModule {} or Application.koinModules() directly within your app setup to declare new modules within your Ktor module:

You can listen to KTor Koin events:

**Examples:**

Example 1 (kotlin):
```kotlin
fun Application.main() {    // Install Koin    install(Koin) {        slf4jLogger()        modules(helloAppModule)    }}
```

Example 2 (kotlin):
```kotlin
fun Application.main() {    // Install Koin    install(Koin) {        slf4jLogger()        modules(helloAppModule)    }}
```

Example 3 (kotlin):
```kotlin
// let's define a Ktor objectfun Application.setupDatabase(config: DbConfig) {    // ...    dependencies {        provide<Database> { database }    }}
```

Example 4 (kotlin):
```kotlin
// let's define a Ktor objectfun Application.setupDatabase(config: DbConfig) {    // ...    dependencies {        provide<Database> { database }    }}
```

---

## Start Koin

**URL:** https://insert-koin.io/docs/reference/koin-core/start-koin

**Contents:**
- Start Koin
  - The startKoin function​
  - Extending your Koin start (help reuse for KMP and other ...)​
  - Behind the start - Koin instance under the hood​
  - Loading modules after startKoin​
  - Unloading modules​
  - Stop Koin - closing all resources​
- Logging​
  - Set logging at start​
- Loading properties​

Koin is a DSL, a lightweight container and a pragmatic API. Once you have declared your definitions within Koin modules, you are ready to start the Koin container.

The startKoin function is the main entry point to launch Koin container. It needs a list of Koin modules to run. Modules are loaded and definitions are ready to be resolved by the Koin container.

Once startKoin has been called, Koin will read all your modules & definitions. Koin is then ready for any get() or by inject() call to retrieve the needed instance.

Your Koin container can have several options:

The startKoin can't be called more than once. If you need several point to load modules, use the loadKoinModules function.

Koin now supports reusable and extensible configuration objects for KoinConfiguration. You can extract shared configuration for use across platforms (Android, iOS, JVM, etc.) or tailor it to different environments. This can be done with the includes() function. Below, we can reuse easily a common configuration, and extend it to add some Android environment settings:

When we start Koin, we create a KoinApplication instance that represents the Koin container configuration instance. Once launched, it will produce a Koin instance resulting of your modules and options. This Koin instance is then hold by the GlobalContext, to be used by any KoinComponent class.

The GlobalContext is a default JVM context strategy for Koin. It's called by startKoin and register to GlobalContext. This will allow us to register a different kind of context, in the perspective of Koin Multiplatform.

You can't call the startKoin function more than once. But you can use directly the loadKoinModules() functions.

This function is interesting for SDK makers who want to use Koin, because they don't need to use the startKoin() function and just use the loadKoinModules at the start of their library.

it's possible also to unload a bunch of definition, and then release theirs instance with the given function:

You can close all the Koin resources and drop instances & definitions. For this you can use the stopKoin() function from anywhere, to stop the Koin GlobalContext. Else on a KoinApplication instance, just call close()

Koin has a simple logging API to log any Koin activity (allocation, lookup ...). The logging API is represented by the class below:

Koin proposes some implementation of logging, in function of the target platform:

By default, Koin use the EmptyLogger. You can use directly the PrintLogger as following:

You can load several type of properties at start:

Be sure to load properties at Koin start:

In a Koin module, you can get a property by its key:

in /src/main/resources/koin.properties file

Just load it with getProperty function:

Your Koin application can now activate some experimental features through a dedicated options section, like:

**Examples:**

Example 1 (kotlin):
```kotlin
// start a KoinApplication in Global contextstartKoin {    // declare used modules    modules(coffeeAppModule)}
```

Example 2 (kotlin):
```kotlin
// start a KoinApplication in Global contextstartKoin {    // declare used modules    modules(coffeeAppModule)}
```

Example 3 (unknown):
```unknown
by inject()
```

Example 4 (unknown):
```unknown
properties()
```

---

## Extension Manager

**URL:** https://insert-koin.io/docs/reference/koin-core/extension-manager

**Contents:**
- Extension Manager
- Defining an extension​
- Starting an extension​
- Resolver Engine & Resolution Extension​

Here is a brief description of KoinExtension manager, dedicated to add new features inside Koin framework.

A Koin extension consist in having a class inheriting from KoinExtension interface:

this interface allow to ensure you get passed a Koin instance, and the extension is called when Koin is closing.

To start an extension, just extend the right place of the system, and register it with Koin.extensionManager.

Below here is how we define the coroutinesEngine extension:

Below here is how we call the coroutinesEngine extension:

Koin's resolution algorithm has been reworked to be pluggable and extensible. The new CoreResolver and ResolutionExtension APIs allow integration with external systems or custom resolution logic.

Internally, resolution now traverses stack elements more efficiently, with cleaner propagation across scopes and parent hierarchies. This will fix many issues related to the linked scope walk-through and allow better integration of Koin in other systems.

See below a test demoing resolution extension:

**Examples:**

Example 1 (unknown):
```unknown
KoinExtension
```

Example 2 (unknown):
```unknown
KoinExtension
```

Example 3 (kotlin):
```kotlin
interface KoinExtension {    fun onRegister(koin : Koin)    fun onClose()}
```

Example 4 (kotlin):
```kotlin
interface KoinExtension {    fun onRegister(koin : Koin)    fun onClose()}
```

---

## Context Isolation

**URL:** https://insert-koin.io/docs/reference/koin-core/context-isolation

**Contents:**
- Context Isolation
- What is Context Isolation?​
- Testing​

For SDK Makers, you can also work with Koin in a non-global way: use Koin for the DI of your library and avoid any conflict by people using your library and Koin by isolating your context.

In a standard way, we can start Koin like that:

This uses the default Koin context to register your dependencies.

But if we want to use an isolated Koin instance, you need to declare an instance and store it in a class to hold your instance. You will have to keep your Koin Application instance available in your library and pass it to your custom KoinComponent implementation:

The MyIsolatedKoinContext class is holding our Koin instance here:

Let's use MyIsolatedKoinContext to define our IsolatedKoinComponent class, a KoinComponent that will use our isolated context:

Everything is ready, just use IsolatedKoinComponent to retrieve instances from isolated context:

To test classes that are retrieving dependencies with by inject() delegate override getKoin() method and define custom Koin module:

**Examples:**

Example 1 (kotlin):
```kotlin
// start a KoinApplication and register it in Global contextstartKoin {    // declare used modules    modules(...)}
```

Example 2 (kotlin):
```kotlin
// start a KoinApplication and register it in Global contextstartKoin {    // declare used modules    modules(...)}
```

Example 3 (unknown):
```unknown
MyIsolatedKoinContext
```

Example 4 (kotlin):
```kotlin
// Get a Context for your Koin instanceobject MyIsolatedKoinContext {    private val koinApp = koinApplication {        // declare used modules        modules(coffeeAppModule)    }    val koin = koinApp.koin }
```

---

## Definitions with Annotations

**URL:** https://insert-koin.io/docs/reference/koin-annotations/definitions

**Contents:**
- Definitions with Annotations
  - Generate Compose ViewModel for Kotlin Multiplatform (since 1.4.0)​
- Automatic or Specific Binding​
- Nullable Dependencies​
- Qualifier with @Named​
- Injected Parameters with @InjectedParam​
- Injecting a lazy dependency - Lazy<T>​
- Injecting a list of dependencies - List<T>​
- Properties with @Property​
  - @PropertyValue - Property with default value (since 1.4)​

Koin Annotations allow declaring the same kind of definitions as the regular Koin DSL, but with annotations. Just tag your class with the needed annotation, and it will generate everything for you!

For example, the equivalent of single { MyComponent(get()) } DSL declaration is just done by tagging with @Single like this:

Koin Annotations keep the same semantics as the Koin DSL. You can declare your components with the following definitions:

For Scopes, check the Declaring Scopes section.

The @KoinViewModel annotation generates ViewModels using the koin-core-viewmodel main DSL by default (enabled since 2.2.0). This provides Kotlin Multiplatform compatibility and uses the unified ViewModel API.

The KOIN_USE_COMPOSE_VIEWMODEL option is enabled by default:

This generates viewModel definitions with org.koin.compose.viewmodel.dsl.viewModel for multiplatform compatibility.

When declaring a component, all detected "bindings" (associated supertypes) will already be prepared for you. For example, the following definition:

Koin will declare that your MyComponent component is also tied to MyInterface. The DSL equivalent is single { MyComponent(get()) } bind MyInterface::class.

Instead of letting Koin detect things for you, you can also specify what type you really want to bind with the binds annotation parameter:

If your component is using nullable dependency, don't worry it will be handled automatically for you. Keep using your definition annotation, and Koin will guess what to do:

The generated DSL equivalent will be single { MyComponent(getOrNull()) }

Note that this also works for injected Parameters and properties

You can add a "name" to a definition (also called qualifier), to make a distinction between several definitions for the same type, with the @Named annotation:

When resolving a dependency, just use the qualifier with named function:

It is also possible to create custom qualifier annotations. Using the previous example:

You can tag a constructor member as "injected parameter", which means that the dependency will be passed in the graph when calling for resolution.

Then you can call your MyComponent and pass an instance of MyDependency:

The generated DSL equivalent will be single { params -> MyComponent(params.get()) }

Koin can automatically detect and resolve a lazy dependency. Here, for example, we want to resolve lazily the LoggerDataSource definition. You just need to use the Lazy Kotlin type as follows:

Behind it will generate the DSL like with inject() instead of get():

Koin can automatically detect and resolve a list of dependencies. Here, for example, we want to resolve all LoggerDataSource definitions. You just need to use the List Kotlin type as follows:

Behind it will generate the DSL, like with getAll() function:

To resolve a Koin property in your definition, just tag a constructor member with @Property. This will resolve the Koin property thanks to the value passed to the annotation:

The generated DSL equivalent will be factory { ComponentWithProps(getProperty("id")) }

Koin Annotations offers you the possibility to define a default value for a property, directly from your code with @PropertyValue annotation. Let's follow our sample:

The generated DSL equivalent will be factory { ComponentWithProps(getProperty("id", ComponentWithProps.DEFAULT_ID)) }

Koin Annotations provides JSR-330 (Jakarta Inject) compatible annotations through the koin-jsr330 module. These annotations are particularly useful for developers migrating from other JSR-330 compatible frameworks like Hilt, Dagger, or Guice.

Add the koin-jsr330 dependency to your project:

JSR-330 standard singleton annotation, equivalent to Koin's @Single:

This generates the same result as @Single - a singleton instance in Koin.

JSR-330 standard qualifier annotation for string-based qualifiers:

JSR-330 standard injection annotation. While Koin Annotations doesn't require explicit constructor marking, @Inject can be used for JSR-330 compatibility:

Meta-annotation for creating custom qualifier annotations:

Meta-annotation for creating custom scope annotations:

You can freely mix JSR-330 annotations with Koin annotations in the same project:

Using JSR-330 annotations provides several advantages for framework migration:

JSR-330 annotations in Koin generate the same underlying DSL as their Koin equivalents. The choice between JSR-330 and Koin annotations is purely stylistic and based on team preferences or migration requirements.

**Examples:**

Example 1 (unknown):
```unknown
single { MyComponent(get()) }
```

Example 2 (kotlin):
```kotlin
@Singleclass MyComponent(val myDependency : MyDependency)
```

Example 3 (kotlin):
```kotlin
@Singleclass MyComponent(val myDependency : MyDependency)
```

Example 4 (unknown):
```unknown
factory { }
```

---

## Scopes

**URL:** https://insert-koin.io/docs/reference/koin-core/scopes

**Contents:**
- Scopes
- What is a scope?​
- Scope definition​
  - Scope Id & Scope Name​
  - Scope Component: Associate a scope to a component [2.2.0]​
  - Resolving dependencies within a scope​
  - Close a scope​
  - Getting scope's source value​
  - Scope Linking​
  - Scope Archetypes​

Koin brings a simple API to let you define instances that are tied to a limit lifetime.

Scope is a fixed duration of time or method calls in which an object exists. Another way to look at this is to think of scope as the amount of time an object’s state persists. When the scope context ends, any objects bound under that scope cannot be injected again (they are dropped from the container).

By default, in Koin, we have 3 kind of scopes:

To declare a scoped definition, use the scoped function like follow. A scope gathers scoped definitions as a logical unit of time.

Declaring a scope for a given type, we need to use the scope keyword:

A Koin Scope is defined by its:

scope<A> { } is equivalent to scope(named<A>()){ } , but more convenient to write. Note that you can also use a string qualifier like: scope(named("SCOPE_NAME")) { }

From a Koin instance, you can access:

By default calling createScope on an object, doesn't pass the "source" of the scope. You need to pass it as parameters: T.createScope(<source>)

Koin has the concept of KoinScopeComponent to help bring a scope instance to its class:

The KoinScopeComponent interface brings several extensions:

Let's define a scope for A, to resolve B:

We can then resolve instance of B directly thanks to org.koin.core.scope get & inject extensions:

To resolve a dependency using the scope's get & inject functions: val presenter = scope.get<Presenter>()

The interest of a scope is to define a common logical unit of time for scoped definitions. It's allow also to resolve definitions from within the given scope

The dependency resolution is then straight forward:

By default, all scopes fallback to resolve in the main scope if no definition is found in the current scope

Once you are finished with your scope instance, just close it with the close() function:

Beware that you can't inject instances anymore from a closed scope.

Koin Scope API in 2.1.4 allow you to pass the original source of a scope, in a definition. Let's take an example below. Let's have a singleton instance A:

By creating A's scope, we can forward the reference of the scope's source (A instance), to underlying definitions of the scope: scoped { BofA(getSource()) } or even scoped { BofA(get()) }

This in order to avoid cascading parameter injection, and just retrieve our source value directly in scoped definition.

Difference between getSource() and get(): getSource will directly get the source value. Get will try to resolve any definition, and fallback to source value if possible. getSource() is then more efficient in terms of performances.

Koin Scope API in 2.1 allow you to link a scope to another, and then allow to resolve joined definition space. Let's take an example. Here we are defining, 2 scopes spaces: a scope for A and a scope for B. In A's scope, we don't have access to C (defined in B's scope).

With scope linking API, we can allow to resolve B's scope instance C, directly from A's scope. For this we use linkTo() on scope instance:

Scope "Archetypes" are scope spaces for a generic kind of classes. For example, you can have Scope Archetypes for Android (Activity, Fragment, ViewModel) or even Ktor (RequestScope). Scope Archetype is Koin's TypeQualifier pass to different APIs, to request scope space for a given

An archetype consists of:

**Examples:**

Example 1 (kotlin):
```kotlin
module {    scope<MyType>{        scoped { Presenter() }        // ...    }}
```

Example 2 (kotlin):
```kotlin
module {    scope<MyType>{        scoped { Presenter() }        // ...    }}
```

Example 3 (unknown):
```unknown
scope<A> { }
```

Example 4 (unknown):
```unknown
scope(named<A>()){ }
```

---
