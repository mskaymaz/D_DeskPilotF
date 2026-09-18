# DESKPILOTC ARCHITECTURE

## 1. Purpose

This document defines the technical architecture of DeskPilotF rebuilt on **Flutter/Dart**.

It must be read together with:
- `DESKPILOT_PRODUCT_SPEC.md`
- `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`
- `ROADMAP.md`
- `STATE.md`
- `TASK.md`

`DESKPILOT_PRODUCT_SPEC.md` defines **what the product should do**.
This document defines **how DeskPilotF should be engineered**.

---

## 2. Primary Technology Stack

### UI
- **Flutter/Dart** with Material 3 + Custom Design Tokens
- `window_manager` for desktop window management
- `tray_manager` for system tray integration

### State Management
- **Riverpod** — reactive, compile-time safe, testable

### Persistence
- **drift** (reactive SQLite) — for Todo, Reminder repositories
- **Hive** — lightweight key-value for settings
- Versioned JSON for complex settings with migration

### Platform Services
- `flutter_tts` — Text-to-speech
- `audioplayers` — Alert sounds
- `path_provider` — File system paths
- `url_launcher` — Startup registration
- `flutter_secure_storage` — Secure data

### Testing
- `flutter_test` — Unit and integration tests
- `mockito` — Mocking
- `drift_dev` + `build_runner` — Type-safe database queries

### Build System
- `flutter` CLI
- `flutter build windows` for packaging

### Supported Initial Platform
- Windows desktop

### Planned Future Desktop Targets
- macOS
- Linux

---

## 3. Architectural Goals

DeskPilotF must optimize for:

- **High visual quality** — Custom Design Tokens, rich animations
- **UI freedom** — Flutter's rendering engine gives pixel-level control
- **Smooth animations** — Implicit animations, custom transitions
- **Native desktop integration** — window_manager, tray_manager
- **Low idle CPU/memory** — Efficient timers, minimal overhead
- **Long-running stability** — Memory leak prevention, efficient state management
- **Clean separation of concerns** — Layered architecture
- **Strong testability** — Pure Dart domain logic, Riverpod for testable state
- **Future mobile/web** — Shared Dart logic, platform-specific UI
- **Incremental development** — Phase by phase, each verified

---

## 4. High-Level Architecture

```
┌─────────────────────────────────────────────┐
│              FLUTTER UI LAYER               │
│                                             │
│  Pages / Screens / Windows / Components    │
│  Material 3 + Custom Widgets               │
│  Animated transitions, gestures            │
└──────────────────┬──────────────────────────┘
                   │ ConsumerWidget / Riverpod
                   ▼
┌─────────────────────────────────────────────┐
│         PRESENTATION / VIEWMODEL            │
│                                             │
│  Riverpod StateProviders                    │
│  ChangeNotifiers per module                 │
│  Formatting adapters                        │
│  Reactive state management                  │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│              DOMAIN LAYER                   │
│                                             │
│  Pure Dart models with business rules       │
│  TodoItem, Reminder, ClockState             │
│  State transition logic                     │
│  Validation, invariants                     │
│  No Flutter dependency                      │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│           APPLICATION SERVICES              │
│                                             │
│  Use cases, workflows, orchestration        │
│  ReminderScheduler, NotificationCoordinator │
│  SettingsService, StartupService            │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│        INFRASTRUCTURE / PERSISTENCE         │
│                                             │
│  drift (SQLite) repositories                │
│  Platform plugins (window_manager,          │
│  tray_manager, flutter_tts)                 │
│  Settings store (Hive + versioned JSON)     │
│  DesignTokens                               │
└─────────────────────────────────────────────┘
```

**Dependency direction must point inward.**

The UI must depend on Riverpod abstractions.
The domain must not depend on Flutter.

---

## 5. Repository Structure

