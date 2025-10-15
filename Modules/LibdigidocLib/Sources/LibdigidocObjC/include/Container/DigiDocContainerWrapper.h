#import <Foundation/Foundation.h>
#import "../Model/DigiDocContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocContainerWrapper : NSObject

+ (void)create:(NSString *)containerPath withDataFilePaths:(NSArray<NSString *> *)dataFilePaths completion:(void (^)(NSError * _Nullable error))completion;

+ (nullable DigiDocContainer *)open:(NSString *)containerPath validateOnline:(BOOL)validateOnline error:(NSError **)error;

+ (void)addDataFilesToContainerWithPath:(NSString *)containerPath withDataFilePaths:(NSArray<NSString*> *)dataFilePaths completion:(void (^)(NSError * _Nullable error))completion;

+ (void)container:(NSString *)containerPath saveDataFile:(NSString *)fileName to:(NSString *)path completion:(void (^)(NSError * _Nullable error))completion;

+ (NSString *)libdigidocppVersion;
+ (NSString *)mediaType;

@end

NS_ASSUME_NONNULL_END
