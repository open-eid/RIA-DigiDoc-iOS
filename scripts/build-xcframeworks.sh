#!/bin/sh
set -e  # stop on any unhandled error

# Move to project folder root
cd "$(dirname "$0")/.."

mkdir -p output

xcodebuild -create-xcframework \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/lib/liblber.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/include/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/lib/liblber.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/include/" \
  -output "$(pwd)/output/liblber.xcframework"
  
  xcodebuild -create-xcframework \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/lib/libldap.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/include/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/lib/libldap.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/include/" \
  -output "$(pwd)/output/libldap.xcframework"

  xcodebuild -create-xcframework \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/lib/libcrypto.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/include/openssl/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/lib/libcrypto.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/include/openssl/" \
  -output "$(pwd)/output/libcrypto.xcframework"
  
  xcodebuild -create-xcframework \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/lib/libssl.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/include/openssl/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/lib/libssl.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/include/openssl/" \
  -output "$(pwd)/output/libssl.xcframework"

xcodebuild -create-xcframework \
    -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/lib/liblber.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/include/" \
    -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/lib/liblber.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/include/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/lib/libldap.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/include/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/lib/libldap.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/include/" \
  -output "$(pwd)/output/OpenLDAP.xcframework"
  
  xcodebuild -create-xcframework \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/lib/libcrypto.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/include/openssl/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/lib/libcrypto.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/include/openssl/" \
    -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/lib/libssl.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/include/openssl/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/lib/libssl.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/include/openssl/" \
  -output "$(pwd)/output/OpenSSL.xcframework"
  
  

libtool -static -o "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/lib/LDAP.a" \
      "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/lib/liblber.a" \
          "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/lib/libldap.a" \
      "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/lib/libcrypto.a" \
          "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphonesimulator/lib/libssl.a"


libtool -static -o "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/lib/LDAP.a" \
      "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/lib/liblber.a" \
          "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/lib/libldap.a" \
      "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/lib/libcrypto.a" \
          "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openssl.iphoneos/lib/libssl.a"

xcodebuild -create-xcframework \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphoneos/lib/LDAP.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/Headers/" \
  -library "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/openldap.iphonesimulator/lib/LDAP.a" -headers "$(pwd)/Modules/CryptoLib/Sources/CryptoObjC/Libs/Headers/" \
  -output "$(pwd)/output/LDAP.xcframework"