```
D_DeskPilotF/
│
├── pubspec.yaml
├── README.md
├── AGENTS.md
├── STATE.md
├── TASK.md
├── ROADMAP.md
├── DESKPILOT_PRODUCT_SPEC.md
├── PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md
├── ARCHITECTURE.md
│
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── design_tokens/
│   │   │   ├── colors.dart
│   │   │   ├── typography.dart
│   │   │   ├── spacing.dart
│   │   │   ├── radius.dart
│   │   │   ├── motion.dart
│   │   │   ├── sizing.dart
│   │   │   ├── z_layers.dart
│   │   │   └── design_tokens.dart
│   │   ├── constants/
│   │   ├── utils/
│   │   └── error_handling/
│   ├── domain/
│   │   ├── models/
│   │   │   ├── clock_model.dart
│   │   │   ├── date_model.dart
│   │   │   ├── battery_model.dart
│   │   │   ├── todo_item.dart
│   │   │   ├── todo_priority.dart
│   │   │   ├── todo_state.dart
│   │   │   ├── reminder.dart
│   │   │   └── reminder_recurrence.dart
│   │   ├── services/
│   │   │   ├── clock_service.dart
│   │   │   ├── date_service.dart
│   │   │   ├── battery_service.dart
│   │   │   └── time_service.dart
│   │   └── repositories/
│   │       ├── itodo_repository.dart
│   │       ├── ireminder_repository.dart
│   │       └── isettings_repository.dart
│   ├── application/
│   │   ├── providers/
│   │   │   ├── app_provider.dart
│   │   │   ├── clock_provider.dart
│   │   │   ├── todo_provider.dart
│   │   │   ├── reminder_provider.dart
│   │   │   └── settings_provider.dart
│   │   └── services/
│   │       ├── reminder_scheduler.dart
│   │       ├── notification_coordinator.dart
│   │       ├── settings_service.dart
│   │       └── startup_service.dart
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── desktop_surface.dart
│   │   │   ├── clock_window.dart
│   │   │   ├── date_window.dart
│   │   │   ├── battery_window.dart
│   │   │   ├── todo_panel.dart
│   │   │   ├── reminder_panel.dart
│   │   │   └── settings_panel.dart
│   │   ├── widgets/
│   │   │   ├── module_window.dart
│   │   │   ├── todo_card.dart
│   │   │   ├── reminder_card.dart
│   │   │   ├── quick_actions_bar.dart
│   │   │   ├── status_overlay.dart
│   │   │   └── priority_color_strip.dart
│   │   ├── components/
│   │   │   ├── base_button.dart
│   │   │   ├── base_textfield.dart
│   │   │   ├── base_card.dart
│   │   │   └── base_dialog.dart
│   │   └── design/
│   │       ├── app_theme.dart
│   │       └── responsive_mixin.dart
│   └── infrastructure/
│       ├── persistence/
│       │   ├── app_database.dart
│       │   ├── todo_repository.dart
│       │   ├── reminder_repository.dart
│       │   └── settings_repository.dart
│       ├── platform/
│       │   ├── window_service.dart
│       │   ├── tray_service.dart
│       │   ├── tts_service.dart
│       │   ├── audio_service.dart
│       │   └── startup_service.dart
│       └── settings/
│           ├── settings_store.dart
│           └── settings_migrator.dart
│
├── assets/
│   ├── fonts/
│   ├── images/
│   └── audio/
├── img/
│   ├── icons/
│   └── logos/
├── test/
│   ├── unit/
│   ├── integration/
│   └── widget/
├── windows/
│   └── runner/
└── docs/
```

This structure is a reference, not a requirement to create every directory immediately.
Create folders only when the corresponding responsibility exists.

---

## 6. UI Responsibility

Flutter UI is responsible for:

- Rendering all visual elements
- Layout and positioning
- Animations and transitions
- Visual states and interaction states
- User input and gesture handling
- Component composition
- Presentation-level property binding via Riverpod

Flutter UI must NOT contain:
- Persistent storage logic
- SQL queries
- Complex business rules
- Reminder scheduling logic
- Alarm scheduling logic
- OS-specific low-level logic
- Large data transformation pipelines

Avoid turning Flutter widgets into the application backend.

---

## 7. Dart Domain Layer

Domain models must express product concepts without Flutter dependency.

