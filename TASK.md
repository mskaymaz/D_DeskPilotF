# DESKPILOTC TASK

## Status Legend
- `[x]` Completed
- `[~]` In progress
- `[ ]` Not started
- `[!]` Blocked / decision required

## AI Execution Protocol

**Bismillah**: Before modifying any file, the AI must read the `<!-- BISMILLAH CHECKPOINT: ... -->` marker in `STATE.md` (or `TASK.md`) to know the last completed step. The marker contains the phase, task number, and a short description.

**Eko Tek Madde**: When the user invokes **Eko** (or **Eko Tek Madde**), the AI must focus on a single pending item, apply the smallest possible fix, and stop. If additional files are required, the AI must request explicit permission; otherwise it finishes after the single change.

The marker format is:
```html
<!-- BISMILLAH CHECKPOINT: Phase X – Task Y – <short description> -->
```

## Current Phase: Phase 8 - Reminder V1 Completion (IN PROGRESS)

## Active Tasks
1. [x] Missed reminder recovery.
2. [x] Duplicate firing prevention.
3. [x] Application-restart recovery.
4. [ ] Enable/disable behavior.
5. [x] Snooze 5 minutes, 10 minutes, 60 minutes.
6. [x] Remaining-time formatting.
7. [x] Safe malformed-data handling.
8. [x] Reminder list UI.
9. [x] Add Reminder dialog.
10. [x] Edit Reminder dialog.
11. [x] Reminder cards.
12. [x] Active/completed/missed states.
13. [x] Validation.
14. [x] Non-disruptive popup behavior.
15. [x] Define native/offline TTS strategy.
16. [x] Optional TTS.
17. [x] Voice selection.
18. [x] Spoken-text preview.
19. [x] Non-blocking execution.
20. [x] Respect silent mode.

## Completed Tasks (Phase 8 Fixes & UI Foundations)
- [x] Final grouped-layout behavior.
- [x] Final free-layout behavior.
- [x] Independent Clock/Date/Battery positioning.
- [x] Position persistence.
- [x] Lock/unlock behavior where required.
- [x] Inter-module spacing.
- [x] Scale interactions.
- [x] Multi-monitor verification.
- [x] Contextual Quick Actions component.
- [x] Settings action.
- [x] Reminder action.
- [x] Todo action.
- [x] Content-aware positioning.
- [x] Stable hover transition.
- [x] Delayed hide behavior.
- [x] Correct behavior during window movement.
- [x] Proportional icon sizing.
- [x] Smooth QML animations.
- [x] No flicker.
- [x] Settings domain/schema.
- [x] Versioned settings storage.
- [x] Safe defaults.
- [x] Migration mechanism.
- [x] Corruption recovery strategy.
- [x] Separate user/shared settings from device-specific settings.
- [x] Clock settings UI.
- [x] Date settings UI.
- [x] Battery settings UI.
- [x] Layout settings UI.
- [x] Quick Actions settings UI.
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
- [x] Verify Git working tree.
- [x] Commit and push verified Phase 0 foundation.
- [x] Mark Phase 0 complete in `ROADMAP.md`.
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
- [x] Create `ReminderPopup.qml` UI component for displaying active reminders.
- [x] Ensure 30-second dismiss logic and Qt TextToSpeech triggers.
- [x] Fix layout constraints, scaling boundaries, and crashing bugs related to auto-hide timers and window settings.
- [x] Free-layout integration.
- [1] Platform-independent battery abstraction.
- [2] Windows battery implementation.
- [3] Battery percentage/status presentation.
- [4] Charging/plugged-in detection.
- [5] Optional battery icon.
- [6] Battery visibility.
- [7] Battery font/color/bold settings.
- [8] Independent battery scaling.
- [9] Low-battery threshold.
- [10] Full-charge threshold.
- [11] Alert interval.
- [12] Alert sound configuration.
- [13] Respect silent mode.
- [14] Safe no-battery behavior.
- [15] Grouped-layout integration.
- [16] Free-layout integration.
- [17] Efficient polling/event strategy.
- [x] Turkish locale correctness.
- [x] Persistent settings.
- [x] Persistent clock settings.
- [~] Stable module settings persistence across close/reopen remains incomplete.
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

## Phase 7 — Todo V1
- [10*] Todo panel/page.
- [11*] Task cards.
- [12*] New Task dialog.
- [13*] Edit Task dialog.
- [14*] Description.
- [15*] Date/time input.
- [16*] Priority selection.
- [17*] Completed state.
- [18*] Overdue state.
- [19*] Cancelled state.
- [20*] Trash state.
- [21*] Search.
- [22*] Turkish-character search correctness.
- [23*] Today view/filter.
- [24*] Tomorrow view/filter.
- [25*] Week view/filter.
- [26*] Completed view/filter.
- [27*] Useful empty states.
- [28*] Stable scrolling and updates.
- [29*] Visual customization where appropriate.
- [30*] TodoModel–SQLite–QML integration.

## Phase 9 — Advanced Todo Features & UI Redesign
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

## Multi-Window UI Architecture Refactor
- [x] Clean up `task.md` status.
- [x] Refactor `ModuleWindow.qml` to be a standalone `Qt.Tool` frameless window with native dragging and position saving (Created `WidgetWindow.qml`).
- [x] Convert `QuickActions.qml` to a `ModuleWindow` (Deferred: QuickActions will be embedded into headers in Phase 9 redesign).
- [x] Convert `ReminderPanel.qml` to a `WidgetWindow`.
- [x] Convert `TodoPanel.qml` to a `WidgetWindow`.
- [x] Convert settings popups to standard QML `Window` or `Dialog` objects (Left as popups in Main.qml).
- [x] Refactor `Main.qml` to act as an invisible controller.
- [x] Remove `InputMaskHelper` and layout managers (`GroupedLayout.qml`, `FreeLayout.qml`) usage.

## Phase 9 - Advanced Todo Features & UI Redesign
- [ ] Todo ve Hatırlatıcı panellerinde sol renkli şerit ve öncelik ikonlarını tasarla.
- [ ] Todo ve Hatırlatıcı panellerinde başlık, açıklama metni için karakter sınırları ve popup balon okuma yapısını tasarla.
- [ ] Tarih/saat bölümü görsel düzenlemeleri (sağ taraf).
- [ ] Dinamik aksiyon butonları (Düzenle, Liste/Ayrıntı, Tamamlandı, İptal).
- [ ] İptal edilen görevlerin (%50 gri, 'İPTAL EDİLDİ' damgası) en alta taşınması.
- [ ] Ayrıntılı liste (subtasks) ekleme UI kutusu ve metin girişi.
- [ ] Yeni görev/düzenle penceresindeki input alanlarını gri köşeleri yuvarlatılmış (rounded) şekilde yeniden tasarla.

## Next Immediate Task
Wait for user to verify the Multi-Window UI refactor.


