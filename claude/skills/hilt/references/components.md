# Hilt - Components

**Pages:** 17

---

## Hilt Application

**URL:** https://dagger.dev/hilt/application

**Contents:**
- Hilt Application
- Hilt Application

Note: Examples on this page assume usage of the Gradle plugin. If you are not using the plugin, please read this page for details.

All apps using Hilt must contain an Application class annotated with @HiltAndroidApp. @HiltAndroidApp kicks off the code generation of the Hilt components and also generates a base class for your application that uses those generated components. Because the code generation needs access to all of your modules, the target that compiles your Application class also needs to have all of your Dagger modules in its transitive dependencies.

Just like other Hilt Android entry points, Applications are members injected as well. This means you can use injected fields in the Application after super.onCreate() has been called.

Note: Since all injected fields are created at the same time in onCreate, if an object is only needed later or conditionally, remember that you can use a Provider to defer injection. Especially in the Application class which is on the critical startup path, avoiding unnecessary injections can be important to performance.

For example, take the class called MyApplication that extends MyBaseApplication and has a member variable Bar:

With Hilt’s members injection, the above code becomes:

**Examples:**

Example 1 (unknown):
```unknown
public final class MyApplication extends MyBaseApplication {
  @Inject Bar bar;

  @Override public void onCreate() {
    super.onCreate();

    MyComponent myComponent =
        DaggerMyComponent
            .builder()
            ...
            .build();

    myComponent.inject(this);
  }
}
```

Example 2 (unknown):
```unknown
class MyApplication : MyBaseApplication() {
  @Inject lateinit var bar: Bar

  override fun onCreate() {
    super.onCreate()

    val myComponent =
        DaggerMyComponent
            .builder()
            ...
            .build()

    myComponent.inject(this)
  }
}
```

Example 3 (unknown):
```unknown
@HiltAndroidApp
public final class MyApplication extends MyBaseApplication {
  @Inject Bar bar;

  @Override public void onCreate() {
    super.onCreate(); // Injection happens in super.onCreate()
    // Use bar
  }
}
```

Example 4 (unknown):
```unknown
@HiltAndroidApp
class MyApplication : MyBaseApplication() {
  @Inject lateinit var bar: Bar

  override fun onCreate() {
    super.onCreate() // Injection happens in super.onCreate()
    // Use bar
  }
}
```

---

## Optional inject

**URL:** https://dagger.dev/hilt/optional-inject.html

**Contents:**
- Optional inject
- Why would you need optional injection?
- How to use @OptionalInject

Hilt fragments need to be attached to Hilt activities and Hilt activities need to be attached to Hilt applications. While this is a natural restriction for pure Hilt codebases, it may be an issue during a migration to Hilt if you have a fragment or activity that is used in a non-Hilt context. For example, say you want to migrate a fragment to Hilt but it is used in too many places to migrate at once. Without optional injection, you would have to migrate every activity that uses that fragment to Hilt first otherwise the fragment will crash when looking for the Hilt components when it is trying to inject itself. Depending on the size of your codebase, this could be a large undertaking.

If you mark an @AndroidEntryPoint class with @OptionalInject then it will only try to inject if the parent is using Hilt and not require it. Using this annotation will also cause a wasInjectedByHilt() method to be generated on the generated base class that returns true if it was successful injecting.

Note: Because API generated on the base class is inaccessible to users of the gradle plugin, there is an alternative API to access this functionality using a static helper method in OptionalInjectCheck.

This gives you the chance to provide dependencies in a different way (usually whichever way you were getting dependencies before using Hilt).

Note that for activities, because Hilt injection is usually run as a part of super.onCreate() and it is recommended to do your own injection before fragments are restored which also happens during super.onCreate(), you likely need to use an OnContextAvailableListener to run your non-Hilt injection code. Hilt uses the same listener under the hood, so then the order would be Hilt’s OnContextAvailableListener would run, then yours, then fragments would be restored.

**Examples:**

Example 1 (unknown):
```unknown
@OptionalInject
@AndroidEntryPoint
public final class MyFragment extends Fragment {

  @Inject Foo foo;

  @Override public void onAttach(Activity activity) {
    super.onAttach(activity);  // Injection will happen here, but only if the Activity used Hilt
    if (!OptionalInjectCheck.wasInjectedByHilt(this)) {
      // Get Dagger components the previous way and inject
    }
  }
}
```

Example 2 (unknown):
```unknown
@OptionalInject
@AndroidEntryPoint
class MyFragment : Fragment() {

  @Inject lateinit var foo: Foo

  override fun onAttach(activity: Activity) {
    super.onAttach(activity)  // Injection will happen here, but only if the Activity used Hilt
    if (!OptionalInjectCheck.wasInjectedByHilt(this)) {
      // Get Dagger components the previous way and inject
    }
  }
}
```

---

## Android Entry Points

**URL:** https://dagger.dev/hilt/android-entry-point.html

**Contents:**
- Android Entry Points
- Android types
  - Retained Fragments
  - Views with Fragment bindings

Note: Examples on this page assume usage of the Gradle plugin. If you are not using the plugin, please read this page for details.

Once you have enabled members injection in your Application, you can start enabling members injection in your other Android classes using the @AndroidEntryPoint annotation. You can use @AndroidEntryPoint on the following types:

Note that ViewModels are supported via a separate API @HiltViewModel. ContentProviders are not directly supported due to their onCreate being called at startup, but you can access dependencies via an entry point.

The following example shows how to add the annotation to an activity, but the process is the same for other types. When adding to other types, note that as a general rule, Hilt types need to be attached to other Hilt types to work. So before adding [@AndroidEntryPoint] to a fragment, the activity must be annotated as well.

To enable members injection in your activity, annotate your class with @AndroidEntryPoint.

Note: Hilt currently only supports activities that extend ComponentActivity and fragments that extend androidx library Fragment, not the (now deprecated) Fragment in the Android platform.

Calling setRetainInstance(true) in a Fragment’s onCreate method will keep a fragment instance across configuration changes (instead of destroying and recreating it).

A Hilt fragment should never be retained because it holds a reference to the component (responsible for injection), and that component holds references to the previous Activity instance. In addition, scoped bindings and providers that are injected into the fragment can also cause memory leaks if a Hilt fragment is retained. To prevent Hilt fragments from being retained, a runtime exception will be thrown on configuration change if a retained Hilt fragment is detected.

A non-Hilt fragment can be retained, even if attached to a Hilt activity. However, if that fragment contains a Hilt child fragment, a runtime exception will be thrown when a configuration change occurs.

