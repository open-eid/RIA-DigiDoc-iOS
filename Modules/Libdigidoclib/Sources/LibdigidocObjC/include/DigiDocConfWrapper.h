#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocConfWrapper : NSObject

- (instancetype)init;
- (void)setLogLevel:(int)level;
- (int)logLevel;

+ (void)initWithConf:(DigiDocConfWrapper *)conf completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
+ (nullable DigiDocConfWrapper *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
