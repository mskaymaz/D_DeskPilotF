# DESKPILOTC ROADMAP

<!-- AI NOTE: This roadmap is structured for automated AI processing. Each phase should be checked sequentially, marking status symbols (✅, 🔍, ⚠️, ✏️, ❌) after verification. -->

## Status Legend

- `[x]` Completed
- `[~]` In progress
- `[ ]` Not started
- `[!]` Blocked / requires decision

---

# MASTER ROADMAP

## [x] Phase 0 â€” Project Foundation and Specification

**Goal:** Establish the new DeskPilotC project on a clean, documented foundation before production implementation begins.

### Tasks

- [x] Freeze the Python DeskPilot reference repository. ✅
- [x] Create `deskpilot-python-freeze` Git tag. ✅
- [x] Create new private `D_DeskPilotC` GitHub repository. ✅
- [x] Initialize local `D_DeskPilotC` Git repository. ✅
- [x] Connect local repository to GitHub remote. ✅
- [x] Add `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`. ✅
- [x] Create and add `DESKPILOT_PRODUCT_SPEC.md`. ✅
- [x] Create and add `ARCHITECTURE.md`. ✅
- [x] Create `ROADMAP.md`. ✅
- [x] Create `TASK.md`. ✅
- [x] Create `STATE.md`. ✅
- [x] Create initial `README.md`. ✅
- [x] Define Qt licensing strategy for Desktop V1. ✅
- [x] Verify required development toolchain. ✅
- [x] Create initial repository structure. ✅
- [x] Create initial `.gitignore`. ✅
- [x] Create root `CMakeLists.txt`. ✅
- [x] Create minimal Qt 6 / Qt Quick / QML application. ✅
- [x] Confirm clean configure/build/run cycle. ✅
- [x] Commit and push the verified project foundation. ✅

### Completion Criteria

Phase 0 is complete when:

- The project builds successfully from a clean checkout.
- A minimal Qt Quick window/application launches.
- Core architecture documents are present.
- Development toolchain is documented and verified.
- Repository is clean and pushed to GitHub.

---

## [ ] Phase 1 — Design System and Desktop Window Foundation

### Design System

**Goal:** Build the visual and native window foundation before implementing product modules.

- ✅ Define color tokens.
- ✅ Define typography tokens.
- ✅ Define spacing tokens.
- ✅ Define radius tokens.
- ✅ Define sizing tokens.
- ✅ Define z-layer tokens.
- ✅ Define motion/animation tokens.
- ✅ Establish high-DPI strategy.
- ✅ Establish global scaling architecture.
- ✅ Create reusable base QML components.

### [ ] Window Foundation

- ✅ Frameless desktop window.
- ✅ Transparent background/window support.
- ✅ Stable drag behavior.
- ✅ Always-on-top support.
- ✅ Window position persistence.
- ✅ Multi-monitor detection.
- ✅ Safe recovery from unavailable monitors.
- ✅ Grouped-layout foundation.
- ✅ Free-layout foundation.
- ✅ Reusable independent module-window behavior.
- ✅ Stable focus/show/hide lifecycle.
- ✅ Verify idle resource behavior.

### Completion Criteria

- The desktop shell is visually clean and stable.
- Windows can be positioned and restored safely.
- Scaling works consistently.
- Core visual tokens are centralized.
- No product module contains duplicated window infrastructure.

---

## [x] Phase 2 â€” Clock Module

**Goal:** Rebuild the primary DeskPilot clock experience with higher visual quality than the Python reference.

### Tasks

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
- [x] Persistent clock settings.
- [x] Performance verification.

### Completion Criteria

- Clock is production-quality visually.
- Clock behavior matches or improves intended Python V1 behavior.
- Rendering remains smooth and stable over long-running use.

---

## [x] Phase 3 â€” Date Module

**Goal:** Implement the complete Turkish-first date experience.

### Tasks

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
- [x] Persistent settings.
- [x] Turkish locale correctness.

