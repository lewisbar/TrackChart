# AGENTS.md — TrackChart (and related iOS work)

This file encodes the developer's preferred way of working. Follow these rules strictly on all coding tasks in this repository and similar iOS projects.

## Core Principles (Essential Developer / iOS Lead Essentials style)

- **Explicit dependencies only**. Prefer constructor injection or closure/function injection. Never use service-locator / DI container patterns (e.g. no `@Inject`, no global `DependencyContainer`) in feature or domain code.
- **Modules are independent**. Feature/presentation/domain modules must not have direct dependencies on each other or on concrete implementations in other modules. Depend only on protocols/abstractions (or pure value types where appropriate).
- **Composition Root does the wiring**. All concrete type assembly happens in one (or very few) places — typically in the main app target's "App Composition" area or a dedicated composition module. The rest of the code receives dependencies via initializers or closures.
- **SwiftUI Previews must always work** without hidden runtime dependencies or fatal errors.
- **Clear layer boundaries** with explicit adapters/mappers when crossing layers (see existing `Presentation/Adapter/` pattern — preserve and extend it).
- **Value types and immutability** preferred for models that cross boundaries (View* types, pure data structs).
- Keep `DataProcessing` (or future Domain) pure, `Sendable`-friendly, and free of UI or persistence concerns.

## Strict TDD Discipline (Red → Green → Commit → Refactor → Commit)

Always follow this cycle for any new behavior or bug fix:

1. **Red**: Write the smallest possible failing test (using Swift Testing: `@Test` + `#expect`).
2. Run the relevant tests/scheme and confirm the failure is visible.
3. **Commit the test-only change** with a clear message, e.g.:
   - `test: TopicListViewModel delete marks correct indices (red)`
4. **Green**: Implement the *minimal* amount of production code required to make the test pass. No extra features, no premature refactoring.
5. Run the tests and confirm they pass.
6. **Commit the minimal implementation**:
   - `feat: make delete test pass (minimal impl)`
7. **Refactor** (only if needed for clarity, duplication removal, or design improvement) while keeping all tests green.
8. Run tests again to prove the refactor didn't break anything.
9. **Commit the refactor**:
   - `refactor: extract helper after delete implementation`
10. Repeat for the next behavior.

Use the `todo_write` tool to track the current TDD phase visibly (`red`, `green`, `refactor`, etc.).

Never claim "done" or move to the next requirement until the current test is green and committed.

Run the project's official test commands (see WARP.md) rather than ad-hoc `swift test` unless the package is isolated.

## Testing

- Use **Swift Testing** framework (`@Test`, `#expect`, `@MainActor` where required).
- Tests live in the corresponding *Tests targets (DataProcessingTests, PresentationTests, PersistenceTests, and future package test targets).
- Prefer small, focused tests. Use `makeSUT(...)` factory helpers (existing pattern) to keep test setup clean and explicit.
- Test the public API of the module. For presentation logic, test view models and mappers directly (they should be easy to instantiate because of closure DI).
- When adding behavior that affects charts, aggregation, or persistence, add tests in the appropriate layer first.

## Build, Run, and Validation Commands

See `WARP.md` for the authoritative commands. Common ones:

- Full CI-style test (recommended for verification):
  ```bash
  xcodebuild test \
    -project TrackChart.xcodeproj \
    -scheme CI_macOS \
    -testPlan CI_macOS \
    -destination 'platform=macOS,arch=arm64' \
    CODE_SIGNING_REQUIRED=NO CODE_SIGNING_IDENTITY="" CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES
  ```

- Specific layer:
  ```bash
  xcodebuild test -project TrackChart.xcodeproj -scheme DataProcessing -testPlan DataProcessing ...
  ```

- iOS app build (simulator):
  ```bash
  xcodebuild build -project TrackChart.xcodeproj -scheme TrackChartiOS -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
  ```

After any change, run the relevant test plan/scheme and show the result before claiming success.

## Modularization & Project Structure

- Prefer evolving toward (or creating) local Swift Package Manager packages for the layers (`DataProcessing`, a potential `Domain`, `Presentation` models/logic, future features).
- When creating a new module/package:
  - It must have its own `Package.swift`.
  - Public API should be minimal and protocol-oriented where dependencies are involved.
  - Internal implementation can be concrete.
  - Tests go in the package's `Tests/` target.
- The main `TrackChartiOS` target (or future app target) is the Composition Root. It is allowed to know about concrete types and perform wiring.
- Do not add direct `import` of one feature module into another feature module's sources.

## Git & Commits

- Make small, focused commits that match the TDD cycle (see messages above).
- Use conventional or at least descriptive prefixes: `test:`, `feat:`, `refactor:`, `fix:`, etc.
- Never squash TDD cycles into one giant commit when working with the agent.

## Swift & iOS Conventions

- Modern Swift (concurrency with `async/await` where it makes sense, `Sendable`, value types).
- Explicit error handling; avoid force-unwraps and `fatalError` in production paths.
- Keep UI code (SwiftUI views) as thin as possible — logic belongs in view models or use-case-style objects that are injected.
- Preserve and extend the existing adapter/mapping pattern for layer crossings.
- Localized strings live in the appropriate `.xcstrings` / resources.

## When Working on ChordSheep or Other Projects

Apply the same TDD + explicit DI + composition root rules. Modernization work should move logic out of massive view controllers into testable, injectable components, preferably in SPM packages over time. CocoaPods usage should be minimized or replaced where practical.

## Interaction With This Agent

- When I suggest architecture changes, explicitly call out how they preserve (or improve) the "modules independent + Composition Root wires" invariant.
- For any non-trivial task (new feature, significant refactor, new module), start in plan mode (`/plan`) unless the change is a pure one-test addition.
- After edits, I will run tests via the documented xcodebuild commands and show output.
- If previews or the app composition would be affected, verify they still compile and (where possible) that preview providers can be instantiated.

## Living Document

Update this file as conventions evolve. The root `AGENTS.md` (and deeper ones) take precedence for this workspace.

---

This file was created as a strong starting point based on the existing codebase structure, WARP.md, current DI patterns (closure injection in view models), Swift Testing usage, and the developer's stated preferences from the iOS Lead Essentials program.