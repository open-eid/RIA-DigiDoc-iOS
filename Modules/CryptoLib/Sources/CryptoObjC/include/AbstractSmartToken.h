#import <Foundation/Foundation.h>

@interface AbstractSmartToken
- (NSData * _Nullable)derive:(NSData * _Nonnull)data error:(NSError *_Nullable*_Nullable)error;
- (NSData * _Nullable)decrypt:(NSData * _Nonnull)data error:(NSError *_Nullable*_Nullable)error;
- (NSData * _Nullable)authenticate:(NSData * _Nonnull)data error:(NSError *_Nullable*_Nullable)error;
- (NSData * _Nullable)getCertificate:(NSError *_Nullable*_Nullable)error;
@end