Note: While it’s not recommended, Hilt fragments can be detached and reattached to the same activity instance. In this case, the Hilt fragment will only be injected on the first call to onAttach. Note that this is not the same as retaining a fragment, because a retained fragment will be reattached to a different instance of the activity. Again, this is not recommended, and it is often less confusing to just create a new fragment instance for each usage.

By default, only SingletonComponent and ActivityComponent bindings can be injected into the view. To enable fragment bindings in your view, add the @WithFragmentBindings annotation to your class.

Unlike the other supported Android classes, BroadcastReceivers do not have their own Dagger component and are instead simply injected from the SingletonComponent. ↩

**Examples:**

Example 1 (unknown):
```unknown
@AndroidEntryPoint
public final class MyActivity extends MyBaseActivity {
  // Bindings in SingletonComponent or ActivityComponent
  @Inject Bar bar;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    // Injection happens in super.onCreate().
    super.onCreate();

    // Do something with bar ...
  }
}
```

Example 2 (unknown):
```unknown
@AndroidEntryPoint
class MyActivity : MyBaseActivity() {
  // Bindings in SingletonComponent or ActivityComponent
  @Inject lateinit var bar: Bar

  override fun onCreate(savedInstanceState: Bundle?) {
    // Injection happens in super.onCreate().
    super.onCreate()

    // Do something with bar ...
  }
}
```

Example 3 (unknown):
```unknown
@WithFragmentBindings
@AndroidEntryPoint
public final class MyView extends MyBaseView {
  // Bindings in SingletonComponent, ActivityComponent,
  // FragmentComponent, and ViewComponent
  @Inject Bar bar;

  public MyView(Context context, AttributeSet attributeSet) {
    super(context, attributeSet);

    // Do something with bar...
  }

  @Override
  public void onFinishInflate() {
    super.onFinishInflate();

    // Find & assign child views from the inflated hierarchy.
  }
}
```

Example 4 (unknown):
```unknown
@AndroidEntryPoint
@WithFragmentBindings
class MyView : MyBaseView {
  // Bindings in SingletonComponent, ActivityComponent,
  // FragmentComponent, and ViewComponent
  @Inject lateinit var bar: Bar

  constructor(context: Context) : super(context)
  constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

  init {
    // Do something with bar ...
  }

  override fun onFinishInflate() {
    super.onFinishInflate();

    // Find & assign child views from the inflated hierarchy.
  }
}
```

---

## Hilt Components

**URL:** https://dagger.dev/hilt/components

**Contents:**
- Hilt Components
- Component hierarchy
- Components used for injection
- Component lifetimes
    - Scoped vs unscoped bindings
    - Scoping in modules
    - When to scope?
- Component default bindings

Note: The following page assumes a basic knowledge of Dagger, including components, modules, scopes, and bindings. (For a refresher, see Dagger users guide.)

Unlike traditional Dagger, Hilt users never define or instantiate Dagger components directly. Instead, Hilt offers predefined components that are generated for you. Hilt comes with a built-in set of components (and corresponding scope annotations) that are automatically integrated into the various lifecycles of an Android application. The diagram below shows the standard Hilt component hierarchy. The annotation above each component is the scoping annotation used to scope bindings to the lifetime of that component. The arrow below a component points to any child components. As normal, a binding in a child component can have dependencies on any binding in an ancestor component.

Note: When scoping a binding within an @InstallIn module, the scope on the binding must match the scope of the component. For example, a binding within an @InstallIn(ActivityComponent.class) module can only be scoped with @ActivityScoped.

When using Hilt APIs like @AndroidEntryPoint to inject your Android classes, the standard Hilt components are used as the injectors. The component used as the injector will determine which bindings are visible to that Android class. The components used are shown in the table below:

The lifetime of a component is important because it relates to the lifetime of your bindings in two important ways:

Component lifetimes are generally bounded by the creation and destruction of a corresponding instance of an Android class. The table below lists the scope annotation and bounded lifetime for each component.

By default, all bindings in Dagger are “unscoped”. This means that each time the binding is requested, Dagger will create a new instance of the binding.

However, Dagger also allows a binding to be “scoped” to a particular component (see the scope annotations in the table above). A scoped binding will only be created once per instance of the component it’s scoped to, and all requests for that binding will share the same instance.

Warning: A common misconception is that all fragment instances will share the same instance of a binding scoped with @FragmentScoped. However, this is not true. Each fragment instance gets a new instance of the fragment component, and thus a new instance of all its scoped bindings.

The previous section showed how to scope a binding declared with an @Inject constructor, but a binding declared in a module can also be scoped in a similar way.

Warning: A common misconception is that all bindings declared in a module will be scoped to the component the module is installed in. However, this isn’t true. Only bindings declarations annotated with a scope annotation will be scoped.

Scoping a binding has a cost on both the generated code size and its runtime performance so use scoping sparingly. The general rule for determining if a binding should be scoped is to only scope the binding if it’s required for the correctness of the code. If you think a binding should be scoped for purely performance reasons, first verify that the performance is an issue, and if it is consider using @Reusable instead of a component scope.

Each Hilt component comes with a set of default bindings that can be injected as dependencies into your own custom bindings. Each component listed has the corresponding default bindings as well as any default bindings from an ancestor component.

ActivityRetainedComponent lives across configuration changes, so it is created at the first onCreate and last onDestroy. ↩ ↩2

The Application binding is available using either @ApplicationContext Context or Application. [^3]: @ActivityRetainedSavedState SavedStateHandlemust be used with @OptIn(UnstableApi.class). This binding relies on an experimental implementation to lazily create SavedStateHandle, which should be safe to rely on, but it is still possible that a future release may remove the binding if a bug is uncovered. ↩

**Examples:**

Example 1 (unknown):
```unknown
// This binding is "unscoped".
// Each request for this binding will get a new instance.
final class UnscopedBinding {
  @Inject UnscopedBinding() {}
}

// This binding is "scoped".
// Each request from the same component instance for this binding will
// get the same instance. Since this is the fragment component, this means
// each request from the same fragment.
@FragmentScoped
final class ScopedBinding {
  @Inject ScopedBinding() {}
}
```

Example 2 (unknown):
```unknown
// This binding is "unscoped".
// Each request for this binding will get a new instance.
class UnscopedBinding @Inject constructor() {
}

// This binding is "scoped".
// Each request from the same component instance for this binding will
// get the same instance. Since this is the fragment component, this means
// each request from the same fragment.
@FragmentScoped
class ScopedBinding @Inject constructor() {
}
```

