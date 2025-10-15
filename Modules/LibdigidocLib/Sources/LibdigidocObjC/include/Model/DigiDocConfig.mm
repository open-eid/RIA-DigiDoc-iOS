#import <Foundation/Foundation.h>
#import "DigiDocConfig.h"

@implementation DigiDocConfig

- (instancetype)initWithConf:(int)logLevel
                     logFile:(NSString *)logFile
                    TSLCache:(NSString *)TSLCache
                     SIVAURL:(NSURL *)SIVAURL
                      TSLURL:(NSURL *)TSLURL
                    TSLCERTS:(NSArray<NSData *> *)TSLCERTS
                   LDAPCERTS:(NSArray<NSData *> *)LDAPCERTS
                      TSAURL:(NSURL *)TSAURL
                 OCSPISSUERS:(NSDictionary *)OCSPISSUERS
                  CERTBUNDLE:(NSArray<NSData *> *)CERTBUNDLE {
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
