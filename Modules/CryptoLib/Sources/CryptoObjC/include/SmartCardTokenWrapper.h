#if __cplusplus

#import <cdoc/CryptoBackend.h>
#import <Foundation/Foundation.h>
#include <memory>
#import "AbstractSmartTokenObjC.h"

@protocol AbstractSmartToken;

class SmartCardTokenWrapper: public libcdoc::CryptoBackend
{
public:
    SmartCardTokenWrapper(id<AbstractSmartTokenObjC> smartToken);
    ~SmartCardTokenWrapper() noexcept;

    libcdoc::result_t deriveECDH1(std::vector<uint8_t> &dst, const std::vector<uint8_t> &public_key, unsigned int idx) final;
    libcdoc::result_t decryptRSA(std::vector<uint8_t> &dst, const std::vector<uint8_t> &data, bool oaep, unsigned int idx) final;
    libcdoc::result_t sign(std::vector<uint8_t> &dst, HashAlgorithm algorithm, const std::vector<uint8_t> &digest, unsigned int idx) final;
    NSError* lastError() const;

private:
    struct Private;
    std::unique_ptr<Private> token;
};

#endif
