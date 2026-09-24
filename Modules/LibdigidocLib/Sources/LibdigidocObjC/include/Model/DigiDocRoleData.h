// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>

@interface DigiDocRoleData : NSObject

@property (nonatomic, strong) NSArray<NSString *> *roles;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *zipcode;

- (instancetype)initWithRoles:(NSArray<NSString *> *)roles
                         city:(NSString *)city
                        state:(NSString *)state
                      country:(NSString *)country
                      zipcode:(NSString *)zipcode;

@end

