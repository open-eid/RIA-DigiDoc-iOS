// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>
#import "../Model/DigiDocRoleData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocSigningWrapper : NSObject

- (void)prepareSignature:(NSData *)cert containerPath:(NSString *)containerPath roleData:(DigiDocRoleData *)roleData userAgent:(NSString *)userAgent completion:(void (^)(NSData * _Nullable dataToSign, NSError * _Nullable error))completion;
- (void)addSignature:(NSData *)data completion:(void (^)(BOOL valid, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
