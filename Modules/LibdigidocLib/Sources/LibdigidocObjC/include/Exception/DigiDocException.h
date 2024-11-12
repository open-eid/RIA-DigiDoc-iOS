#import <Foundation/Foundation.h>

@interface DigiDocException : NSException

@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSInteger code;
@property (nonatomic, readonly) NSArray<DigiDocException *> *causes;

- (instancetype)init:(NSString *)message code:(NSInteger)code;
- (instancetype)init:(NSString *)message code:(NSInteger)code causes:(NSArray<DigiDocException *> *)causes;

@end
