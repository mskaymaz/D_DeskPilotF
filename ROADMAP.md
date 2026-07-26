# DESKPILOTC ROADMAP

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

- [x] Freeze the Python DeskPilot reference repository.
- [x] Create `deskpilot-python-freeze` Git tag.
- [x] Create new private `D_DeskPilotC` GitHub repository.
- [x] Initialize local `D_DeskPilotC` Git repository.
- [x] Connect local repository to GitHub remote.
- [x] Add `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`.
- [x] Create and add `DESKPILOT_PRODUCT_SPEC.md`.
- [x] Create and add `ARCHITECTURE.md`.
- [x] Create `ROADMAP.md`.
- [x] Create `TASK.md`.
- [x] Create `STATE.md`.
- [x] Create initial `README.md`.
- [x] Define Qt licensing strategy for Desktop V1.
- [x] Verify required development toolchain.
- [x] Create initial repository structure.
- [x] Create initial `.gitignore`.
- [x] Create root `CMakeLists.txt`.
- [x] Create minimal Qt 6 / Qt Quick / QML application.
- [x] Confirm clean configure/build/run cycle.
- [x] Commit and push the verified project foundation.

### Completion Criteria

Phase 0 is complete when:

- The project builds successfully from a clean checkout.
- A minimal Qt Quick window/application launches.
- Core architecture documents are present.
- Development toolchain is documented and verified.
- Repository is clean and pushed to GitHub.

---

## [x] Phase 1 â€” Design System and Desktop Window Foundation

**Goal:** Build the visual and native window foundation before implementing product modules.

### Design System

- [x] Define color tokens.
- [x] Define typography tokens.
- [x] Define spacing tokens.
- [x] Define radius tokens.
- [x] Define sizing tokens.
- [x] Define z-layer tokens.
- [x] Define motion/animation tokens.
- [x] Establish high-DPI strategy.
- [x] Establish global scaling architecture.
- [x] Create reusable base QML components.

### Window Foundation

- [x] Frameless desktop window.
- [x] Transparent background/window support.
- [x] Stable drag behavior.
- [x] Always-on-top support.
- [x] Window position persistence.
- [x] Multi-monitor detection.
- [x] Safe recovery from unavailable monitors.
- [x] Grouped-layout foundation.
- [x] Free-layout foundation.
- [x] Reusable independent module-window behavior.
- [x] Stable focus/show/hide lifecycle.
- [x] Verify idle resource behavior.

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

## [~] Phase 4 â€” Battery Module

**Goal:** Implement efficient battery status and alert foundations.

### Tasks

- [x] Platform-independent battery abstraction.
- [x] Windows battery implementation.
- [x] Battery percentage/status.
- [ ] Charging/plugged-in detection.
- [ ] Optional battery icon.
- [ ] Battery visibility.
- [ ] Font/color/bold settings.
- [x] Independent scaling.
- [ ] Low-battery threshold.
- [ ] Full-charge threshold.
- [ ] Alert interval.
- [ ] Alert sound configuration.
- [ ] Respect silent mode.
- [ ] Safe no-battery behavior.
- [x] Grouped-layout integration.
- [x] Free-layout integration.
- [ ] Efficient polling/event strategy.

### Completion Criteria

- Battery module works without excessive CPU/polling.
- Alerts are ready to integrate with unified notifications.
- Desktop behavior is stable on battery and non-battery systems.

---

## [ ] Phase 5 â€” Layout System and Quick Actions

**Goal:** Complete the primary DeskPilot desktop interaction model.

### Layout

- [ ] Final grouped-layout behavior.
- [ ] Final free-layout behavior.
- [ ] Independent Clock/Date/Battery positioning.
- [ ] Position persistence.
- [ ] Lock/unlock behavior where required.
- [ ] Inter-module spacing.
- [ ] Scale interactions.
- [ ] Multi-monitor verification.

### Quick Actions

- [ ] Contextual Quick Actions component.
- [ ] Settings action.
- [ ] Reminder action.
- [ ] Todo action.
- [ ] Content-aware positioning.
- [ ] Stable hover transition.
- [ ] Delayed hide behavior.
- [ ] Correct behavior during window movement.
- [ ] Proportional icon sizing.
- [ ] Smooth QML animations.
- [ ] No flicker.

### Completion Criteria

- The main desktop surface reaches a polished daily-usable state.
- Quick Actions are at least as stable as the frozen Python implementation.
- Layout behavior remains predictable after restart.

---

## [ ] Phase 6 â€” Settings System

**Goal:** Build a professional, versioned settings architecture and polished settings UI.

### Tasks

- [ ] Settings domain/schema.
- [ ] Versioned settings storage.
- [ ] Safe defaults.
- [ ] Migration mechanism.
- [ ] Corruption recovery strategy.
- [ ] Separate user/shared settings from device-specific settings.
- [ ] Clock settings UI.
- [ ] Date settings UI.
- [ ] Battery settings UI.
- [ ] Layout settings UI.
- [ ] Quick Actions settings UI.
- [ ] Notification settings UI.
- [ ] Silent mode.
- [ ] Always-on-top setting.
- [ ] Startup setting.
- [ ] Global scale.
- [ ] Per-module scale.
- [ ] Live visual updates.
- [ ] Reset-to-default behavior.
- [ ] Import/export strategy if included in V1.

