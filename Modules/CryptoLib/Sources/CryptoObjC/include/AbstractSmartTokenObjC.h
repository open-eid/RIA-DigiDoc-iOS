#import <Foundation/Foundation.h>

@protocol AbstractSmartTokenObjC
- (NSData * _Nullable)derive:(NSData * _Nonnull)data error:(NSError *_Nullable*_Nullable)error;
- (NSData * _Nullable)decrypt:(NSData * _Nonnull)data error:(NSError *_Nullable*_Nullable)error;
- (NSData * _Nullable)authenticate:(NSData * _Nonnull)data error:(NSError *_Nullable*_Nullable)error;
- (NSData * _Nullable)getCertificateSync:(NSError *_Nullable*_Nullable)error;
@end
