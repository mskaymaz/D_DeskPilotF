# DESKPILOTC ARCHITECTURE

## 1. Purpose

This document defines the technical architecture of DeskPilotC.

It must be read together with:

- `DESKPILOT_PRODUCT_SPEC.md`
- `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`
- `ROADMAP.md`
- `STATE.md`
- `TASK.md`

`DESKPILOT_PRODUCT_SPEC.md` defines **what the product should do**.

This document defines **how DeskPilotC should be engineered**.

The frozen Python implementation (`D_DeskPilot`) is a behavioral reference only. It must not be mechanically translated into C++.

---

## 2. Primary Technology Stack

### Desktop UI
- Qt 6
- Qt Quick
- QML

### Core / Native Layer
- Modern C++ (C++20 or newer where supported and appropriate)

### Build System
- CMake

### Local Structured Storage
- SQLite

### Configuration / Lightweight State
- Versioned settings layer
- JSON only where genuinely useful for human-readable configuration or export/import

### Testing
- Qt Test and/or Catch2/GoogleTest depending on final project setup
- QML UI tests where useful
- Automated unit tests for business logic and services

### Supported Initial Platform
- Windows desktop

### Planned Future Desktop Targets
- macOS
- Linux

The initial implementation may contain Windows-specific platform adapters where required, but domain and application logic must remain platform-independent.

---

## 3. Architectural Goals

DeskPilotC must optimize for:

- High visual quality
- UI freedom
- Smooth animations
- Native desktop integration
- Low idle CPU usage
- Controlled memory usage
- Long-running stability
- Clean separation of concerns
- Strong testability
- Maintainability
- Future synchronization
- Future mobile and web integration
- Incremental development
- AI-agent-friendly code structure

Do not overengineer speculative functionality.

However, do not create architectural dead ends for requirements already known to be part of the DeskPilot roadmap.

---

## 4. High-Level Architecture

```text
+--------------------------------------------------+
|                    QML UI                        |
|   Pages / Windows / Panels / Components / UX     |
+---------------------------+----------------------+
                            |
                            v
+--------------------------------------------------+
|            Presentation / ViewModels             |
| UI state, commands, bindings, formatting adapters|
+---------------------------+----------------------+
                            |
                            v
+--------------------------------------------------+
|              Application Services                |
| Use cases, workflows, orchestration, validation  |
+---------------------------+----------------------+
                            |
                            v
+--------------------------------------------------+
|                  Domain Layer                    |
| Models, rules, value objects, domain behavior    |
+---------------------------+----------------------+
                            |
                            v
+--------------------------------------------------+
| Infrastructure / Platform / Persistence          |
| SQLite, OS APIs, tray, startup, battery, TTS,    |
| notifications, filesystem, future sync adapters  |
+--------------------------------------------------+
```

Dependency direction must point inward.

The UI must depend on application/domain abstractions.

The core domain must not depend on QML.

---

## 5. Recommended Repository Structure

```text
D_DeskPilotC/
│
├── CMakeLists.txt
├── README.md
├── DESKPILOT_PRODUCT_SPEC.md
├── PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md
├── ARCHITECTURE.md
├── ROADMAP.md
├── STATE.md
├── TASK.md
│
├── cmake/
│
├── src/
│   ├── app/
│   │   ├── Application.cpp
│   │   ├── Application.h
│   │   └── AppContext.*
│   │
│   ├── domain/
│   │   ├── clock/
│   │   ├── date/
│   │   ├── battery/
│   │   ├── todo/
│   │   ├── reminder/
│   │   ├── alarm/
│   │   └── notification/
│   │
│   ├── application/
│   │   ├── services/
│   │   ├── usecases/
│   │   └── dto/
│   │
│   ├── presentation/
│   │   ├── viewmodels/
│   │   ├── models/
│   │   └── adapters/
│   │
│   ├── infrastructure/
│   │   ├── persistence/
│   │   ├── settings/
│   │   ├── notifications/
│   │   ├── audio/
│   │   ├── tts/
│   │   └── logging/
│   │
│   ├── platform/
│   │   ├── windows/
│   │   ├── macos/
│   │   └── linux/
│   │
│   └── shared/
│       ├── utils/
│       ├── types/
│       └── errors/
│
├── qml/
│   ├── App.qml
│   ├── windows/
│   ├── pages/
│   ├── panels/
│   ├── components/
│   ├── controls/
│   ├── overlays/
│   ├── dialogs/
│   ├── design/
│   └── animations/
│
├── assets/
│   ├── fonts/
│   ├── icons/
│   ├── sounds/
│   └── images/
│
├── resources/
│
├── migrations/
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── qml/
│
└── tools/
```

