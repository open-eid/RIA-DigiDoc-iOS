#import <Foundation/Foundation.h>
#import "../DigiDocException.h"
#import "../DigiDocExceptionWrapper.h"

@class ExternalClass;

@interface ExceptionUtil : NSObject

// Method that accepts a std::vector<digidoc::Exception> parameter as void *,
// which will be converted to std::vector<digidoc::Exception>, in the implementation.
// This is to avoid C++ types in header files
+ (NSArray<DigiDocException *> *)exceptionCauses:(void *)causes;

@end
