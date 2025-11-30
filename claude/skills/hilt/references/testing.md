# Hilt - Testing

**Pages:** 10

---

## Robolectric testing

**URL:** https://dagger.dev/hilt/robolectric-testing.html

**Contents:**
- Robolectric testing
- Setting the test application
  - Using @Config
  - Using robolectric.properties

Warning: See here for limitations when running Robolectric tests via Android Studio when using the Hilt Gradle plugin.

Hilt’s testing APIs are built to be agnostic of the particular testing environment; however, the instructions for setting up the application class in your test will depend on whether you are using Robolectric or Android instrumentation tests.

For Robolectric tests, the application can be set either locally using @Config or globally using robolectric.properties. For Hilt tests, the application must either be HiltTestApplication or one of Hilt’s custom test applications.

Note: This setup is not particular to Hilt. See the official Robolectric documentation for more details.

The Hilt application class can be set locally using @Config. To set the application, just annotate the test (or test method) with @Config and set the value of the annotation to the desired application class.

The Hilt application class can be set globally using the robolectric.properties file. To set the application, just create the robolectric.properties file in the appropriate resources package, and set the Hilt test application class.

This approach can be useful when a test needs to run in both Robolectric and Android instrumentation environments, since the @Config annotation cannot be used with Android instrumentation tests.

**Examples:**

Example 1 (java):
```java
@HiltAndroidTest
@Config(application = HiltTestApplication.class)
public class FooTest {...}
```

Example 2 (csharp):
```csharp
@HiltAndroidTest
@Config(application = HiltTestApplication.class)
public class FooTest {...}
```

Example 3 (kotlin):
```kotlin
@HiltAndroidTest
@Config(application = HiltTestApplication::class)
class FooTest {...}
```

Example 4 (unknown):
```unknown
@HiltAndroidTest
@Config(application = HiltTestApplication::class)
class FooTest {...}
```

---

## Testing

**URL:** https://dagger.dev/hilt/testing.html

**Contents:**
- Testing
- Introduction
- Test Setup
- Accessing bindings
  - Accessing SingletonComponent bindings
  - Accessing ActivityComponent bindings
  - Accessing FragmentComponent bindings
- Replacing bindings
  - @TestInstallIn
  - @UninstallModules

Hilt makes testing easier by bringing the power of dependency injection to your Android tests. Hilt allows your tests to easily access Dagger bindings, provide new bindings, or even replace bindings. Each test gets its own set of Hilt components so that you can easily customize bindings at a per-test level.

Many of the testing APIs and functionality described in this documentation are based upon an unstated philosophy of what makes a good test. For more details on Hilt’s testing philosophy see here.

Note: For Gradle users, make sure to first add the Hilt test build dependencies as described in the Gradle setup guide.

To use Hilt in a test:

Note that setting the application class for a test (step 3 above) is dependent on whether the test is a Robolectric or instrumentation test. For a more detailed guide on how to set the test application for a particular test environment, see Robolectric testing or Instrumentation testing. The remainder of this doc applies to both Robolectric and instrumentation tests.

If your test requires a custom application class, see the section on custom test application.

If your test requires multiple test rules, see the section on Hilt rule order to determine the proper placement of the Hilt rule.

A test often needs to request bindings from its Hilt components. This section describes how to request bindings from each of the different components.

An SingletonComponent binding can be injected directly into a test using an @Inject annotated field. Injection doesn’t occur until calling HiltAndroidRule#inject().

Requesting an ActivityComponent binding requires an instance of a Hilt Activity. One way to do this is to define a nested activity within your test that contains an @Inject field for the binding you need. Then create an instance of your test activity to get the binding.

Alternatively, if you already have a Hilt activity instance available in your test, you can get any ActivityComponent binding using an EntryPoint.

A FragmentComponent binding can be accessed in a similar way to an ActivityComponent binding. The main difference is that accessing a FragmentComponent binding requires both an instance of a Hilt Activity and a Hilt Fragment.

Alternatively, if you already have a Hilt fragment instance available in your test, you can get any FragmentComponent binding using an EntryPoint.

Warning:Hilt does not currently support FragmentScenario because there is no way to specify an activity class, and Hilt requires a Hilt fragment to be contained in a Hilt activity. One workaround for this is to launch a Hilt activity and then attach your fragment.

It’s often useful for tests to be able to replace a production binding with a fake or mock binding to make tests more hermetic or easier to control in test. The next sections describe some ways to accomplish this in Hilt.

A Dagger module annotated with @TestInstallIn allows users to replace an existing @InstallIn module for all tests in a given source set. For example, suppose we want to replace ProdDataServiceModule with FakeDataServiceModule. We can accomplish this by annotating FakeDataServiceModule with @TestInstallIn, as shown below:

A @TestInstallIn module can be included in the same source set as your test sources, as shown below:

However, if a particular @TestInstallIn module is needed in multiple Gradle modules, we recommend putting it in its own Gradle module (usually the same one as the fake), as shown below:

Putting the @TestInstallIn in the same Gradle module as the fake has a number of benefits. First, it ensures that all clients that depend on the fake properly replace the production module with the test module. It also avoids duplicating FakeDataServiceModule for every Gradle module that needs it.

Note that @TestInstallIn applies to all tests in a given source set. For cases where an individual test needs to replace a binding that is specific to the given test, the test can either be moved into its own source set, or it can use Hilt testing features such as @UninstallModules, @BindValue, and nested @InstallIn modules to replace bindings specific to that test. These features will be described in more detail in the following sections.

Warning:Test classes that use @UninstallModules, @BindValue, or nested @InstallIn modules result in a custom component being generated for that test. While this may be fine in most cases, it does have an impact on build speed. The recommended approach is to use @TestInstallIn modules instead.

A test annotated with @UninstallModules can uninstall production @InstallIn modules for that particular test (unlike @TestInstallIn, it has no effect on other tests). Once a module is uninstalled, the test can install new, test-specific bindings for that particular test.

There are two ways to install a new binding for a particular test:

These two approaches are described in more detail in the next sections.

Note: @UninstallModules can only uninstall @InstallIn modules, not @TestInstallIn modules. If a @TestInstallIn module needs to be uninstalled the module must be split into two separate modules: a @TestInstallIn module that replaces the production module with no bindings (i.e. only removes the production module), and a @InstallIn module that provides the standard fake so that @UninstallModules can uninstall the provided fake.

Warning:Test classes that use @UninstallModules, @BindValue, or nested @InstallIn modules result in a custom component being generated for that test. While this may be fine in most cases, it does have an impact on build speed. The recommended approach is to use @TestInstallIn modules instead.

Normally, @InstallIn modules are installed in the Hilt components of every test. However, if a binding needs to be installed only in a particular test, that can be accomplished by nesting the @InstallIn module within the test class.

Thus, if there is another test that needs to provision the same binding with a different implementation, it can do that without a duplicate binding conflict.

In addition to static nested @InstallIn modules, Hilt also supports inner (non-static) @InstallIn modules within tests. Using an inner module allows the @Provides methods to reference members of the test instance.

Note: Hilt does not support @InstallIn modules with constructor parameters.

Warning:Test classes that use @UninstallModules, @BindValue, or nested @InstallIn modules result in a custom component being generated for that test. While this may be fine in most cases, it does have an impact on build speed. The recommended approach is to use @TestInstallIn modules instead.

For simple bindings, especially those that need to also be accessed in the test methods, Hilt provides a convenience annotation to avoid the boilerplate of creating a module and method normally required to provision a binding.

@BindValue is an annotation that allows you to easily bind fields in your test into the Dagger graph. To use it, just annotate a field with @BindValue and it will be bound to the declared field type with any qualifiers that are present on the field.

Note that @BindValue does not support the use of scope annotations since the binding’s scope is tied to the field and controlled by the test. The field’s value is queried whenever it is requested, so it can be mutated as necessary for your test. If you want the binding to be effectively singleton, just ensure that the field is only set once per test case, e.g. by setting the field’s value from either the field’s initializer or from within an @Before method of the test.

Similarly, Hilt also has a convenience annotation for multibindings with @BindValueIntoSet, @BindElementsIntoSet, and @BindValueIntoMap to support @IntoSet, @ElementsIntoSet, and @IntoMap respectively. (Note that @BindValueIntoMap requires the field to also be annotated with a map key annotation.)

Warning:Be careful when using @BindValue or non-static inner modules with ActivityScenarioRule. ActivityScenarioRule creates the activity before calling the @Before method, so if an @BindValue field is initialized in @Before (or later), then it’s possible for the Activity to inject the binding in its unitialized state. To avoid this, try initializing the @BindValue field in the field’s initializer.

