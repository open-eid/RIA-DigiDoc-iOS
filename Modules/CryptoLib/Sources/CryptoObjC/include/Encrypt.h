#import <Foundation/Foundation.h>

@class Addressee;
@class CryptoDataFile;

NS_ASSUME_NONNULL_BEGIN

@interface Encrypt: NSObject

+ (void)encryptFile:(NSString *)fullPath withDataFiles:(NSArray<CryptoDataFile*> *)dataFiles
     withAddressees:(NSArray<Addressee*> *)addressees completion:(void (^)(NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
