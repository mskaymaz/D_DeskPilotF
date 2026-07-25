# DESKPILOTC STATE

## Project
**D_DeskPilotC**

## Repository
Private GitHub repository: `mskaymaz/D_DeskPilotC`

## Current Phase
**Phase 4 — Battery Module**

## Current Status
The Clock and Date modules are implemented and build-verified. Phase 4 battery abstraction, Windows adapter, percentage/status presentation, charging/plugged-in detection, optional icon, visibility, font/color/bold settings, and independent scaling are implemented and build-verified.

## Completed
- Existing Python/PyQt DeskPilot repository was frozen.
- Frozen reference was tagged as `deskpilot-python-freeze`.
- Python reference remains the behavioral/product reference.
- New `D_DeskPilotC` repository was created and connected to GitHub.
- `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md` added.
- `DESKPILOT_PRODUCT_SPEC.md` added.
- `ARCHITECTURE.md` added.
- `ROADMAP.md` added.
- `TASK.md` created.
- `STATE.md` created.
- Phase 1 design tokens, reusable QML components, grouped/free layout foundations, and desktop window foundation completed.
- Phase 2 Clock Module tasks through performance verification completed.
- Phase 3 Date service implemented and build-verified.
- Gregorian date model implemented and build-verified.
- Hijri date output implemented with Qt IslamicCivil calendar and build-verified.
- Combined Gregorian/Hijri display added to the Clock surface and build-verified.
- Gregorian-first/Hijri-first date ordering added and build-verified.
- Date format choices added: dotted, slash, and ISO; build-verified.
- Optional ISO week number added to the combined date display and build-verified.
- Independent date font selection added and build-verified.
- Independent date font color added and build-verified.
- Independent date bold behavior added and build-verified.
- Date visibility toggle added and build-verified.
- Independent date scaling added and build-verified.
- Date grouped-layout integration added and build-verified.
- Date free-layout integration added and build-verified.
- Persistent Date Module settings added and build-verified.
- Turkish locale correctness verified for the Date Module and build-verified.
- Phase 3 Date Module completed.
- Phase 4 platform-independent battery abstraction implemented and build-verified.
- Windows battery adapter implemented and build-verified.
- Battery percentage/status presentation implemented and build-verified.
- Charging/plugged-in detection implemented and build-verified.
- Optional battery icon implemented and build-verified.
- Battery visibility implemented and build-verified.
- Battery font/color/bold settings implemented and build-verified.
- Independent battery scaling implemented and build-verified.
- Clock and date context-menu options grouped into dedicated settings submenus.

## Clock Performance Verification
- Debug build completed successfully.
- Short idle sample: approximately 2.76 MB working-set memory and 0% CPU of one core.

## Frozen Python Reference Point
The Python DeskPilot was frozen near the end of Desktop V1 development. Core desktop functionality, Clock, Date, Battery, layout behavior, Quick Actions, Settings, Todo, tray, and related infrastructure were substantially developed. Reminder development had just entered its final major implementation/polish stage.

DeskPilotC must reach the intended Desktop V1 product scope while rebuilding the implementation on a clean C++ + Qt 6 + Qt Quick/QML architecture.

## Architecture Direction
- Desktop UI: Qt 6 + Qt Quick/QML
- Core/native layer: Modern C++
- Build system: CMake
- Initial platform: Windows
- Local structured storage direction: SQLite
- Future mobile reference: Flutter + Dart
- Future web reference: TypeScript + React + Next.js
- Future sync: separate optional account/synchronization layer

Qt licensing baseline: use Qt Community/Open Source with LGPL-compatible modules where possible; avoid paid/commercial-only dependencies and review licenses before adding new Qt modules.

## Important Product Rule
The frozen Python implementation defines intended behavior, not implementation architecture.

Do not:
- mechanically translate Python code to C++;
- copy QWidget-specific workarounds;
- reinterpret settled product decisions without user approval;
- start Sync/Mobile/Web work before Desktop V1 unless explicitly requested.

## Development Workflow
Use the SPP-style workflow:
1. Analyze and verify first.
2. Work on one agreed task at a time.
3. Keep changes focused.
4. Avoid unrelated refactoring.
5. Verify each implementation before continuing.
6. Update `TASK.md` and `STATE.md` after meaningful milestones.
7. Update `ROADMAP.md` when phase-level progress changes.

Commands and patches should be concise and fail-fast. When working interactively with the user, provide one implementation step at a time and wait for the result when later steps depend on it.

## Immediate Next Steps
1. Implement and verify grouped-layout battery integration.

## AI Agent Continuation Instruction
Before modifying this repository, read in this order:

1. `AGENTS.md`
2. `STATE.md`
3. `TASK.md`
4. `ROADMAP.md`
5. `DESKPILOT_PRODUCT_SPEC.md`
6. `ARCHITECTURE.md`
7. `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`

Continue from the current state. Do not restart architectural interpretation unless a real conflict or new requirement requires a decision.

Communicate with the user in Turkish unless explicitly requested otherwise.

## Last Updated
2026-07-25 — Phase 4 independent battery scaling implemented and build-verified; grouped-layout integration is next.



