#import <Foundation/Foundation.h>
#import "DigiDocConfig.h"

@implementation DigiDocConfig

- (instancetype)initWithConf:(int)logLevel
                     logFile:(NSString *)logFile
                    TSLCache:(NSString *)TSLCache
                     SIVAURL:(NSString *)SIVAURL
                      TSLURL:(NSString *)TSLURL
                    TSLCERTS:(NSArray<NSString *> *)TSLCERTS
                   LDAPCERTS:(NSArray<NSString *> *)LDAPCERTS
                      TSAURL:(NSString *)TSAURL
                 OCSPISSUERS:(NSDictionary *)OCSPISSUERS
                  CERTBUNDLE:(NSArray<NSString *> *)CERTBUNDLE
                     TSACERT:(NSString *)TSACERT {
    self = [super init];
    if (self) {
        _logLevel = logLevel;
        _logFile = logFile;
        _TSLCACHE = TSLCache;
        _SIVAURL = SIVAURL;
        _TSLURL = TSLURL;
        _TSLCERTS = TSLCERTS;
        _LDAPCERTS = LDAPCERTS;
        _TSAURL = TSAURL;
        _OCSPISSUERS = OCSPISSUERS;
        _CERTBUNDLE = CERTBUNDLE;
    }
    return self;
}

@end