Example 3 (unknown):
```unknown
@Module
@InstallIn(FragmentComponent.class)
abstract class FooModule {
  // This binding is "unscoped".
  @Provides
  static UnscopedBinding provideUnscopedBinding() {
    return new UnscopedBinding();
  }

  // This binding is "scoped".
  @Provides
  @FragmentScoped
  static ScopedBinding provideScopedBinding() {
    return new ScopedBinding();
  }
}
```

Example 4 (unknown):
```unknown
@Module
@InstallIn(FragmentComponent::class)
object FooModule {
  // This binding is "unscoped".
  @Provides
  fun provideUnscopedBinding() = UnscopedBinding()

  // This binding is "scoped".
  @Provides
  @FragmentScoped
  fun provideScopedBinding() = ScopedBinding()
}
```

---

## View Models

**URL:** https://dagger.dev/hilt/view-model.html

**Contents:**
- View Models
- Hilt View Models
- View Model Scope
- Assisted Injection

Note: Examples on this page assume usage of the Gradle plugin. If you are not using the plugin, please read this page for details.

A Hilt View Model is a Jetpack ViewModel that is constructor injected by Hilt. To enable injection of a ViewModel by Hilt use the @HiltViewModel annotation:

Then an activity or fragments annotated with @AndroidEntryPoint can get the ViewModel instance as normal using ViewModelProvider or the by viewModels() KTX extension:

Warning: Even though the view model has an @Inject constructor, it is an error to request it from Dagger directly (for example, via field injection) since that would result in multiple instances. View Models must be retrieved through the ViewModelProvider API. This is checked at compile time by Hilt.

Only dependencies from the ViewModelComponent and its parent components can be provided into the ViewModel.

The ViewModelComponent also comes with two default bindings available:

All Hilt View Models are provided by the ViewModelComponent which follows the same lifecycle as a ViewModel, i.e. it survives configuration changes. To scope a dependency to a ViewModel use the @ViewModelScoped annotation.

A @ViewModelScoped type will make it so that a single instance of the scoped type is provided across all dependencies injected into the Hilt View Model. Other instances of a ViewModel that requests the scoped instance will receive a different instance. Scoping to the ViewModelComponent allows for flexible and granular scope since View Models survive configuration changes and their lifecycle is controlled by the activity or fragment. If a single instance needs to be shared across various View Models then it should be scoped using either @ActivityRetainedScoped or @Singleton.

For example, we can scope a dependency to be shared within a single ViewModel as such:

Hilt View Models can also be assisted injected. Compared to using SavedStateHandle, this enables passing data that are not Parcelable to a Hilt View Model easily. To use assisted injection, annotate the view model constructor with @AssistedInject and the assisted parameters with @Assisted, and specify the assisted factory in the @HiltViewModel annotation:

Note: Unlike SavedStateHandle, the values passed through assisted parameters to a Hilt View Model do not get saved to disk. They have the same scope as the view model and do not persist after the lifecycle of the view model has ended, e.g. containing activity gets popped off the stack or process death. Consider using normal injection with SavedStateHandle instead or other mechanisms if persistence is needed.

Next, define the assisted factory with an abstract factory method that returns the view model:

Note: It is an error to request the assisted factory for view models from Dagger directly since the factory may be used to create view model instances that are not stored correctly. This is checked at compile time by Hilt.

Finally, pass a callback to the helper function HiltViewModelExtensions.withCreationCallback() to create a CreationExtras that can be used with the ViewModelProvider API or other view model functions like by viewModels(). Use the passed in factory to create a view model instance inside the callback:

Warning: Do not pass any objects that have a smaller lifecycle than the view model (e.g. an Activity, Fragment, or View) or any objects that reference them to the assisted factory as that would be leaking them.

Note: Unlike normal @AssistedInject types, a Hilt View Models, like all View Models, are memoized by the owner. Once a Hilt View Model instance has been created, the callback will be ignored as long as the view model’s lifecycle has not ended. For example, Hilt does not call the callback to create a new view model instance after configuration changes, nor will it update the values of assisted parameters in the existing view model instances.

**Examples:**

Example 1 (unknown):
```unknown
@HiltViewModel
public final class FooViewModel extends ViewModel {

  @Inject
  FooViewModel(SavedStateHandle handle, Foo foo) {
    // ...
  }
}
```

Example 2 (unknown):
```unknown
@HiltViewModel
class FooViewModel @Inject constructor(
  val handle: SavedStateHandle,
  val foo: Foo
) : ViewModel()
```

Example 3 (unknown):
```unknown
@AndroidEntryPoint
public final class MyActivity extends AppCompatActivity {

  private FooViewModel fooViewModel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    fooViewModel = new ViewModelProvider(this).get(FooViewModel.class);
  }
}
```

Example 4 (unknown):
```unknown
@AndroidEntryPoint
class MyActivity : AppCompatActivity() {
  private val fooViewModel: FooViewModel by viewModels()
}
```

---

## Subcomponents vs Component dependencies

**URL:** https://dagger.dev/hilt/subcomponents-vs-deps.html

**Contents:**
- Subcomponents vs Component dependencies
- Overview
- Single binding key space
- Propagating bindings with component dependencies defeats Dagger pruning
- Configuration at the root and build speed

Hilt is based around using Dagger subcomponents as opposed to component dependencies. This page explains some of the reasons why Hilt was designed this way.

Subcomponents propagate all bindings by default. This includes multibindings which can be difficult to propagate via component dependencies. This creates a merged binding key space. This generally makes it easier to understand the Dagger graph because you don’t have to worry about considering if a binding is propagated or not from a parent component to a child component. Also, if bindings are not propagated with component dependencies, it is possible to use two different definitions of the same binding key in different components. This can make it difficult to walk through code when debugging issues as the binding definition will be based on the context of the usage.

One of the downsides of a single binding key space is that it can be extra work to place restrictions on code usage (e.g. if one feature shouldn’t use bindings from another feature). For this we generally recommend using qualifier annotations that are restricted visibility or using an SPI plugin to enforce separation of code. Using a qualifier or an SPI plugin is better than building these concerns into the structure of your Dagger component dependencies graph because often these rules encode policy. Policy decisions like this are often in flux (or need to have exceptions allowed) and having to restructure a Dagger component dependencies graph based on those changes can be costly.

