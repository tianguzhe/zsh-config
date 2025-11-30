# Hilt - Other

**Pages:** 3

---

## Dependency injection with Hilt Stay organized with collections Save and categorize content based on your preferences.

**URL:** https://developer.android.com/training/dependency-injection/hilt-android

**Contents:**
- Dependency injection with Hilt Stay organized with collections Save and categorize content based on your preferences.
- Adding dependencies
  - Groovy
  - Kotlin
  - Groovy
  - Kotlin
  - Groovy
  - Kotlin
- Hilt application class
  - Kotlin

Hilt is a dependency injection library for Android that reduces the boilerplate of doing manual dependency injection in your project. Doing manual dependency injection requires you to construct every class and its dependencies by hand, and to use containers to reuse and manage dependencies.

Hilt provides a standard way to use DI in your application by providing containers for every Android class in your project and managing their lifecycles automatically. Hilt is built on top of the popular DI library Dagger to benefit from the compile-time correctness, runtime performance, scalability, and Android Studio support that Dagger provides. For more information, see Hilt and Dagger.

This guide explains the basic concepts of Hilt and its generated containers. It also includes a demonstration of how to bootstrap an existing app to use Hilt.

First, add the hilt-android-gradle-plugin plugin to your project's root build.gradle file:

Then, apply the Gradle plugin and add these dependencies in your app/build.gradle file:

Hilt uses Java 8 features. To enable Java 8 in your project, add the following to the app/build.gradle file:

All apps that use Hilt must contain an Application class that is annotated with @HiltAndroidApp.

@HiltAndroidApp triggers Hilt's code generation, including a base class for your application that serves as the application-level dependency container.

This generated Hilt component is attached to the Application object's lifecycle and provides dependencies to it. Additionally, it is the parent component of the app, which means that other components can access the dependencies that it provides.

Once Hilt is set up in your Application class and an application-level component is available, Hilt can provide dependencies to other Android classes that have the @AndroidEntryPoint annotation:

Hilt currently supports the following Android classes:

If you annotate an Android class with @AndroidEntryPoint, then you also must annotate Android classes that depend on it. For example, if you annotate a fragment, then you must also annotate any activities where you use that fragment.

@AndroidEntryPoint generates an individual Hilt component for each Android class in your project. These components can receive dependencies from their respective parent classes as described in Component hierarchy.

To obtain dependencies from a component, use the @Inject annotation to perform field injection:

Classes that Hilt injects can have other base classes that also use injection. Those classes don't need the @AndroidEntryPoint annotation if they're abstract.

To learn more about which lifecycle callback an Android class gets injected in, see Component lifetimes.

To perform field injection, Hilt needs to know how to provide instances of the necessary dependencies from the corresponding component. A binding contains the information necessary to provide instances of a type as a dependency.

One way to provide binding information to Hilt is constructor injection. Use the @Inject annotation on the constructor of a class to tell Hilt how to provide instances of that class:

The parameters of an annotated constructor of a class are the dependencies of that class. In the example, AnalyticsAdapter has AnalyticsService as a dependency. Therefore, Hilt must also know how to provide instances of AnalyticsService.

Sometimes a type cannot be constructor-injected. This can happen for multiple reasons. For example, you cannot constructor-inject an interface. You also cannot constructor-inject a type that you do not own, such as a class from an external library. In these cases, you can provide Hilt with binding information by using Hilt modules.

A Hilt module is a class that is annotated with @Module. Like a Dagger module, it informs Hilt how to provide instances of certain types. Unlike Dagger modules, you must annotate Hilt modules with @InstallIn to tell Hilt which Android class each module will be used or installed in.

Dependencies that you provide in Hilt modules are available in all generated components that are associated with the Android class where you install the Hilt module.

Consider the AnalyticsService example. If AnalyticsService is an interface, then you cannot constructor-inject it. Instead, provide Hilt with the binding information by creating an abstract function annotated with @Binds inside a Hilt module.

The @Binds annotation tells Hilt which implementation to use when it needs to provide an instance of an interface.

The annotated function provides the following information to Hilt:

The Hilt module AnalyticsModule is annotated with @InstallIn(ActivityComponent.class) because you want Hilt to inject that dependency into ExampleActivity. This annotation means that all of the dependencies in AnalyticsModule are available in all of the app's activities.

Interfaces are not the only case where you cannot constructor-inject a type. Constructor injection is also not possible if you don't own the class because it comes from an external library (classes like Retrofit, OkHttpClient, or Room databases), or if instances must be created with the builder pattern.

