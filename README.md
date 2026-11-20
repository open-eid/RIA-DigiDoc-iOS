# RIA-DigiDoc-iOS

![EU Regional Development Fund](docs/images/EL_Regionaalarengu_Fond_horisontaalne-vaike.jpg)

* License: LGPL-2.1-or-later
* &copy; Estonian Information System Authority

This repo contains source code for RIA DigiDoc application for iOS.
This application contains following functionality:
* Sign documents with ID-card (via NFC), mobile-ID and Smart-ID.
* Encrypt and decrypt documents (via NFC)
* Control ID-card certificates validity (via NFC)
* Change or unlock PIN/PUK codes (via NFC)

## libdigidocpp
RIA-DigiDoc-iOS is using static version of libdigidoc. libdigidoc is used in app for managing container manipulations. More info: https://github.com/open-eid/libdigidocpp

## libcdoc
CryptoLib builds [libcdoc](https://github.com/open-eid/libcdoc) from source for encryption and decryption. Clone with `--recurse-submodules` or run `git submodule update --init`, then install FlatBuffers with `brew install flatbuffers`.

The CDoc package's SwiftPM build-tool plugin generates the schema headers with `flatc` and exposes the matching C++ headers from the same Homebrew installation. Use Xcode 27 for Xcode builds so the C++ target can use the generated headers. When invoking `swift build` directly with Swift 6.3, use `--build-system swiftbuild`.

Update `VERSION_STR` in `Modules/CryptoLib/CDoc/Package.swift` when updating libcdoc. The script `scripts/create-openssl-xcframework.sh` recreates `OpenSSL.xcframework` from the libdigidocpp `iphoneos` and `iphonesimulator` artifacts.

# Features
* Creating ASiC-E containers
* Signing containers with Mobile-ID, Smart-ID and ID-card (via NFC)
* Validating ASiC-E, BDOC, ASIC-S and DDOC containers
* Validating detached XAdES and CAdES
* Encrypting, decrypting and validating CDOC and CDOC2 containers
* Change and unlock ID-card PIN codes (via NFC)

## Overview and how to use
App requirements, container format overview, documentation links and how to use instructions are available in Wiki:
[How to use](https://github.com/open-eid/RIA-DigiDoc-iOS/wiki/How-to-use)

## Building source code with Xcode
Installation instructions are available in Wiki: 
[Building source code with Xcode](https://github.com/open-eid/RIA-DigiDoc-iOS/wiki/Building-source-code-with-Xcode)

## Development
In [releases](https://github.com/open-eid/RIA-DigiDoc-iOS/releases) you will find application and modules, that you can use in your own application to implement document signing and encryption features. For more detailed instructions check out [wiki page](https://github.com/open-eid/RIA-DigiDoc-iOS/wiki).

## Support
Official builds are provided through official distribution point [https://www.id.ee/en/article/install-id-software/](https://www.id.ee/en/article/install-id-software/). If you want support, you need to be using official builds. Contact our support via www.id.ee for assistance.

Source code is provided on "as is" terms with no warranty (see license for more information). Do not file Github issues with generic support requests.
