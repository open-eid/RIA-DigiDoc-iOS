# RIA-DigiDoc-iOS v3

![EU Regional Development Fund](docs/images/EL_Regionaalarengu_Fond_horisontaalne-vaike.jpg)

* License: LGPL 2.1
* &copy; Estonian Information System Authority

This repo contains source code for RIA DigiDoc application for iOS.
This application contains following functionality:
* Sign documents with ID-card (via USB card reader and NFC), mobile-ID and Smart-ID.
* Encrypt and decrypt documents (via USB card reader and NFC)
* Control ID-card certificates validity (via USB card reader and NFC)
* Change or unlock PIN/PUK codes (via USB card reader and NFC)

## libdigidocpp
RIA-DigiDoc-iOS is using static version of libdigidoc. libdigidoc is used in app for managing container manipulations. More info: https://github.com/open-eid/libdigidocpp

## libdcdoc
RIA-DigiDoc-iOS is using static version of libcdoc. libcdoc is used in app for encrypt and decrypt operations. More info: https://github.com/open-eid/libcdoc

# Features
* Creating ASiC-E containers
* Signing containers with Mobile-ID, Smart-ID and ID-card (via USB card reader and NFC)
* Validating ASiC-E, BDOC, ASIC-S and DDOC containers
* Validating detached XAdES and CAdES
* Encrypting, decrypting and validating CDOC and CDOC2 containers

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