### Completion Criteria

- All implemented modules can be configured through one coherent UI.
- Settings survive restart safely.
- UI changes apply immediately where appropriate.

---

## [ ] Phase 7 â€” Todo V1

**Goal:** Rebuild the Todo module as a lightweight professional task manager.

### Data and Domain

- [ ] Finalize Todo V1 data model.
- [ ] SQLite Todo repository.
- [ ] Schema migrations.
- [ ] Priority model.
- [ ] Task state transitions.
- [ ] Due/overdue rules.
- [ ] Ordering rules.
- [ ] Retention rules.
- [ ] Trash/restore/permanent-delete behavior.

### UI

- [ ] Todo panel/page.
- [ ] Task cards.
- [ ] New Task dialog.
- [ ] Edit Task dialog.
- [ ] Description.
- [ ] Date/time input.
- [ ] Priority selection.
- [ ] Completed state.
- [ ] Overdue state.
- [ ] Cancelled state.
- [ ] Trash state.
- [ ] Search.
- [ ] Turkish-character search correctness.
- [ ] Today view/filter.
- [ ] Tomorrow view/filter.
- [ ] Week view/filter.
- [ ] Completed view/filter.
- [ ] Useful empty states.
- [ ] Stable scrolling and updates.
- [ ] Visual customization where appropriate.

### Completion Criteria

- Todo reaches functional parity with intended Python V1 scope.
- Sorting and state transitions are covered by tests.
- UI is substantially more polished than the frozen implementation.

---

## [ ] Phase 8 â€” Reminder V1 Completion

**Goal:** Complete the major unfinished functional area inherited from the frozen Python project.

### Core

- [ ] Finalize Reminder model.
- [ ] SQLite Reminder repository.
- [ ] Reminder scheduler.
- [ ] One-time reminders.
- [ ] Daily recurrence.
- [ ] Weekly recurrence.
- [ ] Missed reminder recovery.
- [ ] Duplicate firing prevention.
- [ ] Application-restart recovery.
- [ ] Enable/disable behavior.
- [ ] Snooze 5 minutes.
- [ ] Snooze 10 minutes.
- [ ] Snooze 60 minutes.
- [ ] Remaining-time formatting.
- [ ] `ZamanÄ± geldi` state.
- [ ] Safe malformed-data handling.

### UI

- [ ] Reminder list.
- [ ] Add Reminder dialog.
- [ ] Edit Reminder dialog.
- [ ] Reminder cards.
- [ ] Active/completed/missed states.
- [ ] Reminder popup.
- [ ] Validation.
- [ ] Non-disruptive popup behavior.

### Voice / TTS

- [ ] Define native/offline TTS strategy.
- [ ] Optional TTS.
- [ ] Voice selection.
- [ ] Spoken-text preview.
- [ ] Non-blocking execution.
- [ ] Safe fallback.
- [ ] Respect silent mode.

### Completion Criteria

- Reminder V1 is complete and reliable across restarts.
- Recurrence and snooze behavior are tested.
- Reminder alerts do not duplicate unexpectedly.
- This closes the primary unfinished area from the frozen Python V1.

---

## [ ] Phase 9 â€” Alarm Module

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

## [ ] Phase 10 â€” Unified Notifications, Tray, and Lifecycle

**Goal:** Complete core desktop integration.

### Unified Notifications

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

### System Tray

- [ ] Tray icon.
- [ ] Show/hide DeskPilot.
- [ ] New Reminder.
- [ ] New Todo.
- [ ] Settings.
- [ ] Quit.
- [ ] Useful tooltip/status.

### Lifecycle

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

## [ ] Phase 11 â€” Localization Foundation and Turkish V1 Polish

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

## [ ] Phase 12 â€” Performance, Stability, and Quality Gate

**Goal:** Prove that DeskPilotC is suitable for continuous daily desktop use.

### Performance

- [ ] Measure cold startup.
- [ ] Measure warm startup.
- [ ] Measure idle CPU.
- [ ] Measure idle memory.
- [ ] Measure long-running behavior.
- [ ] Measure animation smoothness.
- [ ] Measure scheduler overhead.
- [ ] Measure battery-service overhead.
- [ ] Measure database latency.

### Stability

- [ ] Multi-monitor tests.
- [ ] DPI/scaling tests.
- [ ] Sleep/wake tests.
- [ ] Restart tests.
- [ ] Corrupted-settings tests.
- [ ] Corrupted-record tests.
- [ ] Long-running reminder tests.
- [ ] Tray lifecycle tests.

### Quality

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

## [ ] Phase 13 â€” Desktop V1 Release

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

## [ ] Phase 14 â€” Shared Account and Sync Architecture

**Goal:** Define and implement optional multi-device synchronization.

### Major Areas

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

### Initial Sync Domains

- [ ] Todo.
- [ ] Reminder.
- [ ] Relevant alarm state if appropriate.
- [ ] Shared preferences.
- [ ] Notification state where appropriate.

---

## [ ] Phase 15 â€” Mobile Client

**Current reference candidate:** Flutter + Dart.

### Goals

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

### Goals

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

**Current phase:** Phase 4 â€” Battery Module (percentage/status, independent scaling, grouped, and free-layout integration complete)

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

**Immediate next step:**

1. Implement and verify charging/plugged-in detection.

