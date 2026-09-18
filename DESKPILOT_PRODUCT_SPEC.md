# DESKPILOT PRODUCT SPECIFICATION

## 1. Document Purpose

This document defines the product behavior and functional scope of DeskPilot as inherited from the frozen Python reference implementation (`D_DeskPilot`, tag: `deskpilot-python-freeze`).

The frozen Python application is a **behavioral and product reference**, not a source-code migration target.

DeskPilotF must not mechanically translate Python/PyQt/PySide code into C++. Existing workarounds, widget-specific limitations, legacy structure, and accidental implementation details must not be carried forward unless they represent an intentional product requirement.

This specification is the primary reference for **what DeskPilot is expected to do**. The technical architecture of DeskPilotF must be defined separately.

---

## 2. Product Vision

DeskPilot is a local-first personal productivity environment that begins as a high-quality desktop application and is intended to evolve into a synchronized multi-device product ecosystem.

The long-term product direction includes:

- Desktop-first professional experience.
- Highly polished and visually distinctive user interface.
- Clock, date, battery, reminder, alarm, todo, notification, settings, and layout capabilities.
- Strong operating-system integration on desktop.
- Optional synchronization across the user's own devices in later stages.
- Mobile companion applications.
- Web access where appropriate.
- Shared product identity and synchronized data across supported platforms.
- Offline-first behavior wherever practical.
- Privacy-conscious architecture.
- No unnecessary dependency on paid APIs or mandatory cloud services.

The desktop application is the first full client, not the permanent boundary of the product.

---

## 3. Frozen Reference Point

The Python reference implementation was frozen when:

- Core desktop surface was functional.
- Clock, date, and battery modules existed.
- Transparent and draggable desktop presentation existed.
- Grouped and free-layout window behavior existed.
- Always-on-top behavior existed.
- System tray integration existed.
- Settings persistence existed.
- Quick Actions hover behavior had been stabilized and was considered frozen.
- Todo had reached an advanced functional implementation stage.
- Reminder baseline existed, but the reminder system was entering its final development/polish stage.
- Alarm foundations existed.
- Turkish-first V1 stabilization was still in progress.
- Mobile, sync, web, and global rollout were future work.

The new DeskPilotF implementation starts from this known product state but may redesign internal architecture and UI implementation completely.

---

## 4. Core Product Modules

DeskPilot consists of the following product areas:

1. Desktop Shell / Window System
2. Clock
3. Date
4. Battery
5. Quick Actions
6. Settings
7. Todo
8. Reminder
9. Alarm
10. Notifications
11. System Tray
12. Startup / Application Lifecycle
13. Localization Foundation
14. Future Account and Synchronization
15. Future Mobile Clients
16. Future Web Client

---

## 5. Desktop Shell and Window Behavior

The desktop client must support a lightweight desktop-surface experience rather than behaving only as a conventional application window.

Required product behaviors include:

- Frameless visual presentation.
- Transparent or configurable-opacity background/window behavior.
- Draggable desktop surface.
- Always-on-top option.
- Configurable startup behavior.
- Multi-monitor awareness.
- Safe fallback when a previously used monitor is unavailable.
- Persistent window positions.
- Persistent scale and layout settings.
- Grouped layout mode.
- Free layout mode.
- Ability to move and position clock, date, and battery independently in free layout.
- Saved per-module positions.
- Ability to lock/unlock appropriate layout behavior.
- Stable behavior during show/hide, focus changes, popup display, and topmost transitions.

The C++/QML implementation should reproduce the intended user behavior without copying QWidget-specific implementation techniques.

---

## 6. Clock Module

The clock is a primary visual element.

Required capabilities:

- Show/hide clock.
- 24-hour and supported time-format behavior.
- Optional seconds.
- Independent seconds scaling.
- Font selection.
- Embedded custom fonts.
- System font support where appropriate.
- Font color.
- Bold option.
- Independent clock scaling.
- Persistent settings.
- Stable behavior in grouped layout.
- Stable behavior in free layout.