Since Dagger can see the entry points to the graph, it can figure out which bindings are unused and not generate code for those bindings. This optimization goes through subcomponents, but it is defeated by component dependencies because propagating bindings through component dependencies adds entry point methods. So even if entry point methods are only used by other Dagger components and across the components the binding is unused, Dagger will be forced to still generate that dead code to adhere to its contract.

One of the main advantages of component dependencies is building Dagger code separately and in parallel. This can be done because of the lack of implicit sharing that make components black boxes with respect to each other. However, Hilt is already based on the idea of central configuration based on build dependencies. Since Hilt has to aggregate modules, all components would be generated at the same time anyway so we wouldn’t be able to take advantage of building in parallel.

Instead, to address build speed, Hilt recommends making smaller test apps for individual feature development. Without Hilt, this would have been difficult to do because of all of the repeated Dagger boilerplate for the small test app. However, with Hilt generating all of the Dagger portion based on build dependencies, putting together a small test app should be much easier.

---

## Android Entry Points

**URL:** https://dagger.dev/hilt/android-entry-point

**Contents:**
- Android Entry Points
- Android types
  - Retained Fragments
  - Views with Fragment bindings

Note: Examples on this page assume usage of the Gradle plugin. If you are not using the plugin, please read this page for details.

Once you have enabled members injection in your Application, you can start enabling members injection in your other Android classes using the @AndroidEntryPoint annotation. You can use @AndroidEntryPoint on the following types:

Note that ViewModels are supported via a separate API @HiltViewModel. ContentProviders are not directly supported due to their onCreate being called at startup, but you can access dependencies via an entry point.

The following example shows how to add the annotation to an activity, but the process is the same for other types. When adding to other types, note that as a general rule, Hilt types need to be attached to other Hilt types to work. So before adding [@AndroidEntryPoint] to a fragment, the activity must be annotated as well.

To enable members injection in your activity, annotate your class with @AndroidEntryPoint.

Note: Hilt currently only supports activities that extend ComponentActivity and fragments that extend androidx library Fragment, not the (now deprecated) Fragment in the Android platform.

Calling setRetainInstance(true) in a Fragment’s onCreate method will keep a fragment instance across configuration changes (instead of destroying and recreating it).

A Hilt fragment should never be retained because it holds a reference to the component (responsible for injection), and that component holds references to the previous Activity instance. In addition, scoped bindings and providers that are injected into the fragment can also cause memory leaks if a Hilt fragment is retained. To prevent Hilt fragments from being retained, a runtime exception will be thrown on configuration change if a retained Hilt fragment is detected.

A non-Hilt fragment can be retained, even if attached to a Hilt activity. However, if that fragment contains a Hilt child fragment, a runtime exception will be thrown when a configuration change occurs.

Note: While it’s not recommended, Hilt fragments can be detached and reattached to the same activity instance. In this case, the Hilt fragment will only be injected on the first call to onAttach. Note that this is not the same as retaining a fragment, because a retained fragment will be reattached to a different instance of the activity. Again, this is not recommended, and it is often less confusing to just create a new fragment instance for each usage.

By default, only SingletonComponent and ActivityComponent bindings can be injected into the view. To enable fragment bindings in your view, add the @WithFragmentBindings annotation to your class.

Unlike the other supported Android classes, BroadcastReceivers do not have their own Dagger component and are instead simply injected from the SingletonComponent. ↩

**Examples:**

Example 1 (unknown):
```unknown
@AndroidEntryPoint
public final class MyActivity extends MyBaseActivity {
  // Bindings in SingletonComponent or ActivityComponent
  @Inject Bar bar;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    // Injection happens in super.onCreate().
    super.onCreate();

    // Do something with bar ...
  }
}
```

Example 2 (unknown):
```unknown
@AndroidEntryPoint
class MyActivity : MyBaseActivity() {
  // Bindings in SingletonComponent or ActivityComponent
  @Inject lateinit var bar: Bar

  override fun onCreate(savedInstanceState: Bundle?) {
    // Injection happens in super.onCreate().
    super.onCreate()

    // Do something with bar ...
  }
}
```

Example 3 (unknown):
```unknown
@WithFragmentBindings
@AndroidEntryPoint
public final class MyView extends MyBaseView {
  // Bindings in SingletonComponent, ActivityComponent,
  // FragmentComponent, and ViewComponent
  @Inject Bar bar;

  public MyView(Context context, AttributeSet attributeSet) {
    super(context, attributeSet);

    // Do something with bar...
  }

  @Override
  public void onFinishInflate() {
    super.onFinishInflate();

    // Find & assign child views from the inflated hierarchy.
  }
}
```

Example 4 (unknown):
```unknown
@AndroidEntryPoint
@WithFragmentBindings
class MyView : MyBaseView {
  // Bindings in SingletonComponent, ActivityComponent,
  // FragmentComponent, and ViewComponent
  @Inject lateinit var bar: Bar

  constructor(context: Context) : super(context)
  constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

  init {
    // Do something with bar ...
  }

  override fun onFinishInflate() {
    super.onFinishInflate();

    // Find & assign child views from the inflated hierarchy.
  }
}
```

---

## Design Overview

**URL:** https://dagger.dev/hilt/design-overview

**Contents:**
- Design Overview
- Component generation and module/entry point installation
- @AndroidEntryPoint injection

Hilt generates components by finding all of the modules and entry points in the transitive classpath. The @InstallIn annotation on every module and entry point generates a small metadata class in a defined package. The special package is inspected when processing @HiltAndroidApp to find all of the aggregated items that need to be installed in the components. The same strategy is used for other helper classes like @DefineComponent and @AliasOf.

Since the Android Application is generated at the same time, the generated Application has a direct reference to the root generated component which is the SingletonComponent.

Since the HiltTestApplication must support multiple tests, unlike in the production application, reflection is used to find the generated components. This is helpful because it allows the test application to be decoupled from building with the tests which allows Hilt to provide a convenient default instead of requiring each project to code generate a test application. Reflection is not used in production because it provides less value and reflection may have more costs.

Aggregating all of the modules in the classpath works well for tests because it means tests can easily add bindings by just nesting classes in the test class (or even better using @BindValue which generates the module). Similarly, the module detection also allows classes to embed @Module classes as inner classes. This can be used to ensure the class cannot be used without the associated Dagger bindings and makes its usage less error prone (e.g. pairing a class with an @BindsOptionalOf it consumes or an @Binds to an interface).

@AndroidEntryPoint works by generating a base class that the user code extends either directly or indirectly via a transform in the Gradle plugin. This base class is responsible for retrieving the parent component (via Hilt interfaces on the parent), creating the component, injecting the class, and exposing the component to children via Hilt interfaces.

