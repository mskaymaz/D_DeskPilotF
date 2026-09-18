# DESKPILOTF STATE

## Project
**D_DeskPilotF**

## Repository
Remote: `https://github.com/mskaymaz/D_DeskPilotF`

## Current Phase
**Phase 3 — Date Module** ✅ COMPLETE

<!-- BISMILLAH CHECKPOINT: Phase 3 – Complete -->

## Current Status
Phase 3 complete. Date module with Gregorian + Hijri support is functional.

## Completed
- C++/Qt codebase removed from repository
- Git remote updated to `https://github.com/mskaymaz/D_DeskPilotF`
- Flutter project structure created (`lib/`, `test/`, `assets/`, `windows/`)
- `pubspec.yaml` configured with `window_manager`, `flutter_localizations`, `intl`, `riverpod`, `flutter_riverpod`
- Design tokens: `lib/core/design_tokens/` (colors, typography, spacing, radius, sizing, z_layers, motion)
- Localization: `lib/core/localization/app_localizations.dart`, `l10n/` (TR, EN)
- **Phase 2 — Clock Module:** domain model, IClockService, Timer-based implementation, ClockNotifier, ClockWindow
- **Phase 3 — Date Module:**
  - `lib/domain/models/date_model.dart` — DateSettings, DateState, DateFormatType, DateOrder
  - `lib/domain/services/date_service.dart` — IDateService abstract interface
  - `lib/infrastructure/platform/date_service_impl.dart` — Timer-based IDateService with intl (Gregorian, Hijri, combined)
  - `lib/application/providers/date_provider.dart` — DateNotifier, StateNotifierProvider
  - `lib/presentation/screens/date_window.dart` — DateWindow ConsumerWidget
- `flutter build windows --debug` produces working `desk_pilot_f.exe`
- Clock + Date displayed in transparent window
- Note: `INSTALL.vcxproj` fails — manually copy `build\flutter_assets\*` to `build\windows\x64\runner\Debug\data\` after build

## Documentation Status
- `DESKPILOT_PRODUCT_SPEC.md` — Updated for Flutter/Dart
- `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md` — Retained
- `ARCHITECTURE.md` — Updated for Flutter/Dart
- `ROADMAP.md` — Updated for Flutter phases
- `README.md` — Updated for Flutter
- `AGENTS.md` — Updated for Flutter workflow

## Technology Stack
- **UI:** Flutter/Dart + Material 3 + Custom Design Tokens
- **State Management:** Riverpod
- **Persistence:** drift (SQLite) + Hive (lightweight settings)
- **Platform:** window_manager, tray_manager, flutter_tts, audioplayers
- **Build:** `flutter build` + `flutter create` Windows embedding
- **Testing:** flutter_test + mockito + drift testing utilities
- **Target Platform:** Windows (initial), macOS/Linux (future)

## Architecture Direction
```
Flutter UI (Presentation Layer)
    ↓ Riverpod State Management
    ↓ ViewModels / Presenters
    ↓ Application Services
    ↓ Domain Models (Dart)
    ↓ Repositories (drift/SQLite)
    ↓ Platform Plugins (window_manager, tray_manager, etc.)
```

## Important Product Rules
- Frozen Python DeskPilot defines intended behavior, not implementation
- Do not mechanically translate any previous code
- Flutter UI must not embed business logic
- Domain models must be pure Dart, testable without Flutter
- All user-facing text must be localization-ready
- Design Tokens must be consumed by all widgets
- File size limit: 400-450 lines soft, 700 hard
- D:\Code dışına yazma yok — bu kural kesin

## Development Workflow
SPP-style workflow:
1. Analyze and verify first
2. Work on one agreed task at a time
3. Keep changes focused
4. Avoid unrelated refactoring
5. Verify each implementation before continuing
6. Update `TASK.md` and `STATE.md` after meaningful milestones
7. Update `ROADMAP.md` when phase-level progress changes

## Immediate Next Steps
1. Proceed to Phase 1: Design System
2. Implement color/typography/spacing/radius design tokens
3. Create reusable base widgets

## AI Agent Continuation Instruction
Before modifying this repository, read in this order:
1. `AGENTS.md`
2. `STATE.md`
3. `TASK.md`
4. `ROADMAP.md`
5. `DESKPILOT_PRODUCT_SPEC.md`
6. `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`
7. `ARCHITECTURE.md`

Continue from the current state. Do not restart architectural interpretation unless a real conflict or new requirement requires a decision.

Communicate with the user in Turkish unless explicitly requested otherwise.

## Last Updated
2026-09-18 — Phase 0: Flutter/Dart project foundation verified. window_manager working. desk_pilot_f.exe builds and runs.
