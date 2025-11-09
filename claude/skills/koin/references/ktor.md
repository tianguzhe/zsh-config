# Koin - Ktor

**Pages:** 1

---

## Ktor & Koin Isolated Context

**URL:** https://insert-koin.io/docs/reference/koin-ktor/ktor-isolated

**Contents:**
- Ktor & Koin Isolated Context
- Isolated Koin Context Plugin​

The koin-ktor module is dedicated to bring dependency injection for Ktor.

To start an Isolated Koin container in Ktor, just install the KoinIsolated plugin like follow:

By using an isolated Koin context you won't be able to use Koin outside Ktor server instance (i.e: by using GlobalContext for example)

**Examples:**

Example 1 (unknown):
```unknown
KoinIsolated
```

Example 2 (kotlin):
```kotlin
fun Application.main() {    // Install Koin plugin    install(KoinIsolated) {        slf4jLogger()        modules(helloAppModule)    }}
```

Example 3 (kotlin):
```kotlin
fun Application.main() {    // Install Koin plugin    install(KoinIsolated) {        slf4jLogger()        modules(helloAppModule)    }}
```

Example 4 (unknown):
```unknown
GlobalContext
```

---