### Completion Criteria

- Gregorian/Hijri presentation is correct.
- Date module is visually consistent with the design system.
- All V1 date settings persist correctly.

---

## [x] Phase 4 â€” Battery Module

**Goal:** Implement efficient battery status and alert foundations.

### Tasks

- [1] Platform-independent battery abstraction.
- [2] Windows battery implementation.
- [3] Battery percentage/status.
- [4] Charging/plugged-in detection.
- [5] Optional battery icon.
- [6] Battery visibility.
- [7] Font/color/bold settings.
- [8] Independent scaling.
- [9] Low-battery threshold.
- [10] Full-charge threshold.
- [11] Alert interval.
- [12] Alert sound configuration.
- [13] Respect silent mode.
- [14] Safe no-battery behavior.
- [15] Grouped-layout integration.
- [16] Free-layout integration.
- [17] Efficient polling/event strategy.

### Completion Criteria

- Battery module works without excessive CPU/polling.
- Alerts are ready to integrate with unified notifications.
- Desktop behavior is stable on battery and non-battery systems.

---

## [x] Phase 5 â€” Layout System and Quick Actions

**Goal:** Complete the primary DeskPilot desktop interaction model.

### [x] Layout

- [1] Final grouped-layout behavior.
- [2] Final free-layout behavior.
- [3] Independent Clock/Date/Battery positioning.
- [4] Position persistence.
- [5] Lock/unlock behavior where required.
- [6] Inter-module spacing.
- [7] Scale interactions.
- [8] Multi-monitor verification.

### [x] Quick Actions

- [9] Contextual Quick Actions component.
- [10] Settings action.
- [11] Reminder action.
- [12] Todo action.
- [13] Content-aware positioning.
- [14] Stable hover transition.
- [15] Delayed hide behavior.
- [16] Correct behavior during window movement.
- [17] Proportional icon sizing.
- [18] Smooth QML animations.
- [19] No flicker.

### Completion Criteria

- The main desktop surface reaches a polished daily-usable state.
- Quick Actions are at least as stable as the frozen Python implementation.
- Layout behavior remains predictable after restart.

---

## [x] Phase 6 â€” Settings System

**Goal:** Build a professional, versioned settings architecture and polished settings UI.

### Tasks

- [1] Settings domain/schema.
- [2] Versioned settings storage.
- [3] Safe defaults.
- [4] Migration mechanism.
- [5] Corruption recovery strategy.
- [6] Separate user/shared settings from device-specific settings.
- [7] Clock settings UI.
- [8] Date settings UI.
- [9] Battery settings UI.
- [10] Layout settings UI.
- [11] Quick Actions settings UI.
- [12] Notification settings UI.
- [13] Silent mode.
- [14] Always-on-top setting.
- [15] Startup setting.
- [16] Global scale.
- [17] Per-module scale.
- [18] Live visual updates.
- [19] Reset-to-default behavior.
- [20] Import/export strategy deferred for V1.

### Completion Criteria

- All implemented modules can be configured through one coherent UI.
- Settings survive restart safely.
- UI changes apply immediately where appropriate.

---

## [x] Phase 7 â€” Todo V1

**Goal:** Rebuild the Todo module as a lightweight professional task manager.

### [x] Data and Domain

- [1] Finalize Todo V1 data model.
- [2] SQLite Todo repository.
- [3] Schema migrations.
- [4] Priority model.
- [5] Task state transitions.
- [6] Due/overdue rules.
- [7] Ordering rules.
- [8] Retention rules.
- [9] Trash/restore/permanent-delete behavior.

### [x] UI

- [10] Todo panel/page.
- [11] Task cards.
- [12] New Task dialog.
- [13] Edit Task dialog.
- [14] Description.
- [15] Date/time input.
- [16] Priority selection.
- [17] Completed state.
- [18] Overdue state.
- [19] Cancelled state.
- [20] Trash state.
- [21] Search.
- [22] Turkish-character search correctness.
- [23] Today view/filter.
- [24] Tomorrow view/filter.
- [25] Week view/filter.
- [26] Completed view/filter.
- [27] Useful empty states.
- [28] Stable scrolling and updates.
- [29] Visual customization where appropriate.

