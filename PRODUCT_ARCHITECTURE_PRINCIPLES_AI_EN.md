# PRODUCT ARCHITECTURE AND TECHNOLOGY SELECTION PRINCIPLES

## Purpose

This document defines the core principles to use when selecting technologies, architecture, and platform strategies for any new software product or application.

At the beginning of every new project, this document should be treated as a decision framework. Technology choices must not be made automatically based on familiarity, ease of learning, previous project choices, or a desire to force all platforms into a single language or framework.

The primary question is:

> **Which technology stack and architecture can realize the best product we can envision with the fewest limitations in visual quality, user experience, performance, functionality, scalability, security, and long-term maintainability?**

This document does not mandate a fixed technology stack. Every new product must be evaluated according to its actual requirements before a final architecture is selected.

---

## 1. Core Product Vision

The goal is not merely to build software that works or is "good enough."

The goal is to:

- Aim for the highest practical level of visual quality and aesthetics.
- Create user experiences capable of competing with top professional products.
- Achieve excellent performance, responsiveness, stability, and resource efficiency.
- Design the core engine and overall software architecture at a professional engineering level.
- Avoid technology choices that could unnecessarily restrict the future product vision.
- Build architectures capable of evolving toward large codebases and potentially very large user bases when required.
- Use platform-specific capabilities when they provide a better product.
- Treat AI development agents such as Codex and Copilot as active engineering tools.

The primary technology-selection criterion is no longer:

> **"Which technology is easiest for the user to learn or write manually?"**

Instead, it is:

> **"Which technology allows the intended final product to be built at the highest quality with the fewest meaningful limitations?"**

---

## 2. Platform Strategy

Do not assume that every platform must use the same programming language or UI framework.

The preferred general principle is:

> **Best experience everywhere, shared architecture underneath.**

This means:

- Aim for the best possible user experience on each target platform.
- Use different frontend technologies for different platforms when this produces a materially better result.
- Share data models, API contracts, authentication concepts, synchronization protocols, business rules, and design principles where appropriate.
- Use "write once, run everywhere" only when it does not significantly compromise quality, performance, native integration, or user experience.
- Reducing code duplication is not more important than product quality.
- Do not force a technology onto a platform merely because it is technically supported there.

---

## 3. Default Technology Candidates

These are starting candidates, not mandatory choices.

At the beginning of each project, reevaluate them against the product's real requirements and the current state of the technology ecosystem.

### Mobile

**Primary candidate: Flutter + Dart**

Strong candidate for:

- Android
- iOS
- Tablets
- Highly customized UI
- Rich animations
- Visually distinctive applications
- Shared mobile codebases

Flutter should normally be the first candidate evaluated for cross-platform mobile products.

However, if critical platform-specific requirements are materially constrained by Flutter, native technologies should also be considered.

---

### Desktop

**Primary high-end candidate: Qt Quick/QML + C++**

Especially suitable for products requiring:

- Maximum visual flexibility
- Highly customized or unconventional desktop interfaces
- Rich animations
- Multiple independent windows
- Frameless and transparent windows
- System tray integration
- Always-on-top behavior
- Deep operating-system integration
- High performance
- Windows, macOS, and Linux targets

General responsibility split:

- **QML / Qt Quick:** Visual layer, interaction, animation, and user experience
- **C++:** Core engine, performance-critical logic, native integration, and lower-level system functionality

For commercial products using Qt, licensing implications must be evaluated at the beginning of the project.

---

### Alternative Desktop Architecture

**Tauri + Rust + React/TypeScript**

A strong candidate when:

- Desktop and web experiences are closely related.
- The visual flexibility of web technologies is valuable.
- A lightweight native desktop shell is desired.
- Rust is useful for secure, high-performance core or backend functionality.
- Significant frontend code sharing with a web product is beneficial.

For desktop products, Qt/QML and Tauri/Rust should be compared according to the actual product requirements rather than selected by default.

---

### Web

**Primary candidate: TypeScript + React + Next.js**

Strong candidate for:

- Modern web applications
- Responsive interfaces
- Progressive Web Apps
- SEO-sensitive products
- Highly customized UI using HTML, CSS, SVG, Canvas, and WebGL
- Large frontend ecosystems

Do not force a web application into Flutter Web solely for code-sharing purposes.

Evaluate the nature of the product and choose the web technology that provides the best actual web experience.

---

## 4. Core / Engine Strategy

For complex or multi-platform products, separate UI concerns from business logic and core functionality using clear architectural boundaries.

Primary technologies to evaluate include:

- **Rust:** Security, performance, concurrency, networking, memory safety, and long-lived core systems.
- **C++:** Native performance, Qt integration, operating-system integration, and low-level access.
- **Go:** Network services, backend systems, concurrency, operational simplicity, and deployment.
- **TypeScript / Node.js:** Web-oriented services and rapid product development.
- **Python:** AI, data processing, automation, tooling, scripting, testing utilities, and prototyping.

Do not select Python as the main product technology solely because it is easier to learn.

Continue using Python where it is technically appropriate and provides genuine advantages.

---

## 5. Multi-Platform Product Architecture

A general reference architecture may look like this:

```text
                  Cloud / Sync / Backend
                           |
              API + Realtime + Authentication
                           |
          Shared Protocol + Shared Data Model
                           |
        +------------------+------------------+
        |                  |                  |
     Desktop             Mobile              Web
   Qt/QML+C++           Flutter        React/Next.js
        |                  |                  |
        +------------------+------------------+
                           |
              Shared Business Concepts / Rules
```

Not every product requires every layer.

Simplify the architecture according to the actual product requirements.

The objective is not maximum architectural complexity. The objective is maximum appropriate engineering quality.

---

## 6. Default Data and Communication Candidates

