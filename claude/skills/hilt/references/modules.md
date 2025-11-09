# Hilt - Modules

**Pages:** 5

---

## Creating extensions

**URL:** https://dagger.dev/hilt/creating-extensions

**Contents:**
- Creating extensions
- Generating modules and entry points
  - @GeneratesRootInput
  - @OriginatingElement

Hilt is particularly well-suited for extensions or libraries that want to integrate with Hilt due to the standard components and the way modules and entry points are picked up from the classpath.

However, extensions that generate an @InstallIn module or entry point will need to add some extra information to the generated classes in order for them to be picked up by Hilt correctly.

Because Hilt picks up modules and entry points from the classpath implicitly, Hilt needs extra information to know if it needs to wait for your extension to generate code before it tries to generate the Dagger components. This is done by annotating your annotation class that triggers your code generation with @GeneratesRootInput.

For example, if an extension generated a module every time someone used a @GenerateMyModule annotation, @GenerateMyModule would need to be annotated like so:

Note that if not annotated, Hilt is not necessarily guaranteed to miss your modules because it may still pick them up if waiting on something else to be generated. This is of course unreliable.

As described in the testing page, nested modules in tests are isolated to the enclosing test. Generated modules for a test, however, cannot be generated as a nested class. To properly support this, generated code should be annotated with an @OriginatingElement annotation with the top-level class as the value. Note that this is not always the same as the enclosing class since there may be many layers of nesting.

For example, assume an extension is triggered by the following code and generates a module called FooTest_FooModule.

Then the generated FooTest_FooModule would need to be annotated like so:

**Examples:**

Example 1 (unknown):
```unknown
@GeneratesRootInput
public @interface GenerateMyModule {}
```

Example 2 (unknown):
```unknown
@GeneratesRootInput
annotation class GenerateMyModule {}
```

Example 3 (unknown):
```unknown
@HiltAndroidTest
public class FooTest {
  @GenerateMyModule
  private Foo foo = new Foo();
  ...
}
```

Example 4 (unknown):
```unknown
@HiltAndroidTest
class FooTest {
  @GenerateMyModule
  val foo: Foo = Foo()
  ...
}
```

---

## Modules

**URL:** https://dagger.dev/hilt/modules

**Contents:**
- Modules
- Hilt Modules
  - Using @InstallIn
  - Installing a module in multiple components
- App Build variants
- Bazel: Organizing your BUILD files
- Hilt module visibility best practice

Hilt modules are standard Dagger modules that have an additional @InstallIn annotation that determines which Hilt component(s) to install the module into.

When the Hilt components are generated, the modules annotated with @InstallIn will be installed into the corresponding component or subcomponent via @Component#modules or @Subcomponent#modules respectively. Just like in Dagger, installing a module into a component allows that binding to be accessed as a dependency of other bindings in that component or any child component(s) below it in the component hierarchy. They can also be accessed from the corresponding @AndroidEntryPoint classes. Being installed in a component also allows that binding to be scoped to that component.

A module is installed in a Hilt Component by annotating the module with the @InstallIn annotation. These annotations are required on all Dagger modules when using Hilt, but this check may be optionally disabled.

Note: If a module does not have an @InstallIn annotation, the module will not be part of the component and may result in compilation errors.

Specify which Hilt Component to install the module in by passing in the appropriate Component type(s) to the @InstallIn annotation. For example, to install a module so that anything in the application can use it, use SingletonComponent:

Each component comes with a scoping annotation that can be used to memoize a binding to the lifetime of the component. For example, to scope a binding to the SingletonComponent component, use the @Singleton annotation:

In addition, each component has bindings that are available to it by default. (See Hilt Components for a complete list.) For example, the SingletonComponent component provides the Application binding:

A module can be installed in multiple components. For example, maybe you have a binding in ViewComponent and ViewWithFragmentComponent and do not want to duplicate modules. @InstallIn({ViewComponent.class, ViewWithFragmentComponent.class}) will install a module in both components.

There are three rules to follow when installing a module in multiple components:

Most Android apps will want to pull in different modules and bindings depending on the build variant of the app (e.g. production, debug, testing, etc.).

In Hilt, if your binary’s build target transitively depends on a module, then that module will be installed in the appropriate component for your app. This makes configuration as easy as defining a different build target and pulling different deps into your binary definition.

Because Bazel tends to enourage separation into finer-grained build targets, it is often better for tests to just avoid depending on modules you intend to replace in tests instead of uninstalling them. This is because it reduces the build dependencies of your test which can lead to overall faster build times.

When organizing your BUILD target for a module, you should consider if this module should be replaceable in tests or other configurations of your app. If it should never be replaced, then feel free to include the module with your other code sources.