Known reference fonts include:

- Stencil
- Digital-7
- DS-Digital
- Technology

The previous seconds-width jitter issue was explicitly deferred and must not automatically dictate the new implementation. DeskPilotF should solve visual stability naturally if the new rendering architecture allows it.

---

## 7. Date Module

Required capabilities:

- Show/hide date.
- Configurable date format.
- Font selection.
- Font color.
- Bold option.
- Gregorian (Miladi) date support.
- Hijri (Hicri) date support.
- Combined Gregorian/Hijri display mode.
- Ability to control which date appears first where applicable.
- Optional week-number support.
- Independent scaling for date elements where required.
- Persistent settings.
- Stable grouped-layout behavior.
- Stable free-layout behavior.

Turkish-first date presentation is the V1 priority.

---

## 8. Battery Module

Required capabilities:

- Show/hide battery information.
- Optional battery icon visibility.
- Battery percentage/status display.
- Charging / plugged-in state awareness.
- Configurable font.
- Configurable color.
- Bold option.
- Independent scaling.
- Low-battery threshold.
- Configurable alert interval.
- Configurable alert sound type.
- Optional full-charge alert.
- Configurable full-charge threshold.
- Safe behavior when battery information is unavailable.
- Respect global silent mode.
- Stable grouped-layout behavior.
- Stable free-layout behavior.

Battery warnings should eventually route through the unified notification system.

---

## 9. Quick Actions

Quick Actions provide contextual access to related functionality from the primary desktop modules.

The frozen reference established the following intended behavior:

- Quick Actions appear contextually around relevant clock/date/battery content.
- Placement is based on the actual visual/content area rather than an oversized container.
- Actions include access to:
  - Settings
  - Reminder
  - Todo
- Hover behavior must be stable.
- The panel must not flicker or disappear prematurely while the pointer moves between the source content and Quick Actions.
- Delayed hiding is allowed to improve usability.
- Quick Actions should hide appropriately when the owning window moves.
- Icon sizing should be visually proportional and independent from unrelated text font sizing.
- The feature was considered stable/frozen in the Python reference and should be behaviorally preserved unless intentionally redesigned.

DeskPilotF may redesign the visual presentation significantly while preserving fast contextual access.

---

## 10. Settings System

Settings must be persistent and safely loaded.

The reference product includes settings for:

- Application language.
- Window opacity.
- Always-on-top.
- Run at startup.
- Startup animation.
- Silent mode.
- Tray notifications.
- Notification cooldown.
- Clock visibility and presentation.
- Date visibility and presentation.
- Battery visibility and presentation.
- Alarm visibility.
- Reminder visibility.
- Todo visibility.
- Dynamic Todo priorities.
- Todo retention periods.
- Global scale.
- Per-module scale.
- Inter-module spacing.
- Quick Actions sizing/spacing.
- Multi-monitor mode.
- Free-layout state and positions.
- Grouped-layout state and positions.

The old implementation used JSON persistence with safe loading and atomic settings writes.

DeskPilotF does not have to preserve JSON as the permanent storage architecture if a superior architecture is selected, but it must:

- Preserve user settings reliably.
- Support migration/versioning.
- Handle missing or unknown fields safely.
- Recover safely from corrupted persisted state where practical.
- Avoid losing user configuration during application upgrades.

---

## 11. Todo System

The Todo system is a lightweight professional task manager, not a full enterprise project-management suite.

### 11.1 Core Todo Data

The frozen reference model includes:

- Unique ID.
- Title.
- Description.
- Priority.
- Completion state.
- Cancellation state.
- Trash/deleted state.
- Manual ordering value.
- Planned/due date and time.
- Creation time.
- Completion time.
- Cancellation time.
- Trash time.
- Checklist/subtask foundation.

The new architecture should finalize the V1 model deliberately rather than copying every legacy field automatically.

### 11.2 Priority

The reference supports dynamic priorities.

Default priority concepts:

- Low
- Normal
- High

Priority configuration includes:

- Internal key.
- User-facing name.
- Color.

