/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

#import "DigiDocContainerWrapper.h"
#import "../Model/DigiDocContainer.h"
#import "../Model/DigiDocDataFile.h"
#import "../Model/DigiDocSignature.h"
#import "Exception/Util/ExceptionUtil.h"

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

@implementation DigiDocContainerWrapper {}

+ (void)dispatch:(void (^)(void))command completion:(void (^)(NSError *error))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;

        try {
            command();
        } catch (const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
                @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
            };

            error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    });
}

+ (NSString *)getSerialNumber:(NSString *)serialNumber {
    NSSet *types = [NSSet setWithObjects:@"PAS", @"IDC", @"PNO", @"TAX", @"TIN", nil];

    if (serialNumber.length > 6) {
        NSString *prefix = [serialNumber substringToIndex:3];
        if ([types containsObject:prefix] || ([serialNumber characterAtIndex:2] == ':' && [serialNumber characterAtIndex:5] == '-'))
        {
            return [serialNumber substringFromIndex:6];
        }
    }

    return serialNumber;
}

+ (NSData *)getNSDataFromVector:(const std::vector<unsigned char>&)vectorData {
    return [NSData dataWithBytes:vectorData.data() length:vectorData.size()];
}

+ (DigiDocSignatureStatus)determineSignatureStatus:(int)status {
    typedef digidoc::Signature::Validator::Status Status;

    switch (status) {
        case Status::Valid: return Valid;
        case Status::NonQSCD: return NonQSCD;
        case Status::Warning: return Warning;
        case Status::Unknown: return UnknownStatus;
        default: return Invalid;
    }
}

+ (DigiDocSignature *)getSignature:(digidoc::Signature *)signature pos:(int)pos mediaType:(const std::string&)mediaType dataFileCount:(NSInteger)dataFileCount {

    digidoc::X509Cert signingCert = signature->signingCertificate();
    digidoc::X509Cert ocspCert = signature->OCSPCertificate();
    digidoc::X509Cert timestampCert = signature->TimeStampCertificate();

    DigiDocSignature *digiDocSignature = [DigiDocSignature new];
    digiDocSignature.signingCert = [DigiDocContainerWrapper getNSDataFromVector:signingCert];
    digiDocSignature.timestampCert = [DigiDocContainerWrapper getNSDataFromVector:ocspCert];
    digiDocSignature.ocspCert = [DigiDocContainerWrapper getNSDataFromVector:ocspCert];

    std::string givename = signingCert.subjectName("GN");
    std::string surname = signingCert.subjectName("SN");
    std::string serialNr = signingCert.subjectName("serialNumber");

    NSString *serialNR = [DigiDocContainerWrapper getSerialNumber:[NSString stringWithUTF8String:serialNr.c_str()]];

    std::string name = givename.empty() || surname.empty() ? signingCert.subjectName("CN") :
        surname + ", " + givename + ", " + [serialNR UTF8String];

    if (name.empty()) {
        name = signature->signedBy();
    }

    digiDocSignature.pos = pos;
    digiDocSignature.signatureId = [NSString stringWithUTF8String:signature->id().c_str()];
    digiDocSignature.claimedSigningTime = [NSString stringWithUTF8String:signature->claimedSigningTime().c_str()];
    digiDocSignature.signatureMethod = [NSString stringWithUTF8String:signature->signatureMethod().c_str()];
    digiDocSignature.ocspProducedAt = [NSString stringWithUTF8String:signature->OCSPProducedAt().c_str()];
    digiDocSignature.timeStampTime = [NSString stringWithUTF8String:signature->TimeStampTime().c_str()];
    digiDocSignature.signedBy = [NSString stringWithUTF8String:name.c_str()];
    digiDocSignature.format = [NSString stringWithUTF8String:signature->profile().c_str()];
    digiDocSignature.messageImprint = [NSData dataWithBytes:signature->messageImprint().data() length:signature->messageImprint().size()];
    digiDocSignature.trustedSigningTime = [NSString stringWithUTF8String:signature->trustedSigningTime().c_str()];

    std::vector<std::string> signerRoles = signature->signerRoles();
    NSMutableArray* signerRolesList = [NSMutableArray arrayWithCapacity: signerRoles.size()];
    for (auto const& signerRole: signerRoles) {
        [signerRolesList addObject: [NSString stringWithUTF8String:signerRole.c_str()]];
    }

    digiDocSignature.roles = signerRolesList;
    digiDocSignature.city = [NSString stringWithUTF8String:signature->city().c_str()];
    digiDocSignature.state = [NSString stringWithUTF8String:signature->stateOrProvince().c_str()];
    digiDocSignature.country = [NSString stringWithUTF8String:signature->countryName().c_str()];
    digiDocSignature.zipCode = [NSString stringWithUTF8String:signature->postalCode().c_str()];

    digidoc::Signature::Validator validator(signature);
    digidoc::Signature::Validator::Status status = validator.status();
    digiDocSignature.diagnosticsInfo = [NSString stringWithUTF8String:validator.diagnostics().c_str()];
    digiDocSignature.status = [DigiDocContainerWrapper determineSignatureStatus:status];
    digiDocSignature.diagnosticsInfo = [NSString stringWithUTF8String:validator.diagnostics().c_str()];
    return digiDocSignature;

}

