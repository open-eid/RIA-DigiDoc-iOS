/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocSigningWrapper : NSObject

+ (void)prepareSignature:(NSData *)cert containerPath:(NSString *)containerPath roles:(NSArray<NSString *> *)roles roleCity:(NSString *)roleCity roleState:(NSString *)roleState roleCountry:(NSString *)roleCountry roleZip:(NSString *)roleZip userAgent:(NSString *)userAgent completion:(void (^)(NSData * _Nullable dataToSign, NSError * _Nullable error))completion;
+ (void)addSignature:(NSData *)data completion:(void (^)(BOOL valid, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
