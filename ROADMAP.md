# DESKPILOTC ROADMAP

<!-- AI NOTE: This roadmap is structured for automated AI processing. Each phase should be checked sequentially, marking status symbols (✅, 🔍, ⚠️, ✏️, ❌) after verification. -->

## Status Legend

- `[x]` Completed
- `[~]` In progress
- `[ ]` Not started
- `[!]` Blocked / requires decision

---

# MASTER ROADMAP

## [x] Phase 0 — Flutter Project Foundation

**Goal:** Initialize the new DeskPilotF Flutter project on a clean foundation.

### Tasks

- [x] C++/Qt codebase removed from repository
- [x] Git remote updated to https://github.com/mskaymaz/D_DeskPilotF
- [ ] Flutter project initialized (`flutter create .`)
- [ ] `pubspec.yaml` configured with core dependencies
- [ ] Window manager, tray manager, riverpod, drift configured
- [ ] Minimal `lib/main.dart` with transparent window
- [ ] Windows embedding configured and verified
- [ ] `flutter run` verified
- [ ] Commit and push verified project foundation

### Completion Criteria

- Project builds successfully from clean checkout
- A transparent Flutter window launches
- Core architecture structure exists

---

## [x] Phase 1 — Design System and Desktop Window Foundation

**Goal:** Establish design tokens, localization infrastructure, and window foundation.

### Design System

- [x] Color tokens (light/dark) — `lib/core/design_tokens/colors.dart`
- [x] Typography tokens — `lib/core/design_tokens/typography.dart`
- [x] Spacing tokens — `lib/core/design_tokens/spacing.dart`
- [x] Radius tokens — `lib/core/design_tokens/radius.dart`
- [x] Sizing tokens — `lib/core/design_tokens/sizing.dart`
- [x] Z-layer tokens — `lib/core/design_tokens/z_layers.dart`
- [x] Motion/animation tokens — `lib/core/design_tokens/motion.dart`
- [x] Global scaling (75%–150%)
- [x] High-DPI strategy
- [x] Reusable base widgets
- [x] Localization infrastructure (TR/EN)

### Window Foundation

- [ ] Frameless transparent desktop window
- [ ] Always-on-top
- [ ] Drag behavior
- [ ] Position persistence
- [ ] Multi-monitor detection
- [ ] Grouped/free layout foundation
- [ ] Stable focus/show/hide lifecycle

### Completion Criteria

- Desktop shell is visually clean and stable
- Windows can be positioned and restored safely
- Core visual tokens are centralized

---

## [x] Phase 2 — Clock Module

**Goal:** Rebuild the primary DeskPilot clock experience with premium visual quality.

### Tasks

- [x] Clock domain model (ClockSettings, ClockState, ClockFormat, ClockFontFamily)
- [x] Time service (Timer-based IClockService implementation)
- [x] 24-hour/12-hour format
- [x] Optional seconds
- [x] Independent seconds scaling
- [x] Embedded fonts (Digital-7, Stencil, Technology, DS-Digital)
- [x] Font selection, color, bold
- [x] Independent clock scaling
- [x] Stable rendering
- [x] Grouped and free layout integration
- [x] Persistent clock settings
- [x] ClockProvider + ClockNotifier (Riverpod)
- [x] ClockWindow UI
- [x] ProviderScope integration

### Completion Criteria

- Clock displays live time in transparent window
- All settings persist correctly

---

## [x] Phase 3 — Date Module

**Goal:** Implement complete Turkish-first date experience with Gregorian + Hijri display.

### Tasks

- [x] Date service — IDateService interface + Timer-based implementation
- [x] Gregorian date (dotted, slash, ISO formats)
- [x] Hijri date (intl ar_SA locale)
- [x] Combined display
- [x] Date ordering options (Gregorian-first/Hijri-first)
- [x] Format choices
- [x] Optional week number
- [x] Font, color, bold settings
- [x] Date visibility and scaling
- [x] Persistent settings (DateSettings model)
- [x] DateWindow UI
- [x] Turkish locale correctness

### Completion Criteria

- Gregorian/Hijri presentation correct
- All settings persist correctly

---

## [x] Phase 4 — Battery Module

**Goal:** Implement efficient battery status and alert foundations.

### Tasks

- [x] Platform-independent battery abstraction (IBatteryService)
- [x] Windows battery implementation (WMI with -NoProfile)
- [x] Percentage/status display
- [x] Charging/plugged-in detection
- [x] Battery icon (lightning SVG, right side)
- [x] Font/color/bold settings
- [x] Independent scaling
- [x] Low-battery and full-charge thresholds
- [x] Alert interval and sound
- [x] Silent mode
- [x] Efficient 30-second polling
- [x] Grouped and free layout integration