Consider the previous example. If you don't directly own the AnalyticsService class, you can tell Hilt how to provide instances of this type by creating a function inside a Hilt module and annotating that function with @Provides.

The annotated function supplies the following information to Hilt:

In cases where you need Hilt to provide different implementations of the same type as dependencies, you must provide Hilt with multiple bindings. You can define multiple bindings for the same type with qualifiers.

A qualifier is an annotation that you use to identify a specific binding for a type when that type has multiple bindings defined.

Consider the example. If you need to intercept calls to AnalyticsService, you could use an OkHttpClient object with an interceptor. For other services, you might need to intercept calls in a different way. In that case, you need to tell Hilt how to provide two different implementations of OkHttpClient.

First, define the qualifiers that you will use to annotate the @Binds or @Provides methods:

Then, Hilt needs to know how to provide an instance of the type that corresponds with each qualifier. In this case, you could use a Hilt module with @Provides. Both methods have the same return type, but the qualifiers label them as two different bindings:

You can inject the specific type that you need by annotating the field or parameter with the corresponding qualifier:

As a best practice, if you add a qualifier to a type, add qualifiers to all the possible ways to provide that dependency. Leaving the base or common implementation without a qualifier is error-prone and could result in Hilt injecting the wrong dependency.

Hilt provides some predefined qualifiers. For example, as you might need the Context class from either the application or the activity, Hilt provides the @ApplicationContext and @ActivityContext qualifiers.

Suppose that the AnalyticsAdapter class from the example needs the context of the activity. The following code demonstrates how to provide the activity context to AnalyticsAdapter:

For other predefined bindings available in Hilt, see Component default bindings.

For each Android class in which you can perform field injection, there's an associated Hilt component that you can refer to in the @InstallIn annotation. Each Hilt component is responsible for injecting its bindings into the corresponding Android class.

The previous examples demonstrated the use of ActivityComponent in Hilt modules.

Hilt provides the following components:

Hilt automatically creates and destroys instances of generated component classes following the lifecycle of the corresponding Android classes.

By default, all bindings in Hilt are unscoped. This means that each time your app requests the binding, Hilt creates a new instance of the needed type.

In the example, every time Hilt provides AnalyticsAdapter as a dependency to another type or through field injection (as in ExampleActivity), Hilt provides a new instance of AnalyticsAdapter.

However, Hilt also allows a binding to be scoped to a particular component. Hilt only creates a scoped binding once per instance of the component that the binding is scoped to, and all requests for that binding share the same instance.

The table below lists scope annotations for each generated component:

In the example, if you scope AnalyticsAdapter to the ActivityComponent using @ActivityScoped, Hilt provides the same instance of AnalyticsAdapter throughout the life of the corresponding activity:

Suppose that AnalyticsService has an internal state that requires the same instance to be used every time—not only in ExampleActivity, but anywhere in the app. In this case, it is appropriate to scope AnalyticsService to the SingletonComponent. The result is that whenever the component needs to provide an instance of AnalyticsService, it provides the same instance every time.

The following example demonstrates how to scope a binding to a component in a Hilt module. A binding's scope must match the scope of the component where it is installed, so in this example you must install AnalyticsService in SingletonComponent instead of ActivityComponent:

To learn more about Hilt component scopes, see Scoping in Android and Hilt.

Installing a module into a component allows its bindings to be accessed as a dependency of other bindings in that component or in any child component below it in the component hierarchy:

Each Hilt component comes with a set of default bindings that Hilt can inject as dependencies into your own custom bindings. Note that these bindings correspond to the general activity and fragment types and not to any specific subclass. This is because Hilt uses a single activity component definition to inject all activities. Each activity has a different instance of this component.

The application context binding is also available using @ApplicationContext. For example:

The activity context binding is also available using @ActivityContext. For example:

Hilt comes with support for the most common Android classes. However, you might need to perform field injection in classes that Hilt doesn't support.

In those cases, you can create an entry point using the @EntryPoint annotation. An entry point is the boundary between code that is managed by Hilt and code that is not. It is the point where code first enters into the graph of objects that Hilt manages. Entry points allow Hilt to use code that Hilt does not manage to provide dependencies within the dependency graph.

