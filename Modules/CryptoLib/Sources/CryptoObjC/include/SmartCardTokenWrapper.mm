// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

@import CryptoObjCWrapper;
#import "SmartCardTokenWrapper.h"
#import "Extensions.h"

struct SmartCardTokenWrapper::Private {
    id<AbstractSmartToken> smartTokenClass;
    NSError *error;
};

SmartCardTokenWrapper::SmartCardTokenWrapper(id<AbstractSmartToken> smartToken)
    : token(std::make_unique<Private>())
{
    *token = {smartToken, nullptr};
}

SmartCardTokenWrapper::~SmartCardTokenWrapper() noexcept = default;

NSError* SmartCardTokenWrapper::lastError() const
{
    return token->error;
}

libcdoc::result_t SmartCardTokenWrapper::deriveECDH1(
    std::vector<uint8_t>& dst,
    const std::vector<uint8_t>& public_key,
    unsigned int idx)
{
    __block NSData  *resultData = nil;
    __block NSError *blockError = nil;
    __block BOOL finished = NO;

    NSData *pub = [NSData dataFromVectorNoCopy:public_key];

    [token->smartTokenClass derive:pub
                 completionHandler:^(NSData * _Nullable data,
                                     NSError * _Nullable error)
    {
        resultData = data;
        blockError = error;
        finished = YES;
    }];

    // Pump the run loop until completion fires
    // FIXME: Review and fix NFC lib, to use normal completion sync like semaphore.
    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }

    if (resultData) {
        dst = [resultData toVector];
    } else {
        dst.clear();
    }

    token->error = blockError;
    return dst.empty() ? libcdoc::CRYPTO_ERROR : libcdoc::OK;
}

libcdoc::result_t SmartCardTokenWrapper::decryptRSA(std::vector<uint8_t>& dst, const std::vector<uint8_t>& data, bool oaep, unsigned int idx)
{
    __block NSData  *resultData = nil;
    __block NSError *blockError = nil;
    __block BOOL finished = NO;

    NSData *pub = [NSData dataFromVectorNoCopy:data];

    [token->smartTokenClass decrypt:pub
                 completionHandler:^(NSData * _Nullable data,
                                     NSError * _Nullable error)
    {
        resultData = data;
        blockError = error;
        finished = YES;
    }];

    // Pump the run loop until completion fires
    // FIXME: Review and fix NFC lib, to use normal completion sync like semaphore.
    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }

    if (resultData) {
        dst = [resultData toVector];
    } else {
        dst.clear();
    }

    token->error = blockError;
    return dst.empty() ? libcdoc::CRYPTO_ERROR : libcdoc::OK;
}

libcdoc::result_t SmartCardTokenWrapper::sign(std::vector<uint8_t> &dst, HashAlgorithm algorithm, const std::vector<uint8_t> &digest, unsigned int idx)
{
    __block NSData  *resultData = nil;
    __block NSError *blockError = nil;
    __block BOOL finished = NO;

    NSData *pub = [NSData dataFromVectorNoCopy:digest];

    [token->smartTokenClass authenticate:pub
                 completionHandler:^(NSData * _Nullable data,
                                     NSError * _Nullable error)
    {
        resultData = data;
        blockError = error;
        finished = YES;
    }];

    // Pump the run loop until completion fires
    // FIXME: Review and fix NFC lib, to use normal completion sync like semaphore.
    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }

    if (resultData) {
        dst = [resultData toVector];
    } else {
        dst.clear();
    }

    token->error = blockError;
    return dst.empty() ? libcdoc::CRYPTO_ERROR : libcdoc::OK;
}
