#import "DigiDocExceptionWrapper.h"
#import "DigiDocException.h"

@implementation DigiDocExceptionWrapper {
    DigiDocException* exception_;
}

- (instancetype)init:(const DigiDocException*)exception {
    if (self = [super init]) {
        exception_ = [[DigiDocException alloc] init:exception.message code:exception.code causes:exception.causes];
    }
    return self;
}

- (NSString *)message {
    return exception_.message;
}

- (NSInteger)code {
    return exception_.code;
}

- (NSArray<DigiDocExceptionWrapper *>*)causes {
    NSMutableArray<DigiDocExceptionWrapper *> *exceptions = [NSMutableArray array];

    NSArray<DigiDocException*> *causes = exception_.causes;

    for (const DigiDocException *ex : causes) {
        DigiDocExceptionWrapper *wrapper = [[DigiDocExceptionWrapper alloc] init:ex];
        [exceptions addObject:wrapper];
    }

    return [exceptions copy];
}

@end
