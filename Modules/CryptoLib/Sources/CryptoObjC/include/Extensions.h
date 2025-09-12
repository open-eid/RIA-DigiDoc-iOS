#import <Foundation/Foundation.h>

#include <string>
#include <vector>

@interface NSError (CryptoLib)
+ (NSError*)cryptoError:(NSString*)msg;
@end

@interface NSString (std_string)
- (std::string)toString;
@end

@interface NSData (std_vector)
- (std::vector<unsigned char>)toVector;
@end

@implementation NSString (std_string)
+ (instancetype)stringWithStdString:(const std::string&)data {
    return data.empty() ? nil : [NSString stringWithUTF8String:data.c_str()];
}

- (std::string)toString {
    if (self == nil) {
        return {};
    }
    return {self.UTF8String};
}
@end

@implementation NSData (std_vector)
+ (instancetype)dataFromVector:(const std::vector<unsigned char>&)data {
    return data.empty() ? nil : [NSData dataWithBytes:(void *)data.data() length:data.size()];
}

+ (instancetype)dataFromVectorNoCopy:(const std::vector<unsigned char>&)data {
    return data.empty() ? nil : [NSData dataWithBytesNoCopy:(void *)data.data() length:data.size() freeWhenDone:0];
}

- (std::vector<unsigned char>)toVector {
    if (self == nil) {
        return {};
    }
    const auto *p = reinterpret_cast<const uint8_t*>(self.bytes);
    return {p, std::next(p, self.length)};
}
@end

@implementation NSError (CryptoLib)
+ (NSError*)cryptoError:(NSString *)msg {
    return [[NSError alloc] initWithDomain:@"ee.ria.digidoc.CryptoLib" code:1000 userInfo: @{NSLocalizedDescriptionKey: msg}];
}
@end
