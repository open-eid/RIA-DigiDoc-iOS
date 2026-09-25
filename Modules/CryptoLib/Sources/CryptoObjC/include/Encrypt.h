// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface Encrypt: NSObject

+ (void)setCdoc2Config:(NSDictionary<NSString *, id> *)config;
+ (void)setFetchURL:(NSString *)url;
+ (void)setPostURL:(NSString *)url;
+ (void)setUUID:(NSString *)uuid;
+ (void)setIsOnlineEncryptionEnabled:(bool)enabled;
+ (void)setCerts:(NSArray<NSData *> * _Nullable)certs;
+ (void)setCert:(NSData * _Nullable)cert;
+ (void)setProxy:(NSString *)host port:(NSInteger)port username:(NSString *)username password:(NSString *)password;
+ (void)enableLogging:(bool)enabled;
+ (void)encryptFile:(NSString *)fullPath withDataFiles:(NSArray *)dataFiles
     withAddressees:(NSArray *)addressees completion:(void (^)(NSError * _Nullable))completion;
+ (void)encryptFile:(NSString *)fullPath withDataFiles:(NSArray *)dataFiles
          withLabel:(NSString*)label withPassword:(NSString *)password completion:(void (^)(NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
