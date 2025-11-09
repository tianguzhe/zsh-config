# Koin - Testing

**Pages:** 1

---

## Injecting in Tests

**URL:** https://insert-koin.io/docs/reference/koin-test/testing

**Contents:**
- Injecting in Tests
- Making your test a KoinComponent with KoinTest​
- JUnit Rules​
  - Create a Koin context for your test​
  - Specify your Mock Provider​
- Mocking out of the box​
- Declaring a component on the fly​
- Checking your Koin modules​
- Starting & stopping Koin for your tests​
- Testing with JUnit5​

Warning: This does not apply to Android Instrumented tests. For Instrumented testing with Koin, please see Android Instrumented Testing

By tagging your class KoinTest, your class become a KoinComponent and bring you:

Don't hesitate to overload Koin modules configuration to help you partly build your app.

You can easily create and hold a Koin context for each of your test with the following rule:

To let you use the declareMock API, you need to specify a rule to let Koin know how you build your Mock instance. This let you choose the right mocking framework for your need.

Create mocks using Mockito:

Create mocks using MockK:

!> koin-test project is not tied anymore to mockito

Instead of making a new module each time you need a mock, you can declare a mock on the fly with declareMock:

declareMock can specify if you want a single or factory, and if you want to have it in a module path.

When a mock is not enough and don't want to create a module just for this, you can use declare:

Koin offers a way to test if you Koin modules are good: checkModules - walk through your definition tree and check if each definition is bound

Take attention to stop your koin instance (if you use startKoin in your tests) between every test. Else be sure to use koinApplication, for local koin instances or stopKoin() to stop the current global instance.

JUnit 5 support provides Extensions that will handle the starting and stopping of Koin context. This means that if you are using the extension you don't need to use the AutoCloseKoinTest.

For testing with JUnit5 you need to use koin-test-junit5 dependency.

You need to Register the KoinTestExtension and provide your module configuration. After this is done you can either get or inject your components to the test. Remember to use @JvmField with the @RegisterExtension.

This works the same way as in JUnit4 except you need to use @RegisterExtension.

You can also get the created koin context as a function parameter. This can be achieved by adding a function parameter to the test function.

**Examples:**

Example 1 (unknown):
```unknown
KoinComponent
```

Example 2 (unknown):
```unknown
by inject()
```

Example 3 (unknown):
```unknown
checkModules
```

Example 4 (unknown):
```unknown
declareMock
```

---
