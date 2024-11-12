#import <Foundation/Foundation.h>
#import "DigiDocException.h"

@interface DigiDocExceptionWrapper : NSObject

@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSInteger code;
@property (nonatomic, readonly) NSArray<DigiDocExceptionWrapper *> *causes;

- (instancetype)init:(const DigiDocException *)exception;

@end
