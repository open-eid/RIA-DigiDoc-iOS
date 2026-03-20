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
#import "DigiDocConfig.h"

@implementation DigiDocConfig

- (instancetype)initWithConf:(int)logLevel
                     logFile:(NSString *)logFile
                    TSLCache:(NSString *)TSLCache
                     SIVAURL:(NSURL *)SIVAURL
                      TSLURL:(NSURL *)TSLURL
                    TSLCERTS:(NSArray<NSData *> *)TSLCERTS
                   LDAPCERTS:(NSArray<NSData *> *)LDAPCERTS
                      TSAURL:(NSURL *)TSAURL
                  CERTBUNDLE:(NSArray<NSData *> *)CERTBUNDLE {
    self = [super init];
    if (self) {
        _logLevel = logLevel;
        _logFile = logFile;
        _TSLCACHE = TSLCache;
        _SIVAURL = SIVAURL;
        _TSLURL = TSLURL;
        _TSLCERTS = TSLCERTS;
        _LDAPCERTS = LDAPCERTS;
        _TSAURL = TSAURL;
        _CERTBUNDLE = CERTBUNDLE;
    }
    return self;
}

@end