This structure is a reference, not a requirement to create every directory immediately.

Create folders only when the corresponding responsibility exists.

---

## 6. QML Responsibility

QML is responsible for:

- Rendering
- Layout
- Animation
- Transitions
- Visual states
- Interaction states
- User input
- Component composition
- Presentation-level property binding

QML should not contain:

- Persistent storage logic
- SQL queries
- Complex business rules
- Reminder scheduling logic
- Alarm scheduling logic
- Sync conflict resolution
- OS-specific low-level logic
- Large data transformation pipelines

Avoid turning QML into the application backend.

---

## 7. C++ Responsibility

C++ is responsible for:

- Application lifecycle
- Domain models
- Application services
- Business rules
- Persistence abstractions
- SQLite access
- Platform integration
- System tray
- Startup registration
- Battery information
- Native notifications
- TTS integration
- Audio
- File system
- Future synchronization engine
- Performance-sensitive operations

Expose only the necessary state and commands to QML.

---

## 8. Presentation Layer

The presentation layer bridges QML and the application layer.

Preferred pattern:

- QML consumes ViewModels / Presentation Models
- ViewModels expose observable properties
- User actions call explicit commands/methods
- Application services execute use cases
- Results update observable state

Avoid direct QML access to low-level services.

Example:

```text
TodoPage.qml
    |
    v
TodoViewModel
    |
    v
TodoService / Use Cases
    |
    v
TodoRepository
    |
    v
SQLiteTodoRepository
```

---

## 9. Domain Layer

Domain models must express product concepts without UI dependencies.

Examples:

- TodoItem
- Reminder
- Alarm
- Priority
- Notification
- RecurrenceRule
- BatteryState
- UserPreference

Domain types should:

- Validate their own invariants where appropriate.
- Use strong types where they improve correctness.
- Avoid dependence on Qt UI modules.
- Remain testable without launching the application UI.

Qt Core types may be used selectively if they materially simplify integration, but unnecessary framework coupling should be avoided in core business logic.

---

## 10. Persistence

DeskPilotC should use structured local persistence.

Recommended baseline:

- SQLite for Todo, Reminder, Alarm, notification history, and future sync metadata.
- Versioned settings store for UI/application preferences.

Requirements:

- Schema versioning
- Explicit migrations
- Transactions
- Safe writes
- Backup/export capability where practical
- Recovery strategy
- Future Python DeskPilot data import path if needed

Repositories should be abstracted behind interfaces.

Example:

```text
ITodoRepository
    |
    +-- SQLiteTodoRepository
```

Future sync must not require rewriting domain logic.

---

## 11. Settings Architecture

Settings should be divided into categories.

### User/Product Preferences
Potentially synchronizable:

- Theme
- Typography preferences
- Todo preferences
- Reminder preferences
- Shared notification preferences

### Device-Specific Preferences
Must remain local where appropriate:

- Window position
- Monitor selection
- Desktop layout coordinates
- Always-on-top behavior
- Startup registration
- Platform-specific integration settings

Do not blindly synchronize all settings.

Each setting should have:

- Key
- Type
- Default
- Scope
- Version/migration rule where required

---

## 12. Platform Abstraction

Platform-specific code must be isolated.

Recommended interfaces may include:

```text
ISystemTrayService
IStartupService
IBatteryService
INotificationService
ITtsService
IAudioService
IMonitorService
IWindowIntegrationService
```

Implementations:

```text
WindowsSystemTrayService
WindowsStartupService
WindowsBatteryService
...
```

Future macOS/Linux implementations can be added without changing application logic.

---

## 13. Window Architecture

DeskPilot requires unusual desktop-window behavior.

Window responsibilities should be separated from business modules.

The desktop layer must support:

- Frameless windows
- Transparent windows
- Always-on-top
- Grouped layout
- Free layout
- Independent module windows if required
- Drag behavior
- Multi-monitor positioning
- Persistent coordinates
- Safe position recovery

Do not duplicate window logic across Clock, Date, and Battery modules.

Create reusable window behavior abstractions and QML components.

---

## 14. Design System

DeskPilotC must establish a design system early.

Recommended structure:

```text
qml/design/
    Colors.qml
    Typography.qml
    Spacing.qml
    Radius.qml
    Motion.qml
    Sizes.qml
    ZLayers.qml
```

Components should consume tokens rather than hard-coded visual constants.

