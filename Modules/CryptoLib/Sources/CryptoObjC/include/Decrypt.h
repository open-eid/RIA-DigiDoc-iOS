// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