### Completion Criteria

- Battery module works without excessive CPU usage
- Alerts ready for unified notification system

---

## [ ] Phase 5 — Layout System and Quick Actions

### Completion Criteria

- Battery module works without excessive CPU usage
- Alerts ready for unified notification system

---

## [ ] Phase 5 — Layout System and Quick Actions

**Goal:** Complete the primary DeskPilot desktop interaction model.

### Layout

- [ ] Final grouped-layout behavior
- [ ] Final free-layout behavior
- [ ] Independent positioning
- [ ] Position persistence
- [ ] Lock/unlock
- [ ] Inter-module spacing
- [ ] Scale interactions
- [ ] Multi-monitor verification

### Quick Actions

- [ ] Contextual Quick Actions component
- [ ] Settings, Reminder, Todo actions
- [ ] Content-aware positioning
- [ ] Stable hover transition with bridge zone
- [ ] Delayed hide (250ms)
- [ ] Movement suppression
- [ ] Independent icon sizing
- [ ] Smooth animations
- [ ] No flicker

### Completion Criteria

- Main desktop surface reaches polished daily-usable state
- Layout behavior predictable after restart

---

## [ ] Phase 6 — Settings System

**Goal:** Build a professional, versioned settings architecture and polished settings UI.

### Tasks

- [ ] Settings domain/schema (typed snapshot)
- [ ] Versioned settings storage (schema version)
- [ ] Safe defaults and bounded values
- [ ] Migration mechanism
- [ ] Corruption recovery
- [ ] Separate user/shared vs device-specific settings
- [ ] Clock, Date, Battery settings UI
- [ ] Layout settings UI
- [ ] Quick Actions settings UI
- [ ] Notification settings UI
- [ ] Silent mode, always-on-top, startup
- [ ] Global and per-module scale
- [ ] Live visual updates
- [ ] Reset-to-default

### Completion Criteria

- All modules configurable through one coherent UI
- Settings survive restart safely

---

## [ ] Phase 7 — Todo V1

**Goal:** Build the Todo module as a lightweight professional task manager with Flutter.

### Data and Domain

- [ ] Todo data model (UUID, title, description, priority, state, timestamps, subtasks, tags)
- [ ] drift SQLite repository
- [ ] Schema migrations
- [ ] Priority model
- [ ] State transitions
- [ ] Due/overdue rules
- [ ] Ordering rules
- [ ] Retention policy
- [ ] Trash/restore/permanent-delete

### UI

- [ ] Todo panel/page
- [ ] Task cards (priority color strip, status watermark)
- [ ] New Task dialog
- [ ] Edit Task dialog
- [ ] Description, date/time, priority
- [ ] Search with Turkish normalization
- [ ] Today/Tomorrow/Week/Completed filters
- [ ] Empty states
- [ ] Stable scrolling
- [ ] Visual customization
- [ ] Subtask/checklist support

### Completion Criteria

- Todo reaches functional parity
- Sorting and state transitions tested
- UI polished and professional

---

## [ ] Phase 8 — Reminder V1 Completion

**Goal:** Complete the primary unfinished functional area with Flutter.

### Core

- [ ] Reminder model and repository
- [ ] Scheduler (Dart Timer-based)
- [ ] One-time, daily, weekly recurrence
- [ ] Missed recovery, duplicate prevention
- [ ] Snooze (5/10/60 min)
- [ ] Remaining-time formatting (Turkish)
- [ ] Malformed-data handling
- [ ] Application-restart recovery

### UI

- [ ] Reminder list, add/edit dialog
- [ ] Reminder cards
- [ ] Active/completed/missed states
- [ ] Validation
- [ ] Non-disruptive popup

### TTS

- [ ] Native TTS (flutter_tts)
- [ ] Voice selection, spoken-text preview
- [ ] Non-blocking execution
- [ ] Silent mode respect

### Completion Criteria

- Reminder V1 complete and reliable across restarts
- Recurrence and snooze tested
- No duplicate notifications

---

## [ ] Phase 9 — Advanced Todo Features & UI Redesign

- [ ] Drag-and-drop reordering
- [ ] Task tags/labels, project grouping
- [ ] Archiving, quick-add command bar
- [ ] UI redesign: left color strip, status icons, watermarks
- [ ] Cancelled state grays out and moves to bottom
- [ ] Action buttons with hover tooltips
- [ ] Subtask list input with free formatting
- [ ] Quick Actions visual redesign
- [ ] Icon assets

### Completion Criteria

