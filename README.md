# D_DeskPilotC

DeskPilotC is the next-generation desktop implementation of DeskPilot, rebuilt on a clean **C++ + Qt 6 + Qt Quick/QML** architecture.

The project is designed as the desktop foundation of a future multi-device DeskPilot ecosystem, with planned mobile, web, and optional synchronization layers.

## Current Status

**Development stage:** Phase 0 — Project Foundation and Specification

No production C++/QML implementation has started yet.

The previous Python/PyQt DeskPilot implementation has been frozen and is retained only as a **behavioral and product reference**.

Frozen reference tag:

```text
deskpilot-python-freeze
```

DeskPilotC must not mechanically translate the old Python codebase into C++.

The objective is to preserve intended product behavior while rebuilding the architecture cleanly.

---

## Primary Desktop Stack

- C++
- Qt 6
- Qt Quick
- QML
- CMake
- SQLite

Initial desktop target:

- Windows

Planned future desktop targets:

- macOS
- Linux

---

## Product Direction

DeskPilot is intended to evolve into a high-quality personal productivity ecosystem with:

- Clock
- Date
- Battery
- Todo
- Reminder
- Alarm
- Notifications
- Desktop integration
- Flexible layout
- Multi-device synchronization
- Mobile clients
- Web access

The first major target is a polished **Desktop V1**.

Future sync, mobile, and web work must not block Desktop V1 development.

---

## Core Product Principles

DeskPilotC prioritizes:

- Maximum practical visual quality
- High UI flexibility
- Smooth interaction and animation
- Strong performance
- Low idle resource usage
- Professional architecture
- Native desktop integration
- Long-term maintainability
- Testability
- Offline-first behavior
- Future multi-device readiness

The project does not prioritize a single shared codebase at the expense of product quality.

---

## Documentation

Before modifying the project, read these files in order:

1. `AGENTS.md`
2. `STATE.md`
3. `TASK.md`
4. `ROADMAP.md`
5. `DESKPILOT_PRODUCT_SPEC.md`
6. `ARCHITECTURE.md`
7. `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`

### Document Roles

- `STATE.md`  
  Current project position, recent decisions, and immediate next steps.

- `TASK.md`  
  Active work items for the current development phase.

- `ROADMAP.md`  
  Full project roadmap from foundation to Desktop V1 and future platform phases.

- `DESKPILOT_PRODUCT_SPEC.md`  
  Canonical product behavior and functional requirements.

- `ARCHITECTURE.md`  
  Technical architecture for the new C++/Qt Quick/QML implementation.

- `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`  
  General technology and architecture selection principles used across current and future projects.

---

## Development Rule

The frozen Python DeskPilot answers:

> What should the product do?

DeskPilotC answers:

> What is the cleanest, most scalable, highest-quality way to implement it now?

Do not preserve accidental limitations or QWidget-specific workarounds from the legacy implementation.

---

## Development Workflow

Use an incremental, verification-first workflow.

1. Analyze before modifying.
2. Work on one agreed task at a time.
3. Keep changes focused.
4. Avoid unrelated refactoring.
5. Verify each step before continuing.
6. Update `TASK.md` and `STATE.md` after meaningful milestones.
7. Update `ROADMAP.md` when phase-level progress changes.

For interactive development with the user, use concise Turkish communication unless another language is explicitly requested.

---

## Current Immediate Goal

Complete Phase 0:

- Finalize project documentation.
- Define Qt licensing baseline.
- Verify Windows C++ / Qt 6 / CMake toolchain.
- Select exact Qt and compiler baseline.
- Create minimal repository structure.
- Create root CMake configuration.
- Build and run the first minimal Qt Quick/QML application.
- Commit and push the verified project foundation.

---

## Repository

Private repository:

```text
https://github.com/mskaymaz/D_DeskPilotC
```

---

## License

Not yet finalized.

Qt licensing and the project's own distribution/license strategy must be reviewed before Desktop V1 distribution decisions are made.