### Completion Criteria

- Todo reaches functional parity with intended Python V1 scope.
- Sorting and state transitions are covered by tests.
- UI is substantially more polished than the frozen implementation.

---

## [ ] Phase 8 â€” Reminder V1 Completion

**Goal:** Complete the major unfinished functional area inherited from the frozen Python project.

### [ ] Core

1. [x] Finalize Reminder model.
2. [x] SQLite Reminder repository.
3. [x] Reminder scheduler.
4. [x] One-time reminders.
5. [x] Daily recurrence.
6. [x] Weekly recurrence.
7. [x] Missed reminder recovery.
8. [x] Duplicate firing prevention.
9. [x] Application-restart recovery.
10. [ ] Enable/disable behavior.
11. [x] Snooze 5 minutes, 10 minutes, 60 minutes.
12. [x] Remaining-time formatting.
13. [x] Safe malformed-data handling.

### [ ] UI

14. [x] Reminder list UI.
15. [x] Add Reminder dialog.
16. [x] Edit Reminder dialog.
17. [x] Reminder cards.
18. [x] Active/completed/missed states.
19. [x] Validation.
20. [x] Non-disruptive popup behavior.

### [ ] Voice / TTS

21. [x] Define native/offline TTS strategy.
22. [x] Optional TTS.
23. [x] Voice selection.
24. [x] Spoken-text preview.
25. [x] Non-blocking execution.
26. [x] Respect silent mode.

### Completion Criteria

- Reminder V1 is complete and reliable across restarts.
- Recurrence and snooze behavior are tested.
- Reminder alerts do not duplicate unexpectedly.
- This closes the primary unfinished area from the frozen Python V1.

---

## [ ] Phase 9 — Advanced Todo Features

**Goal:** Implement highly requested professional Todo enhancements.

### Tasks

- [ ] Sub-tasks / Checklist support.
- [ ] Drag-and-drop reordering.
- [ ] Task tags/labels.
- [ ] "Project" or "Category" grouping.
- [ ] Archiving old tasks.
- [ ] Quick-add command bar.
- [ ] Todo UI Redesign: Left vertical color strip with priority text and dynamic status icon (!, hourglass, check).
- [ ] Todo UI Redesign: Custom priority colors via settings.
- [ ] Todo UI Redesign: Title and truncated description in center, with tooltip balloon for full text.
- [ ] Todo UI Redesign: "SÜRESİ GEÇTİ", "TAMAMLANDI", "İPTAL EDİLDİ", "SİLİNDİ" diagonal watermarks.
- [ ] Todo UI Redesign: Cancelled state grays out the card (50-40% black) and moves it to the bottom.
- [ ] Todo UI Redesign: Right action buttons (Edit, List, Complete/Restore, Cancel/Delete) with dynamic visibility based on task state and hover tooltips.
- [ ] Todo UI Redesign: Input fields in Edit Dialog use gray rounded border style.
- [ ] Todo UI Redesign: Subtask list input with free text formatting (1., 2., -, *) accessible via List icon.
- [ ] Quick Actions visual redesign: icons displayed horizontally above each module.
- [ ] Quick Actions icon assets: use dedicated img icons (user will provide filenames).
- [ ] Quick Actions colored/filled icon style matching reference design.

### Completion Criteria

- Todo functionality feels professional and comparable to modern standards.
- Data integrity maintained during complex transitions.
- Quick Actions icons appear above modules with the reference visual style.

---

## [ ] Phase 10 — Alarm Module

**Goal:** Finalize the Alarm capability without conflating it with Reminder.

### Tasks