Every Hilt test must use a Hilt test application as the Android application class. Hilt comes with a default test application, HiltTestApplication, which extends MultiDexApplication; however, there are cases where a test may need to use a different base class.

If your test requires a custom base class, @CustomTestApplication can be used to generate a Hilt test application that extends the given base class.

To use @CustomTestApplication, just annotate a class or interface with @CustomTestApplication and specify the base class in the annotation value:

In the above example, Hilt will generate an application named MyCustom_Application that extends MyBaseApplication. In general, the name of the generated application will be the name of the annotated class appended with _Application. If the annotated class is a nested class, the name will also include the name of the outer class separated by an underscore. Note that the class that is annotated is irrelevant, other than for the name of the generated application.

As a best practice, avoid using @CustomTestApplication and instead use HiltTestApplication in your tests. In general, having your Activity, Fragment, etc. be independent of the parent they are contained in makes it easier to compose and reuse it in the future.

However, if you must use a custom base application, there are some subtle differences with the production lifecycle to be aware of.

One difference is that instrumentation tests use the same application instance for every test and test case. Thus, it’s easy to accidentally leak state across test cases when using a custom test application. Instead, it’s better to avoid storing any test or test case dependendent state in your application.

Another difference is that the Hilt component in a test application is not created in super#onCreate. This restriction is mainly due to fact that some of Hilt’s features (e.g. @BindValue) rely on the test instance, which is not available in tests until after Application#onCreate is called. Thus, unlike production applications, custom base applications must avoid calling into the component during Application#onCreate. This includes injecting members into the application. To prevent this issue, Hilt doesn’t allow injection in the base application.

If your test uses multiple test rules, make sure that the HiltAndroidRule runs before any other test rules that require access to the Hilt component. For example ActivityScenarioRule calls Activity#onCreate, which (for Hilt activities) requires the Hilt component to perform injection. Thus, the ActivityScenarioRule should run after the HiltAndroidRule to ensure that the component has been properly initialized.

Note: If you’re using JUnit < 4.13 use RuleChain to specify the order instead.

**Examples:**

Example 1 (java):
```java
@HiltAndroidTest
public class FooTest {
  @Rule public HiltAndroidRule hiltRule = new HiltAndroidRule(this);
  ...
}
```

Example 2 (csharp):
```csharp
@HiltAndroidTest
public class FooTest {
  @Rule public HiltAndroidRule hiltRule = new HiltAndroidRule(this);
  ...
}
```

Example 3 (kotlin):
```kotlin
@HiltAndroidTest
class FooTest {
  @get:Rule val hiltRule = HiltAndroidRule(this)
  ...
}
```

Example 4 (unknown):
```unknown
@HiltAndroidTest
class FooTest {
  @get:Rule val hiltRule = HiltAndroidRule(this)
  ...
}
```

---

## Hilt Testing Philosophy

**URL:** https://dagger.dev/hilt/testing-philosophy.html

**Contents:**
- Hilt Testing Philosophy
- Overview
- What to test
- Using real dependencies
- Hilt, DI, and testing
- Downsides of manual instantiation
  - Direct instantiation encourages mocks
  - Direct instantiation encourages incorrect scoping
  - Direct instantiation encodes implementation details in the test
- Summary

This page aims to explain the testing practices that Hilt is built upon. A lot of the APIs and functionality in Hilt (and certain lack of functionality as well) were created on an unstated philosophy of what makes a good test. The notion of a good test is not universally agreed upon though, so this document aims to clarify the Hilt team’s testing philosophy.

Hilt encourages testing as much as possible from an outside user’s perspective. An outside user’s perspective can mean many things. It could mean the actual users of your app or service, but it can also be more scoped down to the users of your API or class.

The key part is that tests shouldn’t encode implementation details. Relying on implementation details, like checking that an internal method has been called, causes the test to be brittle. If a refactoring changes the name of an internal method, a good test should not have to be updated. The only changes that should break existing tests are those that are changing your user-visible behavior.

The Hilt testing philosophy doesn’t prescribe strict rules such as every class must have its own test. In fact, usually such a rule would violate the above principle of testing from the user’s perspective. Tests should be only as small as necessary to make them convenient to write and run (e.g. small enough to be fast or not resource intensive). All else being equal, tests should, in this order, prefer to:

However, there are trade offs. Using real dependencies/real DI in tests may be prohibitively difficult for one or both of the following reasons:

Hilt was built to solve the first issue of set up (more on that below). Performance can be an issue but is often not a problem for most dependencies. This likely is only an issue when using dependencies with significant I/O. So, if a test can be written more conveniently and robustly by using more real dependencies without significantly degrading performance, it should be written using those dependencies. For those classes that do come with large negative effects in tests, Hilt provides a means to switch out the bindings.

Using more real dependencies has significant advantages:

If the real dependency is not possible to use though, a standard fake provided by the library is usually the next best option. A standardized fake is better than a mock because it is more likely to be in sync with the production code if it is maintained by the library authors and thus provides more robust coverage. For these reasons, mocks are typically a last resort.

With those foundations explained, we now get into the specifics of Hilt, DI, and testing. In line with the philosophy of using real objects, Hilt’s answer is to use dependency injection / Dagger in tests. This is more realistic because objects are created as they would be in production code. It means that tests are not any more brittle than production code would be and it makes it easier to use real objects. In fact, for types that have @Inject constructors, it is actually easier and less code to follow this advice and use the real code than it is to configure and bind a mock.

Unfortunately, this kind of testing without Hilt has traditionally been difficult in practice due to the boilerplate and extra work to set up Dagger in the tests. However, Hilt generates the boilerplate for you and has a clear story for setting up different configurations of bindings for tests when you do need a fake or a mock. With Hilt, this issue should no longer be a deterrent to writing tests with Dagger and therefore easily using real dependencies.

One of the common alternatives to using Dagger in unit tests is to instantiate an object directly by manually calling its constructor (or @Provides method). This, unfortunately, ends up having significant drawbacks, though it is understandable advice given the difficulty of using Dagger in tests without Hilt.

For example, let’s say we have a Foo class that we want to test:

The test directly instantiates Foo by calling its constructor. At first glance, this seems like a very simple and reasonable thing to do; however, things start to unravel as you try to supply Foo’s dependencies. In this case, Foo depends on Bar. Bar may have other dependencies of its own. As we’ll see in the following sections, supplying all of these dependencies manually can lead brittle tests.

From the previously discussed testing philosophy, we should prefer to get a real Bar class. However, how should we do that? This actually is just a recursion of getting a real Foo class to test: you would have to instantiate it yourself and if Bar has dependencies of its own, then that would require similarly instantiating those. In order to not go too deep you would likely need to start using a fake or a mock, not because of the effects on speed or performance of the test, but simply to avoid too much brittle boilerplate that causes maintenance problems. This is not a good reason to use a fake or a mock, and yet you are forced to do so anyway.

An alternative, as discussed above, is to use a standard fake, which may help cut dependencies and reduce the maintenance burden of direct instantiation. However, even that is not always that simple. Many times a good fake will similarly have dependencies it needs. For example, a FakeBar may end up needing to take in a FakeClock if the real Bar took a Clock. This is because a FakeClock is often a coordination point between different classes. (Imagine if Foo had another dependency Baz that also used a clock, you would want the FakeBaz to use the same FakeClock instance so things are coordinated when time is advanced). Managing these dependencies can quickly get out of hand.

This usually leads test authors to mocks. The mock solves the issue of tediously following these dependency chains, but has significant drawbacks in that it can easily get out of date silently and make the test useless in its overall goal of finding real bugs. Because no one checks the mock behavior besides the test author, this usually means that after enough time, there is a decent likelihood that the test is no longer testing a useful scenario.

By directly instantiating a dependency, you are assuming responsibility for correctly scoping that dependency. It is easy to accidentally create multiple instances of scoped bindings, or to provide the same instance of an unscoped binding multiple times.

For example, a FakeClock may contain global state that maintains the current time and allows advancing this time manually in tests. Because of this, it is marked as @Singleton so that the code under test and the test itself reference the same instance. But if an additional instance is directly instantiated by the test, multiple instances would exist. This would lead to code under test observing skewed timestamps, or the test advancing the current time to no effect.

Additionally, manually writing Provider and Lazy constructor parameters for scoped types is error-prone. You need to know whether the dependency is scoped, and store an instance of the object at the right level. For example, you would need to associate any @ActivityScoped bindings with the Activity under test, and recreate the dependency if the Activity undergoes a configuration change. To accurately reflect the real Dagger behavior, all of this would need to be made thread-safe.

