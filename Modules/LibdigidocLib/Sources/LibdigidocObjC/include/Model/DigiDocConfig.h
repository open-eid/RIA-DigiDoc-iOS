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

@interface DigiDocConfig : NSObject


@property (nonatomic, assign) int logLevel;
@property (nonatomic, strong) NSString *logFile;

@property (nonatomic, strong) NSString *TSLCACHE;
@property (nonatomic, strong) NSURL *SIVAURL;
@property (nonatomic, strong) NSURL *TSLURL;
@property (nonatomic, strong) NSArray<NSData *> *TSLCERTS;
@property (nonatomic, strong) NSArray<NSData *> *LDAPCERTS;
@property (nonatomic, strong) NSURL *TSAURL;
@property (nonatomic, strong) NSDictionary *OCSPISSUERS;
@property (nonatomic, strong) NSArray<NSData *> *CERTBUNDLE;

- (instancetype)initWithConf:(int)logLevel
                     logFile:(NSString *)logFile
                    TSLCache:(NSString *)TSLCache
                     SIVAURL:(NSString *)SIVAURL
                      TSLURL:(NSString *)TSLURL
                    TSLCERTS:(NSArray<NSString*> *)TSLCERTS
                   LDAPCERTS:(NSArray<NSString*> *)LDAPCERTS
                      TSAURL:(NSString *)TSAURL
                 OCSPISSUERS:(NSDictionary *)OCSPISSUERS
                  CERTBUNDLE:(NSArray<NSString*> *)CERTBUNDLE;

@end