For example, to inject the activity the generated code essentially does the following (simplified for readability):

The generation of all of this glue code makes breaking dependencies with unsafe casts safe and easy. Also, the automatic discovery combined with the fact that the interfaces are generated with the activity that uses them makes it so that including or removing an @AndroidEntryPoint adds/takes all of its dependencies with it. This allows apps built with Hilt to be modular.

Most of the time the parent component is easy to get, but in the case of views and fragments it isn’t so easy because views get the activity context. To support views with fragment bindings, the generated base class for fragments override getLayoutInflater to wrap the Context in a ContextWrapper that holds the Dagger component for the view to get.

By standardizing all of these design decisions in Hilt, integrating libraries with activities/fragments/views should be much easier.

**Examples:**

Example 1 (unknown):
```unknown
@Override public void onCreate(Bundled savedInstanceState) {
  // This gets the parent component from the Application (in reality there is
  // actually the activity retained component as the parent).
  Object parentComponent =
      ((GeneratedComponentManager) getApplication()).generatedComponent();
  // This creates the activity component. This involves an unsafe cast
  // to know the parent component has the methods to build the activity component.
  Object activityComponent = ((ActivityComponentBuilderEntryPoint) parentComponent)
      .activityComponentBuilder()
      .activity(this)
      .build();
  // This injects the activity. It also involves an unsafe cast to get access
  // to the activity inject method. Like the other unsafe casts, these casts
  // break build dependencies and are safe because they are code generated and
  // guaranteed via the classpath discovery of modules/interfaces.
  (MyActivity_GeneratedInjector) activityComponent).inject(this).
}
```

---

## View Models

**URL:** https://dagger.dev/hilt/view-model

**Contents:**
- View Models
- Hilt View Models
- View Model Scope
- Assisted Injection

Note: Examples on this page assume usage of the Gradle plugin. If you are not using the plugin, please read this page for details.

A Hilt View Model is a Jetpack ViewModel that is constructor injected by Hilt. To enable injection of a ViewModel by Hilt use the @HiltViewModel annotation:

Then an activity or fragments annotated with @AndroidEntryPoint can get the ViewModel instance as normal using ViewModelProvider or the by viewModels() KTX extension:

Warning: Even though the view model has an @Inject constructor, it is an error to request it from Dagger directly (for example, via field injection) since that would result in multiple instances. View Models must be retrieved through the ViewModelProvider API. This is checked at compile time by Hilt.

Only dependencies from the ViewModelComponent and its parent components can be provided into the ViewModel.

The ViewModelComponent also comes with two default bindings available:

All Hilt View Models are provided by the ViewModelComponent which follows the same lifecycle as a ViewModel, i.e. it survives configuration changes. To scope a dependency to a ViewModel use the @ViewModelScoped annotation.

A @ViewModelScoped type will make it so that a single instance of the scoped type is provided across all dependencies injected into the Hilt View Model. Other instances of a ViewModel that requests the scoped instance will receive a different instance. Scoping to the ViewModelComponent allows for flexible and granular scope since View Models survive configuration changes and their lifecycle is controlled by the activity or fragment. If a single instance needs to be shared across various View Models then it should be scoped using either @ActivityRetainedScoped or @Singleton.

For example, we can scope a dependency to be shared within a single ViewModel as such:

Hilt View Models can also be assisted injected. Compared to using SavedStateHandle, this enables passing data that are not Parcelable to a Hilt View Model easily. To use assisted injection, annotate the view model constructor with @AssistedInject and the assisted parameters with @Assisted, and specify the assisted factory in the @HiltViewModel annotation:

Note: Unlike SavedStateHandle, the values passed through assisted parameters to a Hilt View Model do not get saved to disk. They have the same scope as the view model and do not persist after the lifecycle of the view model has ended, e.g. containing activity gets popped off the stack or process death. Consider using normal injection with SavedStateHandle instead or other mechanisms if persistence is needed.

Next, define the assisted factory with an abstract factory method that returns the view model:

Note: It is an error to request the assisted factory for view models from Dagger directly since the factory may be used to create view model instances that are not stored correctly. This is checked at compile time by Hilt.

Finally, pass a callback to the helper function HiltViewModelExtensions.withCreationCallback() to create a CreationExtras that can be used with the ViewModelProvider API or other view model functions like by viewModels(). Use the passed in factory to create a view model instance inside the callback:

Warning: Do not pass any objects that have a smaller lifecycle than the view model (e.g. an Activity, Fragment, or View) or any objects that reference them to the assisted factory as that would be leaking them.

Note: Unlike normal @AssistedInject types, a Hilt View Models, like all View Models, are memoized by the owner. Once a Hilt View Model instance has been created, the callback will be ignored as long as the view model’s lifecycle has not ended. For example, Hilt does not call the callback to create a new view model instance after configuration changes, nor will it update the values of assisted parameters in the existing view model instances.

**Examples:**

Example 1 (unknown):
```unknown
@HiltViewModel
public final class FooViewModel extends ViewModel {

  @Inject
  FooViewModel(SavedStateHandle handle, Foo foo) {
    // ...
  }
}
```

Example 2 (unknown):
```unknown
@HiltViewModel
class FooViewModel @Inject constructor(
  val handle: SavedStateHandle,
  val foo: Foo
) : ViewModel()
```

Example 3 (unknown):
```unknown
@AndroidEntryPoint
public final class MyActivity extends AppCompatActivity {

  private FooViewModel fooViewModel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    fooViewModel = new ViewModelProvider(this).get(FooViewModel.class);
  }
}
```

Example 4 (unknown):
```unknown
@AndroidEntryPoint
class MyActivity : AppCompatActivity() {
  private val fooViewModel: FooViewModel by viewModels()
}
```

---

## Monolithic components

**URL:** https://dagger.dev/hilt/monolithic

**Contents:**
- Monolithic components
- Overview
- Single binding key space
- Simplicity for configuration
- Less generated code
- fastInit and start up latency

Hilt uses a monolithic component system. This means that a single activity component definition is used to inject all activity classes. Same for Fragments and other Android types. Each activity has a separate instance of the component though, just the class definition is shared. This is as opposed to a polylithic component system where each activity has a separate component definition. A polylithic system is the default mode when using dagger.android’s @ContributesAndroidInjector. This page goes through some of the reasons Hilt was designed using monolithic components along with tradeoffs between the two models.