Finally, if the scope of a dependency is later changed, the tests using that dependency will not actually reflect that change without manual updates. This prevents tests from detecting unintended changes due to a change in scope.

Direct instantiation also breaks the philosophy of not encoding implementation details in a test because the constructor call encodes details of its dependencies. If Bar were an @Inject constructor type, there is no reason a user of Foo needs to know about the existence of the Bar class as it could easily be an implementation detail from refactoring logic in Foo into another class private to the library.

To illustrate this point, consider if Foo had two dependencies like Foo(Bar, Baz). In Dagger, switching the order of these parameters on the @Inject constructor is a no-op. Yet if we were to test Foo via direct instantiation, we’d still have to update the test. Similarly, adding a usage of a new @Inject class or an optional binding would similarly be an invisible change for production users of the class, yet the test would still need to be updated.

Hilt was designed to fix the downside of using Dagger in tests in order to allow easy testing with real dependencies. Tests written using Hilt will have a better overall experience if they follow these principles.

**Examples:**

Example 1 (java):
```java
final class Foo {
  @Inject Foo(Bar bar) {...}
}
```

Example 2 (unknown):
```unknown
final class Foo {
  @Inject Foo(Bar bar) {...}
}
```

Example 3 (kotlin):
```kotlin
class Foo @Inject constructor(bar: Bar) {
}
```

Example 4 (unknown):
```unknown
class Foo @Inject constructor(bar: Bar) {
}
```

---

## Hilt testing guide Stay organized with collections Save and categorize content based on your preferences.

**URL:** https://developer.android.com/training/dependency-injection/hilt-testing

**Contents:**
- Hilt testing guide Stay organized with collections Save and categorize content based on your preferences.
- Unit tests
  - Kotlin
  - Java
- End-to-end tests
  - Adding testing dependencies
  - Groovy
  - Kotlin
  - UI test setup
  - Kotlin

One of the benefits of using dependency injection frameworks like Hilt is that it makes testing your code easier.

Hilt isn't necessary for unit tests, since when testing a class that uses constructor injection, you don't need to use Hilt to instantiate that class. Instead, you can directly call a class constructor by passing in fake or mock dependencies, just as you would if the constructor weren't annotated:

For integration tests, Hilt injects dependencies as it would in your production code. Testing with Hilt requires no maintenance because Hilt automatically generates a new set of components for each test.

To use Hilt in your tests, include the hilt-android-testing dependency in your project:

You must annotate any UI test that uses Hilt with @HiltAndroidTest. This annotation is responsible for generating the Hilt components for each test.

Also, you need to add the HiltAndroidRule to the test class. It manages the components' state and is used to perform injection on your test:

Next, your test needs to know about the Application class that Hilt automatically generates for you.

You must execute instrumented tests that use Hilt in an Application object that supports Hilt. The library provides HiltTestApplication for use in tests. If your tests need a different base application, see Custom application for tests.

You must set your test application to run in your instrumented tests or Robolectric tests. The following instructions aren't specific to Hilt, but are general guidelines on how to specify a custom application to run in tests.

To use the Hilt test application in instrumented tests, you need to configure a new test runner. This makes Hilt work for all of the instrumented tests in your project. Perform the following steps:

Next, configure this test runner in your Gradle file as described in the instrumented unit test guide. Make sure you use the full classpath:

If you use Robolectric to test your UI layer, you can specify which application to use in the robolectric.properties file:

application = dagger.hilt.android.testing.HiltTestApplication

Alternatively, you can configure the application on each test individually by using Robolectric's @Config annotation:

If you use an Android Gradle Plugin version lower than 4.2, enable transforming @AndroidEntryPoint classes in local unit tests by applying the following configuration in your module's build.gradle file:

More information about enableTransformForLocalTests in the Hilt documentation.

Once Hilt is ready to use in your tests, you can use several features to customize the testing process.

To inject types into a test, use @Inject for field injection. To tell Hilt to populate the @Inject fields, call hiltRule.inject().

See the following example of an instrumented test:

If you need to inject a fake or mock instance of a dependency, you need to tell Hilt not to use the binding that it used in production code and to use a different one instead. To replace a binding, you need to replace the module that contains the binding with a test module that contains the bindings that you want to use in the test.

For example, suppose your production code declares a binding for AnalyticsService as follows:

To replace the AnalyticsService binding in tests, create a new Hilt module in the test or androidTest folder with the fake dependency and annotate it with @TestInstallIn. All the tests in that folder are injected with the fake dependency instead.

To replace a binding in a single test instead of all tests, uninstall a Hilt module from a test using the @UninstallModules annotation and create a new test module inside the test.

Following the AnalyticsService example from the previous version, begin by telling Hilt to ignore the production module by using the @UninstallModules annotation in the test class:

Next, you must replace the binding. Create a new module within the test class that defines the test binding:

This only replaces the binding for a single test class. If you want to replace the binding for all test classes, use the @TestInstallIn annotation from the section above. Alternatively, you can put the test binding in the test module for Robolectric tests, or in the androidTest module for instrumented tests. The recommendation is to use @TestInstallIn whenever possible.

Use the @BindValue annotation to easily bind fields in your test into the Hilt dependency graph. Annotate a field with @BindValue and it will be bound under the declared field type with any qualifiers that are present for that field.

In the AnalyticsService example, you can replace AnalyticsService with a fake by using @BindValue:

This simplifies both replacing a binding and referencing a binding in your test by allowing you to do both at the same time.

@BindValue works with qualifiers and other testing annotations. For example, if you use testing libraries such as Mockito, you could use it in a Robolectric test as follows:

If you need to add a multibinding, you can use the @BindValueIntoSet and @BindValueIntoMap annotations in place of @BindValue. @BindValueIntoMap requires you to also annotate the field with a map key annotation.

Hilt also provides features to support nonstandard use cases.

If you cannot use HiltTestApplication because your test application needs to extend another application, annotate a new class or interface with @CustomTestApplication, passing in the value of the base class you want the generated Hilt application to extend.

@CustomTestApplication will generate an Application class ready for testing with Hilt that extends the application you passed as a parameter.

In the example, Hilt generates an Application named HiltTestApplication_Application that extends the BaseApplication class. In general, the name of the generated application is the name of the annotated class appended with _Application. You must set the generated Hilt test application to run in your instrumented tests or Robolectric tests as described in Test application.

If you have other TestRule objects in your test, there are multiple ways to ensure that all of the rules work together.

You can wrap the rules together as follows:

Alternatively, you can use both rules at the same level as long as the HiltAndroidRule executes first. Specify the execution order using the order attribute in the @Rule annotation. This only works in JUnit version 4.13 or higher:

It is not possible to use launchFragmentInContainer from the androidx.fragment:fragment-testing library with Hilt, because it relies on an activity that is not annotated with @AndroidEntryPoint.

Use the launchFragmentInHiltContainer code from the architecture-samples GitHub repository instead.

The @EarlyEntryPoint annotation provides an escape hatch when a Hilt entry point needs to be created before the singleton component is available in a Hilt test.

More information about @EarlyEntryPoint in the Hilt documentation.

---

## Robolectric testing

**URL:** https://dagger.dev/hilt/robolectric-testing

**Contents:**
- Robolectric testing
- Setting the test application
  - Using @Config
  - Using robolectric.properties

Warning: See here for limitations when running Robolectric tests via Android Studio when using the Hilt Gradle plugin.

Hilt’s testing APIs are built to be agnostic of the particular testing environment; however, the instructions for setting up the application class in your test will depend on whether you are using Robolectric or Android instrumentation tests.

For Robolectric tests, the application can be set either locally using @Config or globally using robolectric.properties. For Hilt tests, the application must either be HiltTestApplication or one of Hilt’s custom test applications.

Note: This setup is not particular to Hilt. See the official Robolectric documentation for more details.

The Hilt application class can be set locally using @Config. To set the application, just annotate the test (or test method) with @Config and set the value of the annotation to the desired application class.

The Hilt application class can be set globally using the robolectric.properties file. To set the application, just create the robolectric.properties file in the appropriate resources package, and set the Hilt test application class.

This approach can be useful when a test needs to run in both Robolectric and Android instrumentation environments, since the @Config annotation cannot be used with Android instrumentation tests.

**Examples:**

Example 1 (java):
```java
@HiltAndroidTest
@Config(application = HiltTestApplication.class)
public class FooTest {...}
```

Example 2 (csharp):
```csharp
@HiltAndroidTest
@Config(application = HiltTestApplication.class)
public class FooTest {...}
```

