#!/usr/bin/env bash
set -euo pipefail

# Move to project folder root
cd "$(dirname "$0")/.."

# ---- Config ----
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT="${PROJECT_ROOT}/build-cdoc"

SOURCE_DIR="${PROJECT_ROOT}/../Downloads/libcdoc"
GIT_URL="https://github.com/open-eid/libcdoc.git"

FLATBUFFERS_GIT_URL="https://github.com/google/flatbuffers.git"
FLATBUFFERS_SRC="${BUILD_ROOT}/third_party/flatbuffers-src"

# Host (macOS) flatbuffers (provides flatc + cmake package with targets)
FLATBUFFERS_HOST_BUILD="${BUILD_ROOT}/third_party/flatbuffers-host-build"
FLATBUFFERS_HOST_INSTALL="${BUILD_ROOT}/third_party/flatbuffers-host-install"

# iOS flatbuffers (provides libflatbuffers.a for each SDK)
FLATBUFFERS_IOS_BUILD_ROOT="${BUILD_ROOT}/third_party/flatbuffers-build"
FLATBUFFERS_IOS_INSTALL_ROOT="${BUILD_ROOT}/third_party/flatbuffers-install"

OPENSSL_ROOT_IOS="${PROJECT_ROOT}/../Downloads/libdigidocppFiles_1910/libdigidocpp.iphoneos"
OPENSSL_ROOT_SIM="${PROJECT_ROOT}/../Downloads/libdigidocppFiles_1910/libdigidocpp.iphonesimulator"

# Defaults
# Use: BUILD_TYPE=Debug ./build-libcdoc-ios.sh  OR  BUILD_TYPE=RelWithDebInfo ./build-libcdoc-ios.sh
BUILD_TYPE="${BUILD_TYPE:-Release}"
IOS_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET:-15.0}"

# Control symbol stripping (default: keep symbols for Debug/RelWithDebInfo, strip for Release)
STRIP_SYMBOLS="${STRIP_SYMBOLS:-auto}"   # auto|0|1
# Generate dSYM bundles (default: on for Debug/RelWithDebInfo)
GENERATE_DSYM="${GENERATE_DSYM:-auto}"   # auto|0|1

# Generator
if command -v ninja >/dev/null 2>&1; then
  CMAKE_GENERATOR="Ninja"
else
  CMAKE_GENERATOR="Unix Makefiles"
fi

export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin"

# ---- Helpers ----
need() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required tool: $1" >&2; exit 1; }
}

sdk_path() {
  local sdk="$1"
  xcrun --sdk "$sdk" --show-sdk-path
}

ensure_dirs() {
  mkdir -p "${BUILD_ROOT}/third_party" "${BUILD_ROOT}/logs" "${BUILD_ROOT}/build" "${BUILD_ROOT}/install"
}

ensure_flatbuffers_src() {
  if [[ ! -d "${FLATBUFFERS_SRC}/.git" ]]; then
    echo "Cloning flatbuffers into ${FLATBUFFERS_SRC} ..." >&2
    git clone "${FLATBUFFERS_GIT_URL}" "${FLATBUFFERS_SRC}" >&2
  fi
}

is_truthy() {
  # Portable lowercase (no ${var,,})
  local v="${1:-}"
  v="$(printf '%s' "$v" | tr '[:upper:]' '[:lower:]')"
  case "$v" in
    1|true|yes|y|on) return 0 ;;
    *) return 1 ;;
  esac
}

# Decide stripping based on BUILD_TYPE (unless overridden)
should_strip() {
  if [[ "${STRIP_SYMBOLS}" != "auto" ]]; then
    is_truthy "${STRIP_SYMBOLS}"
    return $?
  fi

  case "${BUILD_TYPE}" in
    Debug|RelWithDebInfo) return 1 ;;  # don't strip
    *) return 0 ;;                     # strip for Release/MinSizeRel/others
  esac
}

# Decide dSYM based on BUILD_TYPE (unless overridden)
should_dsym() {
  if [[ "${GENERATE_DSYM}" != "auto" ]]; then
    is_truthy "${GENERATE_DSYM}"
    return $?
  fi

  case "${BUILD_TYPE}" in
    Debug|RelWithDebInfo) return 0 ;;  # generate dSYM
    *) return 1 ;;
  esac
}

