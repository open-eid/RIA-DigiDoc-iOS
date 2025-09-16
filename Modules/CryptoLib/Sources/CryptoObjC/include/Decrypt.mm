#import "Decrypt.h"
#import "Extensions.h"
#import "SmartCardTokenWrapper.h"

#include <cdoc/CdocReader.h>
#include <cdoc/Lock.h>
#include <cdoc/Recipient.h>

#import "AbstractSmartTokenObjC.h"

@implementation Decrypt

+ (void)decryptFile:(NSString *)fullPath withToken:(id<AbstractSmartTokenObjC>)smartToken
         completion:(void (^)(NSDictionary<NSString*,NSData*> *, NSError *))completion {

        NSError *error = nil;
        NSData *certData = [smartToken getCertificateSync:&error];
        auto cert = [certData toVector];
        if(cert.empty()) {
            return completion(nil, error);
        }

        SmartCardTokenWrapper token(smartToken);
        std::unique_ptr<libcdoc::CDocReader> reader(libcdoc::CDocReader::createReader(fullPath.UTF8String, nullptr, &token, nullptr));

        auto idx = reader->getLockForCert(cert);
        if(idx < 0) {
            return completion(nil, [NSError cryptoError:@"Failed to find lock for cert"]);
        }
        std::vector<uint8_t> fmk;
        if(reader->getFMK(fmk, unsigned(idx)) != 0 || fmk.empty()) {
            return completion(nil, token.lastError() ?: [NSError cryptoError:@"Failed to get FMK"]);
        }
        if(reader->beginDecryption(fmk) != 0) {
            return completion(nil, [NSError cryptoError:@"Failed to start encryption"]);
        }

        NSMutableDictionary<NSString*,NSData*> *response = [NSMutableDictionary new];
        std::string name;
        int64_t size{};
        while((reader->nextFile(name, size)) == 0)
        {
            NSMutableData *data = [[NSMutableData alloc] initWithLength:16 * 1024];
            NSUInteger currentLength = 0;

            uint64_t bytesRead = 0;
            while (true) {
                bytesRead = reader->readData(reinterpret_cast<uint8_t *>(data.mutableBytes) + currentLength, 16 * 1024);
                if (bytesRead < 0) {
                    NSLog(@"Error reading data from file: %s", name.c_str());
                    return completion(nil, [NSError cryptoError:@"Failed to decrypt file"]);
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
        if (reader->finishDecryption() != 0)
            return completion(nil, [NSError cryptoError:@"Failed to end encryption"]);
        return completion(response, nil);
}

@end