Default reference colors:

- Low: `#22c55e`
- Normal: `#3b82f6`
- High: `#f97316`

The future design should allow customization without making the system unnecessarily complex.

### 11.3 Task States

The UI must clearly distinguish relevant states, including:

- Active
- Overdue
- Completed
- Cancelled
- Trashed/deleted where applicable

The reference visual language included explicit overlays/status presentation such as:

- TAMAMLANDI
- SÜRESİ GEÇTİ
- İPTAL EDİLDİ

The exact visual design may be improved in DeskPilotF.

### 11.4 Todo Workflow

Required product behavior includes:

- Fast task creation.
- New Task dialog.
- Task editing.
- Shared date/time editing behavior.
- Save/load planned date and time.
- Description support.
- Priority selection.
- Stable priority/time ordering.
- Tasks without dates should remain predictably ordered.
- Completed/cancelled cleanup/visibility rules.
- Trash retention behavior.
- Restore from trash where applicable.
- Permanent deletion where applicable.

### 11.5 Todo Discovery and Filtering

V1/future V1 polish includes:

- Today filter/view.
- Tomorrow filter/view.
- Week filter/view.
- Completed filter/view.
- Search.
- Correct Turkish-character search behavior.
- Useful empty states.

### 11.6 Todo Visual System

The Todo experience should:

- Use a card-based visual language.
- Avoid a flat, generic gray appearance.
- Maintain clear priority/status communication.
- Scale proportionally.
- Keep text, checkbox/control sizes, padding, and icons visually balanced.
- Support configurable panel/card/text/border/accent colors where practical.
- Apply visual changes immediately.
- Maintain safe contrast.

---

## 12. Reminder System

The reminder system existed at baseline level when the Python project was frozen and is the primary unfinished V1 product area to complete in DeskPilotF.

### 12.1 Existing Baseline

The frozen reference already established:

- Reminder model.
- Persistent reminder service.
- Reminder list UI.
- Reminder popup.
- Active state.
- Completed state.
- Missed state.
- One-time reminder foundation.
- Daily recurrence foundation.
- Weekly recurrence foundation.
- Upcoming reminder queries.
- Daily reminder queries.
- Missed reminder queries.
- Enable/disable behavior.
- Snooze-related service foundation.
- Due-reminder scanning.

### 12.2 Reminder V1 Completion Requirements

DeskPilotF should complete the intended reminder design, including:

- Reliable one-time reminders.
- Daily recurrence.
- Weekly recurrence.
- Remaining-time text in Turkish.
- Minute/hour/day remaining-time presentation.
- `Zamanı geldi` state.
- Safe past-time handling.
- Snooze:
  - 5 minutes
  - 10 minutes
  - 60 minutes
- Missed reminder handling after application restart.
- Duplicate-notification prevention.
- Safe handling of malformed persisted reminder records.
- Backward/migration-safe defaults where legacy data import is supported.

### 12.3 Reminder Voice / TTS Direction

The planned V1 direction includes:

- Optional voice/TTS enablement.
- Voice alert content.
- Repeat rules where appropriate.
- Offline TTS.
- Non-blocking TTS execution.
- Preferred voice selection when available.
- Safe fallback to system default.
- Graceful failure when TTS is unavailable.
- No mandatory cloud/API TTS dependency.

The original Python-specific `pyttsx3` choice is not a requirement for DeskPilotF. Use the best native/offline solution for the new architecture.

### 12.4 Reminder UI

The reminder UI should provide:

- Add reminder.
- Edit reminder.
- Reminder list.
- Clear status presentation.
- Input validation.
- Spoken-text preview if voice reminders are enabled.
- Polished reminder cards.
- Appropriate status colors.
- Popup behavior that does not unnecessarily hide or disrupt the main desktop clock surface.

---

## 13. Alarm System

Alarm foundations exist in the frozen reference.

DeskPilotF should treat Alarm as a separate but related product capability.

Expected direction includes:

