#import <Foundation/Foundation.h>
#import <digidocpp/Container.h>

class DigiDocContainerOpenCBImpl: public digidoc::ContainerOpenCB {
private:
    bool validate;

public:
    DigiDocContainerOpenCBImpl(bool validate)
        : validate(validate) {}

    virtual bool validateOnline() const override {
        return validate;
    }
};

#import "DigiDocContainerOpenCB.h"

@implementation DigiDocContainerOpenCB {
    DigiDocContainerOpenCBImpl *_containerOpenImpl;
}

+ (instancetype)sharedInstance {
    static DigiDocContainerOpenCB *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithValidation:NO];
    });
    return sharedInstance;
}

- (instancetype)initWithValidation:(BOOL)validate {
    self = [super init];
    if (self) {
        _containerOpenImpl = new DigiDocContainerOpenCBImpl(validate);
    }
    return self;
}

- (BOOL)validateOnline {
    return _containerOpenImpl->validateOnline();
}

- (void *)containerOpenCBImplInstance {
    return static_cast<void *>(_containerOpenImpl);
}

@end