+ (void)create:(NSString *)containerPath withDataFilePaths:(NSArray<NSString *> *)dataFilePaths completion:(void (^)(NSError * _Nullable error))completion {
    [self dispatch:^{
        NSError *error = nil;
        if (auto container = digidoc::Container::createPtr(containerPath.UTF8String)) {
            for (NSString *dataFilePath in dataFilePaths) {
                try {
                    container->addDataFile(dataFilePath.UTF8String, @"application/octet-stream".UTF8String);
                } catch(const digidoc::Exception &e) {
                    std::vector<digidoc::Exception> causes = e.causes();
                    NSDictionary *userInfo = @{
                        NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
                        @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
                    };

                    error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];
                }
            }
            container->save(containerPath.UTF8String);
        }
    } completion:completion];
}

+ (void)open:(NSString *)containerPath validateOnline:(BOOL)validateOnline command:(void (^)(digidoc::Container &container))command completion:(void (^)(NSError *error))completion {
    [self dispatch:^{
        if (DigiDocContainerOpenCB cb(validateOnline);
            auto container = digidoc::Container::openPtr(containerPath.UTF8String, &cb)) {
            command(*container);
        }
    } completion:completion];
}

+ (nullable DigiDocContainer *)open:(NSString *)containerPath validateOnline:(BOOL)validateOnline error:(NSError **)error {
    // Having two container instances of the same file is causing crashes. Should synchronize all container operations?
    @synchronized (self) {
        std::unique_ptr<digidoc::Container> container;
        try {
            DigiDocContainerOpenCB cb(validateOnline);
            container = digidoc::Container::openPtr(containerPath.UTF8String, &cb);
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
                @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
            };

            *error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];
            return nil;
        }

    try {
        // DataFiles
            NSMutableArray *datafiles = [NSMutableArray array];
            for (const digidoc::DataFile *dataFile : container->dataFiles()) {
                DigiDocDataFile *digiDocDataFile = [DigiDocDataFile new];
                digiDocDataFile.fileId = [NSString stringWithUTF8String:dataFile->id().c_str()];
                digiDocDataFile.fileName = [NSString stringWithUTF8String:dataFile->fileName().c_str()];
                digiDocDataFile.fileSize = dataFile->fileSize();
                digiDocDataFile.mediaType = [NSString stringWithUTF8String:dataFile->mediaType().c_str()];
                [datafiles addObject:digiDocDataFile];
            }


            // Signatures
            NSMutableArray *signatures = [NSMutableArray array];
            int pos = 0;
            for (digidoc::Signature *signature: container->signatures()) {
                [signatures addObject:[DigiDocContainerWrapper getSignature:signature pos:pos++ mediaType:container->mediaType() dataFileCount:container->dataFiles().size()]];
            }

            NSString *mediatype = [NSString stringWithUTF8String:container->mediaType().c_str()];

            return [[DigiDocContainer alloc]
                    initWithFileName:containerPath.lastPathComponent
                    filePath:containerPath
                    dataFiles:datafiles
                    signatures:signatures
                    mediatype:mediatype
            ];
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
                @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
            };

            *error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];
            return nil;
        }
    }
}