- Alarm model.
- Alarm service.
- Alarm list.
- Alarm popup.
- Alarm sounds.
- Daily alarm/recurrence behavior where defined.
- Clear distinction between alarms and general reminders.

The final V1 alarm scope should be confirmed during DeskPilotF roadmap planning rather than inferred solely from legacy implementation.

---

## 14. Notification System

DeskPilot should use a unified notification architecture.

Expected behavior:

- Common notification service.
- Visual notifications.
- Sound where enabled.
- TTS where applicable.
- Per-source cooldown rules.
- Silent mode:
  - No sound.
  - No TTS.
  - Visual notification may remain available.
- Reminder alerts routed through the common system.
- Battery alerts routed through the common system.
- Potential notification history if it remains lightweight.

Notification history, if implemented, should remain bounded and should not become an analytics platform.

---

## 15. System Tray

Required desktop tray capabilities:

- Tray icon.
- Show/hide DeskPilot.
- New Reminder action.
- New Todo action.
- Settings action.
- Quit action.
- Useful tooltip/status summary.
- Safe fallback if tray support is unavailable.

Tray behavior must remain stable with application show/hide and close behavior.

---

## 16. Startup and Lifecycle

Expected desktop lifecycle behavior:

- Single application instance.
- Safe startup.
- Settings loaded before dependent UI state is finalized.
- Embedded assets/fonts loaded correctly.
- System tray initialized safely.
- Main desktop surface initialized predictably.
- Optional run-at-startup.
- Multi-monitor position recovery.
- No unnecessary duplicate processes.
- Graceful shutdown and state persistence.

---

## 17. Localization

Product policy:

- V1 is Turkish-first.
- Localization architecture should exist from the beginning.
- English is a later full localization target.
- Arabic/RTL is a later localization target.
- New user-facing text should be localization-ready.
- Do not delay V1 merely to fully polish all languages.

The frozen reference already contains Turkish, English, and Arabic translation foundations.

DeskPilotF should establish a clean localization architecture early, even while Turkish remains the primary V1 language.

---

## 18. Visual and UX Quality Standard

DeskPilotF must not reproduce the visual limitations of the previous QWidget-based implementation.

The new product target is:

- Premium visual quality.
- Highly customizable UI.
- Smooth animations and transitions.
- Strong typography.
- Precise layout.
- High-DPI correctness.
- Proportional scaling.
- Clear hierarchy.
- Responsive interactions.
- Stable hover/focus behavior.
- Strong accessibility and contrast.
- Consistent design language.
- No generic "developer tool" appearance.
- No unnecessary visual clutter.

The UI should be designed through a reusable QML component system and shared Design Tokens.

---

## 19. Performance Standard

DeskPilot is expected to remain running for long periods.

Therefore:

- Idle CPU usage must remain low.
- Memory use must be controlled.
- Animations must remain smooth.
- Timers and polling must be efficient.
- Battery monitoring must not create excessive polling.
- Background reminder/alarm checks must be efficient.
- UI rendering must not trigger unnecessary full-window repaint behavior.
- Startup should be fast.
- Desktop interaction should feel immediate.

Performance must be measured during development rather than assumed.

---

## 20. Privacy and Offline-First Policy

For the desktop V1:

- Core functionality must work without an account.
- Core functionality must work without mandatory internet.
- No mandatory paid API.
- No mandatory cloud dependency.
- User productivity data remains local unless the user later explicitly enables synchronization.

Future synchronization must remain an optional product layer and must not destroy local-first usability.

---

## 21. Future Multi-Device Synchronization

DeskPilot is intended to evolve beyond a single Windows installation.

Future synchronization should support the same user across:

- Work desktop.
- Home desktop.
- Android.
- iOS.
- Web where appropriate.

Potential synchronized domains include:

- Todos.
- Reminders.
- Relevant notification state.
- User preferences.
- Shared product settings where cross-device synchronization makes sense.

Device-specific settings must remain device-specific where appropriate.

Examples:

- Window coordinates should not blindly synchronize between unrelated devices.
- Shared Todo data should synchronize.
- Reminder state should synchronize according to defined conflict and alert-routing rules.

