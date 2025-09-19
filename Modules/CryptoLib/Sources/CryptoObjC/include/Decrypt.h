#import <Foundation/Foundation.h>

@protocol AbstractSmartTokenObjC;
@class CdocInfo;

NS_ASSUME_NONNULL_BEGIN

@interface Decrypt : NSObject

+ (void)decryptFile:(NSString *)fullPath withToken:(id<AbstractSmartTokenObjC>)smartToken
         completion:(void (^)(NSDictionary<NSString*,NSData*> * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
