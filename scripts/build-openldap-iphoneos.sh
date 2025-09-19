#!/bin/sh
set -e  # stop on any unhandled error

# Move to project folder root
cd "$(dirname "$0")/.."

# ====== Configurable parameters ======
: ${OPENLDAP:=openldap-2.6.10}
: ${IPHONEOS_DEPLOYMENT_TARGET:="15.0"}
: ${PLATFORM_NAME:="iphoneos"}

# Final merged output
: ${PREFIX:="$(pwd)/openldap.iphoneos"}
# Where to download/build
: ${SOURCE_DIR:="$(pwd)/build"}
# Where to keep pristine extracted source
SRC_DIR="${SOURCE_DIR}/src"
# Path to OpenSSL (adjust as needed)
: ${OPENSSL_DIR:="$(pwd)/../Downloads/libdigidocppFiles_1910/libdigidocpp.${PLATFORM_NAME}"}

# Clean old outputs
yes | rm -rf "${PREFIX:?}"/*
rm -rf "${SOURCE_DIR}"
mkdir -p "${SOURCE_DIR}"
cd "${SOURCE_DIR}"

# ====== Download tarball if needed ======
if [ ! -f ${OPENLDAP}.tgz ]; then
  curl -O -L http://mirror.eu.oneandone.net/software/openldap/openldap-release/${OPENLDAP}.tgz
fi

# ====== Extract sources once into pristine copy ======
mkdir -p "${SRC_DIR}"
if [ ! -d "${SRC_DIR}/${OPENLDAP}" ]; then
  tar xf ${OPENLDAP}.tgz -C "${SRC_DIR}"
fi

# ====== Build function ======
build_arch() {
  ARCH=$1
  SYSROOT=$(/usr/bin/xcrun --sdk ${PLATFORM_NAME} --show-sdk-path)
  BUILD_DIR="${SOURCE_DIR}/${OPENLDAP}-${ARCH}"
  INSTALL_DIR="${BUILD_DIR}/install"

  echo ">>> Building OpenLDAP for ${PLATFORM_NAME} (${ARCH})"

  # Fresh per-arch working copy
  rm -rf "${BUILD_DIR}"
  cp -R "${SRC_DIR}/${OPENLDAP}" "${BUILD_DIR}"

  # Ensure install dir is clean
  rm -rf "${INSTALL_DIR}"
  mkdir -p "${INSTALL_DIR}"

  cd "${BUILD_DIR}"

  # Disable building clients, servers, tests, docs
  sed -ie 's! clients servers tests doc!!' Makefile.in

  export CC="$(xcrun -sdk ${PLATFORM_NAME} -f clang)"
  export AR="$(xcrun -sdk ${PLATFORM_NAME} -f ar)"
  export RANLIB="$(xcrun -sdk ${PLATFORM_NAME} -f ranlib)"
  export IPHONEOS_DEPLOYMENT_TARGET

  export CFLAGS="-arch ${ARCH} -isysroot ${SYSROOT} -miphoneos-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
  export CPPFLAGS="${CFLAGS} -I${OPENSSL_DIR}/include"
  export LDFLAGS="-L${OPENSSL_DIR}/lib -isysroot ${SYSROOT}"

  ./configure \
    --build=aarch64-apple-darwin \
       --host=${ARCH}-apple-darwin \
       --prefix=${INSTALL_DIR} \
       --enable-static --disable-shared \
       --disable-syslog --disable-local --disable-slapd \
       --disable-cleartext --disable-mdb --disable-relay --disable-syncprov \
       --without-cyrus-sasl --without-systemd --without-fetch \
       --without-threads --with-tls=openssl --without-argon2 \
       ac_cv_func_memcmp_working=yes lt_cv_apple_cc_single_mod=yes \
       || { echo "configure failed for $ARCH, see config.log"; cat config.log; exit 1; }

  make -j$(sysctl -n hw.ncpu)
  make install
}

# ====== Build only arm64 ======
build_arch arm64

# ====== Merge libs with lipo ======
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/include"

# Copy binaries (from arm64 build)
cp -R "${SOURCE_DIR}/${OPENLDAP}-arm64/install/lib/"* "${PREFIX}/lib/"

# Copy headers (take from arm64 build as representative)
cp -R "${SOURCE_DIR}/${OPENLDAP}-arm64/install/include/"* "${PREFIX}/include/"

# ====== Generate Swift modulemap ======
cat > "${PREFIX}/include/module.modulemap" <<EOF
module LDAP [system] {
    private header "ldap.h"
    link "crypto"
    link "ssl"
    link "lber"
    link "ldap"
    export *
}
EOF

echo "✅ OpenLDAP iphoneos build finished successfully"
echo "Artifacts installed into: ${PREFIX}"
