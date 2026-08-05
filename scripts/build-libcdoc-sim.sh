#!/bin/sh
set -e  # stop on any unhandled error

# Move to project folder root
cd "$(dirname "$0")/.."

# ====== Configurable parameters ======
export PATH=$PATH:/usr/local/bin:/opt/homebrew/bin

SOURCE_DIR="$(pwd)/build/src/libcdoc"
BUILD_DIR="$(pwd)/build/libcdoc-sim"
INSTALL_DIR="$(pwd)/output/libcdoc-sim"

OPENSSL_DIR="$(pwd)/../Downloads/libdigidocppFiles_1910/libdigidocpp.iphonesimulator"
DEPLOYMENT_TARGET="18.0"

# ====== Clone repo if missing ======
if [ ! -d "${SOURCE_DIR}" ]; then
    git clone https://github.com/open-eid/libcdoc.git "${SOURCE_DIR}"
fi

# ====== Configure ======
cmake \
  -S "${SOURCE_DIR}" \
  -B "${BUILD_DIR}" \
  -GXcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-std=c++20 -D_LIBCPP_DISABLE_AVAILABILITY" \
  -DCMAKE_XCODE_ATTRIBUTE_INFOPLIST_FILE="" \
  -DBUILD_FRAMEWORK=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TOOLS=OFF \
  -DOPENSSL_ROOT_DIR="${OPENSSL_DIR}" \
  -DOPENSSL_INCLUDE_DIR="${OPENSSL_DIR}/include" \
  -DOPENSSL_CRYPTO_LIBRARY="${OPENSSL_DIR}/lib/libcrypto.a" \
  -DOPENSSL_SSL_LIBRARY="${OPENSSL_DIR}/lib/libssl.a" \
  -DFlatBuffers_DIR="/opt/homebrew/Cellar/flatbuffers/25.2.10/lib/cmake/flatbuffers" \
  -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=YES \
  -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=YES \
  -DCMAKE_DISABLE_FIND_PACKAGE_Boost=YES

# ====== Real build ======
echo ">>> Running real build"
cmake --build "${BUILD_DIR}" --config Release

# ====== Install ======
echo ">>> Installing"
cmake --install "${BUILD_DIR}" --config Release
