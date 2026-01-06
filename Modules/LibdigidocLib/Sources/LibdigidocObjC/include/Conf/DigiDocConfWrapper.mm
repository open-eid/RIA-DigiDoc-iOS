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
#import <digidocpp/Conf.h>
#import <digidocpp/Container.h>
#import <digidocpp/crypto/X509Cert.h>
#import "digidocpp/Exception.h"
#import "DigiDocConfWrapper.h"
#import "../Model/DigiDocConfig.h"
#import "Exception/Util/ExceptionUtil.h"

struct DigiDocConfCurrent final : public digidoc::ConfCurrent {
private:
    DigiDocConfig *currentConf;
    inline static NSURL * _Nullable _sivaUrl = nil;
    inline static NSData * _Nullable _sivaCert = nil;
    inline static NSURL * _Nullable _tsUrl = nil;
    inline static NSData * _Nullable _tsCert = nil;
    inline static NSString * _Nullable _proxyHost = nil;
    inline static NSString * _Nullable _proxyPort = nil;
    inline static NSString * _Nullable _proxyUser = nil;
    inline static NSString * _Nullable _proxyPass = nil;

public:
    DigiDocConfCurrent(DigiDocConfig *conf) : currentConf(conf) {}
    
    void setTSUrl(NSURL *tsaUrl) {
        _tsUrl = tsaUrl;
    }
    
    void addTSCert(NSData * cert) {
        _tsCert = cert;
    }
    
    void setSiVaUrl(NSURL *sivaUrl) {
        _sivaUrl = sivaUrl;
    }
    
    void addSiVaCert(NSData * cert) {
        _sivaCert = cert;
    }

    void setProxyHost(NSString *proxyHost) {
        _proxyHost = proxyHost;
    }
    
    void setProxyPort(NSString *proxyPort) {
        _proxyPort = proxyPort;
    }
    
    void setProxyUser(NSString *proxyUser) {
        _proxyUser = proxyUser;
    }
    
    void setProxyPass(NSString *proxyPass) {
        _proxyPass = proxyPass;
    }

    std::string TSLCache() const final {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *tslCachePath = [paths objectAtIndex:0];
        return tslCachePath.UTF8String;
    }

    std::string TSLUrl() const final {
        NSURL *tslUrl = currentConf.TSLURL;
        if (tslUrl && tslUrl.absoluteString.length > 0) {
            return [tslUrl.absoluteString UTF8String];
        }
        return digidoc::ConfCurrent::TSLUrl();
    }

    std::vector<digidoc::X509Cert> TSLCerts() const final {
        NSMutableArray<NSData *> *certBundle = [NSMutableArray arrayWithArray:currentConf.TSLCERTS];

        if (certBundle != nil && certBundle.count > 0) {
            return toX509Certs(certBundle);
        }

        return digidoc::ConfCurrent::TSLCerts();
    }

    std::vector<digidoc::X509Cert> TSCerts() const override {
        NSMutableArray<NSData *> *certBundle = [NSMutableArray arrayWithArray:currentConf.CERTBUNDLE];

        if (_tsCert != nil && [_tsCert length] > 0) {
            [certBundle addObject:_tsCert];
        }
        
        return toX509Certs(certBundle);
    }
    
    std::string TSUrl() const override {
        if (_tsUrl != nil && [_tsUrl isKindOfClass:[NSURL class]] && _tsUrl.absoluteString.length > 0) {
            std::string tsUrl = std::string([[_tsUrl absoluteString] UTF8String]);
            return tsUrl;
        }

        NSURL *tsaUrl = currentConf.TSAURL;
        
        if (tsaUrl && tsaUrl.absoluteString.length > 0) {
            return [tsaUrl.absoluteString UTF8String];
        }
        
        return digidoc::ConfCurrent::TSUrl();
    }
    
    std::string proxyHost() const final {
        if (_proxyHost && _proxyHost.length > 0) {
            std::string proxyHost = std::string([_proxyHost UTF8String]);
            return proxyHost;
        }
        return {};
    }
    
