/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