For example, Hilt doesn't directly support content providers. If you want a content provider to use Hilt to get some dependencies, you need to define an interface that is annotated with @EntryPoint for each binding type that you want and include qualifiers. Then add @InstallIn to specify the component in which to install the entry point as follows:

To access an entry point, use the appropriate static method from EntryPointAccessors. The parameter should be either the component instance or the @AndroidEntryPoint object that acts as the component holder. Make sure that the component you pass as a parameter and the EntryPointAccessors static method both match the Android class in the @InstallIn annotation on the @EntryPoint interface:

In this example, you must use the ApplicationContext to retrieve the entry point because the entry point is installed in SingletonComponent. If the binding that you wanted to retrieve were in the ActivityComponent, you would instead use the ActivityContext.

Hilt is built on top of the Dagger dependency injection library, providing a standard way to incorporate Dagger into an Android application.

With respect to Dagger, the goals of Hilt are as follows:

Because the Android operating system instantiates many of its own framework classes, using Dagger in an Android app requires you to write a substantial amount of boilerplate. Hilt reduces the boilerplate code that is involved in using Dagger in an Android application. Hilt automatically generates and provides the following:

Dagger and Hilt code can coexist in the same codebase. However, in most cases it is best to use Hilt to manage all of your usage of Dagger on Android. To migrate a project that uses Dagger to Hilt, see the migration guide and the Migrating your Dagger app to Hilt codelab.

To learn more about Hilt, see the following additional resources.

---

## Hilt

**URL:** https://developer.android.com/jetpack/androidx/releases/hilt

**Contents:**
- Hilt
- Feedback
- Hilt Version 1.3
  - Version 1.3.0
  - Version 1.3.0-rc01
  - Version 1.3.0-beta01
  - Version 1.3.0-alpha02
  - Version 1.3.0-alpha01
- Hilt Version 1.2
  - Version 1.2.0

Your feedback helps make Jetpack better. Let us know if you discover new issues or have ideas for improving this library. Please take a look at the existing issues in this library before you create a new one. You can add your vote to an existing issue by clicking the star button.

See the Issue Tracker documentation for more information.

androidx.hilt:hilt-*:1.3.0 is released. Version 1.3.0 contains these commits.

Important changes since 1.2.0:

androidx.hilt:hilt-*:1.3.0-rc01 is released with no notable changes since 1.3.0-beta01. Version 1.3.0-rc01 contains these commits.

androidx.hilt:hilt-*:1.3.0-beta01 is released. Version 1.3.0-beta01 contains these commits.

androidx.hilt:hilt-*:1.3.0-alpha02 is released. Version 1.3.0-alpha02 contains these commits.

androidx.hilt:hilt-*:1.3.0-alpha01 is released. Version 1.3.0-alpha01 contains these commits.

androidx.hilt:hilt-*:1.2.0 is released. Version 1.2.0 contains these commits.

Important changes since 1.1.0

androidx.hilt:hilt-*:1.2.0-rc01 is released. Version 1.2.0-rc01 contains these commits.

androidx.hilt:hilt-*:1.2.0-beta01 is released. Version 1.2.0-beta01 contains these commits.

androidx.hilt:hilt-*:1.2.0-alpha01 is released. Version 1.2.0-alpha01 contains these commits.

androidx.hilt:hilt-*:1.1.0 is released. Version 1.1.0 contains these commits.

Major changes since 1.0.0

androidx.hilt:hilt-*:1.1.0-rc01 is released. Version 1.1.0-rc01 contains these commits.

androidx.hilt:hilt-common:1.1.0-beta01, androidx.hilt:hilt-compiler:1.1.0-beta01, androidx.hilt:hilt-work:1.1.0-beta01, androidx.hilt:hilt-navigation:1.1.0-beta01, androidx.hilt:hilt-navigation-compose:1.1.0-beta01, and androidx.hilt:hilt-navigation-fragment:1.1.0-beta01 are released.

androidx.hilt:hilt-common:1.1.0-alpha01, androidx.hilt:hilt-compiler:1.1.0-alpha01, and androidx.hilt:hilt-work:1.1.0-alpha01 are released. Version 1.1.0-alpha01 contains these commits.

androidx.hilt:hilt-navigation-fragment:1.1.0-alpha02 is released. Version 1.1.0-alpha02 contains these commits.

androidx.hilt:hilt-navigation:1.1.0-alpha02 is released. Version 1.1.0-alpha02 contains these commits.

androidx.hilt:hilt-navigation:1.1.0-alpha01 is released. Version 1.1.0-alpha01 contains these commits.

