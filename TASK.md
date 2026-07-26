# DESKPILOTC TASK

## Status Legend
- `[x]` Completed
- `[~]` In progress
- `[ ]` Not started
- `[!]` Blocked / decision required

## Active Phase
**Phase 4 â€” Battery Module**

## Active Tasks
- [x] Freeze Python DeskPilot reference repository.
- [x] Tag frozen reference as `deskpilot-python-freeze`.
- [x] Create private `D_DeskPilotC` repository.
- [x] Initialize local Git repository and connect GitHub remote.
- [x] Add `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`.
- [x] Add `DESKPILOT_PRODUCT_SPEC.md`.
- [x] Add `ARCHITECTURE.md`.
- [x] Add `ROADMAP.md`.
- [x] Create `TASK.md`.
- [x] Create `STATE.md`.
- [x] Create initial `README.md`.
- [x] Define Qt licensing baseline for Desktop V1.
- [x] Verify Windows C++ / Qt 6 / CMake development toolchain.
- [x] Define minimum supported Qt and compiler versions.
- [x] Create initial `.gitignore`.
- [x] Create only the repository directories needed for the first implementation.
- [x] Create root `CMakeLists.txt`.
- [x] Create minimal C++ application bootstrap.
- [x] Create minimal Qt Quick/QML application shell.
- [x] Configure QML resources/modules cleanly.
- [x] Configure initial logging.
- [x] Build from a clean state.
- [x] Launch and verify the minimal application.
- [ ] Verify Git working tree.
- [ ] Commit and push verified Phase 0 foundation.
- [ ] Mark Phase 0 complete in `ROADMAP.md`.
- [x] Complete Phase 1 - Design System and Desktop Window Foundation.
- [x] Clock domain/presentation model.
- [x] Time service.
- [x] 24-hour/time-format behavior.
- [x] Optional seconds.
- [x] Independent seconds scaling.
- [x] Embedded font loading.
- [x] System font support where appropriate.
- [x] Font selection.
- [x] Font color.
- [x] Bold behavior.
- [x] Clock visibility.
- [x] Independent clock scaling.
- [x] Stable rendering without visible width jitter.
- [x] Grouped-layout integration.
- [x] Free-layout integration.
- [x] Platform-independent battery abstraction.
- [x] Windows battery implementation.
- [x] Battery percentage/status presentation.
- [ ] Charging/plugged-in detection.
- [ ] Optional battery icon.
- [ ] Battery visibility.
- [ ] Battery font/color/bold settings.
- [x] Independent battery scaling.
- [ ] Low-battery threshold.
- [x] Turkish locale correctness.
- [x] Persistent settings.
- [x] Persistent clock settings.
- [x] Performance verification.
- [x] Date service.
- [x] Gregorian date.
- [x] Hijri date.
- [x] Combined display.
- [x] Date ordering options.
- [x] Date formatting options.
- [x] Optional week number.
- [x] Font selection.
- [x] Font color.
- [x] Bold behavior.
- [x] Date visibility.
- [x] Independent date scaling.
- [x] Grouped-layout integration.
- [x] Free-layout integration.

## Current Working Rule
Work on one verified task at a time. Do not begin later phases early. Do not mechanically port Python/PyQt code. Use the frozen Python project only as a behavioral reference.

## Next Immediate Task
Implement and verify charging/plugged-in detection.





