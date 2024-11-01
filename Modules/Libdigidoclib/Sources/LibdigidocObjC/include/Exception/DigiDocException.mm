#import "DigiDocException.h"

@implementation DigiDocException {
    NSString *_message;
    NSInteger _code;
    NSArray<DigiDocException *> *_causes;
}

- (NSString *)message {
    return _message;
}

- (NSInteger)code {
    return _code;
}

- (NSArray<DigiDocException *> *)causes {
    return _causes;
}

- (instancetype)init:(NSString *)message code:(NSInteger)code {
    return [self init:message code:code causes:@[]];
}

- (instancetype)init:(NSString *)message code:(NSInteger)code causes:(NSArray<DigiDocException *> *)causes {
    NSString *name = NSStringFromClass([self class]);
    NSDictionary *userInfo = @{
        @"code": @(code),
        @"causes": causes
    };

    self = [super initWithName:name
                        reason:message
                      userInfo:userInfo];
    if (self) {
        _message = message;
        _code = code;
        _causes = [causes copy];
    }
    return self;
}

@end