+ (NSString *)libdigidocppVersion {
    return [NSString stringWithUTF8String:digidoc::version().c_str()];
}

+ (NSString *)mediaType {
    return [NSString stringWithUTF8String:digidoc::version().c_str()];
}

+ (void)addDataFilesToContainerWithPath:(NSString *)containerPath
                        withDataFilePaths:(NSArray<NSString *> *)dataFilePaths
                              completion:(void (^)(NSError * _Nullable error))completion
{
    [self open:containerPath validateOnline:YES command:^(digidoc::Container &container) {
        NSMutableArray<NSError *> *errors = [NSMutableArray array];

        for (NSString *dataFilePath in dataFilePaths) {
            try {
                container.addDataFile(dataFilePath.UTF8String, "application/octet-stream");
            }
            catch (const digidoc::Exception &e) {
                std::vector<digidoc::Exception> causes = e.causes();
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
                    @"causes": @{
                        @"exceptions": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)],
                        @"fileName": dataFilePath.lastPathComponent
                    }
                };

                NSError *addFileError = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];

                [errors addObject:addFileError];
            }
        }

        container.save(containerPath.UTF8String);

        if (completion) {
            if (errors.count > 0) {
                NSInteger failedCount = errors.count;
                NSInteger totalFileCount = dataFilePaths.count;
                NSString *summary = [NSString stringWithFormat: @"Could not add files"];
                NSDictionary *info = @{
                    NSLocalizedDescriptionKey: summary,
                    @"failedFileCount": @(failedCount),
                    @"totalFileCount": @(totalFileCount),
                    @"causes": @{
                        @"errors": errors
                    }
                };
                NSError *combined = [NSError errorWithDomain:@"LibdigidocLib" code:1 userInfo:info];
                completion(combined);
            } else {
                completion(nil);
            }
        }

    } completion:^(NSError * _Nullable error) {
        if (error && completion) {
            completion(error);
        }
    }];
}

+ (void)container:(NSString *)containerPath saveDataFile:(NSString *)fileName to:(NSString *)path completion:(void (^)(NSError * _Nullable error))completion {
    [self open:containerPath validateOnline:TRUE command:^(digidoc::Container &container) {
        const char *fileNameUTF8 = fileName.UTF8String;
        BOOL fileFound = NO;

        for (digidoc::DataFile *dataFile : container.dataFiles()) {
            if (dataFile->fileName() == fileNameUTF8) {
                dataFile->saveAs(path.UTF8String);
                fileFound = YES;
                break;
            }
        }

        if (!fileFound) {
            if (completion) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"Libdigidocpp - unable to save data file"
                };

                NSError *error = [NSError errorWithDomain:@"LibdigidocLib" code:1 userInfo:userInfo];
                completion(error);
                return;
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } completion:^(NSError * _Nullable openError) {
        if (openError && completion) {
            completion(openError);
        }
    }];
}

+ (void)removeSignature:(NSUInteger)index fromContainerWithPath:(NSString *)containerPath completion:(void (^)(NSError * _Nullable error))completion {
    [self open:containerPath validateOnline:TRUE command:^(digidoc::Container &container) {
        container.removeSignature((int)index);
        container.save(containerPath.UTF8String);
    } completion:completion];
}

+ (void)removeDataFileFromContainerWithPath:(NSString *)containerPath atIndex:(NSUInteger)dataFileIndex completion:(void (^)(NSError * _Nullable error))completion {
    [self open:containerPath validateOnline:TRUE command:^(digidoc::Container &container) {
        container.removeDataFile((int)dataFileIndex);
        container.save(containerPath.UTF8String);
    } completion:completion];
}


@end
