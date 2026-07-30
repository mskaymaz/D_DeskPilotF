# DESKPILOTC STATE

## Project
**D_DeskPilotC**

## Repository
Private GitHub repository: `mskaymaz/D_DeskPilotC`

## Current Phase
**Phase 8 — Reminder V1 Completion**

<!-- BISMILLAH CHECKPOINT: Phase 9 – Task 1 – Start Phase 9 advanced Todo features -->

## Current Status
The desktop surface is transparent and panel-free across the primary screen. Visible module regions receive input; all other areas pass through to underlying applications. Free-layout modules remain within the available screen area, while grouped mode moves all modules together. The Clock, Date, and Battery modules are implemented and build-verified. Phase 4 battery work is complete, including efficient polling and unchanged-state suppression. Phase 5 grouped/free startup behavior, independent module positioning, layout locking, inter-module spacing, scale interactions, monitor-bound clamping, the reusable contextual Quick Actions component, the Settings action, the Reminder action, the Todo action, content-aware Quick Actions positioning, stable hover transition, delayed hide behavior, window movement behavior, proportional icon sizing, smooth QML animations, and no-flicker behavior are verified. Phase 6 Settings System is complete; Phase 7 Todo V1 Data and Domain stage, Todo panel/page, Task cards, New Task dialog, and Edit Task dialog are complete.

Module settings persistence, including stable layout, placement, and visual settings across close/reopen, is complete for the current scope.

> Not: Faz 4 — Battery Module tamamlandı. Faz 5 — Layout System and Quick Actions başlangıcına geçildi.

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
- Phase 4 platform-independent battery abstraction verified by `BatteryModelTest`.
- Phase 4 Windows battery implementation verified by `WindowsBatteryServiceTest`.
- Phase 4 battery percentage/status verified by `BatteryModelTest` and Debug build.
- Phase 4 independent scaling and free-layout integration verified by `BatteryModelTest` and Debug build.
- Phase 4 charging/plugged-in detection verified by deterministic Windows battery-state tests.
- Phase 4 optional battery icon added with persisted visibility setting and verified by Debug build and CTest.
- Phase 4 battery visibility menu control and persistence verified by Debug build and CTest.
- Phase 4 battery font, color, and bold controls verified by Debug build and CTest.
- Phase 4 low-battery threshold boundaries and discharging-only behavior verified by CTest.
- Phase 4 full-charge threshold boundaries and charging-only behavior verified by CTest.
- Phase 4 alert interval setting, persistence, and bounds verified by Debug build and CTest.
- Phase 4 alert sound enable/disable setting and persistence verified by Debug build and CTest.
- Phase 4 silent-mode suppression state and persistence verified by Debug build and CTest.
- Phase 4 no-battery fallback and non-alerting behavior verified by `BatteryModelTest`.
- Phase 4 efficient 30-second coarse polling and unchanged-state suppression verified by Debug build and CTest.
- Phase 5 final grouped-layout startup preserves saved grouped positions and only centers when no positions exist.
- Phase 5 final free-layout startup reapplies saved positions after loader creation and layout-mode changes.
- Phase 5 independent Clock/Date/Battery positioning verified through separate free-layout loaders, drag areas, and persisted keys.
- Phase 5 layout lock state disables grouped/free dragging and persists through the layout settings.
- Phase 5 configurable inter-module spacing is applied to grouped centering and free-layout defaults and persists through layout settings.
- Phase 5 grouped scaling preserves group centering/spacing while free scaling preserves each module's independent position.
- Phase 5 saved grouped positions are clamped to the active window bounds for monitor/geometry changes.
- Phase 5 reusable contextual Quick Actions component was verified with delayed hover hiding and Settings/Reminder/Todo action signals.
- Phase 7: Settings/Quick Actions V1 (Completed)
- Phase 8: Reminder V1 Implementation (In Progress)
- Phase 9: Todo V1 Implementation (Pending)
- Phase 5 Settings Quick Action opens the existing settings context menu and is included in the input mask.
- Phase 5 Reminder Quick Action opens a clear placeholder dialog until the Phase 8 Reminder system is implemented.
- Phase 5 Todo Quick Action opens the Phase 7 Todo panel.
- Phase 5 Quick Actions positioning uses the actual clock content bounds, flips at the right edge, and clamps vertically within the window.
- Phase 5 Quick Actions source-to-panel transitions retain hover through a small bridge zone.
- Phase 5 Quick Actions hide only after a 250 ms timer confirms that source and panel are no longer hovered.
- Phase 5 Quick Actions are suppressed when the owning window moves and re-enabled on the next hover entry.
- Phase 5 Quick Actions expose an independent icon-size property backed by the design token and are not coupled to module font scales.
- Phase 5 Quick Actions use short opacity and scale animations for show/hide transitions.
- Phase 5 Quick Actions no-flicker behavior is covered by the bridge zone, guarded hide timer, movement suppression, and reversible animations.