# ---- Build FlatBuffers host (macOS): flatc + flatlib ON ----
flatbuffers_host_pkg_dir() {
  ensure_flatbuffers_src

  local pkg_dir="${FLATBUFFERS_HOST_INSTALL}/lib/cmake/flatbuffers"
  if [[ -f "${pkg_dir}/flatbuffers-config.cmake" ]]; then
    echo "${pkg_dir}"
    return 0
  fi

  mkdir -p "${FLATBUFFERS_HOST_BUILD}" "${FLATBUFFERS_HOST_INSTALL}"
  echo "---- Building FlatBuffers host (flatc + flatlib) ----" >&2

  cmake -G "${CMAKE_GENERATOR}" \
    -S "${FLATBUFFERS_SRC}" \
    -B "${FLATBUFFERS_HOST_BUILD}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_INSTALL_PREFIX="${FLATBUFFERS_HOST_INSTALL}" \
    -DFLATBUFFERS_BUILD_TESTS=OFF \
    -DFLATBUFFERS_BUILD_FLATHASH=OFF \
    -DFLATBUFFERS_BUILD_FLATC=ON \
    -DFLATBUFFERS_BUILD_FLATLIB=ON \
    -DFLATBUFFERS_INSTALL=ON >&2

  cmake --build "${FLATBUFFERS_HOST_BUILD}" --config "${BUILD_TYPE}" >&2
  cmake --install "${FLATBUFFERS_HOST_BUILD}" --config "${BUILD_TYPE}" >&2

  if [[ ! -f "${pkg_dir}/flatbuffers-config.cmake" ]]; then
    echo "ERROR: Host flatbuffers package not found at: ${pkg_dir}" >&2
    exit 1
  fi

  echo "${pkg_dir}"
}

# ---- Build FlatBuffers for iOS (per SDK): flatlib ON, flatc OFF ----
build_flatbuffers_ios_one() {
  local name="$1"   # iphoneos | iphonesimulator
  local sdk="$2"    # iphoneos | iphonesimulator
  local archs="$3"  # "arm64" or "arm64;x86_64"

  ensure_flatbuffers_src

  local sysroot
  sysroot="$(sdk_path "$sdk")"

  local build_dir="${FLATBUFFERS_IOS_BUILD_ROOT}/${name}"
  local install_dir="${FLATBUFFERS_IOS_INSTALL_ROOT}/${name}"
  local pkg_dir="${install_dir}/lib/cmake/flatbuffers"
  local lib_path="${install_dir}/lib/libflatbuffers.a"

  # Skip if already installed
  if [[ -f "${lib_path}" && -f "${pkg_dir}/flatbuffers-config.cmake" ]]; then
    echo "${pkg_dir}"
    return 0
  fi

  mkdir -p "${build_dir}" "${install_dir}"
  echo "---- Building FlatBuffers for ${name} (iOS) ----" >&2

  cmake -G "${CMAKE_GENERATOR}" \
    -S "${FLATBUFFERS_SRC}" \
    -B "${build_dir}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="${sysroot}" \
    -DCMAKE_OSX_ARCHITECTURES="${archs}" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET}" \
    -DCMAKE_INSTALL_PREFIX="${install_dir}" \
    -DFLATBUFFERS_BUILD_TESTS=OFF \
    -DFLATBUFFERS_BUILD_FLATHASH=OFF \
    -DFLATBUFFERS_BUILD_FLATC=OFF \
    -DFLATBUFFERS_BUILD_FLATLIB=ON \
    -DFLATBUFFERS_INSTALL=ON >&2

  cmake --build "${build_dir}" --config "${BUILD_TYPE}" >&2
  cmake --install "${build_dir}" --config "${BUILD_TYPE}" >&2

  if [[ ! -f "${lib_path}" ]]; then
    echo "ERROR: iOS libflatbuffers.a not found at: ${lib_path}" >&2
    exit 1
  fi

  echo "${pkg_dir}"
}

