//
//  Config.h
//  CryptoLib
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

@import CryptoObjCWrapper;
#import <Foundation/Foundation.h>
#include <cdoc/Configuration.h>
#include <cdoc/NetworkBackend.h>

struct Settings : public libcdoc::Configuration {
private:
    inline static NSDictionary<NSString *, id> * _Nullable _cdoc2Config = nil;
    inline static NSString * _Nullable _fetchURL = nil;
    inline static NSString * _Nullable _postURL = nil;
    inline static NSString * _Nullable _uuid = nil;
    inline static bool _isOnlineEncryptionEnabled = false;

public:
    static void setCdoc2Config(NSDictionary<NSString *, id> * _Nonnull config) {
        _cdoc2Config = config;
    }
    
    static void setFetchURL(NSString * _Nonnull url) {
        _fetchURL = url;
    }
    
    static void setPostURL(NSString * _Nonnull url) {
        _postURL = url;
    }
    
    static void setUUID(NSString * _Nonnull uuid) {
        _uuid = uuid;
    }

    static NSString * _Nullable getUUID() {
        return _uuid;
    }
    
    static void setIsOnlineEncryptionEnabled(bool isOnlineEncryptionEnabled) {
        _isOnlineEncryptionEnabled = isOnlineEncryptionEnabled;
    }

    static bool isOnlineEncryptionEnabled() {
        return _isOnlineEncryptionEnabled;
    }
    
    std::string getValue(std::string_view domain,
                         std::string_view param) const final {

        NSString *nsDomain =
            [[NSString alloc] initWithBytes:domain.data()
                                      length:domain.size()
                                    encoding:NSUTF8StringEncoding];

        if (param == KEYSERVER_FETCH_URL) {

            NSDictionary *uuidDict = _cdoc2Config[nsDomain];

            if (![uuidDict isKindOfClass:[NSDictionary class]]) {
                return std::string([_fetchURL UTF8String]);
            }

            NSString *fetch = uuidDict[@"FETCH"];
            if (![fetch isKindOfClass:[NSString class]]) {
                return std::string([_fetchURL UTF8String]);
            }

            return std::string([fetch UTF8String]);
        }

        if (param == KEYSERVER_SEND_URL) {

            NSDictionary *uuidDict = _cdoc2Config[nsDomain];

            if (![uuidDict isKindOfClass:[NSDictionary class]]) {
                return std::string([_postURL UTF8String]);
            }

            NSString *post = uuidDict[@"POST"];
            if (![post isKindOfClass:[NSString class]]) {
                return std::string([_postURL UTF8String]);
            }

            return std::string([post UTF8String]);
        }

        return {};
    }
};

struct Network: public libcdoc::NetworkBackend {
private:
    inline static NSArray<NSData *> * _Nullable _certs = nil;
    inline static NSData * _Nullable _cert = nil;
    inline static NSString * _Nonnull _host = @"";
    inline static NSInteger _port = 80;
    inline static NSString * _Nonnull _username = @"";
    inline static NSString * _Nonnull _password = @"";

public:
    static void setCert(NSData * _Nullable cert) {
        _cert = cert;
    }
    
    static void setCerts(NSArray<NSData *> * _Nullable certs) {
        _certs = certs;
    }
    
    static void setProxy(NSString * _Nonnull host,
                         NSInteger port,
                         NSString * _Nonnull username,
                         NSString * _Nonnull password) {
        _host = host;
        _port = port;
        _username = username;
        _password = password;
    }

    libcdoc::result_t getPeerTLSCertificates(std::vector<std::vector<uint8_t>> &dst, const std::string& url) final {
        libcdoc::NetworkBackend::getPeerTLSCertificates(dst);
        for (NSData *cert in _certs) {
            dst.push_back([cert toVector]);
        }
        if (auto cert = [_cert toVector]; !cert.empty()) {
            dst.push_back(std::move(cert));
        }
        return libcdoc::OK;
    }

    libcdoc::result_t getProxyCredentials(ProxyCredentials &cred) const final {
        if (_host.length > 0) {
            cred = {
                .host = std::string([_host UTF8String]),
                .port = (uint16_t)_port,
                .username = std::string([_username UTF8String]),
                .password = std::string([_password UTF8String])
            };
        }
        return libcdoc::OK;
    }
};