    std::string proxyPort() const final {
        if (_proxyPort && _proxyPort.length > 0) {
            std::string proxyPort = std::string([_proxyPort UTF8String]);
            return proxyPort;
        }
        return {};
    }
    
    std::string proxyUser() const final {
        if (_proxyUser && _proxyUser.length > 0) {
            std::string proxyUser = std::string([_proxyUser UTF8String]);
            return proxyUser;
        }
        return {};
    }
    
    std::string proxyPass() const final {
        if (_proxyPass && _proxyPass.length > 0) {
            std::string proxyPass = std::string([_proxyPass UTF8String]);
            return proxyPass;
        }
        return {};
    }

    std::string verifyServiceUri() const override {
        if (_sivaUrl != nil && _sivaUrl.absoluteString.length > 0) {
            std::string sivaUrl = std::string([[_sivaUrl absoluteString] UTF8String]);
            return sivaUrl;
        }

        NSURL *sivaUrl = currentConf.SIVAURL;
        if (sivaUrl && sivaUrl.absoluteString.length > 0) {
            return [sivaUrl.absoluteString UTF8String];
        }

        return digidoc::ConfCurrent::verifyServiceUri();
    }

    virtual std::vector<digidoc::X509Cert> verifyServiceCerts() const override {
        NSMutableArray<NSData*> *certs = [NSMutableArray arrayWithArray:currentConf.CERTBUNDLE];

        if (_sivaCert != nil && [_sivaCert length] > 0) {
            [certs addObject:_sivaCert];
        }
        
        return toX509Certs(certs);
    }

    int logLevel() const final {
        return (int) currentConf.logLevel;
    }

    std::string logFile() const final {
        return logFileLocation(currentConf.logFile);
    }

    std::string logFileLocation(NSString *logsFolderPath) const {
        return [logsFolderPath stringByAppendingPathComponent:@"libdigidocpp.log"].UTF8String;
    }

    std::vector<digidoc::X509Cert> toX509Certs(NSArray<NSData*> *certBundle, NSURL *cert = nil) const {
        std::vector<digidoc::X509Cert> x509Certs;
        auto add = [&x509Certs](NSData *data) {
            try {
                bool isPEM = std::string_view(reinterpret_cast<const char*>(data.bytes), data.length)
                    .starts_with("-----BEGIN CERTIFICATE-----");
                auto bytes = reinterpret_cast<const unsigned char*>(data.bytes);
                x509Certs.emplace_back(bytes, data.length, isPEM ? digidoc::X509Cert::Pem : digidoc::X509Cert::Der);
            } catch (const digidoc::Exception &e) {
                printLog(@"Unable to generate a X509 certificate object. Code: %u, message: %s", e.code(), e.msg().c_str());
            }
        };
        for (NSData *data in certBundle) {
            add(data);
        }
        if (cert) {
            add([NSData dataWithContentsOfURL:cert]);
        }
        return x509Certs;
    }

    static digidoc::Conf* instance() {
        return digidoc::Conf::instance();
    }
};

class DigiDocConfWrapperImpl {
private:
    template<typename Func>
    static void withCurrentConf(Func&& fn) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            fn(currentConf);
        }
    }
    
