#import <Foundation/Foundation.h>
#import <digidocpp/Conf.h>
#import <digidocpp/Container.h>
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
        return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/libdigidocpp.log"].UTF8String;
    }

    std::string TSLCache() const override {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = paths[0];
        [NSFileManager.defaultManager createFileAtPath:[libraryDirectory stringByAppendingPathComponent:@"EE_T.xml"] contents:nil attributes:nil];
        return libraryDirectory.UTF8String;
    }

    static Conf* instance() {
        return digidoc::Conf::instance();
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