Examples:
- `TodoItem`, `TodoPriority`, `TodoState`
- `Reminder`, `ReminderRecurrence`, `ReminderState`
- `ClockState`, `DateState`, `BatteryState`
- `Priority` enum, `Notification` model
- `RecurrenceRule`
- `UserPreference`

Domain types must:
- Validate their own invariants
- Use strong types where they improve correctness
- Avoid dependence on Flutter packages in core business logic
- Remain testable without launching the Flutter application

---

## 8. State Management (Riverpod)

Preferred pattern:
- `ConsumerWidget` or `HookConsumerWidget` for UI
- `StateProvider` for simple state
- `StateNotifierProvider` for complex state machines
- `FutureProvider` / `StreamProvider` for async data
- UI consumes providers, actions call methods on notifiers
- Application services execute use cases
- Results update observable state

Example flow:
```dart
TodoPanel (ConsumerWidget)
    → ref.watch(todoViewModelProvider)
    → TodoViewModel (StateNotifier)
    → TodoService (Use Case)
    → TodoRepository (drift)
    → AppDatabase (SQLite)
```

---

## 9. Persistence

DeskPilotF uses structured local persistence.

### SQLite (drift)
- Todo, Reminder, and future sync metadata
- Type-safe queries
- Reactive streams (`watch()`)
- Schema versioning
- Explicit migrations
- Transactions
- Safe writes

### Settings (Hive + JSON)
- Versioned settings store
- `schemaVersion` tracking
- Safe defaults
- Migration mechanism
- Corruption recovery

Repositories must be abstracted behind interfaces:
```dart
abstract class ITodoRepository {
  Future<List<TodoItem>> list();
  Future<void> save(TodoItem item);
  Future<void> remove(TodoItem item);
}
```

---

## 10. Platform Abstraction

Platform-specific code must be isolated behind interfaces.

```dart
abstract class IWindowService {
  Future<void> setPosition(double x, double y);
  Future<void> setAlwaysOnTop(bool value);
  Future<void> setOpacity(double value);
  Future<MonitorInfo> getMonitorInfo();
}

abstract class ITrayService {
  Future<void> registerTrayIcon();
  Future<void> addMenuItem(String label, VoidCallback onTap);
}

abstract class IBatteryService {
  Future<BatteryState> getCurrentState();
  Stream<BatteryState> get onStateChanged();
  Future<void> startMonitoring();
}

abstract class ITtsService {
  Future<void> speak(String text);
  Future<void> stop();
}
```

Windows implementations use `window_manager`, `tray_manager`, platform-specific channels.
Future macOS/Linux implementations can be added without changing application logic.

---

## 11. Window Architecture

DeskPilot requires unusual desktop-window behavior.

Each module is an independent overlay window:
- Frameless, transparent background
- Always-on-top
- Drag via MouseRegion
- Position persistence
- Grouped and free layout modes

The `DesktopSurface` widget manages all module windows in a Stack:
- Position each module via `window_manager.setPosition()`
- Z-index management for layering
- Drag group coordination (grouped mode)
- Module spacing configuration

Do not duplicate window logic across modules.
Create reusable `ModuleWindow` widget with position/drag/visibility logic.

---

## 12. Design System

DeskPilotF establishes a design system from day one.

`lib/core/design_tokens/` contains:
- `colors.dart` — Primary, surface, background, accent colors (light/dark)
- `typography.dart` — Font families, sizes, weights, line heights
- `spacing.dart` — Consistent spacing scale (space1=4, space2=8, etc.)
- `radius.dart` — Corner radius definitions
- `motion.dart` — Animation durations, curves
- `sizing.dart` — Component sizes, icon sizes
- `z_layers.dart` — Stack layering order
- `design_tokens.dart` — Central export

All widgets consume tokens. No hardcoded pixel values in the widget tree.

Supports:
- Global scaling (75%–150%)
- High-DPI correctness
- Theme switching (light/dark)
- Consistent motion
- Accessibility and contrast

---

## 13. Animation Strategy

Rules:
- Use Flutter's implicit animations (`AnimatedContainer`, `AnimatedOpacity`)
- Custom animations via `AnimationController` for complex transitions
- Avoid continuous animation when nothing is changing
- Pause animations when windows are hidden
- Measure idle CPU impact
- Use `Hero` transitions for shared element animations