Example 3 (kotlin):
```kotlin
@HiltAndroidTest
@Config(application = HiltTestApplication::class)
class FooTest {...}
```

Example 4 (unknown):
```unknown
@HiltAndroidTest
@Config(application = HiltTestApplication::class)
class FooTest {...}
```

---

## Hilt Testing Philosophy

**URL:** https://dagger.dev/hilt/testing-philosophy

**Contents:**
- Hilt Testing Philosophy
- Overview
- What to test
- Using real dependencies
- Hilt, DI, and testing
- Downsides of manual instantiation
  - Direct instantiation encourages mocks
  - Direct instantiation encourages incorrect scoping
  - Direct instantiation encodes implementation details in the test
- Summary

This page aims to explain the testing practices that Hilt is built upon. A lot of the APIs and functionality in Hilt (and certain lack of functionality as well) were created on an unstated philosophy of what makes a good test. The notion of a good test is not universally agreed upon though, so this document aims to clarify the Hilt team’s testing philosophy.

Hilt encourages testing as much as possible from an outside user’s perspective. An outside user’s perspective can mean many things. It could mean the actual users of your app or service, but it can also be more scoped down to the users of your API or class.

The key part is that tests shouldn’t encode implementation details. Relying on implementation details, like checking that an internal method has been called, causes the test to be brittle. If a refactoring changes the name of an internal method, a good test should not have to be updated. The only changes that should break existing tests are those that are changing your user-visible behavior.

The Hilt testing philosophy doesn’t prescribe strict rules such as every class must have its own test. In fact, usually such a rule would violate the above principle of testing from the user’s perspective. Tests should be only as small as necessary to make them convenient to write and run (e.g. small enough to be fast or not resource intensive). All else being equal, tests should, in this order, prefer to:

However, there are trade offs. Using real dependencies/real DI in tests may be prohibitively difficult for one or both of the following reasons:

Hilt was built to solve the first issue of set up (more on that below). Performance can be an issue but is often not a problem for most dependencies. This likely is only an issue when using dependencies with significant I/O. So, if a test can be written more conveniently and robustly by using more real dependencies without significantly degrading performance, it should be written using those dependencies. For those classes that do come with large negative effects in tests, Hilt provides a means to switch out the bindings.

Using more real dependencies has significant advantages:

If the real dependency is not possible to use though, a standard fake provided by the library is usually the next best option. A standardized fake is better than a mock because it is more likely to be in sync with the production code if it is maintained by the library authors and thus provides more robust coverage. For these reasons, mocks are typically a last resort.

With those foundations explained, we now get into the specifics of Hilt, DI, and testing. In line with the philosophy of using real objects, Hilt’s answer is to use dependency injection / Dagger in tests. This is more realistic because objects are created as they would be in production code. It means that tests are not any more brittle than production code would be and it makes it easier to use real objects. In fact, for types that have @Inject constructors, it is actually easier and less code to follow this advice and use the real code than it is to configure and bind a mock.

Unfortunately, this kind of testing without Hilt has traditionally been difficult in practice due to the boilerplate and extra work to set up Dagger in the tests. However, Hilt generates the boilerplate for you and has a clear story for setting up different configurations of bindings for tests when you do need a fake or a mock. With Hilt, this issue should no longer be a deterrent to writing tests with Dagger and therefore easily using real dependencies.

One of the common alternatives to using Dagger in unit tests is to instantiate an object directly by manually calling its constructor (or @Provides method). This, unfortunately, ends up having significant drawbacks, though it is understandable advice given the difficulty of using Dagger in tests without Hilt.

For example, let’s say we have a Foo class that we want to test:

The test directly instantiates Foo by calling its constructor. At first glance, this seems like a very simple and reasonable thing to do; however, things start to unravel as you try to supply Foo’s dependencies. In this case, Foo depends on Bar. Bar may have other dependencies of its own. As we’ll see in the following sections, supplying all of these dependencies manually can lead brittle tests.

From the previously discussed testing philosophy, we should prefer to get a real Bar class. However, how should we do that? This actually is just a recursion of getting a real Foo class to test: you would have to instantiate it yourself and if Bar has dependencies of its own, then that would require similarly instantiating those. In order to not go too deep you would likely need to start using a fake or a mock, not because of the effects on speed or performance of the test, but simply to avoid too much brittle boilerplate that causes maintenance problems. This is not a good reason to use a fake or a mock, and yet you are forced to do so anyway.

An alternative, as discussed above, is to use a standard fake, which may help cut dependencies and reduce the maintenance burden of direct instantiation. However, even that is not always that simple. Many times a good fake will similarly have dependencies it needs. For example, a FakeBar may end up needing to take in a FakeClock if the real Bar took a Clock. This is because a FakeClock is often a coordination point between different classes. (Imagine if Foo had another dependency Baz that also used a clock, you would want the FakeBaz to use the same FakeClock instance so things are coordinated when time is advanced). Managing these dependencies can quickly get out of hand.

This usually leads test authors to mocks. The mock solves the issue of tediously following these dependency chains, but has significant drawbacks in that it can easily get out of date silently and make the test useless in its overall goal of finding real bugs. Because no one checks the mock behavior besides the test author, this usually means that after enough time, there is a decent likelihood that the test is no longer testing a useful scenario.

By directly instantiating a dependency, you are assuming responsibility for correctly scoping that dependency. It is easy to accidentally create multiple instances of scoped bindings, or to provide the same instance of an unscoped binding multiple times.

For example, a FakeClock may contain global state that maintains the current time and allows advancing this time manually in tests. Because of this, it is marked as @Singleton so that the code under test and the test itself reference the same instance. But if an additional instance is directly instantiated by the test, multiple instances would exist. This would lead to code under test observing skewed timestamps, or the test advancing the current time to no effect.

Additionally, manually writing Provider and Lazy constructor parameters for scoped types is error-prone. You need to know whether the dependency is scoped, and store an instance of the object at the right level. For example, you would need to associate any @ActivityScoped bindings with the Activity under test, and recreate the dependency if the Activity undergoes a configuration change. To accurately reflect the real Dagger behavior, all of this would need to be made thread-safe.

Finally, if the scope of a dependency is later changed, the tests using that dependency will not actually reflect that change without manual updates. This prevents tests from detecting unintended changes due to a change in scope.

Direct instantiation also breaks the philosophy of not encoding implementation details in a test because the constructor call encodes details of its dependencies. If Bar were an @Inject constructor type, there is no reason a user of Foo needs to know about the existence of the Bar class as it could easily be an implementation detail from refactoring logic in Foo into another class private to the library.

To illustrate this point, consider if Foo had two dependencies like Foo(Bar, Baz). In Dagger, switching the order of these parameters on the @Inject constructor is a no-op. Yet if we were to test Foo via direct instantiation, we’d still have to update the test. Similarly, adding a usage of a new @Inject class or an optional binding would similarly be an invisible change for production users of the class, yet the test would still need to be updated.

Hilt was designed to fix the downside of using Dagger in tests in order to allow easy testing with real dependencies. Tests written using Hilt will have a better overall experience if they follow these principles.

**Examples:**

Example 1 (java):
```java
final class Foo {
  @Inject Foo(Bar bar) {...}
}
```

Example 2 (unknown):
```unknown
final class Foo {
  @Inject Foo(Bar bar) {...}
}
```

Example 3 (kotlin):
```kotlin
class Foo @Inject constructor(bar: Bar) {
}
```

Example 4 (unknown):
```unknown
class Foo @Inject constructor(bar: Bar) {
}
```

---

## Testing

**URL:** https://dagger.dev/hilt/testing

**Contents:**
- Testing
- Introduction
- Test Setup
- Accessing bindings
  - Accessing SingletonComponent bindings
  - Accessing ActivityComponent bindings
  - Accessing FragmentComponent bindings
- Replacing bindings
  - @TestInstallIn
  - @UninstallModules

Hilt makes testing easier by bringing the power of dependency injection to your Android tests. Hilt allows your tests to easily access Dagger bindings, provide new bindings, or even replace bindings. Each test gets its own set of Hilt components so that you can easily customize bindings at a per-test level.

Many of the testing APIs and functionality described in this documentation are based upon an unstated philosophy of what makes a good test. For more details on Hilt’s testing philosophy see here.

Note: For Gradle users, make sure to first add the Hilt test build dependencies as described in the Gradle setup guide.

To use Hilt in a test:

Note that setting the application class for a test (step 3 above) is dependent on whether the test is a Robolectric or instrumentation test. For a more detailed guide on how to set the test application for a particular test environment, see Robolectric testing or Instrumentation testing. The remainder of this doc applies to both Robolectric and instrumentation tests.