androidx.hilt:hilt-navigation-compose:1.1.0-alpha01 is released. Version 1.1.0-alpha01 contains these commits.

androidx.hilt:hilt-navigation-compose:1.0.0 is released. Version 1.0.0 contains these commits.

Major features of 1.0.0

The androidx.hilt:hilt-navigation-compose artifact provides APIs that allow users to get a @HiltViewModel annotated ViewModel from a Navigation back stack entry within a Compose application using :navigation-compose.

The function hiltViewModel() returns an existing ViewModel or creates a new one scoped to the current navigation graph present on the NavController back stack. The function can optionally take a NavBackStackEntry to scope the ViewModel to a parent back stack entry.

androidx.hilt:hilt-navigation-compose:1.0.0-rc01 is released with no changes since 1.0.0-beta01. Version 1.0.0-rc01 contains these commits.

androidx.hilt:hilt-navigation-compose:1.0.0-beta01 is released. Version 1.0.0-beta01 contains these commits.

androidx.hilt:hilt-navigation-compose:1.0.0-alpha03 is released. Version 1.0.0-alpha03 contains these commits.

androidx.hilt:hilt-navigation-compose:1.0.0-alpha02 is released. Version 1.0.0-alpha02 contains these commits.

Compose Compatibility

androidx.hilt:hilt-navigation-compose:1.0.0-alpha01 is released. Version 1.0.0-alpha01 contains these commits.

androidx.hilt:hilt-*:1.1.0-beta01 is released. Version 1.1.0-beta01 contains these commits.

androidx.hilt:hilt-*:1.1.0-beta01 is released with no changes since 1.1.0-alpha*.

androidx.hilt:hilt-*:1.0.0 is released. Version 1.0.0 contains these commits.

Major features of 1.0.0

The androidx.hiltartifacts offers extensions for integrating Hilt with various other AndroidX libraries, such as WorkManager and Navigation. To see a list of features and examples check out the integration documentation.

androidx.hilt:hilt-*:1.0.0-beta01 is released. Version 1.0.0-beta01 contains these commits.

androidx.hilt:hilt-*:1.0.0-alpha03 is released. Version 1.0.0-alpha03 contains these commits.

androidx.hilt:hilt-*:1.0.0-alpha02 is released. Version 1.0.0-alpha02 contains these commits.

androidx.hilt:hilt-*:1.0.0-alpha01 is released. Version 1.0.0-alpha01 contains these commits.

The androidx.hilt package and libraries extend the functionality of Dagger Hilt to enable dependency injection of certain classes from the androidx libraries.

---

## Hilt in multi-module apps Stay organized with collections Save and categorize content based on your preferences.

**URL:** https://developer.android.com/training/dependency-injection/hilt-multi-module

**Contents:**
- Hilt in multi-module apps Stay organized with collections Save and categorize content based on your preferences.
- Hilt in feature modules
  - Kotlin
  - Java
  - Kotlin
  - Java
  - Kotlin
  - Java
  - Kotlin
  - Java

Hilt code generation needs access to all the Gradle modules that use Hilt. The Gradle module that compiles your Application class needs to have all Hilt modules and constructor-injected classes in its transitive dependencies.

If your multi-module project is composed of regular Gradle modules, then you can use Hilt as described in Dependency injection with Hilt. However, this is not the case with apps that include feature modules.

In feature modules, the way that modules usually depend on each other is inverted. Therefore, Hilt cannot process annotations in feature modules. You must use Dagger to perform dependency injection in your feature modules.

You must use component dependencies to solve this problem with feature modules. Follow these steps:

Consider the example from the Dependency injection with Hilt page. Suppose you add a login feature module to your project. You implement the login feature with an activity called LoginActivity. This means that you can get bindings only from the application component.

For this feature, you need an OkHttpClient with the authInterceptor binding.

First, create an @EntryPoint interface installed in the SingletonComponent with the bindings that the login module needs:

To perform field injection in the LoginActivity, create a Dagger component that depends on the @EntryPoint interface:

Once those steps are complete, use Dagger as usual in your feature module. For example, you can use the bindings from the SingletonComponent as a dependency of a class:

To perform field injection, create an instance of the Dagger component using the applicationContext to get the SingletonComponent dependencies:

For more context on module dependencies in feature modules, see Component dependencies with feature modules.

For more information about Dagger on Android, see Using Dagger in Android apps.

---