Visual quality and efficiency must be balanced.

---

## 14. Notification System

All alert-producing modules route through a unified `NotificationCoordinator`:
- Reminder alerts
- Battery alerts
- Todo due events
- Alarm alerts (future)

Handles:
- Visual popup display
- Sound playback
- TTS routing
- Silent mode suppression
- Cooldown management
- Duplicate suppression

---

## 15. Threading and Concurrency

Rules:
- Never block the Flutter UI thread with long-running operations
- Database work via `drift`'s async API
- TTS must not block UI
- Timer-based scheduler uses `Timer.periodic` with efficient checks
- Heavy file operations use `Isolate` if needed
- Prefer Dart's event-driven mechanisms

---

## 16. Testing Strategy

### Unit Tests
Required for:
- Domain model state transitions
- Reminder recurrence logic
- Snooze behavior
- Todo ordering and filtering
- Settings validation and migration
- Timer/scheduler logic

### Integration Tests
Required for:
- drift repositories
- Settings store
- Reminder persistence
- Application service workflows

### Widget Tests
Use selectively for:
- Critical interaction paths
- Quick Actions behavior
- Dialog workflows
- Scaling and theme changes

Do not rely exclusively on manual testing.

---

## 17. Future Synchronization Boundary

Desktop V1 should not implement cloud synchronization.

Architecture must make future sync possible:
- Local repositories sit behind stable interfaces
- Sync engine replaces local repository layer
- Domain models unchanged
- Future structure: `Local Database` → `Sync Engine` → `Remote API`

Do not mix future sync logic into UI or domain models prematurely.

---

## 18. Future Mobile and Web Integration

Flutter/Dart is already designed for this:

```
Desktop: Flutter/Dart + Material 3
Mobile:  Flutter/Dart (same codebase!)
Web:     Flutter/Dart (same codebase!)
```

They share:
- Domain models
- Repository interfaces
- Application services
- Design tokens (with platform adaptations)
- Product behavior definitions

They differ in:
- UI components (platform-specific adaptations)
- Plugin usage (platform-specific)
- Window management (mobile needs different approach)

---

## 19. Build and Dependency Policy

Use `flutter` CLI as the primary build system.

Dependencies must be:
- Necessary
- Maintained
- License-compatible
- Documented

Avoid adding third-party dependencies for functionality already provided by Flutter or Dart's standard library.

---

## 20. Coding Standards

General direction:
- Modern Dart (null safety, extensions, mixins)
- RAII via `dispose()` methods
- `const` constructors where possible
- Strong typing
- Small focused classes
- Avoid unnecessary inheritance
- Prefer composition
- Avoid global mutable state
- Explicit dependencies
- Meaningful names
- Minimal hidden side effects

Do not split code merely to satisfy arbitrary line-count rules.

---

## 21. Localization Foundation

Product policy:
- V1 is Turkish-first
- `flutter_localizations` + `intl` for localization architecture
- All user-facing text wrapped in `AppLocalizations.of(context)!.tr()`
- Turkish character correctness verified
- English foundation later
- Arabic/RTL architecture checked later

---

## 22. AI-Assisted Development Rules

AI agents must:
- Read product and architecture documents before implementing
- Work only on the requested scope
- Verify existing code before modifying it
- Avoid unrelated refactoring
- Keep changes incremental
- Update `TASK.md` and `STATE.md` when a task is completed
- Preserve settled decisions
- Prefer small verified patches
- Do not mechanically translate any previous code
- Communicate with the user in Turkish unless explicitly requested otherwise

---

## 23. Initial Development Order

Recommended sequence:
1. Flutter project initialization and toolchain verification
2. Design system foundation (tokens, theme, base widgets)
3. Window/platform foundation (transparent window, drag, positioning)
4. Clock module
5. Date module
6. Battery module
7. Grouped/free layout
8. Quick Actions
9. Settings system
10. Todo module
11. Reminder module
12. Alarm module
13. Unified notifications, tray, lifecycle
14. Performance and stability pass
15. Desktop V1 release readiness