If your test requires a custom application class, see the section on custom test application.

If your test requires multiple test rules, see the section on Hilt rule order to determine the proper placement of the Hilt rule.

A test often needs to request bindings from its Hilt components. This section describes how to request bindings from each of the different components.

An SingletonComponent binding can be injected directly into a test using an @Inject annotated field. Injection doesn’t occur until calling HiltAndroidRule#inject().

Requesting an ActivityComponent binding requires an instance of a Hilt Activity. One way to do this is to define a nested activity within your test that contains an @Inject field for the binding you need. Then create an instance of your test activity to get the binding.

Alternatively, if you already have a Hilt activity instance available in your test, you can get any ActivityComponent binding using an EntryPoint.

A FragmentComponent binding can be accessed in a similar way to an ActivityComponent binding. The main difference is that accessing a FragmentComponent binding requires both an instance of a Hilt Activity and a Hilt Fragment.

Alternatively, if you already have a Hilt fragment instance available in your test, you can get any FragmentComponent binding using an EntryPoint.

Warning:Hilt does not currently support FragmentScenario because there is no way to specify an activity class, and Hilt requires a Hilt fragment to be contained in a Hilt activity. One workaround for this is to launch a Hilt activity and then attach your fragment.

It’s often useful for tests to be able to replace a production binding with a fake or mock binding to make tests more hermetic or easier to control in test. The next sections describe some ways to accomplish this in Hilt.

A Dagger module annotated with @TestInstallIn allows users to replace an existing @InstallIn module for all tests in a given source set. For example, suppose we want to replace ProdDataServiceModule with FakeDataServiceModule. We can accomplish this by annotating FakeDataServiceModule with @TestInstallIn, as shown below:

A @TestInstallIn module can be included in the same source set as your test sources, as shown below:

However, if a particular @TestInstallIn module is needed in multiple Gradle modules, we recommend putting it in its own Gradle module (usually the same one as the fake), as shown below:

Putting the @TestInstallIn in the same Gradle module as the fake has a number of benefits. First, it ensures that all clients that depend on the fake properly replace the production module with the test module. It also avoids duplicating FakeDataServiceModule for every Gradle module that needs it.

Note that @TestInstallIn applies to all tests in a given source set. For cases where an individual test needs to replace a binding that is specific to the given test, the test can either be moved into its own source set, or it can use Hilt testing features such as @UninstallModules, @BindValue, and nested @InstallIn modules to replace bindings specific to that test. These features will be described in more detail in the following sections.

Warning:Test classes that use @UninstallModules, @BindValue, or nested @InstallIn modules result in a custom component being generated for that test. While this may be fine in most cases, it does have an impact on build speed. The recommended approach is to use @TestInstallIn modules instead.

A test annotated with @UninstallModules can uninstall production @InstallIn modules for that particular test (unlike @TestInstallIn, it has no effect on other tests). Once a module is uninstalled, the test can install new, test-specific bindings for that particular test.

There are two ways to install a new binding for a particular test:

These two approaches are described in more detail in the next sections.

Note: @UninstallModules can only uninstall @InstallIn modules, not @TestInstallIn modules. If a @TestInstallIn module needs to be uninstalled the module must be split into two separate modules: a @TestInstallIn module that replaces the production module with no bindings (i.e. only removes the production module), and a @InstallIn module that provides the standard fake so that @UninstallModules can uninstall the provided fake.

Warning:Test classes that use @UninstallModules, @BindValue, or nested @InstallIn modules result in a custom component being generated for that test. While this may be fine in most cases, it does have an impact on build speed. The recommended approach is to use @TestInstallIn modules instead.

Normally, @InstallIn modules are installed in the Hilt components of every test. However, if a binding needs to be installed only in a particular test, that can be accomplished by nesting the @InstallIn module within the test class.

Thus, if there is another test that needs to provision the same binding with a different implementation, it can do that without a duplicate binding conflict.

In addition to static nested @InstallIn modules, Hilt also supports inner (non-static) @InstallIn modules within tests. Using an inner module allows the @Provides methods to reference members of the test instance.

Note: Hilt does not support @InstallIn modules with constructor parameters.

Warning:Test classes that use @UninstallModules, @BindValue, or nested @InstallIn modules result in a custom component being generated for that test. While this may be fine in most cases, it does have an impact on build speed. The recommended approach is to use @TestInstallIn modules instead.

For simple bindings, especially those that need to also be accessed in the test methods, Hilt provides a convenience annotation to avoid the boilerplate of creating a module and method normally required to provision a binding.

@BindValue is an annotation that allows you to easily bind fields in your test into the Dagger graph. To use it, just annotate a field with @BindValue and it will be bound to the declared field type with any qualifiers that are present on the field.

Note that @BindValue does not support the use of scope annotations since the binding’s scope is tied to the field and controlled by the test. The field’s value is queried whenever it is requested, so it can be mutated as necessary for your test. If you want the binding to be effectively singleton, just ensure that the field is only set once per test case, e.g. by setting the field’s value from either the field’s initializer or from within an @Before method of the test.

Similarly, Hilt also has a convenience annotation for multibindings with @BindValueIntoSet, @BindElementsIntoSet, and @BindValueIntoMap to support @IntoSet, @ElementsIntoSet, and @IntoMap respectively. (Note that @BindValueIntoMap requires the field to also be annotated with a map key annotation.)

Warning:Be careful when using @BindValue or non-static inner modules with ActivityScenarioRule. ActivityScenarioRule creates the activity before calling the @Before method, so if an @BindValue field is initialized in @Before (or later), then it’s possible for the Activity to inject the binding in its unitialized state. To avoid this, try initializing the @BindValue field in the field’s initializer.

Every Hilt test must use a Hilt test application as the Android application class. Hilt comes with a default test application, HiltTestApplication, which extends MultiDexApplication; however, there are cases where a test may need to use a different base class.

If your test requires a custom base class, @CustomTestApplication can be used to generate a Hilt test application that extends the given base class.

To use @CustomTestApplication, just annotate a class or interface with @CustomTestApplication and specify the base class in the annotation value:

In the above example, Hilt will generate an application named MyCustom_Application that extends MyBaseApplication. In general, the name of the generated application will be the name of the annotated class appended with _Application. If the annotated class is a nested class, the name will also include the name of the outer class separated by an underscore. Note that the class that is annotated is irrelevant, other than for the name of the generated application.

As a best practice, avoid using @CustomTestApplication and instead use HiltTestApplication in your tests. In general, having your Activity, Fragment, etc. be independent of the parent they are contained in makes it easier to compose and reuse it in the future.

However, if you must use a custom base application, there are some subtle differences with the production lifecycle to be aware of.

One difference is that instrumentation tests use the same application instance for every test and test case. Thus, it’s easy to accidentally leak state across test cases when using a custom test application. Instead, it’s better to avoid storing any test or test case dependendent state in your application.

Another difference is that the Hilt component in a test application is not created in super#onCreate. This restriction is mainly due to fact that some of Hilt’s features (e.g. @BindValue) rely on the test instance, which is not available in tests until after Application#onCreate is called. Thus, unlike production applications, custom base applications must avoid calling into the component during Application#onCreate. This includes injecting members into the application. To prevent this issue, Hilt doesn’t allow injection in the base application.

If your test uses multiple test rules, make sure that the HiltAndroidRule runs before any other test rules that require access to the Hilt component. For example ActivityScenarioRule calls Activity#onCreate, which (for Hilt activities) requires the Hilt component to perform injection. Thus, the ActivityScenarioRule should run after the HiltAndroidRule to ensure that the component has been properly initialized.

Note: If you’re using JUnit < 4.13 use RuleChain to specify the order instead.

**Examples:**

Example 1 (java):
```java
@HiltAndroidTest
public class FooTest {
  @Rule public HiltAndroidRule hiltRule = new HiltAndroidRule(this);
  ...
}
```

Example 2 (csharp):
```csharp
@HiltAndroidTest
public class FooTest {
  @Rule public HiltAndroidRule hiltRule = new HiltAndroidRule(this);
  ...
}
```

Example 3 (kotlin):
```kotlin
@HiltAndroidTest
class FooTest {
  @get:Rule val hiltRule = HiltAndroidRule(this)
  ...
}
```

Example 4 (unknown):
```unknown
@HiltAndroidTest
class FooTest {
  @get:Rule val hiltRule = HiltAndroidRule(this)
  ...
}
```

---

## Instrumentation testing

**URL:** https://dagger.dev/hilt/instrumentation-testing.html

**Contents:**
- Instrumentation testing
- Setting the test application