Evaluate these technologies according to project requirements:

- **Server database:** PostgreSQL
- **Local database:** SQLite
- **Realtime communication:** WebSocket
- **Peer-to-peer communication:** WebRTC when appropriate
- **General API:** REST
- **High-performance service communication:** gRPC when appropriate

These are default candidates, not automatic requirements.

Do not introduce infrastructure that the product does not need.

---

## 7. Design System Strategy

When different UI technologies are used across platforms, the product should still maintain a coherent identity.

Where appropriate, share:

- Color systems
- Typography
- Spacing
- Corner radius definitions
- Iconography
- Animation language
- Motion principles
- Component behavior
- Accessibility rules

Define these through shared **Design Tokens** where practical.

However, each platform should still respect its natural interaction patterns and platform conventions when doing so improves usability.

The objective is not necessarily pixel-identical UI across every platform.

The objective is:

> **A consistent product identity expressed through the best possible experience on each platform.**

---

## 8. New Project Architecture Decision Process

Before writing production code for a new application, answer the following questions:

1. What exactly is this product?
2. What are the primary and secondary target platforms?
3. What level of visual quality and UI customization is required?
4. What are the hardest technical requirements?
5. How deeply must the application integrate with the operating system?
6. How critical are performance and resource efficiency?
7. Is offline operation required?
8. Is synchronization across devices required?
9. Is realtime communication required?
10. What are the security and privacy requirements?
11. What user scale could the product eventually reach?
12. Could the selected technology become a limitation within five years?
13. Can the architecture be effectively developed and maintained with AI engineering agents?
14. Which code genuinely benefits from being shared across platforms?
15. Which components would produce a better result if implemented with platform-specific technologies?

Do not select a technology merely because it was used in a previous project.

---

## 9. General Decision Priority

Technology decisions should generally prioritize:

1. Ability to realize the full product vision
2. User experience and visual freedom
3. Performance and stability
4. Technical capability and platform integration
5. Architectural quality and scalability
6. Long-term maintainability
7. Security
8. Ecosystem and tooling
9. Compatibility with AI-assisted engineering workflows
10. Development speed and cost

Ease of learning must not be the primary deciding factor.

---

## 10. Instructions for AI Engineering Agents

When this document is provided to Codex, Copilot, ChatGPT, or another AI engineering agent:

> Do not automatically copy technology choices from previous projects.
>
> Analyze the actual product requirements first.
>
> Evaluate visual quality, performance, user experience, architecture, native platform integration, security, scalability, and long-term maintainability together.
>
> Recommend different frontend technologies for different platforms when doing so materially improves the product.
>
> Do not sacrifice product quality merely to maintain a single codebase.
>
> Clearly explain the advantages, disadvantages, tradeoffs, licensing implications, and long-term risks of proposed technologies.
>
> Do not treat the user's familiarity with a language or ease of learning as the primary technology-selection criterion.
>
> Before final selection, compare the strongest two or three realistic architecture alternatives.
>
> Avoid unnecessary overengineering.
>
> Do not introduce complexity that exceeds the real requirements of the product.
>
> However, when future requirements are already known, do not create an architectural dead end merely for short-term convenience.
>
> Prefer evidence-based technical recommendations over agreement or reassurance. If the user's preferred technology is not the best fit, explain why and recommend a better alternative.

---

## 11. Recommended Prompt for Starting a New Project

Use the following instruction when beginning architecture discussions with ChatGPT, Codex, or another AI engineering agent:

> **Use the principles in PRODUCT_ARCHITECTURE_AND_TECHNOLOGY_SELECTION_PRINCIPLES.md as the general architecture and technology-selection framework for this project. Do not automatically select the technologies listed in the document. First analyze the real requirements of this specific application with me. Our goals are maximum practical freedom in visual design and aesthetics, high performance, professional architecture, strong functionality, security, scalability, and long-term maintainability. Do not choose a weaker technology merely because it is easier to learn. At the same time, do not introduce unnecessary complexity or overengineering. Evaluate mobile, desktop, web, backend, and core requirements independently. Select the best technology for each platform when appropriate. Before coding, compare the strongest realistic architecture alternatives, including their advantages, disadvantages, tradeoffs, licensing considerations, migration risks, and long-term limitations. Discuss the options with me and establish the final technology stack before implementation begins.**

---

## 12. Current General Reference Stack

Based on the current architectural assessment, the starting reference stack is:

- **Mobile:** Flutter + Dart
- **Desktop:** Qt Quick/QML + C++, or Tauri + Rust + React/TypeScript depending on product requirements
- **Web:** TypeScript + React + Next.js
- **High-performance core:** Rust or C++
- **Backend:** Rust or Go; TypeScript/Node.js where appropriate
- **Server database:** PostgreSQL
- **Local database:** SQLite
- **Realtime:** WebSocket
- **P2P:** WebRTC when appropriate
- **Cross-platform visual identity:** Shared Design System + Design Tokens

This reference stack is not a permanent or mandatory standard.

For every new product:

> **Define the product and its requirements first. Then select the technology architecture that imposes the fewest meaningful constraints while enabling the highest practical product quality.**

---

## 13. Communication Language with the User

This document is intentionally written in English so that AI engineering agents such as ChatGPT, Codex, Copilot, and similar systems can interpret the architectural principles and technical instructions as clearly and consistently as possible.

**However, all communication, explanations, architecture discussions, recommendations, questions, progress reports, and normal collaboration with the user must continue in Turkish unless the user explicitly requests another language.**

Technical identifiers, source-code naming, commit messages, documentation, or AI-agent prompts may use English when appropriate or when separately specified by the user.

The use of English in this document must never be interpreted as a request to switch the normal conversation language from Turkish to English.
