#!/bin/sh
set -e  # stop on any unhandled error

# Move to project folder
cd "$(dirname "$0")/.."

# ====== Configurable parameters ======
: ${OPENLDAP:=openldap-2.6.10}
: ${IPHONEOS_DEPLOYMENT_TARGET:="13.0"}
: ${ARCHS:="arm64"}
: ${PLATFORM_NAME:="iphoneos"}

# Where to install build artifacts
: $PROJECT_DIR:="$(pwd)"}
# : ${PREFIX:="$(pwd)/build/openldap"}
: ${PREFIX:="$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap"}
# Where to download and build sources
: ${SOURCE_DIR:="$(pwd)/build"}
# Path to OpenSSL (adjust as needed)
: ${OPENSSL_DIR:="$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl"}

SYSROOT=$(/usr/bin/xcrun --sdk ${PLATFORM_NAME} --show-sdk-path)

export IPHONEOS_DEPLOYMENT_TARGET
export CFLAGS="-arch ${ARCHS// / -arch } -isysroot ${SYSROOT} -miphoneos-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="${CFLAGS} -I${OPENSSL_DIR}/include"
export LDFLAGS="-L${OPENSSL_DIR}/lib -isysroot ${SYSROOT}"
yes | rm -rf ./Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap/*
rm -rf "${SOURCE_DIR}"
mkdir -p "${SOURCE_DIR}"
cd "${SOURCE_DIR}"

# ====== Download tarball if needed ======
if [ ! -f ${OPENLDAP}.tgz ]; then
  curl -O -L http://mirror.eu.oneandone.net/software/openldap/openldap-release/${OPENLDAP}.tgz
fi

# ====== Extract & configure ======
if [ ! -d ${OPENLDAP} ]; then
    tar xf ${OPENLDAP}.tgz
    cd ${OPENLDAP}

    # disable building clients, servers, tests, docs
    sed -ie 's! clients servers tests doc!!' Makefile.in

    echo "Running configure..."
    ./configure \
       --build=aarch64-apple-darwin \
       --host=arm-apple-darwin \
       --prefix=${PREFIX} \
       --enable-static --disable-shared \
       --disable-syslog --disable-local --disable-slapd \
       --disable-cleartext --disable-mdb --disable-relay --disable-syncprov \
       --without-cyrus-sasl --without-systemd --without-fetch \
       --without-threads --with-tls=openssl --without-argon2 \
       ac_cv_func_memcmp_working=yes lt_cv_apple_cc_single_mod=yes \
       || { echo "configure failed, see config.log"; cat config.log; exit 1; }
else
    cd ${OPENLDAP}
fi

# ====== Build ======
echo "Running make install..."
make install || { echo "make install failed"; exit 1; }

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

echo "OpenLDAP build finished successfully"
echo "Artifacts installed into: ${PREFIX}"