Hilt’s testing APIs are built to be agnostic of the particular testing environment; however, the instructions for setting up the application class in your test will depend on whether you are using Robolectric or Android instrumentation tests.

For Android instrumentation tests, the application can be set using a custom test runner that extends AndroidJUnitRunner. To set the application using the runner, just override the newApplication method and pass in the application class name. For Hilt tests, the application must either be HiltTestApplication or one of Hilt’s custom test applications.

In addition, the testInstrumentationRunner must be configured in the build.gradle file for the given Gradle module:

**Examples:**

Example 1 (java):
```java
package my.pkg;

public final class MyTestRunner extends AndroidJUnitRunner {
  @Override
  public Application newApplication(
      ClassLoader cl, String appName, Context context) {
    return super.newApplication(
        cl, HiltTestApplication.class.getName(), context);
  }
}
```

Example 2 (unknown):
```unknown
package my.pkg;

public final class MyTestRunner extends AndroidJUnitRunner {
  @Override
  public Application newApplication(
      ClassLoader cl, String appName, Context context) {
    return super.newApplication(
        cl, HiltTestApplication.class.getName(), context);
  }
}
```

Example 3 (kotlin):
```kotlin
package my.pkg

class MyTestRunner: AndroidJUnitRunner() {
  override fun newApplication(
      cl: ClassLoader,
      appName: String,
      context: Context) : Application {
    return super.newApplication(
        cl, HiltTestApplication::class.java.getName(), context)
  }
}
```

Example 4 (unknown):
```unknown
package my.pkg

class MyTestRunner: AndroidJUnitRunner() {
  override fun newApplication(
      cl: ClassLoader,
      appName: String,
      context: Context) : Application {
    return super.newApplication(
        cl, HiltTestApplication::class.java.getName(), context)
  }
}
```

---

## Instrumentation testing

**URL:** https://dagger.dev/hilt/instrumentation-testing

**Contents:**
- Instrumentation testing
- Setting the test application

Hilt’s testing APIs are built to be agnostic of the particular testing environment; however, the instructions for setting up the application class in your test will depend on whether you are using Robolectric or Android instrumentation tests.

For Android instrumentation tests, the application can be set using a custom test runner that extends AndroidJUnitRunner. To set the application using the runner, just override the newApplication method and pass in the application class name. For Hilt tests, the application must either be HiltTestApplication or one of Hilt’s custom test applications.

In addition, the testInstrumentationRunner must be configured in the build.gradle file for the given Gradle module:

**Examples:**

Example 1 (java):
```java
package my.pkg;

public final class MyTestRunner extends AndroidJUnitRunner {
  @Override
  public Application newApplication(
      ClassLoader cl, String appName, Context context) {
    return super.newApplication(
        cl, HiltTestApplication.class.getName(), context);
  }
}
```

Example 2 (unknown):
```unknown
package my.pkg;

public final class MyTestRunner extends AndroidJUnitRunner {
  @Override
  public Application newApplication(
      ClassLoader cl, String appName, Context context) {
    return super.newApplication(
        cl, HiltTestApplication.class.getName(), context);
  }
}
```

Example 3 (kotlin):
```kotlin
package my.pkg

class MyTestRunner: AndroidJUnitRunner() {
  override fun newApplication(
      cl: ClassLoader,
      appName: String,
      context: Context) : Application {
    return super.newApplication(
        cl, HiltTestApplication::class.java.getName(), context)
  }
}
```

Example 4 (unknown):
```unknown
package my.pkg

class MyTestRunner: AndroidJUnitRunner() {
  override fun newApplication(
      cl: ClassLoader,
      appName: String,
      context: Context) : Application {
    return super.newApplication(
        cl, HiltTestApplication::class.java.getName(), context)
  }
}
```

---

## (Deprecated) Migrating your Dagger app to Hilt Stay organized with collections Save and categorize content based on your preferences.

**URL:** https://developer.android.com/codelabs/android-dagger-to-hilt

**Contents:**
- (Deprecated) Migrating your Dagger app to Hilt Stay organized with collections Save and categorize content based on your preferences.
- 1. Introduction
- Prerequisites
- What you'll learn
- What you'll need
- 2. Getting set up
- Get the code
- Open Android Studio
- Project set up
- Frequently asked questions

In this codelab you'll learn how you migrate Dagger to Hilt for dependency injection (DI) in an Android app. This codelab migrates the Using Dagger in your Android app codelab to Hilt. This codelab aims to show you how to plan your migration and keep Dagger and Hilt working side by side during the migration by keeping the app functional while you migrate each Dagger component to Hilt.

Dependency injection helps with reusability of code, ease of refactoring and ease of testing. Hilt is built on top of the popular DI library Dagger to benefit from the compile time correctness, runtime performance, scalability, and Android Studio support that Dagger provides.

Since many Android framework classes are instantiated by the OS itself, there's an associated boilerplate when using Dagger in Android apps. Hilt removes most of this boilerplate by automatically generating and providing:

Best of all, as Dagger and Hilt can coexist together, apps can be migrated on an as-needed basis.

Migration from dagger.android is not covered in this codelab, if your app uses it, make sure you checkout the appropriate sections of the Migration Guide.

If you run into any issues (code bugs, grammatical errors, unclear wording, etc.) as you work through this codelab, please report the issue via the Report a mistake link in the lower left corner of the codelab.

Get the codelab code from GitHub:

Alternatively you can download the repository as a Zip file:

file_downloadDownload Zip

If you need to download Android Studio, you can do so here.

The project is built in multiple GitHub branches:

We recommend you to follow the codelab step by step at your own pace starting with the master branch.

During the codelab, you'll be presented with snippets of code that you'll have to add to the project. In some places, you'll also have to remove code that will be explicitly mentioned in comments on the code snippets.

As checkpoints, you have the intermediate branches available in case you need help with a particular step.

To get the solution branch using git, use this command:

Or download the solution code from here:

file_downloadDownload the final code

First, let's see what the starting sample app looks like. Follow these instructions to open the sample app in Android Studio.

The app consists of 4 different flows working with Dagger (implemented as Activities):

The project follows a typical MVVM pattern where all the complexity of the View is deferred to a ViewModel. Take a moment to familiarize yourself with the structure of the project.

The arrows represent dependencies between objects. This is what we call the application graph: all the classes of the app and the dependencies between them.

The code in the master branch uses Dagger to inject dependencies. Instead of creating Components by hand, we will refactor the app to use Hilt to generate Components and other Dagger related code.

Dagger is set up in the app as shown in the following diagram. The dot on certain types means that the type is scoped to the Component that provides it:

To keep things simple, Hilt dependencies are already added to this project in the master branch that you downloaded initially. You don't need to add the following code to your project as it's already done for you. Nonetheless, let's see what's needed to use Hilt in an Android app.

Apart from the library dependencies, Hilt uses a Gradle plugin that is configured in the project. Open the root (project level) build.gradle file and find the following Hilt dependency in the classpath:

Open app/build.gradle and check Hilt gradle plugin declaration on the top just below the kotlin-kapt plugin.

Lastly, Hilt dependencies and annotation processor are included in our project in the same app/build.gradle file:

All libraries, including Hilt, get downloaded when you build and sync the project. Let's start using Hilt!

If you have any issues while building the project, select clean to remove generated code by Dagger or Hilt and then build the project again.

You might be tempted to migrate everything to Hilt at once but in a real world project you want the app building and running without errors while you are migrating to Hilt in steps.

When migrating to Hilt, you'll want to organize your work into steps. The recommended approach is to start with migrating your Application or @Singleton component and later migrate activities and fragments.

In the codelab, you'll migrate the AppComponent first and then each flow of the app starting with Registration, then Login, and lastly Main and Settings.

During the migration, you'll remove all @Component and @Subcomponent interfaces and annotate all modules with @InstallIn.

After the migration, all Application/Activity/Fragment/View/Service/BroadcastReceiver classes should be annotated with @AndroidEntryPoint and any code instantiating or propagating components should also be removed.

To plan the migration, let's start with AppComponent.kt to understand component hierarchy.

AppComponent is annotated with @Component and includes two modules, StorageModule and AppSubcomponents.

AppSubcomponents has three components, RegistrationComponent, LoginComponent, and UserComponent.

UserComponent is injected in MainActivity and SettingsActivity.

References to AppComponent can be replaced by the Hilt-generated SingletonComponent (link to all generated components) that maps to the Component you're migrating in your app.

In this section you'll migrate the AppComponent. You will need to do some groundwork to keep existing Dagger code working while in the following steps you migrate each component to Hilt.

To initialize Hilt and start the code generation, you need to annotate your Application class with Hilt annotations.

