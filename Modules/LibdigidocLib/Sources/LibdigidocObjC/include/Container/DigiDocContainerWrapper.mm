#import <Foundation/Foundation.h>

#import <digidocpp/Container.h>
#import <digidocpp/DataFile.h>
#import <digidocpp/Signature.h>
#import <digidocpp/Exception.h>
#import <digidocpp/crypto/X509Cert.h>

#import "DigiDocContainerWrapper.h"
#import "CB/DigiDocContainerOpenCB.h"
#import "../Model/DigiDocContainer.h"
#import "Exception/DigiDocExceptionWrapper.h"
#import "Exception/Util/ExceptionUtil.h"

class DigiDocContainerWrapperImpl {
public:
    DigiDocContainerWrapperImpl() {};

    NSArray<DigiDocDataFile *>* getDataFiles() {
        NSMutableArray<DigiDocDataFile *> *datafiles = [[NSMutableArray alloc] init];
        for (const digidoc::DataFile *dataFile : container->dataFiles()) {
            DigiDocDataFile *digiDocDataFile = [DigiDocDataFile new];
            digiDocDataFile.fileId = [NSString stringWithUTF8String:dataFile->id().c_str()];
            digiDocDataFile.fileName = [NSString stringWithUTF8String:dataFile->fileName().c_str()];
            digiDocDataFile.fileSize = dataFile->fileSize();
            digiDocDataFile.mediaType = [NSString stringWithUTF8String:dataFile->mediaType().c_str()];
            [datafiles addObject:digiDocDataFile];
        }

        return datafiles;
    }

    NSArray<DigiDocSignature *>* getSignatures() {
        NSMutableArray<DigiDocSignature *> *signatures = [[NSMutableArray alloc] init];
        for (const digidoc::Signature *signature : container->signatures()) {
            DigiDocSignature *digiDocSignature = [DigiDocSignature new];
            digiDocSignature.signingCert = getCertDataFromX509(signature->signingCertificate());
            digiDocSignature.timestampCert = getCertDataFromX509(signature->TimeStampCertificate());
            digiDocSignature.ocspCert = getCertDataFromX509(signature->OCSPCertificate());

            digiDocSignature.signatureId = [NSString stringWithUTF8String:signature->id().c_str()];
            digiDocSignature.claimedSigningTime = [NSString stringWithUTF8String:signature->claimedSigningTime().c_str()];
            digiDocSignature.signatureMethod = [NSString stringWithUTF8String:signature->signatureMethod().c_str()];
            digiDocSignature.ocspProducedAt = [NSString stringWithUTF8String:signature->OCSPProducedAt().c_str()];
            digiDocSignature.timeStampTime = [NSString stringWithUTF8String:signature->TimeStampTime().c_str()];
            digiDocSignature.signedBy = [NSString stringWithUTF8String:signature->signedBy().c_str()];
            digiDocSignature.format = [NSString stringWithUTF8String:signature->profile().c_str()];
            digiDocSignature.messageImprint = [NSData dataWithBytes:signature->messageImprint().data() length:signature->messageImprint().size()];
            digiDocSignature.trustedSigningTime = [NSString stringWithUTF8String:signature->trustedSigningTime().c_str()];

            digidoc::Signature::Validator validator(signature);
            digidoc::Signature::Validator::Status status = validator.status();
            digiDocSignature.diagnosticsInfo = [NSString stringWithUTF8String:validator.diagnostics().c_str()];
            digiDocSignature.status = determineSignatureStatus(status);
            digiDocSignature.diagnosticsInfo = [NSString stringWithUTF8String:validator.diagnostics().c_str()];
            [signatures addObject:digiDocSignature];
        }
        return signatures;
    }

    DigiDocContainer* toDigiDocContainer(digidoc::Container *container) {
        DigiDocContainer *digiDocContainer = [DigiDocContainer new];

        digiDocContainer.dataFiles = getDataFiles();
        digiDocContainer.signatures = getSignatures();
        digiDocContainer.mediatype = [NSString stringWithUTF8String:container->mediaType().c_str()];

        return digiDocContainer;
    }

    DigiDocContainer* create(NSString *url) {
        try {
            container = digidoc::Container::createPtr(url.UTF8String);
            return toDigiDocContainer(container.get());
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            @throw [[DigiDocExceptionWrapper alloc] init:
                        [[DigiDocException alloc] init:[NSString stringWithUTF8String:e.msg().c_str()] code:static_cast<NSInteger>(e.code()) causes:[ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]]
            ];
        }
    }

    DigiDocContainer* open(NSString *url, bool validateOnline) {
        try {
            DigiDocContainerOpenCB *containerOpenCB = [[DigiDocContainerOpenCB alloc] initWithValidation:validateOnline];

            digidoc::ContainerOpenCB *cb = static_cast<digidoc::ContainerOpenCB *>([containerOpenCB containerOpenCBImplInstance]);

            container = digidoc::Container::openPtr(url.UTF8String, cb);
            return toDigiDocContainer(container.get());
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            @throw [[DigiDocExceptionWrapper alloc] init:
                        [[DigiDocException alloc] init:[NSString stringWithUTF8String:e.msg().c_str()] code:static_cast<NSInteger>(e.code()) causes:[ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]]
            ];
        }
    }

