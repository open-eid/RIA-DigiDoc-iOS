#import <Foundation/Foundation.h>
#import "../Model/DigiDocContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocContainerWrapper : NSObject

- (instancetype)init;

- (void)create:(NSString *)url completion:(void (^)(DigiDocContainer * container, NSError * _Nullable error))completion;
- (void)open:(NSString *)url validateOnline:(BOOL)validateOnline completion:(void (^)(DigiDocContainer * container, NSError * _Nullable error))completion;

- (DigiDocSignatureStatus)determineSignatureStatus:(int)status;
- (DigiDocContainer *)getContainer;
- (NSArray<DigiDocDataFile *> *)getDataFiles;
- (NSArray<DigiDocSignature *> *)getSignatures;

- (void)addDataFile:(NSString *)url mimetype:(NSString *)mimetype completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (void)save:(NSString *)url completion:(void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