Open MyApplication.kt and add the @HiltAndroidApp annotation to the class. These annotations tell Hilt to trigger the code generation that Dagger will pick up and use in its annotation processor.

To start, open AppComponent.kt. The AppComponent has two modules (StorageModule and AppSubcomponents) added in the @Component annotation. The first thing you need to do is to migrate these 2 modules, so that Hilt adds them into the generated SingletonComponent.

To do that, open AppSubcomponents.kt and annotate the class with @InstallInannotation. @InstallIn annotation takes a parameter to add the module to the right component. In this case, as you're migrating the application level component, you want the bindings to be generated in SingletonComponent.

You need to make the same change in StorageModule. Open StorageModule.kt and add the @InstallIn annotation as you did in the previous step.

With @InstallIn annotation, once again you told Hilt to add the module to the Hilt-generated SingletonComponent.

Now let's go back and check AppComponent.kt. AppComponent provides dependencies for RegistrationComponent, LoginComponent and UserManager. In the next steps you'll prepare these components for migration.

While you migrate the app fully to Hilt, Hilt let's you manually ask for dependencies from Dagger via using entry points. By using entry points you can keep the app working while migrating every Dagger component. In this step you will replace each Dagger component with a manual dependency lookup in the SingletonComponent generated by Hilt.

To get the RegistrationComponent.Factory for RegistrationActivity.kt from the Hilt generated SingletonComponent, you need to create a new EntryPoint interface annotated with @InstallIn. InstallIn annotation tells Hilt where to grab the binding from. To access an entry point, use the appropriate static method from EntryPointAccessors. The parameter should be either the component instance or the @AndroidEntryPoint object that acts as the component holder.

Now you need to replace Dagger related code with the RegistrationEntryPoint. Change the initialization of registrationComponent to use the RegistrationEntryPoint. With this change RegistrationActivity can access its dependencies over Hilt generated code until it is migrated to use Hilt.

Next, you need to do the same groundwork for all the other exposed types of Components. Let's continue with the LoginComponent.Factory. Open LoginActivity and create a LoginEntryPoint interface annotated with @InstallIn and @EntryPoint as you did before but exposing what LoginActivity needs from the Hilt component.

Now that Hilt knows how to provide the LoginComponent, replace the old inject() call with the EntryPoint's loginComponent().

Two of the three exposed types from AppComponent are replaced to work with Hilt EntryPoints. Next, you need to make a similar change for UserManager. Unlike RegistrationComponent and LoginComponent, UserManager is used in both MainActivity and SettingsActivity. You only need to create an EntryPoint interface only once. The annotated EntryPoint interface can be used in both Activities. To keep this simple, declare the Interface in MainActivity.

Entry points are usually declared in the class they are used. If an EntryPoint is used in more than one class, you can declare the EntryPoint in a new class and place it in a common package such as util.

To create a UserManagerEntryPoint interface open MainActivity.kt and annotate it with @InstallIn and @EntryPoint.

Now change UserManager to use the UserManagerEntryPoint.

You need to do the same change in SettingsActivity. Open SettingsActivity.kt and replace how UserManager is injected.

Passing Context to a Dagger component using @BindsInstance is a common pattern. This is not needed in Hilt as Context is already available as a predefined binding.

Context is usually needed to access resources, databases, shared preferences, and etc. Hilt simplifies injecting to context by using the Qualifier @ApplicationContext and @ActivityContext.

While migrating your app, check which types require Context as a dependency and replace them with the ones Hilt provides.

In this case, SharedPreferencesStorage has Context as a dependency. In order to tell Hilt to inject the context, open SharedPreferencesStorage.kt. SharedPreferences requires application's Context, so add @ApplicationContext annotation to the context parameter.

Next, you need to check the component code for inject() methods and annotate the corresponding classes with @AndroidEntryPoint. In our case, AppComponent doesn't have any inject() methods so you don't need to do anything.

Since you already added EntryPoints for all the components listed in AppComponent.kt, you can delete AppComponent.kt.

You don't need the code to initialize the custom AppComponent in the application class anymore, instead, the Application class uses Hilt-generated SingletonComponent. Remove all the code inside the class body. The end code should look like the code listing below.

With this, you've successfully added Hilt to your Application, removed the AppComponent and changed the Dagger code to inject dependencies over the AppComponent generated by Hilt. When you build and try the app on a device or emulator, the app should be working just like it used to. In the following sections, we will migrate each Activity and Fragment to use Hilt.

Now that you migrated the Application component and laid out the groundwork, you can migrate each Component to Hilt one by one.

Let's start migrating the login flow. Instead of creating the LoginComponent manually and using it in the LoginActivity, you want Hilt to do that for you.

You can follow the same steps you used in the previous section but this time using the Hilt-generated ActivityComponent as we'll be migrating a Component that is managed by an Activity.

To start with Open LoginComponent.kt. LoginComponent doesn't have any modules so you don't need to do anything. To make Hilt generate a component for the LoginActivity and inject it, you need to annotate the activity with @AndroidEntryPoint.

This is all the code you need to add to migrate LoginActivity to Hilt. Since Hilt will generate the Dagger related code, all you need to do is some cleanup. Delete the LoginEntryPoint interface.

Next, remove the EntryPoint code in onCreate().

Since Hilt will generate the component, find and delete LoginComponent.kt.

LoginComponent is currently listed as a subcomponent in AppSubcomponents.kt. You can safely delete LoginComponent from subcomponents list since Hilt will generate the bindings for you.

This is all you need to migrate LoginActivity to use Hilt. In this section you deleted much more code than you added which is great! You are not only typing less code when using Hilt but also this means less code to maintain and introduce bugs.

In this section you will migrate the registration flow. To plan the migration let's take a look at RegistrationComponent. Open RegistrationComponent.kt and scroll down to the inject() function. RegistrationComponent is responsible for injecting dependencies to RegistrationActivity, EnterDetailsFragment, and TermsAndConditionsFragment.

Let's start with migrating the RegistrationActivity. Open RegistrationActivity.kt and annotate the class with @AndroidEntryPoint.

Now that the RegistrationActivity is registered to Hilt, you can remove the RegistrationEntryPoint Interface and the EntryPoint related code from onCreate() function.

Hilt is responsible for generating the component and injecting dependencies so you can remove the registrationComponent variable and the inject call on the deleted Dagger component.

Next, open EnterDetailsFragment.kt. Annotate the EnterDetailsFragment with @AndroidEntryPoint, similar to what you did in RegistrationActivity.

Since Hilt is providing the dependencies, the inject() call on the deleted Dagger component is not needed. Delete onAttach() function.

The next step is to migrate the TermsAndConditionsFragment. Open TermsAndConditionsFragment.kt, annotate the class and remove the onAttach() function as you did in the previous step. The end code should look like this.

With this change, you migrated all activities and fragments listed in the RegistrationComponent so you can delete RegistrationComponent.kt.

Once you delete RegistrationComponent, you need to remove its reference from the subcomponents list in AppSubcomponents.

There is one thing left to finish migrating the Registration flow. Registration flow declares and uses its own scope, ActivityScope. Scopes control the lifecycle of dependencies. In this case, ActivityScope tells Dagger to inject the same instance of RegistrationViewModel within the flow started with RegistrationActivity. Hilt provides built in lifecycle scopes to support this.

Open RegistrationViewModel change @ActivityScope annotation with the @ActivityScoped provided by Hilt.

Since ActivityScope is not used anywhere else. you can safely delete ActivityScope.kt.

Now run the app and try out the Registration flow. You can use your current username and password to login or unregister and reregister with a new account to confirm the flow works just like it used to.

Right now, Dagger and Hilt are working together in the app. Hilt is injecting all dependencies except for UserManager. In the next section you'll fully migrate to Hilt from Dagger by migrating the UserManager.

If you are having any issues or want to compare your code, you can checkout the interop branch or download the solution code up to this point.

So far in this codelab, you've successfully migrated most of the sample app to Hilt except one component, UserComponent. UserComponent is annotated with a custom scope, @LoggedUserScope. This means, UserComponent will inject the same instance of UserManager to classes which are annotated with @LoggedUserScope.

UserComponent doesn't map to any of the available Hilt components as its lifecycle is not managed by an Android class. Since adding a custom component in the middle of the generated Hilt hierarchy is not supported, you have two options:

You've already achieved #1 in the previous step. In this step, you'll follow #2 to have the application fully migrated to Hilt. However, in a real app, you are free to choose whichever suits better your specific use case.

In this step, UserComponent will be migrated to be part of Hilt's SingletonComponent. If there are any modules in that component, those should be installed in SingletonComponent as well.

