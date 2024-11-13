#import <Foundation/Foundation.h>

@interface DigiDocContainerOpenCB : NSObject

+ (instancetype)sharedInstance;

- (instancetype)initWithValidation:(BOOL)validate;
- (BOOL)validateOnline;

// Method that returns a digidoc::ContainerOpenCB parameter as void *,
// which will be converted to digidoc::ContainerOpenCB, in the implementation.
// This is to avoid C++ types in header files
- (void *)containerOpenCBImplInstance;

@end