One of the main benefits of using a monolithic system like in Hilt is that the binding key space is merged. If you are in a fragment injecting a Foo class, it is much easier to find where that Foo binding came from because it cannot differ based on the activity the fragment is attached to. Polylithic components give you more flexibility to define different bindings per activity, but this usually ends up making things more confusing as code bases become larger and harder to trace.

For keeping bindings private to only code that should use them, we recommend using qualifier annotations that are protected through restricted visibility or using an SPI plugin to enforce separation of code.

The single binding key space also makes configuration a lot easier. It reduces the number of places that a module might be installed which makes swapping out bindings for testing easier. It also means you don’t have to worry about propagating modules for features to all the places that use that feature. This can be really useful for features that make use of different scopes. In a polylithic world, a feature using a fragment scoped object and activity scoped object might have to have the user include modules into the fragment and then into all the activities that use that fragment. Oftentimes, this configuration code just adds to boilerplate and breaks encapsulation.

Using a monolithic system also means less generated code. When a common module is used across many subcomponents (as may be the case with a common activity helper class), this means the generated Dagger code has to be repeated for every subcomponent. While it may not initially seem like a lot, it can quickly add up across many activities and be multiplied further by many fragments or views.

Some users may be worried about how this will affect startup latency. If you are using the fastInit compile option, monolithic components should not have a noticeable effect on startup latency. This is the default setting for Hilt gradle users using the plugin and should generally be the Dagger compilation mode used on Android.

---

## Custom Components

**URL:** https://dagger.dev/hilt/custom-components

**Contents:**
- Custom Components
- Is a custom component needed?
  - Custom component limitations
- Adding a custom Hilt component

Hilt has predefined components for Android that are managed for you. However, there may be situations where the standard Hilt components do not match the object lifetimes or needs of a particular feature. In these cases, you may want a custom component. However, before creating a custom component, consider if you really need one as not every place where you can logically add a custom component deserves one.

For example, consider a background task. The task has a reasonably well-defined lifetime that could make sense for a scope. Also, if there were a request object for that task, binding that into Dagger may save some work passing that around as a parameter. However, for most background tasks, a component really isn’t necessary and only adds complexity where simply passing a couple objects on the call stack is simpler and sufficient. Before commiting to adding a custom component, consider the following drawbacks.

Adding a custom component has the following drawbacks:

With those in mind, these are some criteria you should use for deciding if a custom component is needed:

Custom component definitions currently have some limitations:

To create a custom Hilt component, create a class annotated with @DefineComponent. This will be the class used in @InstallIn annotations.

The parent of your component should be defined in the value of the @DefineComponent annotation. Your @DefineComponent class can also be annotated with a scope annotation to allow scoping objects to this component.

A builder interface must also be defined. If this builder is missing, the component will not be generated since there will be no way to construct the component. This interface will be injectable from the parent component and will be the interface for creating new instances of your component. As these are custom components, once instances are built, it will be your job to hold on to or release component instances at the appropriate time.

Builder interfaces are defined by marking an interface with @DefineComponent.Builder. Builders must have a method that returns the @DefineComponent type. They may also have additional methods (like @BindsInstance methods) that a normal Dagger component builder may have.

While the @DefineComponent.Builder class can be nested within the @DefineComponent, it is usually better as a separate class. It may be separated into a different class as long as it is a transitive dependency of the @HiltAndroidApp application or @HiltAndroidTest test. Since the @DefineComponent class is referenced in many places via @InstallIn, it may be better to separate the builder so that dependencies in the builder do not become transitive dependencies of every module installed in the component.

For the same reason of avoiding excessive dependencies, methods are not allowed on the @DefineComponent interface. Instead, Dagger objects should be accessed via entry points.

**Examples:**

Example 1 (unknown):
```unknown
@DefineComponent(parent = SingletonComponent.class)
interface MyCustomComponent {}
```

Example 2 (unknown):
```unknown
@DefineComponent(parent = SingletonComponent::class)
interface MyCustomComponent
```

Example 3 (unknown):
```unknown
@DefineComponent.Builder
interface MyCustomComponentBuilder {
  MyCustomComponentBuilder fooSeedData(@BindsInstance Foo foo);
  MyCustomComponent build();
}
```

Example 4 (unknown):
```unknown
@DefineComponent.Builder
interface MyCustomComponentBuilder {
  fun fooSeedData(@BindsInstance foo: Foo): MyCustomComponentBuilder
  fun build(): MyCustomComponent
}
```

---

## Monolithic components

**URL:** https://dagger.dev/hilt/monolithic.html

**Contents:**
- Monolithic components
- Overview
- Single binding key space
- Simplicity for configuration
- Less generated code
- fastInit and start up latency

Hilt uses a monolithic component system. This means that a single activity component definition is used to inject all activity classes. Same for Fragments and other Android types. Each activity has a separate instance of the component though, just the class definition is shared. This is as opposed to a polylithic component system where each activity has a separate component definition. A polylithic system is the default mode when using dagger.android’s @ContributesAndroidInjector. This page goes through some of the reasons Hilt was designed using monolithic components along with tradeoffs between the two models.

One of the main benefits of using a monolithic system like in Hilt is that the binding key space is merged. If you are in a fragment injecting a Foo class, it is much easier to find where that Foo binding came from because it cannot differ based on the activity the fragment is attached to. Polylithic components give you more flexibility to define different bindings per activity, but this usually ends up making things more confusing as code bases become larger and harder to trace.

For keeping bindings private to only code that should use them, we recommend using qualifier annotations that are protected through restricted visibility or using an SPI plugin to enforce separation of code.

The single binding key space also makes configuration a lot easier. It reduces the number of places that a module might be installed which makes swapping out bindings for testing easier. It also means you don’t have to worry about propagating modules for features to all the places that use that feature. This can be really useful for features that make use of different scopes. In a polylithic world, a feature using a fragment scoped object and activity scoped object might have to have the user include modules into the fragment and then into all the activities that use that fragment. Oftentimes, this configuration code just adds to boilerplate and breaks encapsulation.

Using a monolithic system also means less generated code. When a common module is used across many subcomponents (as may be the case with a common activity helper class), this means the generated Dagger code has to be repeated for every subcomponent. While it may not initially seem like a lot, it can quickly add up across many activities and be multiplied further by many fragments or views.

Some users may be worried about how this will affect startup latency. If you are using the fastInit compile option, monolithic components should not have a noticeable effect on startup latency. This is the default setting for Hilt gradle users using the plugin and should generally be the Dagger compilation mode used on Android.

