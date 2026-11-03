#!/usr/bin/env bash
# Re-vendors third-party skills into flat folders .claude/skills/<name>/ and rewrites SOURCES.md.
# Flat on purpose: Claude Code only discovers .claude/skills/<name>/SKILL.md, not group folders.
# The frontmatter name is set to the folder name so the / menu and the kit's references agree.
# Usage: scripts/vendor-skills.sh   (from the kit root; needs git, rsync)
set -euo pipefail
K="$(cd "$(dirname "$0")/.." && pwd)"
S="$(mktemp -d)"
EX=(--exclude=.git --exclude=.github --exclude=README.md --exclude=CHANGELOG.md --exclude=CONTRIBUTING.md --exclude=CODE_OF_CONDUCT.md --exclude=.gitignore --exclude=install.sh --exclude=.DS_Store --exclude=AGENTS.md --exclude=CLAUDE.md --exclude=tests --exclude=tooling)
TMP="$K/.claude/skills/SOURCES.tmp"; : > "$TMP"

clone(){ [ -d "$S/$1" ] || git clone --quiet --depth 1 "https://github.com/${1/_//}.git" "$S/$1"; }
lic(){ f=$(ls "$1"/LICENSE* 2>/dev/null | head -1); if [ -n "$f" ]; then head -3 "$f" | tr -s ' \n' ' ' | grep -oiE 'MIT|Apache License Version 2\.0|BSD[^ ]*|GPL[^ ]*' | sed 's/Apache License Version 2.0/Apache-2.0/' | head -1; else echo "?"; fi; }
# vendor <owner_repo> <path-inside-repo> <platform> <local-name>
vendor(){ clone "$1"; r="$S/$1"; dst="$K/.claude/skills/$4"
  rm -rf "$dst"; mkdir -p "$dst"; rsync -a "${EX[@]}" "$r/$2/" "$dst/"
  [ -f "$dst/SKILL.md" ] || { echo "ERROR: no SKILL.md in $dst" >&2; exit 1; }
  l=$(ls "$r" | grep -i "^licen" | head -1); [ -n "$l" ] && cp "$r/$l" "$dst/LICENSE" || { echo "ERROR: $1 has no license file; do not vendor it" >&2; exit 1; }
  perl -0pi -e "s/\A(---\n)name: [^\n]+\n/\${1}name: $4\n/" "$dst/SKILL.md"
  printf '| %s | %s | `%s` | %s | %s | %s |\n' "$4" "$3" "${1/_//}" "$(git -C "$r" log -1 --format=%h)" "$(git -C "$r" log -1 --format=%cs)" "$(lic "$r")" >> "$TMP"; }

# iOS
vendor twostraws_SwiftUI-Agent-Skill swiftui-pro ios swiftui-pro
vendor twostraws_SwiftData-Agent-Skill swiftdata-pro ios swiftdata-pro
vendor twostraws_Swift-Concurrency-Agent-Skill swift-concurrency-pro ios swift-concurrency-pro
vendor twostraws_Swift-Testing-Agent-Skill swift-testing-pro ios swift-testing-pro
vendor efremidze_swift-architecture-skill swift-architecture-skill ios swift-architecture
vendor Dimillian_Skills swiftui-performance-audit ios swiftui-performance-audit
vendor Dimillian_Skills swiftui-view-refactor ios swiftui-view-refactor
vendor ivan-magda_swift-security-skill swift-security-expert ios swift-security
vendor dadederk_iOS-Accessibility-Agent-Skill ios-accessibility ios ios-accessibility
vendor 3paws-ai_mobile-ai-skills skills/appstore-review ios appstore-review
vendor conorluddy_ios-simulator-skill ios-simulator-skill/skills/ios-simulator-skill ios ios-simulator
vendor rudrankriyam_app-store-connect-cli-skills skills/asc-cli-usage ios asc-cli-usage
vendor rudrankriyam_app-store-connect-cli-skills skills/asc-release-flow ios asc-release-flow
vendor rudrankriyam_app-store-connect-cli-skills skills/asc-testflight-orchestration ios asc-testflight
# Flutter
for s in flutter-skills-index flutter-architecture flutter-dart-style flutter-state-management flutter-testing flutter-performance; do vendor abugeek_flutter-skills ".claude/skills/$s" flutter "$s"; done
vendor Ethiel97_flutter-clean-riverpod-skills skills/flutter-result-errors flutter flutter-result-errors
vendor Ethiel97_flutter-clean-riverpod-skills skills/flutter-riverpod3 flutter flutter-riverpod3
# Android
for s in using-chrisbanes-skills compose-state-and-effects compose-performance compose-component-design compose-ui-testing-patterns kotlin-concurrency-and-flow kotlin-control-flow kotlin-api-design gradle-run android-benchmark-comparison; do vendor chrisbanes_skills "skills/$s" android "$s"; done
vendor dpconde_claude-android-skill . android android-development

{ echo "# Vendored skill sources"; echo
  echo "Each vendored folder \`.claude/skills/<name>/\` is a copy of a third-party skill (SKILL.md + references; repo README and CHANGELOG left out; each folder carries its upstream LICENSE file unchanged). Frontmatter names are set to the folder name. Re-vendor with \`scripts/vendor-skills.sh\`; keep this table current."; echo
  echo "| Skill | Platform | Repository (github) | Commit | Date | License |"; echo "|---|---|---|---|---|---|"; sort "$TMP"; } > "$K/.claude/skills/SOURCES.md"
rm -f "$TMP"; rm -rf "$S"
echo "vendored $(find "$K/.claude/skills" -name SKILL.md | wc -l | tr -d ' ') skills"
grep -h "^name:" "$K"/.claude/skills/*/SKILL.md | sort | uniq -d | sed 's/^/DUPLICATE NAME: /' || true
