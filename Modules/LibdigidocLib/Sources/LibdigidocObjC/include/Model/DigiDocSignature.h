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

typedef NS_ENUM(int, DigiDocSignatureStatus) {
    Valid,
    Warning,
    NonQSCD,
    Invalid,
    UnknownStatus
};

@interface DigiDocSignature : NSObject

@property (nonatomic, strong) NSData *signingCert;
@property (nonatomic, strong) NSData *timestampCert;
@property (nonatomic, strong) NSData *ocspCert;
@property (nonatomic, strong) NSString *signatureId;
@property (nonatomic, strong) NSString *claimedSigningTime;
@property (nonatomic, strong) NSString *signatureMethod;
@property (nonatomic, strong) NSString *ocspProducedAt;
@property (nonatomic, strong) NSString *timeStampTime;
@property (nonatomic, strong) NSString *signedBy;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSData *messageImprint;
@property (nonatomic, strong) NSString *trustedSigningTime;

@property (nonatomic, strong) NSArray *roles;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *zipCode;

@property (nonatomic, assign) DigiDocSignatureStatus status;
@property (nonatomic, strong) NSString *diagnosticsInfo;

@end

