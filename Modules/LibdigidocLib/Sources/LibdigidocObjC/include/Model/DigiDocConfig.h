#import <Foundation/Foundation.h>

@interface DigiDocConfig : NSObject

@property (assign, nonatomic) int logLevel;
@property (strong, nonatomic) NSString *logFile;
@property (strong, nonatomic) NSString *TSLCache;

- (instancetype)initWithConf:(int)logLevel logFile:(NSString *)logFile TSLCache:(NSString *)TSLCache;

@end
