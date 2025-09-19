#import "SmartCardTokenWrapper.h"
#import "Extensions.h"
#import "AbstractSmartTokenObjC.h"

struct SmartCardTokenWrapper::Private {
    id<AbstractSmartTokenObjC> smartTokenClass;
    NSError *error;
};


SmartCardTokenWrapper::SmartCardTokenWrapper(id<AbstractSmartTokenObjC> smartToken)
    : token(std::make_unique<Private>())
{
    *token = {smartToken, nullptr};
}

SmartCardTokenWrapper::~SmartCardTokenWrapper() noexcept = default;

NSError* SmartCardTokenWrapper::lastError() const
{
    return token->error;
}

libcdoc::result_t SmartCardTokenWrapper::deriveECDH1(std::vector<uint8_t>& dst, const std::vector<uint8_t> &public_key, unsigned int idx)
{
    NSError *error = nil;
    dst = [[token->smartTokenClass derive:[NSData dataFromVectorNoCopy:public_key] error:&error] toVector];
    token->error = error;
    return dst.empty() ? libcdoc::CRYPTO_ERROR : libcdoc::OK;
}

libcdoc::result_t SmartCardTokenWrapper::decryptRSA(std::vector<uint8_t>& dst, const std::vector<uint8_t>& data, bool oaep, unsigned int idx)
{
    NSError *error = nil;
    dst = [[token->smartTokenClass decrypt:[NSData dataFromVectorNoCopy:data] error:&error] toVector];
    token->error = error;
    return dst.empty() ? libcdoc::CRYPTO_ERROR : libcdoc::OK;
}

libcdoc::result_t SmartCardTokenWrapper::sign(std::vector<uint8_t> &dst, HashAlgorithm algorithm, const std::vector<uint8_t> &digest, unsigned int idx)
{
    NSError *error = nil;
    dst = [[token->smartTokenClass authenticate:[NSData dataFromVectorNoCopy:digest] error:&error] toVector];
    token->error = error;
    return dst.empty() ? libcdoc::CRYPTO_ERROR : libcdoc::OK;
}