The only scoped type in UserComponent is UserDataRepository - that is annotated with @LoggedUserScope. As UserComponent will converge with Hilt's SingletonComponent, UserDataRepository will be annotated with @Singleton and you'll change the logic to make it null when the user is logged out.

UserManager is already annotated with @Singleton which means you can provide the same instance throughout the app and, with some changes, you can achieve the same functionality with Hilt. Let's start with changing how UserManager and UserDataRepository works, as you need to do some groundwork first.

Open UserManager.kt and apply the following changes.

When you are done the final code for UserManager.kt should look like this.

Now that you are done with UserManager, you need to make some changes in UserDataRepository. Open UserDataRepository.kt and apply the following changes.

When you are done, the end code should look like this.

To finish migrating the UserComponent, open UserComponent.kt and scroll down to inject() methods. This dependency is used in MainActivity and SettingsActivity. Let's start with migrating the MainActivity. Open MainActivity.kt and annotate the class with @AndroidEntryPoint.

Remove the UserManagerEntryPoint interface and also remove entry point related code from onCreate().

Declare a lateinit var for UserManager and annotate it with @Inject annotation so that Hilt can inject the dependency.

Since UserManager will be injected by Hilt, remove the inject() call on UserComponent.

This is all you need to do for MainActivity. Now, you can perform the similar changes to migrate SettingsActivity. Open SettingsActivity and annotate it with @AndroidEntryPoint.

Create a lateinit var for UserManager and annotate it with @Inject.

Remove entry point code and the inject call on userComponent(). When you are done, onCreate() function should look like this.

Now you can clean up the unused resources to finish the migration. Delete the LoggedUserScope.kt, UserComponent.kt and finally the AppSubcomponent.kt classes.

Now run and try the app again. The app should be functioning just like it used to with Dagger.

There is one crucial step left before you finish migrating the app to Hilt. So far you've migrated all the app code but not the tests. Hilt injects dependencies in tests just like it does in the app code. Testing with Hilt requires no maintenance because Hilt automatically generates a new set of components for each test.

Let's start with the Unit tests. You don't need to use Hilt for unit tests since you can directly call the target class's constructor passing in fake or mock dependencies just as you would if the constructor weren't annotated.

If you run the unit tests, you'd see UserManagerTest is failing. You've done a lot of work and changes in UserManager, including it's constructor parameters in the previous sections. Open UserManagerTest.kt which still depends on UserComponent and UserComponentFactory. Since you already changed the parameters of UserManager, change the UserComponent.Factory parameter with a new instance of UserDataRepository.

This is it! Run the tests again and all unit tests should be passing.

Before you dive in, open app/build.gradle and confirm the following Hilt dependencies exist. Hilt uses hilt-android-testing for testing-specific annotations. Additionally, as Hilt needs to generate code for classes in the androidTest folder, its annotation processor must also be able to run there.

Hilt generates test components and a test Application automatically for each test. To start, open TestAppComponent.kt to plan the migration. TestAppComponent has 2 modules, TestStorageModule and AppSubcomponents. You've already migrated and deleted AppSubcomponents, you can continue with migrating TestStorageModule.

In this step, you'll use @TestInstallIn annotation to replace the StorageModule with the TestStorageModule. @TestInstallIn annotation takes two parameters, the component(s) this module will be installed in and the module(s) this module is replacing.

Open TestStorageModule.kt and annotate the class with @TestInstallIn annotation. You want to install this module into the SingletonComponent where the StorageModule is installed in the app. Add SingletonComponent::class as the component to install this module in and StorageModule::class as the module to be replaced by this module. Once you do this, all tests in this folder will be injected with the fake dependencies instead.

Since you finished migrating all modules, go ahead and delete TestAppComponent.

Next let's add Hilt to ApplicationTest. You must annotate any UI test that uses Hilt with @HiltAndroidTest. This annotation is responsible for generating the Hilt components for each test.

Open ApplicationTest.kt and add the following:

As Hilt generates a new Application for every instrumentation test, we need to specify that the Hilt generated Application should be used when running UI tests. To do this we need a custom test runner.

The codelab app already has a custom test runner. Open MyCustomTestRunner.kt

Hilt already comes with an Application you can use for tests named HiltTestApplication. You need to change MyTestApplication::class.java with HiltTestApplication::class.java in the newApplication() function body.

With this change it is now safe to delete MyTestApplication.kt file. Now go ahead and run the tests. All tests should be passing.

Hilt includes extensions for providing classes from other Jetpack libraries such as WorkManager and ViewModel. The ViewModels in the codelab project are plain classes which do not extend ViewModel from Architecture Components. Before adding Hilt support for ViewModels, let's migrate the ViewModels in the app to the Architecture Components ones.

To migrate a plain class to ViewModel, you need to extend ViewModel().

Open MainViewModel.kt and add : ViewModel(). This is enough to migrate to Architecture Components ViewModels but you also need to tell Hilt how to provide instances of the ViewModel. To do that, add the @HiltViewModel annotation to ViewModel class.

Next, open LoginViewModel and do the same changes. The end code should look like this.

Similarly open RegistrationViewModel.kt and migrate to ViewModel() and add the Hilt annotation. You don't need the @ActivityScoped annotation since with the extension methods viewModels() and activityViewModels(), you can control the scope of this ViewModel.

RegistrationViewModel.kt

Do the same changes to migrate EnterDetailsViewModel and SettingViewModel. The end code for these two classes should look like this.

Now that all the ViewModels are migrated to Architecture Component Viewmodels and annotated with Hilt annotations, you can migrate how they are injected.

Next, you need to change how the ViewModels are initialised in the View layer. ViewModels are created by the OS and the way to get them is using the by viewModels() delegate function.

Open MainActivity.kt, replace the @Inject annotation with the Jetpack extensions. Note, you also need to remove the lateinit, change var to val and mark the field private.

Similarly, open LoginActivity.kt and change how the ViewModel is obtained.

Next, open RegistrationActivity.kt and apply the similar changes to obtain the registrationViewModel.

Open EnterDetailsFragment.kt. Replace how EnterDetailsViewModel is obtained.

Similarly, replace how registrationViewModel is obtained but this time use activityViewModels() delegate function instead of viewModels(). When the registrationViewModel is injected, Hilt will inject the activity level scoped ViewModel.

Open TermsAndConditionsFragment.kt and once again use activityViewModels() extension function instead of viewModels() to obtain registrationViewModel.

Finally, open SettingsActivity.kt and migrate how settingsViewModel is obtained.

Now run the app and confirm everything works as expected.

Congratulations! You've successfully migrated an app to use Hilt! Not only you completed the migration but you also kept the application working while migrating Dagger components one by one.

In this codelab you've learned how to start with the Application component and build the groundwork necessary to make Hilt work with existing Dagger components. From there you migrated each Dagger Component to Hilt by using Hilt Annotations on Activities and Fragments and removing Dagger related code. Each time you finished migrating a component, the app worked and functioned as expected. You also migrated Context and ApplicationContext dependencies with the Hilt provided @ActivityContext and @ApplicationContext annotations. You've migrated other Android components. Finally, you've migrated the tests and finish migrating to Hilt.

To learn more about migrating your app to Hilt, check out the Migrating to Hilt documentation. Apart from more information about migrating Dagger to Hilt, you also have information about migrating a dagger.android app.

**Examples:**

Example 1 (unknown):
```unknown
buildscript {
    ...
    ext.hilt_version = '2.35'
    dependencies {
        ...
        classpath "com.google.dagger:hilt-android-gradle-plugin:$hilt_version"
    }
}
```

Example 2 (unknown):
```unknown
...
apply plugin: 'kotlin-kapt'
apply plugin: 'dagger.hilt.android.plugin'

android {
    ...
}
```

Example 3 (unknown):
```unknown
...
dependencies {
    implementation "com.google.dagger:hilt-android:$hilt_version"
    kapt "com.google.dagger:hilt-android-compiler:$hilt_version"
}
```

Example 4 (unknown):
```unknown
@Singleton
// Definition of a Dagger component that adds info from the different modules to the graph
@Component(modules = [StorageModule::class, AppSubcomponents::class])
interface AppComponent {

    // Factory to create instances of the AppComponent
    @Component.Factory
    interface Factory {
        // With @BindsInstance, the Context passed in will be available in the graph
        fun create(@BindsInstance context: Context): AppComponent
    }

    // Types that can be retrieved from the graph
    fun registrationComponent(): RegistrationComponent.Factory
    fun loginComponent(): LoginComponent.Factory
    fun userManager(): UserManager
}
```

---
