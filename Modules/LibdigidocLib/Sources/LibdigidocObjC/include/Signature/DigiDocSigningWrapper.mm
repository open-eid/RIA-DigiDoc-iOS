/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
#import "Exception/Util/ExceptionUtil.h"

@implementation DigiDocSigningWrapper {}

static std::unique_ptr<digidoc::Container> docContainer = nil;
static digidoc::Signature *signature = nil;
static std::unique_ptr<digidoc::Signer> signer{};

+ (void)prepareSignature:(NSData *)cert containerPath:(NSString *)containerPath roleData:(DigiDocRoleData *)roleData userAgent:(NSString *)userAgent completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
    NSError *error = nil;
    try {
        signer = std::make_unique<WebSigner>(digidoc::X509Cert(reinterpret_cast<const unsigned char *>(cert.bytes), cert.length));
        signature = NULL;

        DigiDocContainerOpenCB cb(TRUE);

        docContainer = digidoc::Container::openPtr(containerPath.UTF8String, &cb);

        signer->setProfile("time-stamp");

        signer->setSignatureProductionPlace(roleData.city.UTF8String ?: "",
                                            roleData.state.UTF8String ?: "",
                                            roleData.zipcode.UTF8String ?: "",
                                            roleData.country.UTF8String ?: "");

        signer->setUserAgent(userAgent.UTF8String);

        std::vector<std::string> rolesList;
        for (NSString *role in roleData.roles) {
            if (role.length > 0) {
                rolesList.push_back(role.UTF8String);
            }
        }
        signer->setSignerRoles(rolesList);

        signature = docContainer->prepareSignature(signer.get());
        NSData *data = [DigiDocSigningWrapper getNSDataFromVector:signature->dataToSign()];
        if (completion) completion(data, nil);
    } catch(const digidoc::Exception &e) {
        std::vector<digidoc::Exception> causes = e.causes();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
            @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
        };

        error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];

        if (completion) completion(nil, error);
    }
}

+ (void)addSignature:(NSData *)data completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    NSError *error = nil;
    if (!signature) {
        error = [NSError errorWithDomain:@"LibdigidocLib" code:2 userInfo:@{
            NSLocalizedDescriptionKey: @"Did not find signature"
        }];
        if (completion) completion(NO, error);
    }

    if (auto timeStampTime = signature->TimeStampTime(); !timeStampTime.empty()) {
        if (completion) completion(YES, error);
    }

    try {
        auto *bytes = reinterpret_cast<const unsigned char*>(data.bytes);
        signature->setSignatureValue({bytes, bytes + data.length});
        signature->extendSignatureProfile(signer.get());
        signature->validate();
        docContainer->save();
        if (completion) completion(YES, error);
    } catch(const digidoc::Exception &e) {
        std::vector<digidoc::Exception> causes = e.causes();
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
            @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
        };

        error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];

        if (completion) completion(NO, error);
    }
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
