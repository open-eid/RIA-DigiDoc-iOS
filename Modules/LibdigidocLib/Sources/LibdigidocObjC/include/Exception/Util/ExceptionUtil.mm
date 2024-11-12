#import <Foundation/Foundation.h>
#import "ExceptionUtil.h"
#import "../DigiDocException.h"
#import "../DigiDocExceptionWrapper.h"
#import <digidocpp/Exception.h>
#include <vector>

@implementation ExceptionUtil

+ (NSArray<DigiDocException *> *)exceptionCauses:(void *)causes {
    std::vector<digidoc::Exception> *exceptionCauses = static_cast<std::vector<digidoc::Exception> *>(causes);
    NSMutableArray<DigiDocException *> *exceptions = [[NSMutableArray alloc] init];
    for (const digidoc::Exception &ex : *exceptionCauses) {
        DigiDocException *exception = [[DigiDocException alloc] init:[NSString stringWithUTF8String:ex.msg().c_str()] code:static_cast<NSInteger>(ex.code())];
        [exceptions addObject:exception];
    }

    return exceptions;
}

@end
