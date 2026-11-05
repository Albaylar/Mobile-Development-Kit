#!/usr/bin/env bash
# Verification ladder (docs/verification-ladder.md): the same warm, capped commands for every builder.
#
#   scripts/verify.sh compile [module]                  L0  type-check what changed
#   scripts/verify.sh only <Target/Suite[/test]>...     L1  the named tests of the app target
#   scripts/verify.sh only --module <path> <Suite>...   L1  the named tests of one local package / Gradle module / test file
#   scripts/verify.sh suite [module]                    L2  all unit and screen tests of one module, no UI tests
#   scripts/verify.sh full                              L3  everything except UI/integration tests, detached
#   scripts/verify.sh ui                                L4  UI / integration tests, detached (QA, main session)
#   scripts/verify.sh wait <full|ui>                    poll a detached run until it ends, print the tail
#   scripts/verify.sh status                            what is warm, last results
#
# Settings (environment or .verify.env at the repository root):
#   VERIFY_SCHEME        iOS app scheme (default: the single project's first scheme)
#   VERIFY_DESTINATION   xcodebuild destination (default: a booted simulator, else the first available iPhone)
#   VERIFY_UI_TARGETS    space-separated test targets that need the app on a device (default: every *UITests target)
#   VERIFY_PACKAGES      space-separated local package dirs for L3 (default: */*/*/Package.swift and */*/Package.swift)
#   VERIFY_ANDROID_MODULES  Gradle modules for L3 (default: :app)
#   VERIFY_LOG_DIR       default .build/verify
set -u
root="${VERIFY_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"   # VERIFY_ROOT: run the kit copy against another checkout
cd "$root"
[ -f .verify.env ] && . ./.verify.env
log_dir="${VERIFY_LOG_DIR:-.build/verify}"
mkdir -p "$log_dir"

# Budgets in seconds. A run over budget is killed and reported; the fix is in the harness, never in skipping the rung.
CAP_L0=${VERIFY_CAP_L0:-300}; CAP_L1=${VERIFY_CAP_L1:-120}; CAP_L2=${VERIFY_CAP_L2:-300}   # the first compile into a cold DerivedData may need VERIFY_CAP_L0=580 once

die() { echo "verify: $*" >&2; exit 2; }