# Create dSYM for a framework binary (LOUD: fails if requested and not produced)
maybe_generate_dsym_for_framework() {
  local framework_bin="$1"   # .../cdoc.framework/cdoc

  if ! should_dsym; then
    return 0
  fi
  if ! command -v dsymutil >/dev/null 2>&1; then
    echo "dsymutil not found; skipping dSYM generation" >&2
    return 0
  fi
  if [[ ! -f "${framework_bin}" ]]; then
    echo "Framework binary not found: ${framework_bin}" >&2
    return 0
  fi

  # IMPORTANT: if this is a static library (ar archive), dsymutil will fail.
  # The dSYM will be generated at the FINAL link step (your app/framework that links it).
  if command -v file >/dev/null 2>&1; then
    local ft
    ft="$(file -b "${framework_bin}" || true)"
    if echo "${ft}" | grep -qiE 'ar archive|current ar archive|static library'; then
      echo "Skipping dSYM: ${framework_bin} is a static library (${ft}). dSYM will be produced when the app links it." >&2
      return 0
    fi
  fi

  local out="${framework_bin}.dSYM"
  echo "Generating dSYM: ${out}" >&2

  rm -rf "${out}"
  dsymutil "${framework_bin}" -o "${out}"

  if [[ ! -d "${out}" ]]; then
    echo "ERROR: dsymutil ran but dSYM folder was not created: ${out}" >&2
    exit 1
  fi

  if command -v dwarfdump >/dev/null 2>&1; then
    echo "dSYM UUIDs:" >&2
    dwarfdump --uuid "${out}" >&2 || true
  fi
}

# ---- Build libcdoc for one platform ----
build_one() {
  local name="$1"           # iphoneos | iphonesimulator
  local sdk="$2"            # iphoneos | iphonesimulator
  local archs="$3"          # "arm64" or "arm64;x86_64"
  local openssl_root="$4"   # path to libdigidocpp.<platform>

  local sysroot
  sysroot="$(sdk_path "$sdk")"

  # Ensure deps:
  local flatbuffers_host_dir
  flatbuffers_host_dir="$(flatbuffers_host_pkg_dir)"

  local flatbuffers_ios_pkg_dir
  flatbuffers_ios_pkg_dir="$(build_flatbuffers_ios_one "${name}" "${sdk}" "${archs}")"

  local flatbuffers_install_dir="${FLATBUFFERS_IOS_INSTALL_ROOT}/${name}"
  local flatbuffers_lib="${flatbuffers_install_dir}/lib/libflatbuffers.a"

  # OpenSSL (iOS) explicit paths
  local openssl_inc="${openssl_root}/include"
  local openssl_crypto="${openssl_root}/lib/libcrypto.a"
  local openssl_ssl="${openssl_root}/lib/libssl.a"

  if [[ ! -d "${openssl_inc}/openssl" ]]; then
    echo "ERROR: OpenSSL headers not found at: ${openssl_inc}/openssl" >&2
    exit 1
  fi
  if [[ ! -f "${openssl_crypto}" ]]; then
    echo "ERROR: OpenSSL crypto lib not found at: ${openssl_crypto}" >&2
    exit 1
  fi
  if [[ ! -f "${openssl_ssl}" ]]; then
    echo "ERROR: OpenSSL ssl lib not found at: ${openssl_ssl}" >&2
    exit 1
  fi

  # FlatBuffers iOS lib sanity
  if [[ ! -f "${flatbuffers_lib}" ]]; then
    echo "ERROR: iOS flatbuffers lib not found at: ${flatbuffers_lib}" >&2
    exit 1
  fi

  local build_dir="${BUILD_ROOT}/build/${name}"
  local install_dir="${BUILD_ROOT}/install/${name}"
  local logs_dir="${BUILD_ROOT}/logs"
  mkdir -p "${build_dir}" "${install_dir}" "${logs_dir}"

  local do_strip="ON"
  if should_strip; then
    do_strip="ON"
  else
    do_strip="OFF"
  fi

  echo "============================================================"
  echo "Building: ${name}"
  echo "  SDK:        ${sdk} -> ${sysroot}"
  echo "  ARCHS:      ${archs}"
  echo "  Build type: ${BUILD_TYPE}"
  echo "  Strip:      ${do_strip} (STRIP_SYMBOLS=${STRIP_SYMBOLS})"
  echo "  dSYM:       $(should_dsym && echo ON || echo OFF) (GENERATE_DSYM=${GENERATE_DSYM})"
  echo "  OpenSSL:    ${openssl_root}"
  echo "  FlatBuffers host pkg: ${flatbuffers_host_dir}"
  echo "  FlatBuffers iOS pkg:  ${flatbuffers_ios_pkg_dir}"
  echo "  BUILD:      ${build_dir}"
  echo "  INSTALL:    ${install_dir}"
  echo "============================================================"

  # Configure
  cmake -G "${CMAKE_GENERATOR}" \
    -S "${SOURCE_DIR}" \
    -B "${build_dir}" \
    -DFRAMEWORK_DESTINATION="${install_dir}/Frameworks" \
    -DBUILD_TOOLS=OFF \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="${sysroot}" \
    -DCMAKE_OSX_ARCHITECTURES="${archs}" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET}" \
    -DFRAMEWORK=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_INSTALL_PREFIX="${install_dir}" \
    -DINSTALL_FRAMEWORKDIR="${install_dir}" \
    -DOPENSSL_ROOT_DIR="${openssl_root}" \
    -DOPENSSL_INCLUDE_DIR="${openssl_inc}" \
    -DOPENSSL_CRYPTO_LIBRARY="${openssl_crypto}" \
    -DOPENSSL_SSL_LIBRARY="${openssl_ssl}" \
    -DOPENSSL_USE_STATIC_LIBS=TRUE \
    -DFlatBuffers_DIR="${flatbuffers_host_dir}" \
    -DCMAKE_PREFIX_PATH="${flatbuffers_install_dir};${FLATBUFFERS_HOST_INSTALL}" \
    -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=YES \
    -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=YES \
    -DCMAKE_INSTALL_DO_STRIP="${do_strip}" \
    -DCMAKE_STRIP="" \
    -DCMAKE_C_FLAGS_DEBUG="-g" \
    -DCMAKE_CXX_FLAGS_DEBUG="-g" \
    -DCMAKE_C_FLAGS_RELWITHDEBINFO="-O2 -g" \
    -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g" \
    -DCMAKE_XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
    2>&1 | tee "${logs_dir}/configure-${name}.log"

  # Build
  cmake --build "${build_dir}" --config "${BUILD_TYPE}" 2>&1 | tee "${logs_dir}/build-${name}.log"

  # Install
  cmake --install "${build_dir}" --config "${BUILD_TYPE}" 2>&1 | tee "${logs_dir}/install-${name}.log"

  # dSYM for your framework binary
  local fw_bin="${install_dir}/Frameworks/cdoc.framework/cdoc"
  maybe_generate_dsym_for_framework "${fw_bin}"
}

