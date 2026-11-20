#!/bin/sh
# SPDX-FileCopyrightText: Estonian Information System Authority
# SPDX-License-Identifier: LGPL-2.1-or-later

# Packages the OpenSSL headers and static archives from the libdigidocpp iOS
# artifacts for libcdoc. At the app link, OpenSSL symbols can resolve from
# digidocpp.framework and from this XCFramework's static archive.
#
# Usage: create-openssl-xcframework.sh <iphoneos dir> <iphonesimulator dir>
# Each directory contains lib/libcrypto.a, lib/libssl.a and include/openssl.

set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <iphoneos dir> <iphonesimulator dir>" >&2
  exit 1
fi

OUTPUT="$(cd "$(dirname "$0")/.." && pwd)/Modules/CryptoLib/CDoc/OpenSSL.xcframework"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

ARGS=""
for PLATFORM in iphoneos iphonesimulator; do
  if [ "${PLATFORM}" = iphoneos ]; then SOURCE="$1"; else SOURCE="$2"; fi
  SLICE="${WORK}/${PLATFORM}"
  mkdir -p "${SLICE}/include"
  libtool -static -arch_only arm64 -no_warning_for_no_symbols -o "${SLICE}/libopenssl.a" "${SOURCE}/lib/libcrypto.a" "${SOURCE}/lib/libssl.a"
  cp -R "${SOURCE}/include/openssl" "${SLICE}/include/"
  ARGS="${ARGS} -library ${SLICE}/libopenssl.a -headers ${SLICE}/include"
done

rm -rf "${OUTPUT}"
# shellcheck disable=SC2086
xcodebuild -create-xcframework ${ARGS} -output "${OUTPUT}"
