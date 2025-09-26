#import <Foundation/Foundation.h>
#import "../Model/DigiDocConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocConfWrapper : NSObject

- (instancetype)init;

- (void)initWithConf:(DigiDocConfig *)conf completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (void)updateConfiguration:(DigiDocConfig *)conf;
- (void)setSiVaUrl:(NSString *)url;
- (void)addSiVaCert:(NSData *)cert;
- (void)setTSUrl:(NSString *)url;
- (void)addTSCert:(NSData *)cert;
+ (nullable DigiDocConfWrapper *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
