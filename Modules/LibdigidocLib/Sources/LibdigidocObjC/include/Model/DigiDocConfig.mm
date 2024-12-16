#import <Foundation/Foundation.h>
#import "DigiDocConfig.h"

@implementation DigiDocConfig

- (instancetype)initWithConf:(int)logLevel logFile:(NSString *)logFile TSLCache:(NSString *)TSLCache {
    self = [super init];
    if (self) {
        _logLevel = logLevel;
        _logFile = [logFile copy];
        _TSLCache = [TSLCache copy];
    }
    return self;
}

@end
