# Koin - Other

**Pages:** 2

---

## Versions, Roadmap & Support

**URL:** https://insert-koin.io/docs/support/

**Contents:**
- Versions, Roadmap & Support
- Releases Cycle​
- Establishing Roadmap with Structured Versions​
- Enterprise Support by Kotzilla​

The Koin team is leading its development with open-source and community-driven approach since the beginning, and propose commercial services to secure your development.

We drive our developments with release cycles of 6 months to follow Kotlin language and library updates in a consistent manner. We will use beta periods of 6 weeks or more, to help gather first feedbacks.

Once a new version is released, we start the Community support phase for 6 months minimum. During that phase, we are actively gathering feedbacks, following all updates impacting our framework, like librairies, Kotling Android, Ktor and others frameworks versions.

The first big thing for the Koin project is organizing release cycles to establish a clear vision on versions deployment, and to help you anticipate updates and new features. We need a clear version tracking: Major.Minor.Patch

We now drive our developments with release cycles of 6 months to follow Kotlin language and library updates in a consistent manner. We will use beta periods of 6 weeks to help gather first feedbacks.

Companies might struggle to follow the Koin release cycle for various reasons, including legal, business, or technical constraints. As a result, when adopting a new technology, companies may require company-backed support and clear open-source license warranties.

For these reasons, Kotzilla has designated Koin 3.5.6 as our Long-Term Support version, as it is the most advanced and stable version of Koin for Kotlin 1.x. We offer peace of mind until at least December 2025 by ensuring compatibility, code audits, and fast-track support for companies that need it.

More information about Koin Long Term Support by Kotzilla.

**Examples:**

Example 1 (unknown):
```unknown
Major.Minor.Patch
```

---

## Koin Embedded

**URL:** https://insert-koin.io/docs/support/embedded

**Contents:**
- Koin Embedded
- Embedded Version (Beta)​
- Relocation Scripts (Beta)​

Koin Embedded is a new Koin project, targeting Android/Kotlin SDK & Library developers.

This project proposes scripts to help rebuild & package Koin project with a different package name. The interest is for SDK & Library development, to avoid conflict between embedded Koin version and any consuming application that would use another version of Koin, that might conflict.

Feedback or help? Contact Koin Team.

this initiative is currently in Beta, we are looking for feedback

Here is an example of Koin embedded version: Kotzilla Repository

Setup your Gradle config with this Maven repository:

Here is some scripts that help rebuild Koin for a given package name, helping to embed it and avoid conflict with regular usage of Koin framework.

Follow-up on Koin relocation scripts project for more details.

**Examples:**

Example 1 (unknown):
```unknown
embedded-koin-core
```

Example 2 (unknown):
```unknown
embedded-koin-android
```

Example 3 (unknown):
```unknown
embedded.koin.*
```

Example 4 (kotlin):
```kotlin
maven { 'https://repository.kotzilla.io/repository/kotzilla-platform/' }
```

---
