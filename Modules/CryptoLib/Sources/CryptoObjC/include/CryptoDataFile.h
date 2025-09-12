#import <Foundation/Foundation.h>

@interface CryptoDataFile : NSObject

@property (nonatomic, strong, readonly) NSString * _Nonnull filename;
@property (nonatomic, strong, readonly, nullable) NSString *filePath;

- (instancetype _Nonnull )initWithFilename:(NSString * _Nonnull)filename
                        filePath:(NSString * _Nullable)filePath;

@end
