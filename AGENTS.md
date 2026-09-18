# DESKPILOTC AI AGENT WORKING PROTOCOL

## HARD RULES — BISMILLAH + EKO + EKO TEK MADDE + SPP

These rules are mandatory for every AI engineering agent working on this repository.

### 1. Bismillah — Verify Before Action
Before changing anything, verify the exact current state relevant to the requested task. Never guess file contents, architecture, implementation state, or patch locations.

### 2. Eko — Token and Interaction Economy
Use the minimum tokens, commands, searches, file reads, explanations, and outputs required to complete the task safely. Do not repeat known information. Keep responses minimal unless the user explicitly requests detail.

### 3. Eko Tek Madde — Strict Scope Lock
**Execute only the explicitly requested scope; do not scan unrelated files, do not broaden the search/changes, and keep responses minimal (one-line status unless asked).**

One requested item means one focused task. Do not add secondary improvements, cleanup, refactoring, optimization, or investigation unless explicitly requested.

### 4. One Step at a Time
For dependent operations, provide or execute only one step at a time. Verify its result before continuing. If a step fails, stop immediately and resolve that failure first.

### 5. No Scope Expansion
Do not inspect, search, analyze, or modify unrelated files or modules. Start with the narrowest possible target and expand only when technically necessary to complete the explicit request.

### 6. No Opportunistic Refactoring
Never refactor unrelated code because it appears improvable while working on another task. Refactoring requires an explicit need or explicit user request.

### 7. SPP — SafePatch Protocol
Use this sequence:
**Analyze requested scope → Verify exact target → Apply smallest safe change → Verify result → Stop and report briefly.**

### 8. Minimal Patch
Prefer the smallest focused change that safely satisfies the requirement. Preserve existing behavior outside the requested scope.

### 9. Fail Fast
At the first meaningful error or unexpected result, stop. Do not continue with dependent commands or patches.

### 10. Commands
Keep commands compact and easy to copy. For dependent operations, give one command/block and wait for its output before giving the next.

### 11. Flutter Reference
The Flutter/Dart DeskPilot is the active implementation. The removed C++/Qt implementation is historical reference only. Do not mechanically port Python/PyQt code or legacy workarounds into DeskPilotF.

### 12. No Image Generation
Do not use image generation or image editing tools for DeskPilotF development.

### 13. Communication
Communicate with the user in Turkish unless explicitly requested otherwise. Default status responses should be one line.

### 14. User-Executed Commands for Builds and Tests
**CRITICAL AND MANDATORY:** For ANY builds, tests, or extensive local analyses, DO NOT RUN the commands in the background yourself. You MUST provide the exact PowerShell (PS) commands to the user. The user will execute them locally and paste the output/results back into the chat. You MUST STOP and wait for the user's report before proceeding. Any deviation from this rule is strictly prohibited.

### 15. Strict File Size Limit (Modularity)
**CRITICAL AND MANDATORY:** No source code file shall normally exceed 400-450 lines. In cases of absolute technical necessity, the maximum hard limit is 700 lines. When a file approaches these limits, it MUST be refactored and split into smaller, single-responsibility components or modules. Do not create "God Objects".

### 16. Global Application and Localization (i18n)
**CRITICAL AND MANDATORY:** The application architecture MUST natively support a global structure, including multi-language support (TR, EN, Arabic, etc.), Right-To-Left (RTL) layout capabilities, and regional formatting (date/time, currency). All user-facing text must be wrapped in translation functions (`AppLocalizations.of(context)!.trString()` in Flutter) from the beginning. Never hardcode UI text strings.

## REQUIRED DOCUMENT READING ORDER

For every new development session:

1. `AGENTS.md`
2. `STATE.md`
3. `TASK.md`
4. `ROADMAP.md`
5. `DESKPILOT_PRODUCT_SPEC.md`
6. `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`
7. `ARCHITECTURE.md`

Read additional documents only when required by the explicit task.

Do not automatically scan the entire repository or all documentation at the start of every task.

## CURRENT PHASE

**Phase 3 — Date Module** ✅ COMPLETE

Next immediate task: Phase 4 — Battery Module.

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

1. Proceed to Phase 4: Battery Module
2. Implement battery domain model and service
3. Create battery UI
4. Verify `flutter run` launches transparent window

## AI Agent Continuation Instruction

Before modifying this repository, read in this order:

1. `AGENTS.md`
2. `STATE.md`
3. `TASK.md`
4. `ROADMAP.md`
5. `DESKPILOT_PRODUCT_SPEC.md`
6. `PRODUCT_ARCHITECTURE_PRINCIPLES_AI_EN.md`
7. `ARCHITECTURE.md`

Continue from the current state. Do not restart architectural interpretation unless a real conflict or new requirement requires a decision.

Communicate with the user in Turkish unless explicitly requested otherwise.

## Last Updated
2026-09-17 — Phase 0: Flutter/Dart project established, C++/Qt removed.
