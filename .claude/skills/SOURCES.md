# Vendored skill sources

Each vendored folder `.claude/skills/<name>/` is a copy of a third-party skill (SKILL.md + references; repo README and CHANGELOG left out; each folder carries its upstream LICENSE file unchanged). Re-vendor with `scripts/vendor-skills.sh`; keep this table current. Four frontmatter names were aligned to their folder names (asc-testflight, ios-simulator, swift-architecture, swift-security); the script does the same.

| Skill | Platform | Repository (github) | Commit | Date | License |
|---|---|---|---|---|---|
| android-benchmark-comparison | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| android-development | android | `dpconde/claude-android-skill` | edfca5e | 2025-12-07 | MIT |
| compose-component-design | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| compose-performance | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| compose-state-and-effects | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| compose-ui-testing-patterns | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| gradle-run | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| kotlin-api-design | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| kotlin-concurrency-and-flow | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| kotlin-control-flow | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| using-chrisbanes-skills | android | `chrisbanes/skills` | 530d686 | 2026-11-03 | Apache-2.0 |
| flutter-architecture | flutter | `abugeek/flutter-skills` | 79d8c4c | 2026-11-02 | MIT |
| flutter-dart-style | flutter | `abugeek/flutter-skills` | 79d8c4c | 2026-11-02 | MIT |
| flutter-performance | flutter | `abugeek/flutter-skills` | 79d8c4c | 2026-11-02 | MIT |
| flutter-result-errors | flutter | `Ethiel97/flutter-clean-riverpod-skills` | 5612d65 | 2026-10-02 | MIT |
| flutter-riverpod3 | flutter | `Ethiel97/flutter-clean-riverpod-skills` | 5612d65 | 2026-10-02 | MIT |
| flutter-skills-index | flutter | `abugeek/flutter-skills` | 79d8c4c | 2026-11-02 | MIT |
| flutter-state-management | flutter | `abugeek/flutter-skills` | 79d8c4c | 2026-11-02 | MIT |
| flutter-testing | flutter | `abugeek/flutter-skills` | 79d8c4c | 2026-11-02 | MIT |
| appstore-review | ios | `3paws-ai/mobile-ai-skills` | 6d3570e | 2026-07-24 | MIT |
| asc-cli-usage | ios | `rudrankriyam/app-store-connect-cli-skills` | 7de1ef7 | 2026-10-26 | MIT |
| asc-release-flow | ios | `rudrankriyam/app-store-connect-cli-skills` | 7de1ef7 | 2026-10-26 | MIT |
| asc-testflight | ios | `rudrankriyam/app-store-connect-cli-skills` | 7de1ef7 | 2026-10-26 | MIT |
| ios-accessibility | ios | `dadederk/iOS-Accessibility-Agent-Skill` | dcc3a36 | 2026-03-09 | MIT |
| ios-simulator | ios | `conorluddy/ios-simulator-skill` | e38b3ad | 2026-10-19 | MIT |
| swift-architecture | ios | `efremidze/swift-architecture-skill` | 60e1776 | 2026-09-27 | MIT |
| swift-concurrency-pro | ios | `twostraws/Swift-Concurrency-Agent-Skill` | bee3f69 | 2026-05-17 | MIT |
| swift-security | ios | `ivan-magda/swift-security-skill` | bda2e0c | 2026-06-17 | MIT |
| swift-testing-pro | ios | `twostraws/Swift-Testing-Agent-Skill` | 2d6bba1 | 2026-05-17 | MIT |
| swiftdata-pro | ios | `twostraws/SwiftData-Agent-Skill` | 8051f17 | 2026-10-19 | MIT |
| swiftui-performance-audit | ios | `Dimillian/Skills` | 05ba982 | 2026-03-29 | MIT |
| swiftui-pro | ios | `twostraws/SwiftUI-Agent-Skill` | f2920b6 | 2026-10-26 | MIT |
| swiftui-view-refactor | ios | `Dimillian/Skills` | 05ba982 | 2026-03-29 | MIT |
