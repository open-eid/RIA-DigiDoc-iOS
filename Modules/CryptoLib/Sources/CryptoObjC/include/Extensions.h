// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>

#include <string>
#include <vector>

static const NSInteger CryptoLibWrongKeyErrorCode = -109; // libcdoc::WRONG_KEY
static const NSInteger CryptoLibNetworkErrorCode = -300; // libcdoc::NetworkBackend::NETWORK_ERROR

@interface NSError (CryptoLib)
+ (NSError*)cryptoError:(NSString*)msg;
+ (NSError*)cryptoError:(NSString*)msg code:(NSInteger)code;
+ (id)cryptoError:(NSString*)msg error:(NSError**)error;
+ (id)cryptoWrongKeyError:(NSError**)error;
@end

@interface NSString (std_string)
- (std::string)toString;
@end

@interface NSData (std_vector)
- (std::vector<unsigned char>)toVector;
@end

@implementation NSString (std_string)
+ (instancetype)stringWithStdString:(const std::string&)data {
    if (data.empty()) {
        return nil;
    }
    NSString *utf8 = [[NSString alloc] initWithBytes:data.data()
                                              length:data.size()
                                            encoding:NSUTF8StringEncoding];
    if (utf8 != nil) {
        return utf8;
    }
    return [[NSString alloc] initWithBytes:data.data()
                                    length:data.size()
                                  encoding:NSISOLatin1StringEncoding];
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
    return [NSError cryptoError:msg code:1000];
}

+ (NSError*)cryptoError:(NSString *)msg code:(NSInteger)code {
    return [[NSError alloc] initWithDomain:@"ee.ria.digidoc.CryptoLib" code:code userInfo: @{NSLocalizedDescriptionKey: msg}];
}

+ (id)cryptoError:(NSString*)msg error:(NSError**)error {
    if (error) {
        *error = [NSError cryptoError:msg];
    }
    return nil;
}

+ (id)cryptoWrongKeyError:(NSError**)error {
    if (error) {
        *error = [[NSError alloc] initWithDomain:@"ee.ria.digidoc.CryptoLib"
                                           code:CryptoLibWrongKeyErrorCode
                                       userInfo:@{NSLocalizedDescriptionKey: @"Wrong password"}];
    }
    return nil;
}
@end