public:
    static void initConf(DigiDocConfig *conf, void (^completion)(NSError * _Nullable error)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            try {
                DigiDocConfCurrent *currentConf = new DigiDocConfCurrent(conf);
                digidoc::Conf::init(currentConf);
                digidoc::initialize("RIA DigiDoc 3.0", "RIA DigiDoc");
            } catch (const digidoc::Exception &e) {
                std::vector<digidoc::Exception> causes = e.causes();
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
                    @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
                };

                error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];
            }

            if (completion) {
                completion(error);
            }
        });
    }

    void updateConfiguration(DigiDocConfig *conf) {
        DigiDocConfCurrent *newCurrentConf = new DigiDocConfCurrent(conf);
        digidoc::Conf::init(newCurrentConf);
    }
    
    static void setTSUrl(NSURL *tsaUrl) {
        withCurrentConf([tsaUrl](DigiDocConfCurrent *currentConf) {
            currentConf->setTSUrl(tsaUrl);
        });
    }
    
    static void addTSCert(NSData *cert) {
        withCurrentConf([cert](DigiDocConfCurrent *currentConf) {
            currentConf->addTSCert(cert);
        });
    }
    
    static void setSiVaUrl(NSURL *sivaUrl) {
        withCurrentConf([sivaUrl](DigiDocConfCurrent *currentConf) {
            currentConf->setSiVaUrl(sivaUrl);
        });
    }
    
    static void addSiVaCert(NSData *cert) {
        withCurrentConf([cert](DigiDocConfCurrent *currentConf) {
            currentConf->addSiVaCert(cert);
        });
    }
    
    static void setProxyHost(NSString *proxyHost) {
        withCurrentConf([proxyHost](DigiDocConfCurrent *currentConf) {
            currentConf->setProxyHost(proxyHost);
        });
    }
    
    static void setProxyPort(NSString *proxyPort) {
        withCurrentConf([proxyPort](DigiDocConfCurrent *currentConf) {
            currentConf->setProxyPort(proxyPort);
        });
    }
    
    static void setProxyUser(NSString *proxyUser) {
        withCurrentConf([proxyUser](DigiDocConfCurrent *currentConf) {
            currentConf->setProxyUser(proxyUser);
        });
    }
    
    static void setProxyPass(NSString *proxyPass) {
        withCurrentConf([proxyPass](DigiDocConfCurrent *currentConf) {
            currentConf->setProxyPass(proxyPass);
        });
    }
};

@implementation DigiDocConfWrapper {
    DigiDocConfWrapperImpl* _impl;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _impl = new DigiDocConfWrapperImpl();
    }
    return self;
}

- (void)initWithConf:(DigiDocConfig *)conf completion:(void (^)(BOOL, NSError * _Nullable))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        try {
            DigiDocConfWrapperImpl::initConf(conf, ^(NSError *error) {
                if (error) {
                    error = [NSError errorWithDomain:@"LibdigidocLib"
                                                code:1
                                            userInfo:@{@"message": @"Unable to init configuration: %@"}];
                }
            });
        } catch (const digidoc::Exception &e) {
            std::vector<digidoc::Exception> causes = e.causes();
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: [NSString stringWithUTF8String:e.msg().c_str()],
                @"causes": [ExceptionUtil exceptionCauses:static_cast<void *>(&causes)]
            };

            error = [NSError errorWithDomain:@"LibdigidocLib" code:e.code() userInfo:userInfo];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(error == nil, error);
            }
        });
    });
}

- (void)updateConfiguration:(DigiDocConfig *)conf {
    _impl->updateConfiguration(conf);
}

- (void)setTSUrl:(NSURL *)tsUrl {
    _impl->setTSUrl(tsUrl);
}

- (void)addTSCert:(NSData *)tsCert {
    _impl->addTSCert(tsCert);
}

- (void)setSiVaUrl:(NSURL *)sivaUrl {
    _impl->setSiVaUrl(sivaUrl);
}

- (void)addSiVaCert:(NSData *)sivaCert {
    _impl->addSiVaCert(sivaCert);
}

- (void)setProxyHost:(NSString *)proxyHost {
    _impl->setProxyHost(proxyHost);
}

- (void)setProxyPort:(NSString *)proxyPort {
    _impl->setProxyPort(proxyPort);
}

- (void)setProxyUser:(NSString *)proxyUser {
    _impl->setProxyUser(proxyUser);
}

- (void)setProxyPass:(NSString *)proxyPass {
    _impl->setProxyPass(proxyPass);
}

+ (nullable instancetype)sharedInstance {
    static DigiDocConfWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DigiDocConfWrapper alloc] init];
    });
    return sharedInstance;
}

@end