If it should be replaceable though, you should create a separate target for your module. This target can then be pulled in at the root of your app so that each test root (or other configuration root) can decide whether to use your module or not.

There are two ways to organize your BUILD targets with regards to modules depending on the situation:

It is recommended to choose the first method by default and use the second method only for bindings that need to be replaceable in tests. It is expected, though, that many libraries will use both methods.

In Dagger, modules are usually public visibility because they are referenced by other components or other modules installing them. However, in Hilt, because modules are installed just by being in the transitive dependencies, modules don’t really need to be public for the same reason (technical aside: Hilt will actually generate public wrappers to get around visibility requirements for compilation).

In fact, doing the opposite and restricting visibility of Hilt modules is a best practice because it prevents non-Hilt Dagger components from installing the modules. Installing a Hilt module in a non-Hilt Dagger component would be confusing because it wouldn’t be a component in the @InstallIn annotation. For libraries where you want a module for Hilt and non-Hilt users, it is usually best to have two separate modules for each case. If the code is going to be the same for both, have the Hilt module just be an empty module that uses @Module(includes = ...) to include the non-Hilt module.

**Examples:**

Example 1 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent.class) // Installs FooModule in the generate SingletonComponent.
final class FooModule {
  @Provides
  static Bar provideBar() {...}
}
```

Example 2 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent::class) // Installs FooModule in the generate SingletonComponent.
internal object FooModule {
  @Provides
  fun provideBar(): Bar {...}
}
```

Example 3 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent.class)
final class FooModule {
  // @Singleton providers are only called once per SingletonComponent instance.
  @Provides
  @Singleton
  static Bar provideBar() {...}
}
```

Example 4 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent::class)
object FooModule {
  // @Singleton providers are only called once per SingletonComponent instance.
  @Provides
  @Singleton
  fun provideBar(): Bar {...}
}
```

---

## Flags

**URL:** https://dagger.dev/hilt/flags.html

**Contents:**
- Flags
- Compiler Options
  - Turning off the @InstallIn check
- Sharing test components
  - Entry point method return types must be public
  - Entry point method names must be unique
  - Modules with non-static/non-abstract methods must be public
- Turning off the cross compilation root validation
- Runtime flags
  - Disable Fragment.getContext() fix

By default, Hilt checks @Module classes for the @InstallIn annotation and raises an error if it is missing. This is because if someone accidentally forgets to put @InstallIn on a module, it could be very hard to debug that Hilt isn’t picking it up.

This check can sometimes be overly broad though, especially if in the middle of a migration. To turn off this check, this flag can be used:

-Adagger.hilt.disableModulesHaveInstallInCheck=true.

Alternatively, the check can be disabled at the individual module level by annotating the module with @DisableInstallInCheck.

In cases where a test does not define @BindValue fields or inner modules, it can share a generated component with other tests in the same compilation unit. Sharing components may reduce the amount of generated code that javac needs to compile, improving build times.

When component sharing is enabled, all test components are generated in a separate package from your test class. This may cause visibility and name collision issues. Those issues are described in the sections below.

Sharing components is enabled by default. If your project does not build due to component sharing, you can disable this behavior and have Hilt generate a Dagger separate @Component for each @HiltAndroidTest using this flag:

-Adagger.hilt.shareTestComponents=false

However, consider the following fixes in order to avoid disabling this behavior.

Because the shared components must be generated in a common package location that is outside of the tests’ packages, any entry points included by the test must only provide publicly visible bindings. This is in order to be referenced by the generated components. You may find that you will have to mark some Java types as public (or remove internal in Kotlin).

Because the shared components must include entry points from every test class, explicit @EntryPoint methods must not clash. Test @EntryPoint methods must either be uniquely named across test classes, or must return the same type.

The generated Dagger component must be able to instantiate modules that have methods that are non-static and non-abstract. This requires referencing the module type explicitly across package boundaries. You may need to mark some package-private test modules as public.

By default, Hilt checks that:

This check can sometimes be overly broad though, especially if in the middle of a migration. To turn off this check, this flag can be used:

-Adagger.hilt.disableCrossCompilationRootValidation=true.

Runtime flags to control Hilt behavior for rollout of changes. These flags are usually meant to be temporary and so defaults may change with releases and then these flags may eventually be removed, just like compiler options with similar purposes.

See https://github.com/google/dagger/pull/2620 for the change that introduces the getContext() fix. This flag controls if fragment code should use the fixed getContext() behavior where it correctly returns null after a fragment is removed. This fixed behavior matches the behavior of a regular, non-Hilt fragment and can help catch issues where a removed or leaked fragment is incorrectly used. This is a runtime flag though because code previous relying on the method returning a non-null value after fragment removal could break.