    DigiDocSignatureStatus determineSignatureStatus(int status) {
        typedef digidoc::Signature::Validator::Status Status;

        switch (status) {
            case Status::Valid: return Valid;
            case Status::NonQSCD: return NonQSCD;
            case Status::Warning: return Warning;
            case Status::Unknown: return UnknownStatus;
            default: return Invalid;
        }
    }

    DigiDocContainer* getContainer() {
        if (container == NULL) {
            return NULL;
        }
        return toDigiDocContainer(container.get());
    }

    BOOL addDataFile(NSString *dataFilePath, NSString *mimetype) {
        try {
            container->addDataFile(dataFilePath.UTF8String, mimetype.UTF8String);
            return true;
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            @throw [[DigiDocExceptionWrapper alloc] init:
                        [[DigiDocException alloc] init:[NSString stringWithUTF8String:e.msg().c_str()] code:static_cast<NSInteger>(e.code()) causes:[ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]]
            ];
        }
    }

    void save(NSString *url) {
        try {
            container->save();
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            @throw [[DigiDocExceptionWrapper alloc] init:
                        [[DigiDocException alloc] init:[NSString stringWithUTF8String:e.msg().c_str()] code:static_cast<NSInteger>(e.code()) causes:[ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]]
            ];
        }
    }

    static DigiDocContainerWrapperImpl* instance() {
        static DigiDocContainerWrapperImpl instance;
        return &instance;
    }

private:
    std::unique_ptr<digidoc::Container> container;

    NSData* getCertDataFromX509(const digidoc::X509Cert& cert) {
        std::vector<unsigned char> data = cert;
        return [NSData dataWithBytes:data.data() length:data.size()];
    }
};

@implementation DigiDocContainerWrapper {
    DigiDocContainerWrapperImpl* _impl;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _impl = new DigiDocContainerWrapperImpl();
    }
    return self;
}

- (void)create:(NSString *)url completion:(void (^)(DigiDocContainer * container, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DigiDocContainer *container = NULL;
        NSError *digidocException = nil;
        @try {
            container = _impl->create(url);
        } @catch (DigiDocExceptionWrapper *exceptionWrapper) {
            digidocException = [NSError errorWithDomain:@"LibdigidocLib" code:exceptionWrapper.code userInfo:@{NSLocalizedDescriptionKey: exceptionWrapper.message, @"causes": exceptionWrapper.causes }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(container, digidocException);
            }
        });
    });
}

- (void)open:(NSString *)url validateOnline:(BOOL)validateOnline completion:(void (^)(DigiDocContainer * container, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DigiDocContainer *container = NULL;
        NSError *digidocException = nil;
        @try {
            container = _impl->open(url, validateOnline);
        } @catch (DigiDocExceptionWrapper *exceptionWrapper) {
            digidocException = [NSError errorWithDomain:@"LibdigidocLib" code:exceptionWrapper.code userInfo:@{NSLocalizedDescriptionKey: exceptionWrapper.message, @"causes": exceptionWrapper.causes }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(container, digidocException);
            }
        });
    });
}

- (DigiDocSignatureStatus)determineSignatureStatus:(int)status {
    return _impl->determineSignatureStatus(status);
}

- (DigiDocContainer *)getContainer {
    return _impl->getContainer();
}

- (NSArray<DigiDocDataFile *> *)getDataFiles; {
    return _impl->getDataFiles();
}

- (NSArray<DigiDocSignature *> *)getSignatures {
    return _impl->getSignatures();
}

- (void)addDataFile:(NSString *)url mimetype:(NSString *)mimetype completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL dataFileAdded = FALSE;
        NSError *digidocException = nil;
        @try {
            dataFileAdded = _impl->addDataFile(url, mimetype);
        } @catch (DigiDocExceptionWrapper *exceptionWrapper) {
            digidocException = [NSError errorWithDomain:@"LibdigidocLib" code:exceptionWrapper.code userInfo:@{NSLocalizedDescriptionKey: exceptionWrapper.message, @"causes": exceptionWrapper.causes }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(dataFileAdded, digidocException);
            }
        });
    });
}

- (void)save:(NSString *)url completion:(void (^)(NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *digidocException = nil;
        @try {
            _impl->save(url);
        } @catch (DigiDocExceptionWrapper *exceptionWrapper) {
            digidocException = [NSError errorWithDomain:@"LibdigidocLib" code:exceptionWrapper.code userInfo:@{NSLocalizedDescriptionKey: exceptionWrapper.message, @"causes": exceptionWrapper.causes }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(digidocException);
            }
        });
    });
}

@end