---

## Hilt Application

**URL:** https://dagger.dev/hilt/application.html

**Contents:**
- Hilt Application
- Hilt Application

Note: Examples on this page assume usage of the Gradle plugin. If you are not using the plugin, please read this page for details.

All apps using Hilt must contain an Application class annotated with @HiltAndroidApp. @HiltAndroidApp kicks off the code generation of the Hilt components and also generates a base class for your application that uses those generated components. Because the code generation needs access to all of your modules, the target that compiles your Application class also needs to have all of your Dagger modules in its transitive dependencies.

Just like other Hilt Android entry points, Applications are members injected as well. This means you can use injected fields in the Application after super.onCreate() has been called.

Note: Since all injected fields are created at the same time in onCreate, if an object is only needed later or conditionally, remember that you can use a Provider to defer injection. Especially in the Application class which is on the critical startup path, avoiding unnecessary injections can be important to performance.

For example, take the class called MyApplication that extends MyBaseApplication and has a member variable Bar:

With Hilt’s members injection, the above code becomes:

**Examples:**

Example 1 (unknown):
```unknown
public final class MyApplication extends MyBaseApplication {
  @Inject Bar bar;

  @Override public void onCreate() {
    super.onCreate();

    MyComponent myComponent =
        DaggerMyComponent
            .builder()
            ...
            .build();

    myComponent.inject(this);
  }
}
```

Example 2 (unknown):
```unknown
class MyApplication : MyBaseApplication() {
  @Inject lateinit var bar: Bar

  override fun onCreate() {
    super.onCreate()

    val myComponent =
        DaggerMyComponent
            .builder()
            ...
            .build()

    myComponent.inject(this)
  }
}
```

Example 3 (unknown):
```unknown
@HiltAndroidApp
public final class MyApplication extends MyBaseApplication {
  @Inject Bar bar;

  @Override public void onCreate() {
    super.onCreate(); // Injection happens in super.onCreate()
    // Use bar
  }
}
```

Example 4 (unknown):
```unknown
@HiltAndroidApp
class MyApplication : MyBaseApplication() {
  @Inject lateinit var bar: Bar

  override fun onCreate() {
    super.onCreate() // Injection happens in super.onCreate()
    // Use bar
  }
}
```

---

## Optional inject

**URL:** https://dagger.dev/hilt/optional-inject

**Contents:**
- Optional inject
- Why would you need optional injection?
- How to use @OptionalInject

Hilt fragments need to be attached to Hilt activities and Hilt activities need to be attached to Hilt applications. While this is a natural restriction for pure Hilt codebases, it may be an issue during a migration to Hilt if you have a fragment or activity that is used in a non-Hilt context. For example, say you want to migrate a fragment to Hilt but it is used in too many places to migrate at once. Without optional injection, you would have to migrate every activity that uses that fragment to Hilt first otherwise the fragment will crash when looking for the Hilt components when it is trying to inject itself. Depending on the size of your codebase, this could be a large undertaking.

If you mark an @AndroidEntryPoint class with @OptionalInject then it will only try to inject if the parent is using Hilt and not require it. Using this annotation will also cause a wasInjectedByHilt() method to be generated on the generated base class that returns true if it was successful injecting.

Note: Because API generated on the base class is inaccessible to users of the gradle plugin, there is an alternative API to access this functionality using a static helper method in OptionalInjectCheck.

This gives you the chance to provide dependencies in a different way (usually whichever way you were getting dependencies before using Hilt).

Note that for activities, because Hilt injection is usually run as a part of super.onCreate() and it is recommended to do your own injection before fragments are restored which also happens during super.onCreate(), you likely need to use an OnContextAvailableListener to run your non-Hilt injection code. Hilt uses the same listener under the hood, so then the order would be Hilt’s OnContextAvailableListener would run, then yours, then fragments would be restored.

**Examples:**

Example 1 (unknown):
```unknown
@OptionalInject
@AndroidEntryPoint
public final class MyFragment extends Fragment {

  @Inject Foo foo;

  @Override public void onAttach(Activity activity) {
    super.onAttach(activity);  // Injection will happen here, but only if the Activity used Hilt
    if (!OptionalInjectCheck.wasInjectedByHilt(this)) {
      // Get Dagger components the previous way and inject
    }
  }
}
```

Example 2 (unknown):
```unknown
@OptionalInject
@AndroidEntryPoint
class MyFragment : Fragment() {

  @Inject lateinit var foo: Foo

  override fun onAttach(activity: Activity) {
    super.onAttach(activity)  // Injection will happen here, but only if the Activity used Hilt
    if (!OptionalInjectCheck.wasInjectedByHilt(this)) {
      // Get Dagger components the previous way and inject
    }
  }
}
```

---

## Hilt Components

**URL:** https://dagger.dev/hilt/components.html

**Contents:**
- Hilt Components
- Component hierarchy
- Components used for injection
- Component lifetimes
    - Scoped vs unscoped bindings
    - Scoping in modules
    - When to scope?
- Component default bindings

Note: The following page assumes a basic knowledge of Dagger, including components, modules, scopes, and bindings. (For a refresher, see Dagger users guide.)

Unlike traditional Dagger, Hilt users never define or instantiate Dagger components directly. Instead, Hilt offers predefined components that are generated for you. Hilt comes with a built-in set of components (and corresponding scope annotations) that are automatically integrated into the various lifecycles of an Android application. The diagram below shows the standard Hilt component hierarchy. The annotation above each component is the scoping annotation used to scope bindings to the lifetime of that component. The arrow below a component points to any child components. As normal, a binding in a child component can have dependencies on any binding in an ancestor component.

Note: When scoping a binding within an @InstallIn module, the scope on the binding must match the scope of the component. For example, a binding within an @InstallIn(ActivityComponent.class) module can only be scoped with @ActivityScoped.

When using Hilt APIs like @AndroidEntryPoint to inject your Android classes, the standard Hilt components are used as the injectors. The component used as the injector will determine which bindings are visible to that Android class. The components used are shown in the table below:

The lifetime of a component is important because it relates to the lifetime of your bindings in two important ways:

Component lifetimes are generally bounded by the creation and destruction of a corresponding instance of an Android class. The table below lists the scope annotation and bounded lifetime for each component.

By default, all bindings in Dagger are “unscoped”. This means that each time the binding is requested, Dagger will create a new instance of the binding.

