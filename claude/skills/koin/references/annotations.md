# Koin - Annotations

**Pages:** 4

---

## Scopes in Koin Annotations

**URL:** https://insert-koin.io/docs/reference/koin-annotations/scope

**Contents:**
- Scopes in Koin Annotations
- Defining a Scope with @Scope​
- Adding a definition in a Scope with @Scoped​
- Dependency resolution from a scope​
- Resolving outside a Scope with @ScopeId (since 1.3.0)​
- Scope Archetype Annotations​
  - Android Scope Archetypes​
    - @ActivityScope​
    - @ActivityRetainedScope​
    - @FragmentScope​

While using definitions and modules, you may need to define scopes for a particular space and time resolution.

Koin allows the use of scopes. Please refer to Koin Scopes section for more details on basics.

To declare a scope with annotations, just use @Scope annotation on a class, like this

this will be equivalent of the following scope section:

Else, if you need a scope name more than a type, you need to tag a class with @Scope(name = ) annotation, using name parameter:

this will be the equivalent of

To declare a definition inside a scope (defined or not with annotations), just tag a class with @Scope and @Scoped annotations:

This will generate the right definition inside the scope section:

You need both annotations to indicate the needed scope space (with @Scope) and the kind of component to define (with @Scoped)

From a scoped definition, you can resolve any definition from your inner Scope and from the parent scopes.

For example, the following case will work:

The component MySingle is defined as single definition, in the root. MyScopedComponent and MyOtherScopedComponent are defined in scope "my_scope_name". The dependencies resolution from MyScopedComponent is accessing the Koin root with MySingle instance, and MyOtherScopedComponent scoped instance from the current "my_scope_name" scope.

You may need to resolve a component from another scope that is not directly accessible to your scope. For this, you need to tag your dependency with @ScopeId annotation to tell Koin to find this dependency in the scope of the given scope Id.

The above code is equivalent is generated:

This example shows that MyFactory component will resolve MyScopedComponent component from a scope instance with id "my_scope_id". This scope, created with id "my_scope_id" needs to be created with the right scope definition.

The MyScopedComponent component needs to be defined in a Scope section, and a scope instance needs to be created with id "my_scope_id".

Koin Annotations provides predefined scope archetype annotations for common scope patterns, eliminating the need to manually declare scope types. These annotations combine scope declaration and component definition in a single annotation.

For Android development, you can use these predefined scope annotations:

Declare a component in an Activity scope:

Usage: The tagged class is meant to be used with Activity and the activityScope function to activate the scope.

Declare a component in an Activity Retained scope (survives configuration changes):

Usage: The tagged class is meant to be used with Activity and the activityRetainedScope function to activate the scope.

Declare a component in a Fragment scope:

Usage: The tagged class is meant to be used with Fragment and the fragmentScope function to activate the scope.

Declare a component in a ViewModel scope. This annotation is Kotlin Multiplatform (KMP) compatible and works with both Android ViewModels and Compose Multiplatform ViewModels:

Usage: The tagged class is meant to be used with ViewModel and the viewModelScope function to activate the scope.

KMP Support: Works seamlessly across all Kotlin Multiplatform targets including Android, iOS, Desktop, and Web platforms where ViewModels are used.

Scope archetype annotations work seamlessly with regular Koin scoping:

Scope archetypes can also be used on functions within modules:

Scope archetype annotations automatically create the appropriate scope definition and scoped component declaration, reducing boilerplate code for common scope patterns.

**Examples:**

Example 1 (kotlin):
```kotlin
@Scopeclass MyScopeClass
```

Example 2 (kotlin):
```kotlin
@Scopeclass MyScopeClass
```

Example 3 (kotlin):
```kotlin
scope<MyScopeClass> {}
```

Example 4 (kotlin):
```kotlin
scope<MyScopeClass> {}
```

---

## Koin Built-in Performance Monitoring with @Monitor

**URL:** https://insert-koin.io/docs/reference/koin-annotations/monitor

**Contents:**
- Koin Built-in Performance Monitoring with @Monitor
- Setup​
- Basic Usage​
- Generated Code​
- ViewModels Monitoring​
- Kotzilla Platform Integration​
- Requirements​

The @Monitor annotation (available since Koin Annotations 2.2.0) enables automatic performance monitoring and tracing for your Koin components through the Kotzilla Platform, the official tooling platform for Koin.

Add the Kotzilla SDK dependency:

Check the latest version on the Kotzilla documentation.

Configure the allOpen plugin to make monitored classes extensible:

Initialize Kotzilla analytics in your Koin configuration:

Simply annotate your Koin components with @Monitor:

The compiler automatically generates a proxy class that wraps your component:

Koin automatically uses the proxy instead of the original class, transparently capturing:

Monitor your ViewModels to track UI performance:

The monitoring data is automatically sent to your Kotzilla Platform workspace, providing:

Create your free Kotzilla account and configure the API key in your kotzilla.json file:

The @Monitor annotation only tracks method calls on the monitored class itself. Dependencies injected into the monitored class are not automatically monitored unless they are also annotated with @Monitor.

For complete setup instructions and advanced configuration options, visit the Kotzilla Documentation.

