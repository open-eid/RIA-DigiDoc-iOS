#!/bin/sh
set -e

# -----------------------------
# Config
# -----------------------------
PROJECT="RIADigiDoc.xcodeproj"
SCHEME="AllTests"
DEVICE="iPhone 17"

COMMON_ARGS=(
  --project "$PROJECT"
  --scheme "$SCHEME"
  --device "$DEVICE"
  --disable-coverage
  --max-concurrent-devices 1
  --max-concurrent-simulators 1
)

MODULE_GROUPS=(
  "SmartIdLibTests"
  "ConfigLibTests"
  "MobileIdLibTests"
  "LibdigidocLibTests"
  "RIADigiDocTests"
  "FileImportShareExtensionTests"
  "UtilsLibTests"
)

# -----------------------------
# Reset simulators
# -----------------------------
reset_simulator() {
  echo "Resetting simulator..."
  xcrun simctl shutdown all 2>/dev/null || true
  sleep 5
  xcrun simctl erase all 2>/dev/null || true
  sleep 5

  # Boot the simulator and wait for it to be ready
  UDID=$(xcrun simctl list devices available | grep "$DEVICE" | head -1 | grep -E -o '[0-9A-F-]{36}')
  if [ -z "$UDID" ]; then
    echo "ERROR: Could not find simulator UDID for '$DEVICE'"
    exit 1
  fi

  echo -n "Booting $DEVICE ($UDID)..."
  xcrun simctl boot "$UDID" 2>/dev/null || true
  until xcrun simctl list devices | grep "$UDID" | grep -q "Booted"; do
    printf '.'
    sleep 5
  done
  echo " ready!"

  # Shutting down any stale simulator processes
  pkill -9 -f "Simulator" 2>/dev/null || true
  sleep 5
  open -a Simulator --args -CurrentDeviceUDID "$UDID"
  sleep 5
}

reset_simulator

# -----------------------------
# Run tests group by group
# -----------------------------
FAILED_GROUPS=()

for GROUP in "${MODULE_GROUPS[@]}"; do
  echo "----------------------------------------"
  echo "Running test group: $GROUP"
  echo "----------------------------------------"

  TEST_XCARGS="$COMMON_XCARGS -skipPackagePluginValidation"
  for MODULE in $GROUP; do
    TEST_XCARGS+=" -only-testing:${MODULE}"
  done

  # Retry once on failure before giving up
  SUCCESS=false
  for ATTEMPT in 1 2; do
    if xcode-project run-tests \
        "${COMMON_ARGS[@]}" \
        --test-xcargs "$TEST_XCARGS"; then
      SUCCESS=true
      break
    else
      echo "Attempt $ATTEMPT failed for $GROUP — resetting simulator and retrying..."
      reset_simulator
    fi
  done

  if [ "$SUCCESS" = false ]; then
    echo "ERROR: $GROUP failed after 2 attempts"
    FAILED_GROUPS+=("$GROUP")
  fi

  echo "Shutting down emulator..."
  xcrun simctl shutdown all 2>/dev/null || true
  sleep 5

done

# -----------------------------
# Report
# -----------------------------
if [ ${#FAILED_GROUPS[@]} -ne 0 ]; then
  echo "The following test groups failed:"
  for G in "${FAILED_GROUPS[@]}"; do echo "  - $G"; done
  exit 1
fi

echo "All test groups completed successfully!"
