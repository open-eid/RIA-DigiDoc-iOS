#import <Foundation/Foundation.h>
#import <digidocpp/Conf.h>
#import <digidocpp/Container.h>
#import <digidocpp/crypto/X509Cert.h>
#import "digidocpp/Exception.h"
#import "DigiDocConfWrapper.h"
#import "../Model/DigiDocConfig.h"
#import "Exception/DigiDocExceptionWrapper.h"
#import "Exception/Util/ExceptionUtil.h"

class DigiDocConfCurrent: public digidoc::ConfCurrent {

private:
    DigiDocConfig *currentConf;

public:
    DigiDocConfCurrent(DigiDocConfig *conf) : currentConf(conf) {}
    ~DigiDocConfCurrent() override = default;

    int logLevel() const final {
        return currentConf.logLevel;
    }
    
    std::string logFile() const override {
        return currentConf.logFile.UTF8String;
    }

    std::string TSLCache() const override {
        NSString *tslCachePath = currentConf.TSLCACHE;
        return tslCachePath.UTF8String;
    }

    std::string TSLUrl() const override {
        return currentConf.TSLURL.UTF8String;
    }

    std::vector<digidoc::X509Cert> TSCerts() const override {
        NSMutableArray<NSString *> *certBundle = [NSMutableArray arrayWithArray:currentConf.CERTBUNDLE];
        return stringsToX509Certs(certBundle);
    }

    std::string TSUrl() const override {
        return currentConf.TSAURL.UTF8String;
    }

    std::string ocsp(const std::string &issuer) const override {
        NSString *ocspIssuer = [NSString stringWithCString:issuer.c_str() encoding:[NSString defaultCStringEncoding]];

        NSString *ocspUrl = currentConf.OCSPISSUERS[ocspIssuer];
        if (ocspUrl) {
            return std::string([ocspUrl UTF8String]);
        }
        return digidoc::ConfCurrent::ocsp(issuer);
    }

    std::string verifyServiceUri() const override {
        return currentConf.SIVAURL.UTF8String;
    }

    virtual std::vector<digidoc::X509Cert> verifyServiceCerts() const override {
        NSMutableArray<NSString*> *certs = [NSMutableArray arrayWithArray:currentConf.CERTBUNDLE];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *sivaFileName = [defaults stringForKey:@"kSivaFileCertName"];
        return stringsToX509Certs(certs);
    }

    static Conf* instance() {
        return digidoc::Conf::instance();
    }

    std::vector<digidoc::X509Cert> stringsToX509Certs(NSArray<NSString*> *certBundle) const {
        std::vector<digidoc::X509Cert> x509Certs;

        for (NSString *certString in certBundle) {
            NSData *data = [[NSData alloc] initWithBase64EncodedString:certString options:NSDataBase64DecodingIgnoreUnknownCharacters];

            if (data == nil || data.length == 0) {
                continue;
            }

            try {
                const unsigned char *bytes = reinterpret_cast<const unsigned char*>(data.bytes);
                x509Certs.emplace_back(bytes, data.length);
            } catch (...) {
                continue;
            }
        }

        return x509Certs;
    }
};

class DigiDocConfWrapperImpl {
public:
    DigiDocConfWrapperImpl() {}

    static void initConf(DigiDocConfig *conf) {
        dispatch_async(dispatch_get_main_queue(), ^{
            try {
                DigiDocConfCurrent *currentConf = new DigiDocConfCurrent(conf);
                digidoc::Conf::init(currentConf);
                digidoc::initialize("RIA DigiDoc 3.0", "RIA DigiDoc");
            } catch(const digidoc::Exception &e) {
                std::vector<digidoc::Exception> causes = e.causes();
                @throw [[DigiDocExceptionWrapper alloc] init:
                            [[DigiDocException alloc] init:[NSString stringWithUTF8String:e.msg().c_str()] code:static_cast<NSInteger>(e.code()) causes:[ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]]
                ];
            }
        });
    }

    static DigiDocConfWrapperImpl* instance() {
        static DigiDocConfWrapperImpl instance;
        return &instance;
    }

    void updateConfiguration(DigiDocConfig *newConfig) {
        DigiDocConfCurrent *newCurrentConf = new DigiDocConfCurrent(newConfig);
        digidoc::Conf::init(newCurrentConf);
    }
};

@implementation DigiDocConfWrapper {
    DigiDocConfWrapperImpl* _impl;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _impl = new DigiDocConfWrapperImpl();
    }
    return self;
}

- (void)initWithConf:(DigiDocConfig *)conf completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *digidocException = nil;
        if (self) {
            @try {
                DigiDocConfWrapperImpl::initConf(conf);
            } @catch (DigiDocExceptionWrapper *exceptionWrapper) {
                digidocException = [NSError errorWithDomain:@"LibdigidocLib" code:exceptionWrapper.code userInfo:@{@"message":exceptionWrapper.message, @"causes": exceptionWrapper.causes }];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(digidocException == nil, digidocException);
            }
        });
    });
}

- (void)updateConfiguration:(DigiDocConfig *)conf {
    _impl->updateConfiguration(conf);
}

+ (nullable DigiDocConfWrapper *)sharedInstance {
    static DigiDocConfWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        digidoc::Conf* instanceImpl = DigiDocConfCurrent::instance();
        if (instanceImpl) {
            sharedInstance = [[DigiDocConfWrapper alloc] init];
            sharedInstance->_impl = DigiDocConfWrapperImpl::instance();
        }
    });
    return sharedInstance;
}

@end
