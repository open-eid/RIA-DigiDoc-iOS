#import "Encrypt.h"
#import "Extensions.h"

#include <cdoc/CDocWriter.h>
#include <cdoc/Recipient.h>

#import "Addressee.h"
#import "CryptoDataFile.h"

@implementation Encrypt

+ (void)encryptFile:(NSString *)fullPath withDataFiles:(NSArray<CryptoDataFile*> *)dataFiles withAddressees:(NSArray<Addressee*> *)addressees
         completion:(void (^)(NSError*))completion {
    std::unique_ptr<libcdoc::CDocWriter> writer(libcdoc::CDocWriter::createWriter(1, fullPath.UTF8String, nullptr, nullptr, nullptr));

    if (!writer) {
        return completion([NSError cryptoError:@"Failed to create writer"]);
    }

    if (writer->beginEncryption() != 0) {
        return completion([NSError cryptoError:@"Failed to start encryption"]);
    }

    for (Addressee *addressee in addressees) {
        if (writer->addRecipient(libcdoc::Recipient::makeEID([addressee.data toVector])) != 0) {
            return completion([NSError cryptoError:@"Failed to add recipien"]);
        }
    }

    for (CryptoDataFile *dataFile in dataFiles) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:dataFile.filePath];
        if (!fileHandle) {
            return completion([NSError cryptoError:[NSString stringWithFormat:@"Failed to open file at path: %@", dataFile.filePath]]);
        }

        if (writer->addFile(dataFile.filename.UTF8String, [fileHandle seekToEndOfFile]) != 0) {
            [fileHandle closeFile];
            return completion([NSError cryptoError:[NSString stringWithFormat:@"Failed to add file to container: %@", dataFile.filename]]);
        }
        [fileHandle seekToFileOffset:0];

        NSUInteger blockSize = 1024 * 16;
        NSData *data;
        while ((data = [fileHandle readDataOfLength:blockSize]) && data.length > 0) {
            if (writer->writeData(reinterpret_cast<const uint8_t*>(data.bytes), data.length) != 0) {
                [fileHandle closeFile];
                return completion([NSError cryptoError:[NSString stringWithFormat:@"Failed to write file to container: %@", dataFile.filename]]);
            }
        }
        [fileHandle closeFile];
    }
    completion(writer->finishEncryption() == 0 ? nil : [NSError cryptoError:@"Failed to finish encryption"]);
}

@end
