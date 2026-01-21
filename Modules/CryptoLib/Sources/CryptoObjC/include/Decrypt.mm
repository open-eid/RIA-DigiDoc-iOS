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

@import CryptoObjCWrapper;

#import "Decrypt.h"
#import "Extensions.h"
#import "SmartCardTokenWrapper.h"
#import "Config.h"

#include <cdoc/CdocReader.h>
#include <cdoc/Lock.h>
#include <cdoc/Recipient.h>

@implementation Addressee (label)

- (instancetype)initWithLabel:(const std::string &)label pub:(NSData*)pub concatKDFAlgorithmURI:(NSString *)concatKDFAlgorithmURI {
    std::map<std::string, std::string> info = libcdoc::Recipient::parseLabel(label);
    id cn = info.contains("cn") ? [NSString stringWithStdString:info["cn"]] : nil;
    id first = info.contains("first_name") ? [NSString stringWithStdString:info["first_name"]] : nil;
    id last = info.contains("last_name") ? [NSString stringWithStdString:info["last_name"]] : nil;
    id serial = info.contains("serial_number") ? [NSString stringWithStdString:info["serial_number"]] : nil;
    id type = info.contains("type") ? [NSString stringWithStdString:info["type"]] : nil;
    CertType certType = CertTypeUnknownType;
    if ([type isEqualToString:@"ID-card"]) {
        certType = CertTypeIDCardType;
    } else if ([type isEqualToString:@"Digi-ID"]) {
        certType = CertTypeDigiIDType;
    } else if ([type isEqualToString:@"Digi-ID E-RESIDENT"]) {
        certType = CertTypeEResidentType;
    }
    id validTo = nil;
    if (info.contains("server_exp")) {
        long long epochTime = [[NSString stringWithStdString:info["server_exp"]] longLongValue];
        validTo = [NSDate dateWithTimeIntervalSince1970:epochTime];
    }
    if (self = [self initWithData:pub cnVal:cn givenName:first surname:last serialNumber:serial certType:certType validTo:validTo concatKDFAlgorithmURI:concatKDFAlgorithmURI]) {
    }
    return self;
}

@end

@implementation Decrypt

+ (CdocInfo*)cdocInfo:(NSString *)fullPath error:(NSError**)error {
    CdocInfo* cdocInfo = nil;
    
    if([fullPath.pathExtension caseInsensitiveCompare:@"cdoc"] == NSOrderedSame) {
        cdocInfo = [[CdocInfo alloc] initWithCdoc1Path:fullPath error:error];
    }

    std::unique_ptr<libcdoc::CDocReader> reader(libcdoc::CDocReader::createReader(fullPath.UTF8String, nullptr, nullptr, nullptr));
    if(!reader) {
        return [NSError cryptoError:@"Parsing failed" error:error];
    }
    NSMutableArray<Addressee*> *addressees = [[NSMutableArray alloc] init];
    for(const libcdoc::Lock &lock: reader->getLocks())
    {
        if(lock.isCertificate()) {
            NSString* concatKDFAlgorithmURI = @"";
            if (!lock.isRSA()) {
                concatKDFAlgorithmURI = [NSString stringWithStdString:lock.getString(libcdoc::Lock::CONCAT_DIGEST)];
            }
            [addressees addObject:[[Addressee alloc] initWithLabel:lock.label pub:[NSData dataFromVector:lock.getBytes(libcdoc::Lock::CERT)] concatKDFAlgorithmURI:concatKDFAlgorithmURI]];
        } else if(lock.isPKI()) {
            [addressees addObject:[[Addressee alloc] initWithLabel:lock.label pub:[NSData dataFromVector:lock.getBytes(libcdoc::Lock::RCPT_KEY)] concatKDFAlgorithmURI:@""]];
        } else if(lock.isSymmetric()) {
            [addressees addObject:[[Addressee alloc] initWithData:[NSData data] cnVal:[NSString stringWithStdString:lock.label]]];
        } else {
            [addressees addObject:[[Addressee alloc] initWithData:[NSData data] cnVal:@"Unknown capsule"]];
        }
    }
    if (cdocInfo != nil) {
        NSMutableArray<Addressee*> *recipients = [cdocInfo.addressees mutableCopy];
        for (Addressee *addressee in addressees) {
            for (Addressee *recipient in recipients) {
                if ([addressee.data isEqualToData:recipient.data]) {
                    recipient.concatKDFAlgorithmURI = addressee.concatKDFAlgorithmURI;
                }
            }
        }
        
        return [[CdocInfo alloc] initWithAddressees:recipients dataFiles:cdocInfo.dataFiles];
    }
    return [[CdocInfo alloc] initWithAddressees:addressees];
}