However, Dagger also allows a binding to be “scoped” to a particular component (see the scope annotations in the table above). A scoped binding will only be created once per instance of the component it’s scoped to, and all requests for that binding will share the same instance.

Warning: A common misconception is that all fragment instances will share the same instance of a binding scoped with @FragmentScoped. However, this is not true. Each fragment instance gets a new instance of the fragment component, and thus a new instance of all its scoped bindings.

The previous section showed how to scope a binding declared with an @Inject constructor, but a binding declared in a module can also be scoped in a similar way.

Warning: A common misconception is that all bindings declared in a module will be scoped to the component the module is installed in. However, this isn’t true. Only bindings declarations annotated with a scope annotation will be scoped.

Scoping a binding has a cost on both the generated code size and its runtime performance so use scoping sparingly. The general rule for determining if a binding should be scoped is to only scope the binding if it’s required for the correctness of the code. If you think a binding should be scoped for purely performance reasons, first verify that the performance is an issue, and if it is consider using @Reusable instead of a component scope.

Each Hilt component comes with a set of default bindings that can be injected as dependencies into your own custom bindings. Each component listed has the corresponding default bindings as well as any default bindings from an ancestor component.

ActivityRetainedComponent lives across configuration changes, so it is created at the first onCreate and last onDestroy. ↩ ↩2

The Application binding is available using either @ApplicationContext Context or Application. [^3]: @ActivityRetainedSavedState SavedStateHandlemust be used with @OptIn(UnstableApi.class). This binding relies on an experimental implementation to lazily create SavedStateHandle, which should be safe to rely on, but it is still possible that a future release may remove the binding if a bug is uncovered. ↩

**Examples:**

Example 1 (unknown):
```unknown
// This binding is "unscoped".
// Each request for this binding will get a new instance.
final class UnscopedBinding {
  @Inject UnscopedBinding() {}
}

// This binding is "scoped".
// Each request from the same component instance for this binding will
// get the same instance. Since this is the fragment component, this means
// each request from the same fragment.
@FragmentScoped
final class ScopedBinding {
  @Inject ScopedBinding() {}
}
```

Example 2 (unknown):
```unknown
// This binding is "unscoped".
// Each request for this binding will get a new instance.
class UnscopedBinding @Inject constructor() {
}

// This binding is "scoped".
// Each request from the same component instance for this binding will
// get the same instance. Since this is the fragment component, this means
// each request from the same fragment.
@FragmentScoped
class ScopedBinding @Inject constructor() {
}
```

Example 3 (unknown):
```unknown
@Module
@InstallIn(FragmentComponent.class)
abstract class FooModule {
  // This binding is "unscoped".
  @Provides
  static UnscopedBinding provideUnscopedBinding() {
    return new UnscopedBinding();
  }

  // This binding is "scoped".
  @Provides
  @FragmentScoped
  static ScopedBinding provideScopedBinding() {
    return new ScopedBinding();
  }
}
```

Example 4 (unknown):
```unknown
@Module
@InstallIn(FragmentComponent::class)
object FooModule {
  // This binding is "unscoped".
  @Provides
  fun provideUnscopedBinding() = UnscopedBinding()

  // This binding is "scoped".
  @Provides
  @FragmentScoped
  fun provideScopedBinding() = ScopedBinding()
}
```

---

## Hilt

**URL:** https://dagger.dev/hilt/

**Contents:**
- Hilt
- Hilt Design Overview

Hilt provides a standard way to incorporate Dagger dependency injection into an Android application.

The goals of Hilt are:

Hilt works by code generating your Dagger setup code for you. This takes away most of the boilerplate of using Dagger and really just leaves the aspects of defining how to create objects and where to inject them. Hilt will generate the Dagger components and the code to automatically inject your Android classes (like activities and fragments) for you.

Hilt generates a set of standard Android Dagger components based off of your transitive classpath. This requires marking your Dagger modules with Hilt annotations to tell Hilt which component they should go into. Getting objects in your Android framework classes is done by using another Hilt annotation which will generate the Dagger injection code into a base class that you will extend. For Gradle users, extending this class is done with a bytecode transformation under the hood.

In your tests, Hilt generates Dagger components for you as well just like in production. Tests have other special utilities to help with adding or replacing test bindings.

---

## Subcomponents vs Component dependencies

**URL:** https://dagger.dev/hilt/subcomponents-vs-deps

**Contents:**
- Subcomponents vs Component dependencies
- Overview
- Single binding key space
- Propagating bindings with component dependencies defeats Dagger pruning
- Configuration at the root and build speed

Hilt is based around using Dagger subcomponents as opposed to component dependencies. This page explains some of the reasons why Hilt was designed this way.

Subcomponents propagate all bindings by default. This includes multibindings which can be difficult to propagate via component dependencies. This creates a merged binding key space. This generally makes it easier to understand the Dagger graph because you don’t have to worry about considering if a binding is propagated or not from a parent component to a child component. Also, if bindings are not propagated with component dependencies, it is possible to use two different definitions of the same binding key in different components. This can make it difficult to walk through code when debugging issues as the binding definition will be based on the context of the usage.

One of the downsides of a single binding key space is that it can be extra work to place restrictions on code usage (e.g. if one feature shouldn’t use bindings from another feature). For this we generally recommend using qualifier annotations that are restricted visibility or using an SPI plugin to enforce separation of code. Using a qualifier or an SPI plugin is better than building these concerns into the structure of your Dagger component dependencies graph because often these rules encode policy. Policy decisions like this are often in flux (or need to have exceptions allowed) and having to restructure a Dagger component dependencies graph based on those changes can be costly.

Since Dagger can see the entry points to the graph, it can figure out which bindings are unused and not generate code for those bindings. This optimization goes through subcomponents, but it is defeated by component dependencies because propagating bindings through component dependencies adds entry point methods. So even if entry point methods are only used by other Dagger components and across the components the binding is unused, Dagger will be forced to still generate that dead code to adhere to its contract.

One of the main advantages of component dependencies is building Dagger code separately and in parallel. This can be done because of the lack of implicit sharing that make components black boxes with respect to each other. However, Hilt is already based on the idea of central configuration based on build dependencies. Since Hilt has to aggregate modules, all components would be generated at the same time anyway so we wouldn’t be able to take advantage of building in parallel.

Instead, to address build speed, Hilt recommends making smaller test apps for individual feature development. Without Hilt, this would have been difficult to do because of all of the repeated Dagger boilerplate for the small test app. However, with Hilt generating all of the Dagger portion based on build dependencies, putting together a small test app should be much easier.

---
