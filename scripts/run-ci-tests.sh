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
echo "Shutting down and erasing all simulators..."
xcrun simctl shutdown all || true
xcrun simctl erase all || true

# -----------------------------
# Run tests group by group
# -----------------------------
for GROUP in "${MODULE_GROUPS[@]}"; do
  echo "----------------------------------------"
  echo "Running test group: $GROUP"
  echo "----------------------------------------"

  TEST_XCARGS="$COMMON_XCARGS"
  for MODULE in $GROUP; do
    TEST_XCARGS+=" -only-testing:${MODULE}"
  done

  xcode-project run-tests \
    "${COMMON_ARGS[@]}" \
    --test-xcargs "$TEST_XCARGS"

done

echo "All test groups completed successfully!"