By default, the fix is turned off (e.g. the flag for disabling is true), but the fixed version may be used by setting the flag at runtime. The default for this flag may change in a future release.

In order to set the flag, bind a boolean value qualified with DisableFragmentGetContextFix into a set in the SingletonComponent. A set is used instead of an optional binding to avoid a dependency on Guava. Only one value may be bound into the set within a given app. Example for binding the value:

This flag used to be paired with a compiler option flag dagger.hilt.android.useFragmentGetContextFix, however, as of Dagger 2.40 this compiler option has now been removed and this behavior is only controlled via the runtime flag.

**Examples:**

Example 1 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent.class)
public final class DisableFragmentGetContextFixModule {
@Provides
@IntoSet
@FragmentGetContextFix.DisableFragmentGetContextFix
  static Boolean provideDisableFragmentGetContextFix() {
    // Return true or false depending on some rollout logic for your app
    // True is the default value if unset. Use false to use the fixed behavior.
 }
}
```

---

## Modules

**URL:** https://dagger.dev/hilt/modules.html

**Contents:**
- Modules
- Hilt Modules
  - Using @InstallIn
  - Installing a module in multiple components
- App Build variants
- Bazel: Organizing your BUILD files
- Hilt module visibility best practice

Hilt modules are standard Dagger modules that have an additional @InstallIn annotation that determines which Hilt component(s) to install the module into.

When the Hilt components are generated, the modules annotated with @InstallIn will be installed into the corresponding component or subcomponent via @Component#modules or @Subcomponent#modules respectively. Just like in Dagger, installing a module into a component allows that binding to be accessed as a dependency of other bindings in that component or any child component(s) below it in the component hierarchy. They can also be accessed from the corresponding @AndroidEntryPoint classes. Being installed in a component also allows that binding to be scoped to that component.

A module is installed in a Hilt Component by annotating the module with the @InstallIn annotation. These annotations are required on all Dagger modules when using Hilt, but this check may be optionally disabled.

Note: If a module does not have an @InstallIn annotation, the module will not be part of the component and may result in compilation errors.

Specify which Hilt Component to install the module in by passing in the appropriate Component type(s) to the @InstallIn annotation. For example, to install a module so that anything in the application can use it, use SingletonComponent:

Each component comes with a scoping annotation that can be used to memoize a binding to the lifetime of the component. For example, to scope a binding to the SingletonComponent component, use the @Singleton annotation:

In addition, each component has bindings that are available to it by default. (See Hilt Components for a complete list.) For example, the SingletonComponent component provides the Application binding:

A module can be installed in multiple components. For example, maybe you have a binding in ViewComponent and ViewWithFragmentComponent and do not want to duplicate modules. @InstallIn({ViewComponent.class, ViewWithFragmentComponent.class}) will install a module in both components.

There are three rules to follow when installing a module in multiple components:

Most Android apps will want to pull in different modules and bindings depending on the build variant of the app (e.g. production, debug, testing, etc.).

In Hilt, if your binary’s build target transitively depends on a module, then that module will be installed in the appropriate component for your app. This makes configuration as easy as defining a different build target and pulling different deps into your binary definition.

Because Bazel tends to enourage separation into finer-grained build targets, it is often better for tests to just avoid depending on modules you intend to replace in tests instead of uninstalling them. This is because it reduces the build dependencies of your test which can lead to overall faster build times.

When organizing your BUILD target for a module, you should consider if this module should be replaceable in tests or other configurations of your app. If it should never be replaced, then feel free to include the module with your other code sources.

If it should be replaceable though, you should create a separate target for your module. This target can then be pulled in at the root of your app so that each test root (or other configuration root) can decide whether to use your module or not.

There are two ways to organize your BUILD targets with regards to modules depending on the situation:

It is recommended to choose the first method by default and use the second method only for bindings that need to be replaceable in tests. It is expected, though, that many libraries will use both methods.

In Dagger, modules are usually public visibility because they are referenced by other components or other modules installing them. However, in Hilt, because modules are installed just by being in the transitive dependencies, modules don’t really need to be public for the same reason (technical aside: Hilt will actually generate public wrappers to get around visibility requirements for compilation).

In fact, doing the opposite and restricting visibility of Hilt modules is a best practice because it prevents non-Hilt Dagger components from installing the modules. Installing a Hilt module in a non-Hilt Dagger component would be confusing because it wouldn’t be a component in the @InstallIn annotation. For libraries where you want a module for Hilt and non-Hilt users, it is usually best to have two separate modules for each case. If the code is going to be the same for both, have the Hilt module just be an empty module that uses @Module(includes = ...) to include the non-Hilt module.

**Examples:**

Example 1 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent.class) // Installs FooModule in the generate SingletonComponent.
final class FooModule {
  @Provides
  static Bar provideBar() {...}
}
```