The design system must support:

- Global scaling
- High DPI
- User customization
- Theme evolution
- Consistent motion
- Accessibility
- Strong contrast

Do not hardcode scattered pixel/color values throughout the QML tree.

---

## 15. Animation Strategy

Animations should enhance the experience without wasting resources.

Rules:

- Prefer GPU-friendly Qt Quick animations.
- Avoid continuous animation when nothing is changing.
- Avoid expensive effects on large transparent surfaces without measurement.
- Pause unnecessary animation when windows are hidden.
- Respect reduced-motion preferences if later introduced.
- Measure idle CPU/GPU behavior.

Visual quality and efficiency must be balanced.

---

## 16. Todo Architecture

Suggested separation:

```text
Todo domain model
    |
Todo repository
    |
Todo application service
    |
Todo ViewModel
    |
Todo QML UI
```

Todo rules such as:

- state transitions
- overdue detection
- ordering
- priority logic
- retention
- restore/delete rules

must not be implemented only inside QML.

---

## 17. Reminder Architecture

Reminder scheduling must be a core service.

Suggested components:

```text
Reminder
RecurrenceRule
ReminderRepository
ReminderScheduler
ReminderService
ReminderNotificationCoordinator
ReminderViewModel
```

The scheduler must:

- Handle one-time reminders.
- Handle daily recurrence.
- Handle weekly recurrence.
- Recover missed reminders.
- Avoid duplicate firing.
- Support snooze.
- Survive application restarts through persisted state.

UI is not the scheduler.

---

## 18. Alarm Architecture

Alarm should remain separate from Reminder even if they share infrastructure.

Shared infrastructure may include:

- Scheduler primitives
- Sound playback
- TTS
- Notification popup
- Recurrence utilities

But:

```text
Reminder != Alarm
```

Keep different product semantics explicit.

---

## 19. Unified Notification Infrastructure

All alert-producing modules should route through a unified coordinator.

Potential sources:

- Reminder
- Alarm
- Battery
- Todo due events
- Future sync/system events

The notification coordinator handles:

- Visual notification
- Sound
- TTS
- Silent mode
- Cooldown
- Duplicate suppression
- Optional history

This avoids separate notification logic in every module.

---

## 20. Threading and Concurrency

Rules:

- Never block the QML/UI thread with long-running operations.
- Database work should remain efficient and use worker execution where justified.
- TTS must not block UI.
- Network sync must be asynchronous.
- Heavy file or import/export operations must not block UI.
- Avoid creating threads without measurable need.

Prefer Qt's event-driven mechanisms and appropriate async patterns.

---

## 21. Performance Budgets

Performance must be treated as a product requirement.

Track at minimum:

- Cold startup time
- Warm startup time
- Idle CPU
- Idle memory
- UI frame smoothness
- Reminder scheduler overhead
- Battery monitoring overhead
- Database query latency
- Window show/hide latency

Do not accept large regressions without understanding the cause.

---

## 22. Logging and Diagnostics

Use structured application logging.

Recommended levels:

- Trace
- Debug
- Info
- Warning
- Error
- Critical

Requirements:

- No sensitive user data in logs unless explicitly necessary and safely handled.
- Log rotation or bounded log storage.
- Debug diagnostics usable by development agents.
- Clear startup and migration errors.

Avoid silent broad exception/error swallowing.

---

## 23. Error Handling

Errors should be:

- Explicit
- Contextual
- Recoverable where possible
- Logged appropriately
- Visible to users only when actionable

Do not use error handling as normal control flow.

Persistence and migration failures must be treated carefully to avoid data loss.

---

## 24. Testing Strategy

### Unit Tests

Required for:

- Domain rules
- Todo state transitions
- Reminder recurrence
- Snooze behavior
- Ordering
- Settings validation
- Migration logic

### Integration Tests

Required where practical for:

- SQLite repositories
- Settings storage
- Reminder persistence
- Application service workflows

### UI / QML Tests

Use selectively for:

- Critical interaction paths
- Quick Actions behavior
- Dialog workflows
- Scaling
- Window-state behavior where automatable

Do not rely exclusively on manual UI testing.

---

## 25. Future Synchronization Boundary

Desktop V1 should not implement full cloud synchronization.

However, architecture should make future sync possible.

Local repositories should sit behind stable abstractions.

Future structure:

```text
Local Database
      |
Sync Engine
      |
Remote API
```

Sync concerns:

- User identity
- Device identity
- Versioning
- Change tracking
- Conflict resolution
- Offline queue
- Encryption
- Retry
- Deletion semantics

