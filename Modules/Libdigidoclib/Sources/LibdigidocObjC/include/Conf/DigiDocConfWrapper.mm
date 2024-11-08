#import <Foundation/Foundation.h>
#import <digidocpp/Conf.h>
#import <digidocpp/Container.h>
#import "digidocpp/Exception.h"
#import "DigiDocConfWrapper.h"
#import "Exception/DigiDocExceptionWrapper.h"
#import "Exception/Util/ExceptionUtil.h"

class DigiDocConfWrapperImpl : public digidoc::ConfCurrent {
public:
    DigiDocConfWrapperImpl() : logsLevel(2) {}
    ~DigiDocConfWrapperImpl() override = default;

    int logLevel() const override {
        return logsLevel;
    }

    void setLogLevel(int level) {
        logsLevel = level;
    }

    static void initConf(digidoc::Conf* conf) {
        try {
            digidoc::Conf::init(conf);
            digidoc::initialize("RIA DigiDoc 3.0", "RIA DigiDoc");
        } catch(const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            @throw [[DigiDocExceptionWrapper alloc] init:
                        [[DigiDocException alloc] init:[NSString stringWithUTF8String:e.msg().c_str()] code:static_cast<NSInteger>(e.code()) causes:[ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]]
            ];
        }
    }

    static DigiDocConfWrapperImpl* instance() {
        return static_cast<DigiDocConfWrapperImpl*>(digidoc::Conf::instance());
    }

private:
    int logsLevel;
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

- (void)setLogLevel:(int)level {
    _impl->setLogLevel(level);
}

- (int)logLevel {
    return _impl->logLevel();
}

+ (void)initWithConf:(DigiDocConfWrapper *)conf completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *digidocException = nil;
        if (conf) {
            @try {
                DigiDocConfWrapperImpl::initConf(conf->_impl);
            } @catch (DigiDocExceptionWrapper *exceptionWrapper) {
                digidocException = [NSError errorWithDomain:@"Libdigidoclib" code:exceptionWrapper.code userInfo:@{@"message":exceptionWrapper.message, @"causes": exceptionWrapper.causes }];
            }
        }

        BOOL isSuccess = ([self sharedInstance] != nil);

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(isSuccess, digidocException);
            }
        });
    });
}

+ (nullable DigiDocConfWrapper *)sharedInstance {
    static DigiDocConfWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DigiDocConfWrapperImpl* instanceImpl = DigiDocConfWrapperImpl::instance();
        if (instanceImpl) {
            sharedInstance = [[DigiDocConfWrapper alloc] init];
            sharedInstance->_impl = instanceImpl;
        }
    });
    return sharedInstance;
}

@end