Example 2 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent::class) // Installs FooModule in the generate SingletonComponent.
internal object FooModule {
  @Provides
  fun provideBar(): Bar {...}
}
```

Example 3 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent.class)
final class FooModule {
  // @Singleton providers are only called once per SingletonComponent instance.
  @Provides
  @Singleton
  static Bar provideBar() {...}
}
```

Example 4 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent::class)
object FooModule {
  // @Singleton providers are only called once per SingletonComponent instance.
  @Provides
  @Singleton
  fun provideBar(): Bar {...}
}
```

---

## Flags

**URL:** https://dagger.dev/hilt/flags

**Contents:**
- Flags
- Compiler Options
  - Turning off the @InstallIn check
- Sharing test components
  - Entry point method return types must be public
  - Entry point method names must be unique
  - Modules with non-static/non-abstract methods must be public
- Turning off the cross compilation root validation
- Runtime flags
  - Disable Fragment.getContext() fix

By default, Hilt checks @Module classes for the @InstallIn annotation and raises an error if it is missing. This is because if someone accidentally forgets to put @InstallIn on a module, it could be very hard to debug that Hilt isn’t picking it up.

This check can sometimes be overly broad though, especially if in the middle of a migration. To turn off this check, this flag can be used:

-Adagger.hilt.disableModulesHaveInstallInCheck=true.

Alternatively, the check can be disabled at the individual module level by annotating the module with @DisableInstallInCheck.

In cases where a test does not define @BindValue fields or inner modules, it can share a generated component with other tests in the same compilation unit. Sharing components may reduce the amount of generated code that javac needs to compile, improving build times.

When component sharing is enabled, all test components are generated in a separate package from your test class. This may cause visibility and name collision issues. Those issues are described in the sections below.

Sharing components is enabled by default. If your project does not build due to component sharing, you can disable this behavior and have Hilt generate a Dagger separate @Component for each @HiltAndroidTest using this flag:

-Adagger.hilt.shareTestComponents=false

However, consider the following fixes in order to avoid disabling this behavior.

Because the shared components must be generated in a common package location that is outside of the tests’ packages, any entry points included by the test must only provide publicly visible bindings. This is in order to be referenced by the generated components. You may find that you will have to mark some Java types as public (or remove internal in Kotlin).

Because the shared components must include entry points from every test class, explicit @EntryPoint methods must not clash. Test @EntryPoint methods must either be uniquely named across test classes, or must return the same type.

The generated Dagger component must be able to instantiate modules that have methods that are non-static and non-abstract. This requires referencing the module type explicitly across package boundaries. You may need to mark some package-private test modules as public.

By default, Hilt checks that:

This check can sometimes be overly broad though, especially if in the middle of a migration. To turn off this check, this flag can be used:

-Adagger.hilt.disableCrossCompilationRootValidation=true.

Runtime flags to control Hilt behavior for rollout of changes. These flags are usually meant to be temporary and so defaults may change with releases and then these flags may eventually be removed, just like compiler options with similar purposes.

See https://github.com/google/dagger/pull/2620 for the change that introduces the getContext() fix. This flag controls if fragment code should use the fixed getContext() behavior where it correctly returns null after a fragment is removed. This fixed behavior matches the behavior of a regular, non-Hilt fragment and can help catch issues where a removed or leaked fragment is incorrectly used. This is a runtime flag though because code previous relying on the method returning a non-null value after fragment removal could break.

By default, the fix is turned off (e.g. the flag for disabling is true), but the fixed version may be used by setting the flag at runtime. The default for this flag may change in a future release.

In order to set the flag, bind a boolean value qualified with DisableFragmentGetContextFix into a set in the SingletonComponent. A set is used instead of an optional binding to avoid a dependency on Guava. Only one value may be bound into the set within a given app. Example for binding the value:

This flag used to be paired with a compiler option flag dagger.hilt.android.useFragmentGetContextFix, however, as of Dagger 2.40 this compiler option has now been removed and this behavior is only controlled via the runtime flag.

**Examples:**

Example 1 (unknown):
```unknown
@Module
@InstallIn(SingletonComponent.class)
public final class DisableFragmentGetContextFixModule {
@Provides
@IntoSet
@FragmentGetContextFix.DisableFragmentGetContextFix
  static Boolean provideDisableFragmentGetContextFix() {
    // Return true or false depending on some rollout logic for your app
    // True is the default value if unset. Use false to use the fixed behavior.
 }
}
```

---