- [ ] Confirm final Desktop V1 alarm scope.
- [ ] Alarm domain model.
- [ ] Alarm repository.
- [ ] Alarm scheduling.
- [ ] Daily recurrence where required.
- [ ] Alarm sounds.
- [ ] Alarm popup.
- [ ] Enable/disable behavior.
- [ ] Shared scheduler infrastructure where appropriate.
- [ ] Clear Reminder vs Alarm semantics.

### Completion Criteria

- Alarm behavior is clearly defined and reliable.
- Shared infrastructure is reused without merging product concepts.

---

## [ ] Phase 11 — Unified Notifications, Tray, and Lifecycle

**Goal:** Complete core desktop integration.

### [ ] Unified Notifications

- [ ] Notification coordinator.
- [ ] Visual notifications.
- [ ] Sound.
- [ ] TTS routing.
- [ ] Silent mode.
- [ ] Cooldown.
- [ ] Duplicate suppression.
- [ ] Battery alert integration.
- [ ] Reminder integration.
- [ ] Alarm integration.
- [ ] Optional bounded history if retained.

### [ ] System Tray

- [ ] Tray icon.
- [ ] Show/hide DeskPilot.
- [ ] New Reminder.
- [ ] New Todo.
- [ ] Settings.
- [ ] Quit.
- [ ] Useful tooltip/status.

### [ ] Lifecycle

- [ ] Single-instance behavior.
- [ ] Run at startup.
- [ ] Clean startup order.
- [ ] Clean shutdown.
- [ ] State persistence.
- [ ] Safe crash/restart recovery where practical.

### Completion Criteria

- DeskPilot behaves like a polished native desktop product.
- Alerts and tray behavior are stable.
- Startup/shutdown behavior is predictable.

---

## [ ] Phase 12 — Localization Foundation and Turkish V1 Polish

**Goal:** Finalize Turkish-first Desktop V1 while keeping future localization clean.

### Tasks

- [ ] Central localization architecture.
- [ ] Move all user-facing strings to localization resources.
- [ ] Turkish V1 text review.
- [ ] Turkish character correctness.
- [ ] Date/time locale review.
- [ ] English foundation.
- [ ] Arabic/RTL architecture check.
- [ ] No requirement for full English/Arabic V1 polish.

### Completion Criteria

- Turkish V1 is complete.
- New strings cannot accidentally bypass localization architecture.

---

## [ ] Phase 13 — UI/UX Visual Overhaul and Enrichment

**Goal:** After the core mechanics are complete, comprehensively enrich the aesthetic and visual experience of the entire application to achieve a premium, modern desktop feel.

### [ ] Design Tokens and Architecture

- [ ] Update primary color palettes (Light/Dark modes) to be modern, vibrant, and eye-friendly.
- [ ] Improve typography hierarchy (better readability, elegant font weights).
- [ ] Enhance shadow and depth perception to create realistic layering.

### [ ] Visual Effects and Modern Styling

- [ ] Implement Glassmorphism/Acrylic or blur effects for panel backgrounds (where supported by OS/Qt).
- [ ] Standardize icon sets to a consistent, sharp, and modern style.

### [ ] Component-Level Polish

- [ ] Redesign Buttons, TextFields, and CheckBoxes with modern hover and press interactions.
- [ ] Refine Task and Reminder "Card" layouts by applying golden ratio spacing (margin/padding) and corner radii.
- [ ] Implement invisible/elegant scrollbars (similar to macOS or modern Windows 11).

### [ ] Motion Design and Fluidity

- [ ] Add micro-animations (e.g., subtle scale down on button press).
- [ ] Implement smooth Fade/Scale transitions for panel visibility toggles.
- [ ] Add sliding animations for adding/removing items from lists.
- [ ] Add spring/bounce animations for Dialog appearances.

### Completion Criteria

- The application looks and feels like a premium desktop product rather than a functional prototype.
- All corners, colors, and transitions are fully cohesive across the entire application.

---

## [ ] Phase 14 — Performance, Stability, and Quality Gate

