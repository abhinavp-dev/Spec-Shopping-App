# AGENTS.md — Spec-Driven Development (SDD) & Skill Rules

## Workspace Rules

1. **Spec-Driven Development (SDD)**:
   - Always refer to and adhere strictly to the specification documents in the [`Docs/`](file:///c:/Users/abhin/OneDrive/Desktop/Spec-Shopping-App/Docs) folder:
     - [`01-TASK-DOCUMENT.md`](file:///c:/Users/abhin/OneDrive/Desktop/Spec-Shopping-App/Docs/01-TASK-DOCUMENT.md)
     - [`02-ARCHITECTURE-DOCUMENT.md`](file:///c:/Users/abhin/OneDrive/Desktop/Spec-Shopping-App/Docs/02-ARCHITECTURE-DOCUMENT.md)
     - [`03-ENGINEERING-DOCUMENT.md`](file:///c:/Users/abhin/OneDrive/Desktop/Spec-Shopping-App/Docs/03-ENGINEERING-DOCUMENT.md)
     - [`04-DESIGN-DOCUMENT.md`](file:///c:/Users/abhin/OneDrive/Desktop/Spec-Shopping-App/Docs/04-DESIGN-DOCUMENT.md)
   - Before implementing features, cross-reference requirements against the Task Document, architecture patterns against the Architecture Document, networking/testing rules against the Engineering Document, and UI tokens/flow against the Design Document.

2. **Skill Utilization**:
   - Automatically consult and apply rules from all installed skills in [`.agents/skills/`](file:///c:/Users/abhin/OneDrive/Desktop/Spec-Shopping-App/.agents/skills) (such as `swiftui-pro`) whenever planning, generating, or refactoring Swift/SwiftUI code.
   - Enforce modern SwiftUI standards, VoiceOver/Dynamic Type accessibility, `@Observable` state isolation, Swift 6 concurrency, and performant view structures.

3. **Architecture & Standards**:
   - Follow the MVVM architecture specified in `02-ARCHITECTURE-DOCUMENT.md` (`Model` - `View` - `@Observable ViewModel` - `Service` - `APIClient` - `KeychainStore`).
   - Maintain folder hierarchy (`Features/`, `Models/`, `Services/`, `Repositories/`, `Persistence/`, `Navigation/`, `Common/`).
   - One primary type per file matching the file name.

4. **Swift Concurrency & MainActor Isolation**:
   - All `@Observable` ViewModels must be annotated `@MainActor`.
   - Use native Swift Concurrency (`async`/`await`, `Task`, `actors`) exclusively. Never use Grand Central Dispatch (`DispatchQueue.main.async`, `DispatchQueue.global`) or `Task.sleep(nanoseconds:)`.

5. **Error Handling & Resilience**:
   - Model all network, decoding, and storage failures as strongly-typed Swift `Error` enums (`APIError`, `KeychainError`).
   - Do not swallow errors silently. Present appropriate user-facing error states or banners as required by [`01-TASK-DOCUMENT.md`](file:///c:/Users/abhin/OneDrive/Desktop/Spec-Shopping-App/Docs/01-TASK-DOCUMENT.md).

