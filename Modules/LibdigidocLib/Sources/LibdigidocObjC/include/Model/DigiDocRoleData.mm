// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>
#import "DigiDocRoleData.h"

@implementation DigiDocRoleData

- (instancetype)initWithRoles:(NSArray<NSString *> *)roles
                         city:(NSString *)city
                        state:(NSString *)state
                      country:(NSString *)country
                      zipcode:(NSString *)zipcode {
    self = [super init];
    if (self) {
        _roles = roles;
        _city = city;
        _state = state;
        _country = country;
        _zipcode = zipcode;
    }
    return self;
}

@end
