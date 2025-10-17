#import <Foundation/Foundation.h>
#import "AbstractSmartToken.h"

@class CdocInfo;

NS_ASSUME_NONNULL_BEGIN

@interface Decrypt : NSObject

+ (void)decryptFile:(NSString *)fullPath withToken:(AbstractSmartToken *)smartToken
         completion:(void (^)(NSDictionary<NSString*,NSData*> * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