Do not mix future sync logic directly into UI or domain models prematurely.

---

## 26. Future Mobile and Web Integration

DeskPilotC is one client in a future product ecosystem.

Expected future clients:

```text
Desktop:
Qt Quick/QML + C++

Mobile:
Flutter + Dart

Web:
TypeScript + React + Next.js
```

They should share:

- API contracts
- Data semantics
- Authentication concepts
- Sync protocol
- Design tokens where practical
- Product behavior definitions

They do not need to share UI implementation code.

---

## 27. API Contract Strategy

When synchronization begins:

- Define explicit versioned API contracts.
- Prefer OpenAPI for REST contracts where appropriate.
- Generate clients/models where useful.
- Avoid undocumented ad-hoc JSON contracts.
- Maintain backward compatibility deliberately.

The desktop application should not depend on backend implementation details.

---

## 28. Security Baseline

Even before cloud sync:

- Validate persisted input.
- Validate imported data.
- Avoid arbitrary code execution paths.
- Use safe filesystem paths.
- Avoid insecure temporary-file practices.
- Protect sensitive future tokens/credentials using OS-secure storage.
- Do not store secrets in plaintext configuration files.

Future sync/authentication must use modern security practices.

---

## 29. Build and Dependency Policy

Use CMake as the primary build system.

Dependencies must be:

- Necessary
- Maintained
- License-compatible
- Documented

Avoid adding third-party dependencies for functionality already cleanly provided by Qt or the standard library.

Use dependency managers only if they provide clear value.

---

## 30. Qt Licensing Rule

Qt licensing must be reviewed before commercial distribution decisions.

The project must:

- Record the Qt license strategy.
- Track modules used.
- Avoid accidental dependence on modules incompatible with the intended distribution model.
- Review LGPL obligations where applicable.
- Reevaluate commercial licensing if future requirements justify it.

Licensing is an architecture constraint, not a last-minute release task.

---

## 31. Coding Standards

General direction:

- Modern C++
- RAII
- Smart pointers where ownership requires them
- Clear ownership semantics
- `const` correctness
- Strong types where useful
- Small focused classes
- Avoid unnecessary inheritance
- Prefer composition
- Avoid global mutable state
- Explicit dependencies
- Meaningful names
- Minimal hidden side effects

Do not split code merely to satisfy arbitrary line-count rules.

Refactor when it improves:

- Cohesion
- Testability
- Maintainability
- Performance
- Reuse
- Architectural boundaries

---

## 32. AI-Assisted Development Rules

AI agents must:

- Read product and architecture documents before implementing.
- Work only on the requested scope.
- Verify existing code before modifying it.
- Avoid unrelated refactoring.
- Avoid speculative architecture changes.
- Keep changes incremental.
- Update `TASK.md` and `STATE.md` when a task is completed.
- Preserve settled decisions.
- Surface architectural conflicts before silently changing behavior.
- Prefer small verified patches.
- Do not mechanically translate frozen Python code.
- Use the Python reference only to inspect intended behavior.
- Communicate with the user in Turkish unless explicitly requested otherwise.

---

## 33. Initial Development Order

Recommended initial implementation sequence:

```text
1. Build/toolchain foundation
2. Minimal Qt Quick application shell
3. Design System foundation
4. Window/platform foundation
5. Clock
6. Date
7. Battery
8. Grouped/free layout
9. Quick Actions
10. Settings
11. Todo
12. Reminder
13. Alarm
14. Unified notifications
15. Tray/startup/lifecycle polish
16. Performance and stability pass
17. Desktop V1 release readiness
```

The detailed phase plan belongs in `ROADMAP.md`.

---

## 34. Architecture Decision Rule

When a major technical question arises:

1. Identify the actual product requirement.
2. Check `DESKPILOT_PRODUCT_SPEC.md`.
3. Evaluate at least the strongest realistic alternatives.
4. Compare:
   - Product quality
   - Visual freedom
   - Performance
   - Native integration
   - Maintainability
   - Complexity
   - Licensing
   - Long-term risk
5. Record significant decisions.

Do not choose the easiest short-term solution if it creates a known long-term limitation.

Do not choose the most complex solution merely because it appears more professional.

Choose the cleanest architecture that supports the real product vision.

---

## 35. Canonical Rule

The architecture is subordinate to the product vision, but implementation details are not dictated by the legacy Python code.

In case of uncertainty:

> **Preserve intended product behavior. Improve the implementation architecture. Avoid preserving accidental legacy constraints.**
