#import <Foundation/Foundation.h>

@interface Addressee : NSObject

@property (nonatomic, strong, readonly) NSData * _Nullable data;

- (instancetype _Nonnull )initWithCert:(NSData * _Nonnull)cert;

@end
