#import <Foundation/Foundation.h>
#import "../Model/DigiDocConfig.h"

#if DEBUG
#define printLog(...) NSLog(__VA_ARGS__)
#else
#define printLog(...)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocConfWrapper : NSObject

- (void)initWithConf:(DigiDocConfig *)conf completion:(void (^)(BOOL, NSError * _Nullable))completion;
- (void)updateConfiguration:(DigiDocConfig *)conf;
- (void)setSiVaUrl:(NSString *)url;
- (void)addSiVaCert:(NSData *)cert;
- (void)setTSUrl:(NSString *)url;
- (void)addTSCert:(NSData *)cert;
+ (nullable instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
