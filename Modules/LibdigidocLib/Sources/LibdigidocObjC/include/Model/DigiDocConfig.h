// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
@property (nonatomic, strong) NSArray<NSData *> *CERTBUNDLE;

- (instancetype)initWithConf:(int)logLevel
                     logFile:(NSString *)logFile
                    TSLCache:(NSString *)TSLCache
                     SIVAURL:(NSURL *)SIVAURL
                      TSLURL:(NSURL *)TSLURL
                    TSLCERTS:(NSArray<NSData *> *)TSLCERTS
                   LDAPCERTS:(NSArray<NSData *> *)LDAPCERTS
                      TSAURL:(NSURL *)TSAURL
                  CERTBUNDLE:(NSArray<NSData *> *)CERTBUNDLE;

@end
