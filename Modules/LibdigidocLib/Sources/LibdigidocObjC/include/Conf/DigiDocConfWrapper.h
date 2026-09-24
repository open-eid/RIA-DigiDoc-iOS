// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>
#import "../Model/DigiDocConfig.h"

#if DEBUG
#define printLog(...) NSLog(__VA_ARGS__)
#else
#define printLog(...)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocConfWrapper : NSObject

- (void)initWithConf:(DigiDocConfig *)conf userAgent:(NSString *)userAgent completion:(void (^)(BOOL, NSError * _Nullable))completion;
- (void)updateConfiguration:(DigiDocConfig *)conf;
- (void)setSiVaUrl:(NSURL * _Nullable)url;
- (void)addSiVaCert:(NSData * _Nullable)cert;
- (void)setTSUrl:(NSURL * _Nullable)url;
- (void)addTSCert:(NSData * _Nullable)cert;
- (void)setProxyHost:(NSString * _Nullable)proxyHost;
- (void)setProxyPort:(NSString * _Nullable)proxyPort;
- (void)setProxyUser:(NSString * _Nullable)proxyUser;
- (void)setProxyPass:(NSString * _Nullable)proxyPass;
+ (nullable instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