- Professional, modern Todo experience
- Data integrity maintained

---

## [ ] Phase 10 — Alarm Module

- [ ] Alarm domain model, repository, scheduler
- [ ] Daily recurrence
- [ ] Alarm sounds, popup
- [ ] Enable/disable
- [ ] Reminder vs Alarm semantics

---

## [ ] Phase 11 — Unified Notifications, Tray, and Lifecycle

- [ ] Notification coordinator
- [ ] Visual notifications, sound, TTS routing
- [ ] Silent mode, cooldown, duplicate suppression
- [ ] System tray integration
- [ ] Show/hide, new Reminder/Todo/Settings actions
- [ ] Single-instance, startup registration
- [ ] Clean shutdown and state persistence

---

## [ ] Phase 12 — Localization Foundation

- [ ] Central localization architecture (flutter_localizations + intl)
- [ ] All strings in translation resources
- [ ] Turkish V1 review
- [ ] English foundation
- [ ] Arabic/RTL architecture check

---

## [ ] Phase 13 — UI/UX Visual Overhaul

- [ ] Modern color palettes (light/dark modes)
- [ ] Enhanced typography hierarchy
- [ ] Glassmorphism/Acrylic effects
- [ ] Component polish (buttons, textfields, checkboxes)
- [ ] Golden ratio spacing
- [ ] Elegant scrollbars
- [ ] Micro-animations and transitions
- [ ] Spring/bounce animations

### Completion Criteria

- Application looks like a premium desktop product

---

## [ ] Phase 14 — Performance, Stability, Quality Gate

- [ ] Startup, idle CPU/memory benchmarks
- [ ] Multi-monitor, DPI, sleep/wake tests
- [ ] Corrupted settings/record tests
- [ ] Unit and integration tests
- [ ] License review, dead code removal

### Completion Criteria

- No known critical V1 defects
- Core workflows covered by automated tests

---

## [ ] Phase 15 — Desktop V1 Release

- [ ] Feature freeze, final polish
- [ ] Packaging, installer
- [ ] Versioning, release notes
- [ ] Clean install test, upgrade test
- [ ] Desktop V1 tagged

### Completion Criteria

- Desktop V1 can be installed, used, upgraded, and removed predictably

---

# POST-V1 PRODUCT EVOLUTION

These phases must not block Desktop V1.

## Phase 16 — Shared Account and Sync Architecture
- [ ] Identity/account, device identity
- [ ] Authentication, API contracts
- [ ] Sync protocol, conflict resolution
- [ ] Encryption, offline queue
- [ ] Sync domains: Todo, Reminder, preferences

## Phase 17 — Mobile Client
- **Reference:** Flutter/Dart (same codebase!)
- [ ] Android, iOS
- [ ] Offline-first local cache
- [ ] Todo and Reminder sync
- [ ] Mobile-native alert actions

## Phase 18 — Web Client
- **Reference:** Flutter/Dart web (same codebase!)
- [ ] Web authentication, Todo/Reminder access
- [ ] Responsive UI, PWA evaluation

## Phase 19 — Cross-Platform Product Maturity
- [ ] Cross-device notification routing
- [ ] macOS/Linux desktop clients
- [ ] Performance and security audits

---

# CURRENT POSITION

**Current phase:** Phase 4 — Battery Module ✅ COMPLETE

**Completed so far:**
- C++/Qt codebase removed
- Git remote updated to https://github.com/mskaymaz/D_DeskPilotF
- Flutter project structure created
- pubspec.yaml configured with window_manager, flutter_localizations, intl, riverpod, flutter_riverpod, flutter_svg
- lib/main.dart with ProviderScope, design tokens, localization, Clock + Date + Battery
- Design tokens created (colors, typography, spacing, radius, sizing, z_layers, motion)
- Localization infrastructure (TR/EN)
- Clock Module: IClockService, Timer-based, ClockNotifier, ClockWindow
- Date Module: IDateService, Timer-based, DateNotifier, DateWindow (Gregorian + Hijri)
- Battery Module: IBatteryService, WMI-based implementation, BatteryNotifier, BatteryWindow (SVG lightning icon)
- lightning_icon.svg in assets/images/
- flutter_build windows --debug produces working desk_pilot_f.exe
- Clock + Date + Battery displayed in transparent window
- WMI battery percentage working with -NoProfile
- Note: INSTALL.vcxproj fails — manually copy build\flutter_assets\* to build\windows\x64\runner\Debug\data\ after build

**Immediate next step:**
1. Run `flutter create .` to initialize Flutter embedding
2. Run `flutter pub get`
3. Verify `flutter run` launches transparent window
