#import <Foundation/Foundation.h>
#import "../Model/DigiDocConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocConfWrapper : NSObject

- (instancetype)init;

- (void)initWithConf:(DigiDocConfig *)conf completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (void)updateConfiguration:(DigiDocConfig *)conf;
+ (nullable DigiDocConfWrapper *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