**Goal:** Prove that DeskPilotC is suitable for continuous daily desktop use.

### [ ] Performance

- [ ] Measure cold startup.
- [ ] Measure warm startup.
- [ ] Measure idle CPU.
- [ ] Measure idle memory.
- [ ] Measure long-running behavior.
- [ ] Measure animation smoothness.
- [ ] Measure scheduler overhead.
- [ ] Measure battery-service overhead.
- [ ] Measure database latency.

### [ ] Stability

- [ ] Multi-monitor tests.
- [ ] DPI/scaling tests.
- [ ] Sleep/wake tests.
- [ ] Restart tests.
- [ ] Corrupted-settings tests.
- [ ] Corrupted-record tests.
- [ ] Long-running reminder tests.
- [ ] Tray lifecycle tests.

### [ ] Quality

- [ ] Unit-test critical domain logic.
- [ ] Integration-test persistence.
- [ ] Validate migration behavior.
- [ ] Review logging.
- [ ] Review error handling.
- [ ] Review dependency licenses.
- [ ] Remove dead code.
- [ ] Remove temporary migration/debug artifacts.

### Completion Criteria

- No known critical V1 defects.
- Performance is measured and acceptable.
- Core workflows are covered by automated tests.
- Application is ready for Desktop V1 release preparation.

---

## [ ] Phase 15 — Desktop V1 Release

**Goal:** Produce the first production-ready DeskPilotC desktop release.

### Tasks

- [ ] Final V1 feature freeze.
- [ ] Final UI/UX polish.
- [ ] Packaging.
- [ ] Installer/update strategy.
- [ ] Versioning.
- [ ] Release notes.
- [ ] Clean installation test.
- [ ] Upgrade test.
- [ ] Uninstall behavior.
- [ ] User-data preservation verification.
- [ ] Final Windows compatibility test.
- [ ] Tag Desktop V1 release.

### Completion Criteria

- Desktop V1 can be installed, used, upgraded, and removed predictably.
- User data is handled safely.
- Release is tagged and reproducible.

---

# POST-V1 PRODUCT EVOLUTION

These phases must not block Desktop V1.

---

## [ ] Phase 16 — Shared Account and Sync Architecture

**Goal:** Define and implement optional multi-device synchronization.

### [ ] Major Areas

- [ ] Identity/account architecture.
- [ ] Device identity.
- [ ] Trusted devices.
- [ ] Authentication.
- [ ] API contracts.
- [ ] Sync protocol.
- [ ] Change tracking.
- [ ] Offline queue.
- [ ] Conflict resolution.
- [ ] Encryption.
- [ ] Retry strategy.
- [ ] Deletion semantics.
- [ ] Data export.
- [ ] Account/data deletion.
- [ ] Privacy controls.
- [ ] Shared vs device-specific settings rules.

### [ ] Initial Sync Domains

- [ ] Todo.
- [ ] Reminder.
- [ ] Relevant alarm state if appropriate.
- [ ] Shared preferences.
- [ ] Notification state where appropriate.

---

## [ ] Phase 17 — Mobile Client

**Current reference candidate:** Flutter + Dart.

### [ ] Goals

- [ ] Android client.
- [ ] iOS client when test/deployment capability is available.
- [ ] Shared account.
- [ ] Offline-first local cache.
- [ ] Todo synchronization.
- [ ] Reminder synchronization.
- [ ] Mobile-native alert actions.
- [ ] Snooze/complete/dismiss.
- [ ] Shared Design Tokens where practical.
- [ ] Best mobile UX rather than desktop UI duplication.

---

## [ ] Phase 16 â€” Web Client

**Current reference candidate:** TypeScript + React + Next.js.

### [ ] Goals

- [ ] Web authentication.
- [ ] Todo access.
- [ ] Reminder access.
- [ ] Shared synchronized state.
- [ ] Responsive UI.
- [ ] PWA evaluation.
- [ ] iOS/web fallback role evaluation.
- [ ] Shared Design Tokens where practical.
- [ ] Best web UX rather than desktop UI duplication.