+ (void)decryptFile:(NSString *)fullPath withCert:(NSData *)certData withToken:(id<AbstractSmartToken>)smartToken
         completion:(void (^)(NSDictionary<NSString*,NSData*> *, NSError *))completion {
    auto cert = [certData toVector];
    auto certCopy = cert; // copy for getLockForCert
    if(cert.empty()) {
        return completion(nil, [NSError cryptoError:@"Failed to get certData"]);
    }

    struct TokenBackend: public SmartCardTokenWrapper, public Network
    {
        std::vector<uint8_t> cert;

        TokenBackend(id<AbstractSmartToken> smartToken, std::vector<uint8_t> &&_cert)
            : SmartCardTokenWrapper(smartToken)
            , cert(std::move(_cert))
        {}

        libcdoc::result_t getClientTLSCertificate(std::vector<uint8_t> &dst) final {
            dst = cert;
            return dst.empty() ? libcdoc::IO_ERROR : libcdoc::OK;
        }

        libcdoc::result_t signTLS(std::vector<uint8_t> &dst, libcdoc::CryptoBackend::HashAlgorithm algorithm, const std::vector<uint8_t> &digest) final {
            return sign(dst, algorithm, digest, 0);
        }
    };
    //TokenBackend token(smartToken, std::move(cert));
    TokenBackend token(smartToken, std::move(cert));
    Settings conf;
    std::unique_ptr<libcdoc::CDocReader> reader(libcdoc::CDocReader::createReader(fullPath.UTF8String, &conf, &token, &token));

    if (!reader) {
        return completion(nil, [NSError cryptoError:@"Failed to create CDocReader"]);
    }
    
    auto idx = reader->getLockForCert(certCopy);
    
    if(idx < 0) {
        return completion(nil, [NSError cryptoError:@"Failed to find lock for cert"]);
    }
    std::vector<uint8_t> fmk;
    if(reader->getFMK(fmk, unsigned(idx)) != 0 || fmk.empty()) {
        return completion(nil, token.lastError() ?: [NSError cryptoError:@"Failed to get FMK"]);
    }
    NSError *error = nil;
    completion([self decryptReader:*reader withFMK:fmk error:&error], error);
}

+ (NSDictionary<NSString*,NSData*> *)decryptFile:(NSString *)fullPath withPassword:(NSString*)password error:(NSError**)error {
    struct PasswordBackend: public libcdoc::CryptoBackend {
        NSString *password;
        PasswordBackend(NSString *pass) : password(pass) {}
        libcdoc::result_t getSecret(std::vector<uint8_t>& dst, unsigned int idx) final {
            dst = [[password dataUsingEncoding:NSUTF8StringEncoding] toVector];
            return libcdoc::OK;
        }
    } crypto {password};
    std::unique_ptr<libcdoc::CDocReader> reader(libcdoc::CDocReader::createReader(fullPath.UTF8String, nullptr, &crypto, nullptr));

    auto idx = 0; // TODO: reader->getLockForCert(network.cert);
    if(idx < 0)
        return [NSError cryptoError:@"Decrypting failed" error:error];
    std::vector<uint8_t> fmk;
    if(reader->getFMK(fmk, unsigned(idx)) != 0 || fmk.empty()) {
        return [NSError cryptoError:@"Decrypting failed" error:error];
    }
    return [self decryptReader:*reader withFMK:fmk error:error];
}

+ (NSDictionary<NSString*,NSData*> *)decryptReader:(libcdoc::CDocReader&)reader withFMK:(const std::vector<uint8_t>&)fmk error:(NSError**)error {

    if(reader.beginDecryption(fmk) != 0) {
        return [NSError cryptoError:@"Failed to start encryption" error:error];
    }

    NSMutableDictionary<NSString*,NSData*> *response = [NSMutableDictionary new];
    std::string name;
    int64_t size{};
    while((reader.nextFile(name, size)) == 0)
    {
        NSMutableData *data = [[NSMutableData alloc] initWithLength:16 * 1024];
        NSUInteger currentLength = 0;

        uint64_t bytesRead = 0;
        while (true) {
            bytesRead = reader.readData(reinterpret_cast<uint8_t *>(data.mutableBytes) + currentLength, 16 * 1024);
            if (bytesRead < 0) {
                NSLog(@"Error reading data from file: %s", name.c_str());
                return [NSError cryptoError:@"Failed to decrypt file" error:error];
            }

            currentLength += bytesRead;
            [data setLength:currentLength];
            if (bytesRead == 0) {
                break;
            }
            [data increaseLengthBy:16 * 1024];
        }
        [response setObject:data forKey:[NSString stringWithStdString:name]];
    }
    if (reader.finishDecryption() != 0)
        return [NSError cryptoError:@"Failed to end encryption" error:error];
    return response;
}

@end

