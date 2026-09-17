# DESKPILOTC STATE

## Project
**D_DeskPilotC**

## Repository
Remote: `https://github.com/mskaymaz/D_DeskPilotF`

## Current Phase
**Phase 0 — Flutter Project Foundation**

<!-- BISMILLAH CHECKPOINT: Phase 0 – Project initialization in progress -->

## Current Status
Fresh Flutter/Dart project setup. All C++/Qt code has been removed. Repository structure rebuilt from scratch.

Previous C++/Qt codebase was frozen as historical reference.

## Completed
- C++/Qt codebase removed from repository
- Git remote updated to `https://github.com/mskaymaz/D_DeskPilotF`
- Flutter project structure created (`lib/`, `test/`, `assets/`, `windows/`)
- `pubspec.yaml` configured with core dependencies
- `lib/main.dart` created (entry point with window_manager initialization)
- `.gitignore` updated for Flutter
- Documentation files marked for Flutter rewrite

## Documentation Status
- `DESKPILOT_PRODUCT_SPEC.md` — Retained (product behavior reference)
- `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md` — Retained (architecture principles)
- `ARCHITECTURE.md` — Pending rewrite for Flutter/Dart
- `ROADMAP.md` — Pending rewrite for Flutter phases
- `README.md` — Pending rewrite for Flutter
- `AGENTS.md` — Pending update for Flutter workflow

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
1. Run `flutter create .` to initialize Flutter embedding
2. Run `flutter pub get`
3. Verify `flutter run` launches transparent window
4. Proceed to Phase 1: Design System

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
2026-09-17 — Phase 0: Flutter project structure established, C++/Qt codebase removed.