---

## [ ] Phase 17 â€” Cross-Platform Product Maturity

**Goal:** Evolve DeskPilot into a coherent multi-device ecosystem.

Potential areas:

- [ ] Cross-device notification routing.
- [ ] Device management.
- [ ] Sync diagnostics.
- [ ] Backup/restore.
- [ ] Export/import.
- [ ] Advanced privacy controls.
- [ ] Mature English localization.
- [ ] Mature Arabic/RTL localization.
- [ ] macOS desktop client.
- [ ] Linux desktop client.
- [ ] Product-wide performance and security audits.

---

# CURRENT POSITION

**Current phase:** Phase 8 — Reminder V1 Completion

**Completed so far:**

- Python DeskPilot frozen.
- New `D_DeskPilotC` repository created.
- GitHub remote connected.
- General architecture principles added.
- DeskPilot product specification added.
- DeskPilotC architecture document added.
- Master roadmap created.
- Phase 4 platform-independent battery abstraction verified by `BatteryModelTest`.
- Phase 4 Windows battery implementation verified by `WindowsBatteryServiceTest`.
- Phase 4 battery percentage/status verified by `BatteryModelTest` and Debug build.
- Phase 4 independent scaling and free-layout integration verified by `BatteryModelTest` and Debug build.
- Phase 4 grouped-layout integration verified by Debug build and CTest.
- Phase 4 charging/plugged-in detection verified by deterministic Windows battery-state tests.
- Persistent layout mode, module positions, and battery appearance settings verified by INI round-trip.
- Phase 4 efficient 30-second coarse polling and unchanged-state suppression verified by Debug build and CTest.
- Phase 5 final grouped-layout startup preserves saved grouped positions and only centers when no positions exist.
- Phase 5 final free-layout startup reapplies saved positions after loader creation and layout-mode changes.
- Phase 5 independent Clock/Date/Battery positioning verified through separate free-layout loaders, drag areas, and persisted keys.
- Phase 5 layout lock state disables grouped/free dragging and persists through the layout settings.
- Phase 5 configurable inter-module spacing is applied to grouped centering and free-layout defaults and persists through layout settings.
- Phase 5 grouped scaling preserves group centering/spacing while free scaling preserves each module's independent position.
- Phase 5 saved grouped positions are clamped to the active window bounds for monitor/geometry changes.
- Phase 5 contextual Quick Actions component provides delayed hover hiding and Settings/Reminder/Todo action signals.
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
- Phase 7 Todo panel/page, reusable task cards, and New Task dialog added and build-verified.
- Phase 7 Edit Task dialog added and build-verified.
- Phase 7 Description support added and build-verified.
- Phase 7 Date/time input added and build-verified.
- Phase 7 Priority selection added and build-verified.
- Phase 7 Completed state added and build-verified.
- Phase 7 Overdue state added and build-verified.
- Phase 7 Cancelled state added and build-verified.
- Phase 7 Trash state added and build-verified.
- Phase 7 Search added and build-verified.
- Phase 7 Turkish-character search correctness added and build-verified.
- Phase 7 Today view/filter added and build-verified.
- Phase 7 Tomorrow view/filter added and build-verified.
- Phase 7 Week view/filter added and build-verified.
- Phase 7 Completed view/filter added and build-verified.
- Phase 7 Useful empty states added and build-verified.
- Phase 7 Stable scrolling and updates added and build-verified.
- Phase 7 Visual customization added and build-verified.
- Phase 8 Reminder model finalized and verified with tests.
- Phase 8 SQLite Reminder repository finalized and verified with tests.
- Phase 8 Reminder scheduler created and verified with tests.
- Phase 8 One-time reminders implemented and verified with tests.

- Phase 8 Daily recurrence implemented and verified with tests.

- Phase 8 Weekly recurrence implemented and verified with tests.

**Immediate next step:**

1. Missed reminder recovery.