**Examples:**

Example 1 (kotlin):
```kotlin
dependencies {    implementation "io.kotzilla:kotzilla-core:latest.version"}
```

Example 2 (kotlin):
```kotlin
dependencies {    implementation "io.kotzilla:kotzilla-core:latest.version"}
```

Example 3 (kotlin):
```kotlin
plugins {    id "org.jetbrains.kotlin.plugin.allopen"}allOpen {    annotation("org.koin.core.annotation.Monitor")}
```

Example 4 (kotlin):
```kotlin
plugins {    id "org.jetbrains.kotlin.plugin.allopen"}allOpen {    annotation("org.koin.core.annotation.Monitor")}
```

---

## KSP Compiler Options

**URL:** https://insert-koin.io/docs/reference/koin-annotations/options

**Contents:**
- KSP Compiler Options
- Available Options​
  - KOIN_CONFIG_CHECK​
  - KOIN_LOG_TIMES​
  - KOIN_DEFAULT_MODULE​
  - KOIN_GENERATION_PACKAGE​
  - KOIN_USE_COMPOSE_VIEWMODEL​
  - KOIN_EXPORT_DEFINITIONS​
- Configuration Examples​
  - Gradle Kotlin DSL​

The Koin Annotations KSP processor supports several configuration options that can be passed during compilation to customize code generation behavior.

When using KOIN_GENERATION_PACKAGE, the provided package name must:

Invalid package names will result in compilation errors with descriptive messages.

**Examples:**

Example 1 (unknown):
```unknown
@Configuration
```

Example 2 (unknown):
```unknown
@KoinApplication
```

Example 3 (unknown):
```unknown
@Configuration
```

Example 4 (unknown):
```unknown
@KoinApplication
```

---

## Application, Configuration and Modules

**URL:** https://insert-koin.io/docs/reference/koin-annotations/modules

**Contents:**
- Application, Configuration and Modules
- Application Bootstrap with @KoinApplication​
- Configuration Management with @Configuration​
  - Basic Configuration Usage​
  - Multiple Configuration Support​
  - Environment-Specific Configurations​
  - Using Configurations with @KoinApplication​
- Default Module (Deprecated since 1.3.0)​
- Class Module with @Module​
- Components Scan with @ComponentScan​

To create a complete Koin application bootstrap, you can use the @KoinApplication annotation on an entry point class. This annotation helps generate Koin application bootstrap functions:

This generates two functions for starting your Koin application:

Both generated functions support custom configuration:

The @KoinApplication annotation supports:

When no configurations are specified, it automatically loads the "default" configuration.

The @Configuration annotation allows you to organize modules into different configurations (environments, flavors, etc.). This is useful for organizing modules by deployment environment or feature sets.

The default configuration is named "default", can be used with @Configuration or @Configuration("default")

You need to use the @KoinApplication to be able to scan modules from configuration:

A module can be associated with multiple configurations:

By default, the @KoinApplication is loading all default configurations (modules tagged with @Configuration)

You can also reference these configurations in your application bootstrap:

The default module approach is deprecated since Annotations 1.3.0. We recommend using explicit modules with @Module and @Configuration annotations for better organization and clarity.

While using definitions, you may need to organize them in modules or not. Previously, you could use the "default" generated module to host definitions without explicit modules.

If you don't want to specify any module, Koin provides a default one to host all your definitions. The defaultModule is ready to be used directly:

Recommended approach: Instead of using the default module, organize your definitions in explicit modules:

Don't forget to use the org.koin.ksp.generated.* import

To declare a module, just tag a class with @Module annotation:

To load your module in Koin, just use the .module extension generated for any @Module class. Just create a new instance of your module MyModule().module:

Don't forget to use the org.koin.ksp.generated.* import

To scan and gather annotated components into a module, just use the @ComponentScan annotation on a module:

This will scan the current package and subpackages for annotated components. You can specify to scan a given package with @ComponentScan("com.my.package")

When using @ComponentScan annotation, KSP traverses across all Gradle modules for the same package. (since 1.4)

To define a definition directly in your code, you can annotate a function with definition annotations:

Note: @InjectedParam (for injected parameters from startKoin) and @Property (for property injection) are also usable on function members. See the definitions documentation for more details on these annotations.

To include other class modules in your module, use the includes attribute of the @Module annotation:

This way you can just run your root module:

**Examples:**

Example 1 (unknown):
```unknown
@KoinApplication
```

Example 2 (kotlin):
```kotlin
@KoinApplication // load default configurationobject MyApp@KoinApplication(    configurations = ["default", "production"],     modules = [MyModule::class])object MyApp
```

Example 3 (kotlin):
```kotlin
@KoinApplication // load default configurationobject MyApp@KoinApplication(    configurations = ["default", "production"],     modules = [MyModule::class])object MyApp
```

Example 4 (kotlin):
```kotlin
// The import below gives you access to generated extension functionsimport org.koin.ksp.generated.*fun main() {    // Option 1: Start Koin directly    MyApp.startKoin()        // Option 2: Get KoinApplication instance    val koinApp = MyApp.koinApplication()}
```

---
