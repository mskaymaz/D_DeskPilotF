# DESKPILOTC TASK

## Status Legend
- `[x]` Completed
- `[~]` In progress
- `[ ]` Not started
- `[!]` Blocked / decision required

## Active Phase
**Phase 0 — Project Foundation and Specification**

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
- [ ] Create initial `README.md`.
- [ ] Define Qt licensing baseline for Desktop V1.
- [ ] Verify Windows C++ / Qt 6 / CMake development toolchain.
- [ ] Define minimum supported Qt and compiler versions.
- [ ] Create initial `.gitignore`.
- [ ] Create only the repository directories needed for the first implementation.
- [ ] Create root `CMakeLists.txt`.
- [ ] Create minimal C++ application bootstrap.
- [ ] Create minimal Qt Quick/QML application shell.
- [ ] Configure QML resources/modules cleanly.
- [ ] Configure initial logging.
- [ ] Build from a clean state.
- [ ] Launch and verify the minimal application.
- [ ] Verify Git working tree.
- [ ] Commit and push verified Phase 0 foundation.
- [ ] Mark Phase 0 complete in `ROADMAP.md`.
- [ ] Start Phase 1 — Design System and Desktop Window Foundation.

## Current Working Rule
Work on one verified task at a time. Do not begin later phases early. Do not mechanically port Python/PyQt code. Use the frozen Python project only as a behavioral reference.

## Next Immediate Task
Create the initial `README.md`, then verify the local Qt/C++ toolchain before creating production code.