platform() {
  if ls ./*.xcodeproj ./*.xcworkspace >/dev/null 2>&1 || [ -f project.yml ] || [ -f Package.swift ]; then echo ios
  elif [ -f pubspec.yaml ]; then echo flutter
  elif [ -f gradlew ]; then echo android
  else die "no Xcode project, pubspec.yaml or gradlew in $root"; fi
}

# run_capped <seconds> <log> <cmd...>: foreground run with a time budget; prints a short summary.
run_capped() {
  local cap=$1 log=$2; shift 2
  : > "$log"
  "$@" >"$log" 2>&1 &
  local pid=$! t=0
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$t" -ge "$cap" ]; then
      kill "$pid" 2>/dev/null; sleep 2; kill -9 "$pid" 2>/dev/null
      echo "verify: over budget (${cap}s): $*" | tee -a "$log"
      echo "verify: note it under Implementation notes as 'test loop too slow' and fix the harness (scope, scheme, DerivedData)."
      return 124
    fi
    sleep 2; t=$((t+2))
  done
  wait "$pid"; local rc=$?
  echo "verify: ${t}s, exit $rc, log $log"
  return $rc
}

# run_detached <name> <cmd...>: survives the tool's time limit; result in <log_dir>/<name>.{log,exit}
run_detached() {
  local name=$1; shift
  local log="$log_dir/$name.log" exitf="$log_dir/$name.exit"
  rm -f "$exitf"; : > "$log"
  nohup bash -c "$(printf '%q ' "$@"); echo \$? > $(printf '%q' "$exitf")" >"$log" 2>&1 < /dev/null &
  echo "verify: started '$name' detached (pid $!). Poll with: scripts/verify.sh wait $name"
}

wait_for() {
  local name=$1 log="$log_dir/$1.log" exitf="$log_dir/$1.exit" t=0
  [ -f "$log" ] || die "no detached run named $name"
  while [ ! -f "$exitf" ]; do sleep 15; t=$((t+15)); [ "$t" -ge 2400 ] && { echo "verify: still running after 40 min, check $log"; return 124; }; done
  summarize "$log"; echo "verify: exit $(cat "$exitf")"; return "$(cat "$exitf")"
}

# summarize <log>: test counts, failures, result; enforces "0 tests run counts as failed".
summarize() {
  local log=$1 n
  grep -E "Test run with|Executed [0-9]+ tests?|✘|error:|warning:|\*\* (TEST|BUILD) (SUCCEEDED|FAILED)|All tests passed|Some tests failed|tests passed|FAILED|BUILD SUCCESSFUL|No issues found" "$log" | grep -v "Executed 0 tests" | cut -c1-200 | tail -40
  n=$(grep -hoE "Test run with [0-9]+ test|Executed [0-9]+ tests?|\+[0-9]+(: All tests passed| ~[0-9]+ -[0-9]+)|[0-9]+ tests completed" "$log" | grep -oE "[0-9]+" | awk '{s+=$1} END {print s+0}')
  echo "verify: tests counted in log: $n"
  if [ "$n" = "0" ]; then echo "verify: 0 tests ran: this counts as FAILED"; return 1; fi
  return 0
}

ios_setup() {
  dd="$root/.build/DerivedData"
  xflags=(-derivedDataPath "$dd" -skipMacroValidation -skipPackagePluginValidation -disableAutomaticPackageResolution -quiet)
  scheme="${VERIFY_SCHEME:-$(xcodebuild -list -json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); p=d.get("project") or d.get("workspace"); s=p["schemes"]; print(p["name"] if p["name"] in s else s[0])' 2>/dev/null)}"
  [ -n "$scheme" ] || die "set VERIFY_SCHEME"
  if [ -z "${VERIFY_DESTINATION:-}" ]; then
    local booted; booted=$(xcrun simctl list devices booted -j | python3 -c 'import json,sys; d=json.load(sys.stdin)["devices"]; ids=[x["udid"] for v in d.values() for x in v if "iPhone" in x["name"]]; print(ids[0] if ids else "")')
    if [ -n "$booted" ]; then VERIFY_DESTINATION="platform=iOS Simulator,id=$booted"
    else VERIFY_DESTINATION="platform=iOS Simulator,name=$(xcrun simctl list devices available | grep -oE 'iPhone [^(]+' | head -1 | sed 's/ *$//')"; fi
  fi
  dest="$VERIFY_DESTINATION"
  if [ -z "${VERIFY_UI_TARGETS:-}" ]; then
    VERIFY_UI_TARGETS=$(xcodebuild -list -json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); p=d.get("project") or {}; print(" ".join(t for t in p.get("targets",[]) if t.endswith("UITests")))' 2>/dev/null)
  fi
  skip_ui=(); for t in $VERIFY_UI_TARGETS; do skip_ui+=("-skip-testing:$t"); done
}
ios_xctestrun() { local f; f=$(ls -t "$dd"/Build/Products/*.xctestrun 2>/dev/null | head -1); [ -n "$f" ] && echo "$f"; }
ios_build_for_testing() { xcodebuild -scheme "$scheme" -destination "$dest" "${xflags[@]}" build-for-testing; }
ios_packages() {
  if [ -n "${VERIFY_PACKAGES:-}" ]; then echo "$VERIFY_PACKAGES"; else
    find . -maxdepth 4 -name Package.swift -not -path '*/.build/*' -not -path './Package.swift' -exec dirname {} \; | sort | tr '\n' ' '; fi
}
pkg_scheme() { python3 -c 'import re,sys; s=open(sys.argv[1]).read(); print(re.search(r"name:\s*\"([^\"]+)\"",s).group(1))' "$1/Package.swift"; }

cmd=${1:-}; shift || true
case "$cmd" in
  compile|only|suite|full|ui|wait|status) ;;
  *) sed -n 2,12p "$0"; exit 2 ;;
esac
[ "$cmd" = wait ] && { wait_for "${1:?full|ui}"; exit $?; }
p=$(platform)

case "$p" in
ios)
  ios_setup
  case "$cmd" in
    compile)
      if [ -n "${1:-}" ]; then s=$(pkg_scheme "$1"); run_capped $CAP_L0 "$log_dir/compile.log" bash -c "cd $(printf %q "$1") && xcodebuild -scheme $(printf %q "$s") -destination $(printf %q "$dest") $(printf '%q ' "${xflags[@]}") build"
      else run_capped $CAP_L0 "$log_dir/compile.log" ios_build_for_testing; fi; rc=$?
      grep -E "error:|warning:" "$log_dir/compile.log" | head -20; exit $rc ;;
    only)
      if [ "${1:-}" = "--module" ]; then
        m=$2; shift 2; s=$(pkg_scheme "$m"); ids=(); for i in "$@"; do ids+=("-only-testing:$i"); done
        run_capped $CAP_L1 "$log_dir/only.log" bash -c "cd $(printf %q "$m") && xcodebuild -scheme $(printf %q "$s") -destination $(printf %q "$dest") $(printf '%q ' "${xflags[@]}") $(printf '%q ' "${ids[@]}") test"
      else
        [ $# -gt 0 ] || die "name at least one Target/Suite[/test]"
        ios_build_for_testing >"$log_dir/compile.log" 2>&1 || { grep -E "error:" "$log_dir/compile.log" | head; die "build-for-testing failed, see $log_dir/compile.log"; }
        ids=(); for i in "$@"; do ids+=("-only-testing:$i"); done
        run_capped $CAP_L1 "$log_dir/only.log" xcodebuild test-without-building -xctestrun "$(ios_xctestrun)" -destination "$dest" "${xflags[@]}" "${ids[@]}"
      fi; rc=$?; summarize "$log_dir/only.log" || rc=1; exit $rc ;;
    suite)
      if [ -n "${1:-}" ]; then s=$(pkg_scheme "$1"); run_capped $CAP_L2 "$log_dir/suite.log" bash -c "cd $(printf %q "$1") && xcodebuild -scheme $(printf %q "$s") -destination $(printf %q "$dest") $(printf '%q ' "${xflags[@]}") test"
      else
        ios_build_for_testing >"$log_dir/compile.log" 2>&1 || die "build-for-testing failed, see $log_dir/compile.log"
        run_capped $CAP_L2 "$log_dir/suite.log" xcodebuild test-without-building -xctestrun "$(ios_xctestrun)" -destination "$dest" "${xflags[@]}" "${skip_ui[@]}"
      fi; rc=$?; summarize "$log_dir/suite.log" || rc=1; exit $rc ;;
    full)
      script="set -e; cd $(printf %q "$root"); xcodebuild -scheme $(printf %q "$scheme") -destination $(printf %q "$dest") $(printf '%q ' "${xflags[@]}") $(printf '%q ' "${skip_ui[@]}") build test"
      for m in $(ios_packages); do s=$(pkg_scheme "$m"); script="$script; (cd $(printf %q "$m") && xcodebuild -scheme $(printf %q "$s") -destination $(printf %q "$dest") $(printf '%q ' "${xflags[@]}") test)"; done
      run_detached full bash -c "$script" ;;
    ui)
      [ -n "$VERIFY_UI_TARGETS" ] || die "no UI test target (set VERIFY_UI_TARGETS)"
      ids=(); for t in $VERIFY_UI_TARGETS; do ids+=("-only-testing:$t"); done
      run_detached ui bash -c "cd $(printf %q "$root"); xcodebuild -scheme $(printf %q "$scheme") -destination $(printf %q "$dest") $(printf '%q ' "${xflags[@]}") $(printf '%q ' "${ids[@]}") build test" ;;
    status)
      echo "platform ios · scheme $scheme · destination $dest · UI targets: ${VERIFY_UI_TARGETS:-none}"
      echo "DerivedData: $( [ -d "$dd" ] && du -sh "$dd" | cut -f1 || echo cold ) · xctestrun: $(ios_xctestrun || echo none) · packages: $(ios_packages)"
      for f in "$log_dir"/*.exit; do [ -f "$f" ] && echo "$(basename "$f" .exit): exit $(cat "$f") ($(date -r "$f" '+%H:%M'))"; done; exit 0 ;;
  esac ;;
flutter)
  case "$cmd" in
    compile) t=${1:-lib}; run_capped $CAP_L0 "$log_dir/compile.log" bash -c "dart analyze $(printf %q "$t") && dart format --set-exit-if-changed $(printf %q "$t")"; rc=$?; tail -5 "$log_dir/compile.log"; exit $rc ;;
    only)
      if [ "${1:-}" = "--module" ]; then f=$2; shift 2; else f=$1; shift; fi
      names=(); for n in "$@"; do names+=(--plain-name "$n"); done
      run_capped $CAP_L1 "$log_dir/only.log" flutter test "$f" "${names[@]}"; rc=$?; summarize "$log_dir/only.log" || rc=1; exit $rc ;;
    suite) run_capped $CAP_L2 "$log_dir/suite.log" flutter test "${1:-test}"; rc=$?; summarize "$log_dir/suite.log" || rc=1; exit $rc ;;
    full) run_detached full bash -c "cd $(printf %q "$root") && flutter analyze && dart format --set-exit-if-changed lib test && flutter test" ;;
    ui) [ -d integration_test ] || die "no integration_test/ directory"; run_detached ui bash -c "cd $(printf %q "$root") && flutter test integration_test ${VERIFY_DEVICE:+-d $VERIFY_DEVICE}" ;;
    status) echo "platform flutter · $(flutter --version 2>/dev/null | head -1)"; for f in "$log_dir"/*.exit; do [ -f "$f" ] && echo "$(basename "$f" .exit): exit $(cat "$f")"; done; exit 0 ;;
  esac ;;
android)
  mods="${VERIFY_ANDROID_MODULES:-:app}"
  case "$cmd" in
    compile) m=${1:-:app}; run_capped $CAP_L0 "$log_dir/compile.log" ./gradlew "$m:compileDebugKotlin" -q; rc=$?; grep -E "^e:|warning:" "$log_dir/compile.log" | head -20; exit $rc ;;
    only)
      if [ "${1:-}" = "--module" ]; then m=$2; shift 2; else m=:app; fi
      args=(); for c in "$@"; do args+=(--tests "$c"); done
      run_capped $CAP_L1 "$log_dir/only.log" ./gradlew "$m:testDebugUnitTest" "${args[@]}"; rc=$?; summarize "$log_dir/only.log" || rc=1; exit $rc ;;
    suite) m=${1:-:app}; run_capped $CAP_L2 "$log_dir/suite.log" ./gradlew "$m:testDebugUnitTest"; rc=$?; summarize "$log_dir/suite.log" || rc=1; exit $rc ;;
    full) tasks=""; for m in $mods; do tasks="$tasks $m:lint $m:testDebugUnitTest"; done; run_detached full bash -c "cd $(printf %q "$root") && ./gradlew$tasks" ;;
    ui) run_detached ui bash -c "cd $(printf %q "$root") && ./gradlew connectedDebugAndroidTest" ;;
    status) echo "platform android · modules $mods"; for f in "$log_dir"/*.exit; do [ -f "$f" ] && echo "$(basename "$f" .exit): exit $(cat "$f")"; done; exit 0 ;;
  esac ;;
esac
