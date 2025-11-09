# Koin - Api

**Pages:** 2

---

## Releases & API Upgrade Guides

**URL:** https://insert-koin.io/docs/support/releases

**Contents:**
- Releases & API Upgrade Guides
- 4.1.1​
  - New 🎉​
  - Library Updates 📚​
  - Bug Fixes 🐛​
- 4.1.0​
  - New 🎉​
  - Experimental 🚧​
  - Deprecation ⚠️​
  - Breaking 💥​

This page provides a comprehensive overview of every Koin main release, detailing the evolution of our framework to help you plan for upgrades and maintain compatibility.

For each version, the document is structured into the following sections:

This structured approach not only clarifies the incremental changes in each release but also reinforces our commitment to transparency, stability, and continuous improvement in the Koin project.

See Api Stability Contract for more details.

koin-compose-viewmodel-navigation

koin-androidx-compose

koin-compose-viewmodel

koin-core-annotations

koin-core-viewmodel-navigation

koin-androidx-compose

koin-androidx-compose-navigation

koin-core-viewmodel-navigation

All used lib versions are located in libs.versions.toml

Following APIs in the given projects are now stable.

koin-core-coroutines - all API is now stable

koin-androidx-startup

The following APIs have been deprecated and should not be used anymore:

old compose API function are deprecated at error level:

koin-compose-viewmodel

The following APIs have been removed, due to deprecations in last milestone:

all API annotated with @KoinReflectAPI has been removed

All used lib versions are located in libs.versions.toml

koin-androidx-compose

koin-core-coroutines - introducing new API to load modules in background

koin-androidx-compose

koin-androidx-compose-navigation - New module for navigation

koin-compose - New Multiplatform API for Compose

koin-compose - New Experimental Multiplatform API for Compose

koin-androidx-compose

**Examples:**

Example 1 (unknown):
```unknown
Experimental
```

Example 2 (unknown):
```unknown
koin-compose-viewmodel-navigation
```

Example 3 (unknown):
```unknown
sharedKoinViewModel
```

Example 4 (unknown):
```unknown
navGraphRoute
```

---

## API Stability & Release Types

**URL:** https://insert-koin.io/docs/support/api-stability

**Contents:**
- API Stability & Release Types
- API Stability​
  - Experimental APIs - @KoinExperimentalAPI​
  - Deprecation Policy - @Deprecated​
  - Internal APIs - @KoinInternalAPI​
  - Opting In with Kotlin's @OptIn Annotation​
- Release Types​

The Koin project is committed to maintaining a high level of compatibility between versions. Kotzilla team and all active maintainers works to ensure that any changes, enhancements, or optimizations introduced in new releases do not break existing applications. We understand that a stable and predictable upgrade path is critical to our users, and we strive to minimize disruptions when evolving our APIs.

To foster innovation while gathering valuable community feedback, we introduce new features and APIs under the @KoinExperimentalAPI annotation. This designation indicates that:

To ensure a smooth transition when parts of the API are being phased out, Koin uses the @Deprecated annotation to clearly mark these areas. Our deprecation strategy includes:

Clear warnings: Deprecated APIs come with a message indicating the recommended alternative or the reason for deprecation.

This approach helps developers identify and update code that relies on outdated APIs, reducing technical debt and paving the way for a cleaner, more robust codebase. ReplaceWith can be provided with the API, depending on the complexity of the update.

For functionalities that are strictly intended for internal use within the Koin framework, we introduce the @KoinInternalAPI annotation. These APIs are not part of the public contract and:

Both experimental and deprecated API usages in Koin requires an opt-in, ensuring that developers are fully aware of the API’s status and potential risks. By using Kotlin's @OptIn annotation, you explicitly acknowledge that your code depends on APIs that are experimental or marked for deprecation.

Koin adheres to semantic versioning (SemVer) with additional prefix identifiers that signal the maturity and intended use of each release. The prefixes we use include:

**Examples:**

Example 1 (unknown):
```unknown
@KoinExperimentalAPI
```

Example 2 (unknown):
```unknown
@Deprecated
```

Example 3 (unknown):
```unknown
ReplaceWith
```

Example 4 (unknown):
```unknown
@KoinInternalAPI
```

---