# ---- Pre-flight ----
need git
need cmake
need xcrun
ensure_dirs

# Fetch libcdoc if missing
if [[ ! -d "${SOURCE_DIR}/.git" ]]; then
  echo "Cloning libcdoc into ${SOURCE_DIR} ..."
  git clone "${GIT_URL}" "${SOURCE_DIR}"
else
  echo "Using existing libcdoc checkout at ${SOURCE_DIR}"
fi

# ---- Build both variants ----
build_one "iphoneos"        "iphoneos"        "arm64"          "${OPENSSL_ROOT_IOS}"
build_one "iphonesimulator" "iphonesimulator" "arm64;x86_64"   "${OPENSSL_ROOT_SIM}"

# ---- Optional: Create XCFramework (FRAMEWORK-based) ----
if command -v xcodebuild >/dev/null 2>&1; then
  IOS_FW="${BUILD_ROOT}/install/iphoneos/Frameworks/cdoc.framework"
  SIM_FW="${BUILD_ROOT}/install/iphonesimulator/Frameworks/cdoc.framework"

  if [[ -d "${IOS_FW}" && -d "${SIM_FW}" ]]; then
    OUT_XC="${BUILD_ROOT}/cdoc.xcframework"
    rm -rf "${OUT_XC}"

    echo "Creating XCFramework (frameworks): ${OUT_XC}"
    xcodebuild -create-xcframework \
      -framework "${IOS_FW}" \
      -framework "${SIM_FW}" \
      -output "${OUT_XC}"

    echo "XCFramework created at: ${OUT_XC}"
  else
    echo "Skipping XCFramework: expected frameworks not found:"
    echo "  ${IOS_FW}"
    echo "  ${SIM_FW}"
  fi
else
  echo "xcodebuild not found; skipping XCFramework creation."
fi

echo
echo "Done. Outputs:"
echo "  Device framework:    ${BUILD_ROOT}/install/iphoneos/Frameworks/cdoc.framework"
echo "  Simulator framework: ${BUILD_ROOT}/install/iphonesimulator/Frameworks/cdoc.framework"
echo "  (Optional) XCFramework: ${BUILD_ROOT}/cdoc.xcframework"
echo
echo "Tips:"
echo "  Debug build (max symbols):     BUILD_TYPE=Debug STRIP_SYMBOLS=0 ./build-libcdoc.sh"
echo "  RelWithDebInfo (opt+symbols):  BUILD_TYPE=RelWithDebInfo ./build-libcdoc.sh"
