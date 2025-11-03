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
    inline static NSURL *_sivaUrl;
    inline static NSData *_sivaCert = nil;
    inline static NSURL *_tsUrl;
    inline static NSData *_tsCert = nil;
    inline static NSString * _Nullable _proxyHost = nil;
    inline static NSString * _Nullable _proxyPort = nil;
    inline static NSString * _Nullable _proxyUser = nil;
    inline static NSString * _Nullable _proxyPass = nil;

public:
    DigiDocConfCurrent(DigiDocConfig *conf) : currentConf(conf) {}

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

    std::vector<digidoc::X509Cert> TSCerts() const override {
        NSMutableArray<NSData *> *certBundle = [NSMutableArray arrayWithArray:currentConf.CERTBUNDLE];

        if (_tsCert != nil && [_tsCert length] > 0) {
            [certBundle addObject:_tsCert];
        }
        
        return toX509Certs(certBundle);
    }
    
    void addTSCert(NSData * cert) {
        _tsCert = cert;
    }
    
    std::string TSUrl() const override {
        if (_tsUrl && _tsUrl.absoluteString.length > 0) {
            std::string tsUrl = std::string([[_tsUrl absoluteString] UTF8String]);
            return tsUrl;
        }

        NSURL *tsaUrl = currentConf.TSAURL;
        
        if (tsaUrl && tsaUrl.absoluteString.length > 0) {
            return [tsaUrl.absoluteString UTF8String];
        }
        
        return digidoc::ConfCurrent::TSUrl();
    }
    
    void setTSUrl(NSURL *tsaUrl) {
        _tsUrl = tsaUrl;
    }
    
    void setSiVaUrl(NSURL *sivaUrl) {
        _sivaUrl = sivaUrl;
    }

    std::string ocsp(const std::string &issuer) const final {
        NSString *ocspIssuer = [NSString stringWithUTF8String:issuer.c_str()];
        NSString *ocspUrl = currentConf.OCSPISSUERS[ocspIssuer];
        if (ocspUrl != nil && ocspUrl.length > 0) {
            return ocspUrl.UTF8String;
        }
        return digidoc::ConfCurrent::ocsp(issuer);
    }
    
    std::string proxyHost() const final {
        if (_proxyHost && _proxyHost.length > 0) {
            std::string proxyHost = std::string([_proxyHost UTF8String]);
            return proxyHost;
        }
        return {};
    }
    
    void setProxyHost(NSString *proxyHost) {
        _proxyHost = proxyHost;
    }
    
    std::string proxyPort() const final {
        if (_proxyPort && _proxyPort.length > 0) {
            std::string proxyPort = std::string([_proxyPort UTF8String]);
            return proxyPort;
        }
        return {};
    }
    
    void setProxyPort(NSString *proxyPort) {
        _proxyPort = proxyPort;
    }
    
    std::string proxyUser() const final {
        if (_proxyUser && _proxyUser.length > 0) {
            std::string proxyUser = std::string([_proxyUser UTF8String]);
            return proxyUser;
        }
        return {};
    }
    
    void setProxyUser(NSString *proxyUser) {
        _proxyUser = proxyUser;
    }
    
    std::string proxyPass() const final {
        if (_proxyPass && _proxyPass.length > 0) {
            std::string proxyPass = std::string([_proxyPass UTF8String]);
            return proxyPass;
        }
        return {};
    }
    
    void setProxyPass(NSString *proxyPass) {
        _proxyPass = proxyPass;
    }

    std::string verifyServiceUri() const override {
        if (_sivaUrl && _sivaUrl.absoluteString.length > 0) {
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
    
    void addSiVaCert(NSData * cert) {
        _sivaCert = cert;
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
    
    static void setSiVaUrl(NSURL *sivaUrl) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            currentConf->setSiVaUrl(sivaUrl);
        }
    }
    
    static void addSiVaCert(NSData *cert) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            currentConf->addSiVaCert(cert);
        }
    }
    
    static void setTSUrl(NSURL *tsaUrl) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            currentConf->setTSUrl(tsaUrl);
        }
    }
    
    static void addTSCert(NSData *cert) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            currentConf->addTSCert(cert);
        }
    }
    
    static void setProxyHost(NSString *proxyHost) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            currentConf->setProxyHost(proxyHost);
        }
    }
    
    static void setProxyPort(NSString *proxyPort) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            currentConf->setProxyPort(proxyPort);
        }
    }
    
    static void setProxyUser(NSString *proxyUser) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            currentConf->setProxyUser(proxyUser);
        }
    }
    
    static void setProxyPass(NSString *proxyPass) {
        digidoc::Conf *conf = DigiDocConfCurrent::instance();
        if (!conf) return;
        DigiDocConfCurrent *currentConf = dynamic_cast<DigiDocConfCurrent*>(conf);
        if (currentConf) {
            currentConf->setProxyPass(proxyPass);
        }
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

- (void)setSiVaUrl:(NSURL *)sivaUrl {
    _impl->setSiVaUrl(sivaUrl);
}

- (void)addSiVaCert:(NSData *)sivaCert {
    if (!sivaCert) return;
    _impl->addSiVaCert(sivaCert);
}

- (void)setTSUrl:(NSURL *)tsUrl {
    _impl->setTSUrl(tsUrl);
}

- (void)addTSCert:(NSData *)tsCert {
    if (!tsCert) return;
    _impl->addTSCert(tsCert);
}

- (void)setProxyHost:(NSString *)proxyHost {
    if (!proxyHost) return;
    _impl->setProxyHost(proxyHost);
}

- (void)setProxyPort:(NSString *)proxyPort {
    if (!proxyPort) return;
    _impl->setProxyPort(proxyPort);
}

- (void)setProxyUser:(NSString *)proxyUser {
    if (!proxyUser) return;
    _impl->setProxyUser(proxyUser);
}

- (void)setProxyPass:(NSString *)proxyPass {
    if (!proxyPass) return;
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