Future sync architecture must define:

- User identity.
- Devices.
- Sessions.
- Trusted devices.
- Offline queue.
- Conflict resolution.
- Data encryption.
- Alert routing.
- Account recovery.
- Data export.
- Account/data deletion.
- Privacy controls.

Sync remains a later phase and must not block desktop V1.

---

## 22. Future Mobile Strategy

Current reference direction:

- Flutter + Dart as the primary mobile candidate.
- Android-first practical rollout.
- iOS when testing/deployment capability is available.
- Shared account and sync API with desktop.
- Offline-first local cache.
- Quick Todo and Reminder actions.
- Snooze, complete, dismiss, and related alert actions.
- Consistent synchronized state with desktop.

The mobile client does not have to reproduce the desktop UI literally.

It should provide the best mobile experience while preserving DeskPilot product identity.

---

## 23. Future Web Strategy

The web client is a future DeskPilot access surface.

Current architectural reference:

- TypeScript
- React
- Next.js

The final choice must be reevaluated when web implementation begins.

The web experience should use the same product account/sync contracts while remaining a true web experience rather than a forced copy of desktop UI.

---

## 24. Storage and Migration

The frozen Python V1 used JSON persistence.

DeskPilotF should select storage based on long-term requirements.

Likely candidates:

- SQLite for structured local application data.
- Versioned settings storage.
- Explicit migration strategy.

Requirements:

- Existing Python DeskPilot user data should be importable if practical.
- Migration must not silently corrupt or discard data.
- Storage schema must be versioned.
- Writes must be safe.
- Recovery strategy must exist for corrupted state.
- Backups should remain simple and local where appropriate.

---

## 25. Architecture Boundary Principle

The new implementation must maintain clear separation between:

- QML visual components.
- View models / presentation logic.
- Application services.
- Domain models.
- Persistence.
- Platform/OS integration.
- Notification infrastructure.
- Future synchronization.

Business rules must not become embedded throughout QML files.

QML should primarily render state, bind properties, animate presentation, and send user actions.

---

## 26. Explicit Non-Goals for Initial DeskPilotF Desktop V1

Unless deliberately reconsidered:

- No plugin system.
- No mandatory cloud sync.
- No paid API dependency.
- No world clock requirement.
- No complex automation scripting engine.
- No unnecessary enterprise project-management features.
- No premature global-language polish.
- No architecture complexity that provides no current or known future value.

---

## 27. DeskPilotF Implementation Principle

The frozen Python project answers:

> **What should the product do?**

DeskPilotF architecture answers:

> **What is the cleanest, most scalable, highest-quality way to implement it now?**

When the two conflict because of legacy implementation limitations, preserve the intended product behavior, not the legacy implementation technique.

---

## 28. Initial DeskPilotF Completion Target

The first major milestone is a professional Desktop V1 that reaches functional parity with the intended frozen Python V1 scope while substantially improving:

- Visual quality.
- UI flexibility.
- Rendering quality.
- Animation.
- Architecture.
- Performance.
- Maintainability.
- Testability.

The migration/rebuild should proceed incrementally, with each major module verified before the next is considered complete.

The reminder system is considered the last major unfinished functional area inherited from the frozen Python reference and must be completed as part of reaching the intended Desktop V1.

---

## 29. AI Agent Interpretation Rule

For ChatGPT, Codex, Copilot, or other AI engineering agents:

- Treat this file as the canonical DeskPilot product-behavior reference.
- Do not reinterpret settled product behavior without explicit user approval.
- Do not mechanically port Python code.
- Use the frozen Python repository only to clarify behavior or edge cases.
- Prefer clean C++/Qt Quick/QML architecture.
- Do not copy QWidget-specific workarounds into QML.
- Do not implement future sync/mobile/web phases during Desktop V1 unless explicitly requested.
- Work incrementally and verify each stage.
- Follow the repository's architecture and task documents.
- Communicate with the user in Turkish unless explicitly asked otherwise.