> Not: Faz 5 — Layout System and Quick Actions tamamlandı. Faz 6 — Settings System başlangıcına geçildi.
- Persistent layout mode, module positions, and battery appearance settings added and INI round-trip verified.
- Clock and date context-menu options grouped into dedicated settings submenus.
- Settings domain/schema centralized in a typed snapshot with safe defaults, bounded values, INI round-trip, and automated tests.
- Versioned settings storage added with `meta/schemaVersion` round-trip at schema version 1.
- Safe defaults verified for missing, malformed, bounded, and invalid-position settings values.
- Legacy settings without metadata migrate to schema version 1; unsupported future versions are rejected safely.
- Corrupted INI settings are preserved as `.corrupt` backups and recovered to a clean settings file.
- Settings are separated into user/shared module preferences and device-specific layout settings, with v1-to-v2 scoped-key migration.
- Clock settings UI added as a dedicated live panel with visibility-related presentation, font, color, bold, and scale controls.
- Date settings UI added as a dedicated live panel with visibility, calendar ordering, format, week-number, font, color, bold, and scale controls.
- Battery settings UI added as a dedicated live panel with visibility, icon, appearance, thresholds, alert interval, sound, and silent-mode controls.
- Layout settings UI added as a dedicated live panel with layout mode, lock, and module-spacing controls.
- Quick Actions settings UI added as a dedicated live panel with visibility, action toggles, icon size, and action-spacing controls.
- Notification settings UI added as a dedicated live panel with visual, sound, TTS, and cooldown preferences.
- Global silent mode added to notification settings; it suppresses battery alert audio while preserving visual notification preference.
- Always-on-top setting added as a persisted device-specific window preference with a context-menu toggle.
- Startup setting added with a persisted device-specific preference and Windows Run-key registration service.
- Global scale added with live 75%–150% DesignTokens scaling, menu controls, persistence, and bounds validation.
- Per-module scale controls for Clock, Date, and Battery are live, persisted, and covered by schema round-trip tests.
- Live visual updates verified across settings panels, model bindings, layout reflow, Quick Actions, and input-mask refreshes.
- Reset-to-default behavior added with confirmation and restoration of schema defaults across module, layout, notification, window, startup, and scale settings.
- Import/export is explicitly deferred from V1; the versioned INI settings store remains the supported persistence mechanism.
- Todo V1 data model finalized with validated identity/content, planned time, priority, state, lifecycle timestamps, and overdue semantics.
- SQLite Todo repository added with transactional CRUD, schema creation, safe row validation, and clean Debug/Release test deployment.
- Todo schema migrations added with SQLite user_version tracking, v1 creation, and future-version rejection.
- Todo priority model added with stable Low/Normal/High values, tokens, validation, and test coverage.
- Todo state transitions added with guarded lifecycle changes, timestamp updates, restore behavior, and transition validation tests.
- Todo due/overdue rules added with active-state filtering, exact due-time handling, and future/completed coverage.
- Todo ordering rules added with state grouping, planned-time priority, priority ranking, creation order, and ID tie-breaking.
- Todo retention policy added with indefinite default retention and configurable trashed-item purge eligibility.
- Todo repository now exposes explicit trash, restore, and permanent removal operations with lifecycle validation.
- Todo panel/page, reusable task cards, and New Task dialog added and build-verified.
- Edit Task dialog added and build-verified.
- Description support added to task creation/editing and build-verified.
- Date/time input added to task creation/editing and build-verified.
- Priority selection added to task creation/editing and build-verified.
- Completed state added to task editing/cards and build-verified.
- Overdue state added to task cards with periodic refresh and build-verified.
- Cancelled state added to task editing/cards and build-verified.
- Trash state added to task cards with restore action and build-verified.
- Search added for task titles/descriptions with empty-result handling and build-verified.
- Turkish search normalization added for I/İ/ı/i and build-verified.
- Today filter added for planned tasks and build-verified.
- Tomorrow filter added for planned tasks and build-verified.
- Week filter added with Monday-start week calculation and build-verified.
- Completed view/filter added with task-state matching and build-verified.
- Filter-specific empty-state messages added and build-verified.
- Stable scrolling and model-update refresh handling added and build-verified.
- Todo card visual customization added for status/priority states and build-verified.
- TodoModel–SQLite–QML integration added with CRUD, state transitions, and 6/6 CTest coverage.
- Phase 8 Daily recurrence implemented and verified with tests.
- Phase 8 Weekly recurrence implemented and verified with tests.

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
1. Missed reminder recovery.

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
2026-07-27 — Phase 7 completed; TodoModel integration added, Debug build and 6/6 CTest passed.



