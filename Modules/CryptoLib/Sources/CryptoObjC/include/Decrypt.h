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

#import <Foundation/Foundation.h>

@protocol AbstractSmartToken;
@class CdocInfo;

NS_ASSUME_NONNULL_BEGIN

@interface Decrypt : NSObject
+ (void)setCdoc2Config:(NSDictionary<NSString *, id> *)config;
+ (void)setFetchURL:(NSString *)url;
+ (void)setPostURL:(NSString *)url;
+ (void)setCerts:(NSArray<NSData *> * _Nullable)certs;
+ (void)setCert:(NSData * _Nullable)cert;
+ (void)setProxy:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password;
+ (nullable id)cdocInfo:(NSString *)fullPath error:(NSError **)error;
+ (void)decryptFile:(NSString *)fullPath withCert:(NSData *)certData withToken:(id)smartToken
         completion:(void (^)(NSDictionary<NSString*,NSData*> * _Nullable, NSError * _Nullable))completion;
+ (NSDictionary<NSString*,NSData*> * _Nullable)decryptFile:(NSString *)fullPath withPassword:(NSString*)password error:(NSError**)error;
@end

NS_ASSUME_NONNULL_END
