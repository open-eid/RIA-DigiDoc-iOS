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

@import CryptoObjCWrapper;

#import "Encrypt.h"
#import "Extensions.h"
#import "Config.h"

#include <cdoc/CDocWriter.h>
#include <cdoc/Recipient.h>
#include <cdoc/Logger.h>

@implementation Encrypt

+ (void)setCerts:(nullable NSArray<NSData *> *)certs {
    Network::setCerts(certs);
}

+ (void)setCert:(nullable NSData *)cert {
    Network::setCert(cert);
}

+ (void)setCdoc2Config:(nonnull NSDictionary<NSString *,id> *)config {
    Settings::setCdoc2Config(config);
}

+ (void)setFetchURL:(nonnull NSString *)url {
    Settings::setFetchURL(url);
}

+ (void)setPostURL:(nonnull NSString *)url {
    Settings::setPostURL(url);
}

+ (void)setUUID:(nonnull NSString *)uuid {
    Settings::setUUID(uuid);
}

+ (void)setIsOnlineEncryptionEnabled:(bool)enabled {
    Settings::setIsOnlineEncryptionEnabled(enabled);
}

+ (void)setProxy:(nonnull NSString *)host port:(NSInteger)port username:(nonnull NSString *)username password:(nonnull NSString *)password {
    Network::setProxy(host, port, username, password);
}

static inline NSString *NSStringFromStringView(std::string_view sv) {
    return [[NSString alloc] initWithBytes:sv.data()
                                    length:sv.size()
                                  encoding:NSUTF8StringEncoding] ?: @"";
}

static inline NSString *NSStringFromLogLevel(libcdoc::LogLevel level) {
    switch (level) {
        case libcdoc::LEVEL_FATAL:   return @"FATAL";
        case libcdoc::LEVEL_ERROR:   return @"ERROR";
        case libcdoc::LEVEL_WARNING: return @"WARN";
        case libcdoc::LEVEL_INFO:    return @"INFO";
        case libcdoc::LEVEL_DEBUG:   return @"DEBUG";
        case libcdoc::LEVEL_TRACE:   return @"TRACE";
    }
    return @"UNKNOWN";
}

static inline NSString *BasenameFromPath(NSString *path) {
    if (path == nil || path.length == 0) return @"<unknown>";
    NSString *last = path.lastPathComponent;
    if (last.length > 0) return last;

    NSCharacterSet *seps = [NSCharacterSet characterSetWithCharactersInString:@"/\\"];
    NSArray<NSString *> *parts = [path componentsSeparatedByCharactersInSet:seps];
    for (NSInteger i = parts.count - 1; i >= 0; i--) {
        if (parts[i].length > 0) return parts[i];
    }
    return path;
}

class ObjCLogger final : public libcdoc::Logger {
protected:
    void logMessage(libcdoc::LogLevel level,
                    std::string_view file,
                    int line,
                    std::string_view message) override
    {
        NSString *nsFileFull = NSStringFromStringView(file);
        NSString *nsFile = BasenameFromPath(nsFileFull);
        NSString *nsMsg  = NSStringFromStringView(message);
        NSString *nsLvl  = NSStringFromLogLevel(level);

        static NSDateFormatter *formatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        });

        NSString *timeString = [formatter stringFromDate:[NSDate date]];

        NSLog(@"[%@] CryptoContainer: %@:%d %@ %@",
              timeString,
              nsFile.length ? nsFile : @"<unknown>",
              line,
              nsLvl,
              nsMsg);
    }
};

+ (void)enableLogging:(bool)enabled {
    static ObjCLogger gLogger;

    if (!enabled) {
        return;
    }

    // Install only once, even if enableLogging:YES is called many times
    static std::once_flag once;
    std::call_once(once, [] {
        libcdoc::setLogger(&gLogger);
        gLogger.setMinLogLevel(libcdoc::LEVEL_TRACE);
    });
}

+ (void)encryptFile:(NSString *)fullPath withDataFiles:(NSArray<CryptoDataFile*> *)dataFiles withAddressees:(NSArray<Addressee*> *)addressees
         completion:(void (^)(NSError*))completion {
    int version = [fullPath.pathExtension caseInsensitiveCompare:@"cdoc2"] == NSOrderedSame ? 2 : 1;
    Settings conf;
    Network network;
    std::unique_ptr<libcdoc::CDocWriter> writer(libcdoc::CDocWriter::createWriter(version, fullPath.UTF8String, &conf, nullptr, &network));

    if (!writer) {
        return completion([NSError cryptoError:@"Failed to create writer"]);
    }
  
    
    if (version == 2 && Settings::isOnlineEncryptionEnabled()) {
        NSString *server_id = Settings::getUUID();
        for (Addressee *addressee in addressees) {
            if (writer->addRecipient(libcdoc::Recipient::makeCertificate({}, [addressee.data toVector], [server_id toString])) != 0) {
                return completion([NSError cryptoError:@"Failed to add recipient"]);
            }
        }
    } else {
        for (Addressee *addressee in addressees) {
            if (writer->addRecipient(libcdoc::Recipient::makeCertificate({}, [addressee.data toVector])) != 0) {
                return completion([NSError cryptoError:@"Failed to add recipient"]);
            }
        }
    }
    
    if (writer->beginEncryption() != 0) {
        return completion([NSError cryptoError:@"Failed to start encryption"]);
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

+ (void)encryptFile:(NSString *)fullPath withDataFiles:(NSArray<CryptoDataFile*> *)dataFiles withLabel:(NSString*)label withPassword:(NSString *)password
         completion:(void (^)(NSError*))completion {
    int version = [fullPath.pathExtension caseInsensitiveCompare:@"cdoc2"] == NSOrderedSame ? 2 : 1;
    Settings conf;
    struct PasswordBackend: public libcdoc::CryptoBackend {
        NSString *password;
        PasswordBackend(NSString *pass) : password(pass) {}
        libcdoc::result_t getSecret(std::vector<uint8_t>& dst, unsigned int idx) final {
            dst = [[password dataUsingEncoding:NSUTF8StringEncoding] toVector];
            return libcdoc::OK;
        }
    } crypto {password};
    libcdoc::NetworkBackend network;
    std::unique_ptr<libcdoc::CDocWriter> writer(libcdoc::CDocWriter::createWriter(version, fullPath.UTF8String, &conf, &crypto, &network));

    if (!writer) {
        return completion([NSError cryptoError:@"Failed to create writer"]);
    }

    auto passwordRecipient = libcdoc::Recipient::makeSymmetric("", 65536);
    passwordRecipient.setLabelValue("label", std::string(label.UTF8String));
    if (writer->addRecipient(passwordRecipient) != 0) {
        return completion([NSError cryptoError:@"Failed to create key"]);
    }

    if (writer->beginEncryption() != 0) {
        return completion([NSError cryptoError:@"Failed to start encryption"]);
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



