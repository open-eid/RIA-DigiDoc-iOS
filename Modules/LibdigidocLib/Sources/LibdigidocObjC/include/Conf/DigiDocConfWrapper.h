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
#import "../Model/DigiDocConfig.h"

#if DEBUG
#define printLog(...) NSLog(__VA_ARGS__)
#else
#define printLog(...)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface DigiDocConfWrapper : NSObject

- (void)initWithConf:(DigiDocConfig *)conf completion:(void (^)(BOOL, NSError * _Nullable))completion;
- (void)updateConfiguration:(DigiDocConfig *)conf;
- (void)setSiVaUrl:(NSURL *)url;
- (void)addSiVaCert:(NSData * _Nullable)cert;
- (void)setTSUrl:(NSURL *)url;
- (void)addTSCert:(NSData * _Nullable)cert;
- (void)setProxyHost:(NSString *)proxyHost;
- (void)setProxyPort:(NSString *)proxyPort;
- (void)setProxyUser:(NSString *)proxyUser;
- (void)setProxyPass:(NSString *)proxyPass;
+ (nullable instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
