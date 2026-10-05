// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>

#import <digidocpp/Container.h>
#import <digidocpp/DataFile.h>
#import <digidocpp/Signature.h>
#import <digidocpp/Exception.h>
#import <digidocpp/crypto/X509Cert.h>
#import <digidocpp/crypto/Signer.h>
#import <digidocpp/crypto/X509Cert.h>

#import "DigiDocSigningWrapper.h"
#import "../Model/DigiDocContainer.h"
#import "../Model/DigiDocDataFile.h"
#import "../Model/DigiDocSignature.h"
#import "../Model/DigiDocRoleData.h"
#import "../Container/DigiDocContainerWrapper.h"
#import "Exception/Util/ExceptionUtil.h"

@implementation DigiDocSigningWrapper {
    std::unique_ptr<digidoc::Container> _docContainer;
    digidoc::Signature *_signature;
    std::unique_ptr<digidoc::Signer> _signer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _docContainer = nil;
        _signature = nil;
        _signer = {};
    }
    return self;
}

- (void)prepareSignature:(NSData *)cert containerPath:(NSString *)containerPath roleData:(DigiDocRoleData *)roleData userAgent:(NSString *)userAgent completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    dispatch_async([DigiDocContainerWrapper libraryQueue], ^{
        NSError *error = nil;
        NSData *dataToSign = nil;
        try {
            @synchronized ([DigiDocContainerWrapper class]) {
                self->_signature = NULL;
                self->_docContainer.reset();
                self->_signer = std::make_unique<WebSigner>(digidoc::X509Cert(reinterpret_cast<const unsigned char *>(cert.bytes), cert.length));

                DigiDocContainerOpenCB cb(TRUE);

                self->_docContainer = digidoc::Container::openPtr(containerPath.UTF8String, &cb);

                self->_signer->setProfile("time-stamp");

                self->_signer->setSignatureProductionPlace(roleData.city.UTF8String ?: "",
                                                           roleData.state.UTF8String ?: "",
                                                           roleData.zipcode.UTF8String ?: "",
                                                           roleData.country.UTF8String ?: "");

                self->_signer->setUserAgent(userAgent.UTF8String);

                std::vector<std::string> rolesList;
                for (NSString *role in roleData.roles) {
                    if (role.length > 0) {
                        rolesList.push_back(role.UTF8String);
                    }
                }

                self->_signer->setSignerRoles(rolesList);

                self->_signature = self->_docContainer->prepareSignature(self->_signer.get());
                dataToSign = [DigiDocSigningWrapper getNSDataFromVector:self->_signature->dataToSign()];
            }
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()] ?: @"Signature preparing failed",
                @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
            };

            dataToSign = nil;
            error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];
        } catch(const std::exception &e) {
            dataToSign = nil;
            error = [NSError errorWithDomain:@"LibdigidocLib" code:-1 userInfo:@{
                NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.what()] ?: @"Signature preparing failed"
            }];
        } catch(...) {
            dataToSign = nil;
            error = [NSError errorWithDomain:@"LibdigidocLib" code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"Signature preparing failed"
            }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(dataToSign, error);
        });
    });
}

- (void)addSignature:(NSData *)data completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_async([DigiDocContainerWrapper libraryQueue], ^{
        NSError *error = nil;
        BOOL success = NO;

        try {
            @synchronized ([DigiDocContainerWrapper class]) {
                if (!self->_signature) {
                    error = [NSError errorWithDomain:@"LibdigidocLib" code:2 userInfo:@{
                        NSLocalizedDescriptionKey: @"Did not find signature"
                    }];
                } else if (auto timeStampTime = self->_signature->TimeStampTime(); !timeStampTime.empty()) {
                    success = YES;
                } else {
                    auto *bytes = reinterpret_cast<const unsigned char*>(data.bytes);
                    self->_signature->setSignatureValue({bytes, bytes + data.length});
                    self->_signature->extendSignatureProfile(self->_signer.get());
                    self->_signature->validate();
                    self->_docContainer->save();
                    success = YES;
                }
            }
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()] ?: @"Signature adding failed",
                @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
            };

            success = NO;
            error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];
        } catch(const std::exception &e) {
            success = NO;
            error = [NSError errorWithDomain:@"LibdigidocLib" code:-1 userInfo:@{
                NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.what()] ?: @"Signature adding failed"
            }];
        } catch(...) {
            success = NO;
            error = [NSError errorWithDomain:@"LibdigidocLib" code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"Signature adding failed"
            }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success, error);
        });
    });
}

- (void)dealloc {
    digidoc::Container *container = _docContainer.release();
    digidoc::Signer *signer = _signer.release();
    _signature = NULL;

    if (!container && !signer) {
        return;
    }

    dispatch_async([DigiDocContainerWrapper libraryQueue], ^{
        @synchronized ([DigiDocContainerWrapper class]) {
            delete container;
            delete signer;
        }
    });
}

+ (NSData *)getNSDataFromVector:(const std::vector<unsigned char>&)vectorData {
    return [NSData dataWithBytes:vectorData.data() length:vectorData.size()];
}

class WebSigner: public digidoc::Signer {
public:
    WebSigner(const digidoc::X509Cert &cert): _cert(cert) {}

private:
    digidoc::X509Cert cert() const override { return _cert; }
    std::vector<unsigned char> sign(const std::string &, const std::vector<unsigned char> &) const override
    {
        return {};
    }

    digidoc::X509Cert _cert;
};

struct DigiDocContainerOpenCB: public digidoc::ContainerOpenCB {
private:
    bool validate;

public:
    DigiDocContainerOpenCB(bool validate)
    : validate(validate) {}

    virtual bool validateOnline() const override {
        return validate;
    }
};

@end
