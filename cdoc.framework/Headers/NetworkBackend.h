/*
 * libcdoc
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
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef __NETWORKBACKEND_H__
#define __NETWORKBACKEND_H__

#include <cdoc/CryptoBackend.h>

namespace libcdoc {

struct CDOC_EXPORT NetworkBackend {
    /**
     * @brief Generic network error
     * 
     */
	static constexpr int NETWORK_ERROR = -300;
    // MID/SID error codes
    // User refused the session
    static constexpr int MIDSID_USER_REFUSED = -350;
    // There was a timeout, i.e. end user did not confirm or refuse the operation within given timeframe
    static constexpr int MIDSID_TIMEOUT = -351;
    // For some reason, this RP request cannot be completed. User must either check his/her Smart-ID mobile application or turn to customer support for getting the exact reason
    static constexpr int MIDSID_DOCUMENT_UNUSABLE = -352;
    // In case the multiple-choice verification code was requested, the user did not choose the correct verification code
    static constexpr int MIDSID_WRONG_VC = -353;
    // User app version does not support any of the allowedInteractionsOrder interactions
    static constexpr int MIDSID_REQUIRED_INTERACTION_NOT_SUPPORTED_BY_APP = -354;
    // User has multiple accounts and pressed Cancel on device choice screen on any device
    static constexpr int MIDSID_USER_REFUSED_CERT_CHOICE = -355;
    // User pressed Cancel on PIN screen. Can be from the most common displayTextAndPIN flow or from verificationCodeChoice flow when user chosen the right code and then pressed cancel on PIN screen
    static constexpr int MIDSID_USER_REFUSED_DISPLAYTEXTANDPIN = -356;
    // User cancelled verificationCodeChoice screen
    static constexpr int MIDSID_USER_REFUSED_VC_CHOICE = -357;
    // User cancelled on confirmationMessage screen
    static constexpr int MIDSID_USER_REFUSED_CONFIRMATIONMESSAGE = -358;
    // User cancelled on confirmationMessageAndVerificationCodeChoice screen
    static constexpr int MIDSID_USER_REFUSED_CONFIRMATIONMESSAGE_WITH_VC_CHOICE = -359;
    // Given user has no active certificates and is not MID client.
    static constexpr int MIDSID_NOT_MID_CLIENT = -360;
    // User cancelled the operation
    static constexpr int MIDSID_USER_CANCELLED = -361;
    // Mobile-ID configuration on user's SIM card differs from what is configured on service provider's side. User needs to contact his/her mobile operator.
    static constexpr int MIDSID_SIGNATURE_HASH_MISMATCH = -362;
    // Sim not available
    static constexpr int MIDSID_PHONE_ABSENT = -363;
    // SMS sending error
    static constexpr int MIDSID_DELIVERY_ERROR = -364;
    // Invalid response from card
    static constexpr int MIDSID_SIM_ERROR = -365;

    /**
     * @brief Share information returned by server
     * 
     */
    struct CapsuleInfo {
        /**
         * @brief Transaction id needed to retrieve the key later
         * 
         */
        std::string transaction_id;
        /**
         * @brief Capsule exipry time on server
         * 
         */
        uint64_t expiry_time;
    };
    /**
     * @brief Share information returned by server
     * 
     */
    struct ShareInfo {
        /**
         * @brief Share value
         * 
         */
        std::vector<uint8_t> share;
        /**
         * @brief Recipoient id (etsi/PNOEE-01234567890)
         * 
         */
        std::string recipient;
    };

    /**
     * @brief Proxy credentials used for network access
     * 
     */
    struct ProxyCredentials {
        /**
         * @brief Proxy host
         */
        std::string host;
        /**
         * @brief Proxy port
         */
        uint16_t port;
        /**
         * @brief Proxy username
         */
        std::string username;
        /**
         * @brief Proxy password
         */
        std::string password;
    };

    NetworkBackend() = default;
	virtual ~NetworkBackend() noexcept = default;
    NetworkBackend(const NetworkBackend&) = delete;
    NetworkBackend& operator=(const NetworkBackend&) = delete;
    CDOC_DISABLE_MOVE(NetworkBackend);
    /**
     * @brief Get the textual description of the last error
     * 
     * The result is undefined if the error code does not match the most recent error
     * @param code The error code
     * @return std::string error description
     */
	virtual std::string getLastErrorStr(result_t code) const;

	/**
	 * @brief send key material to keyserver
     *
     * The default implementation uses internal http client and peer TLS certificate list.
     * @param dst the transaction id and expiry date of the capsule on server
     * @param url server url
     * @param rcpt_key recipient's public key
     * @param key_material encrypted KEK or ECDH public Key used to derive shared secret
	 * @param type algorithm type, currently either "rsa" or "ecc_secp384r1"
	 * @return error code or OK
	 */
    virtual result_t sendKey (CapsuleInfo& dst, const std::string& url, const std::vector<uint8_t>& rcpt_key, const std::vector<uint8_t> &key_material, const std::string& type);
    /**
     * @brief send key share to server
     *
     * The recipient has to be in form "etsi/PNOEE-XXXXXXXXXXXX" and must match certificate subject serial number field (without "etsi/" prefix).
     * @param dst a container for share id
     * @param url server url
     * @param recipient the recipient id (ETSI319412-1)
     * @param share base64 encoded Key Share
     * @return error code or OK
     */
    virtual result_t sendShare(std::vector<uint8_t>& dst, const std::string& url, const std::string& recipient, const std::vector<uint8_t>& share);
	/**
	 * @brief fetch key material from keyserver
     *
     * The default implementation uses internal http client, peer TLS list and client TLS certificate
     * @param dst a destination container for key material
     * @param url server url
     * @param transaction_id transaction id of capsule
	 * @return error code or OK
	 */
    virtual result_t fetchKey (std::vector<uint8_t>& dst, const std::string& url, const std::string& transaction_id);
    /**
     * @brief fetch authentication nonce from share server
     * @param dst a destination container for nonce
     * @param url server url
     * @param share_id share id (transaction id)
     * @return error code or OK
     */
    virtual result_t fetchNonce(std::vector<uint8_t>& dst, const std::string& url, const std::string& share_id);
    /**
     * @brief fetch key share from share server
     * @param share a container for result
     * @param url server url
     * @param share_id share id (transaction id)
     * @param ticket signed ticket with disclosed url
     * @param cert a certificate of signing key (PEM without newlines)
     * @return error code or OK
     */
    virtual result_t fetchShare(ShareInfo& share, const std::string& url, const std::string& share_id, const std::string& ticket, const std::vector<uint8_t>& cert);


    /**
     * @brief get client TLS certificate in der format
     * @param dst a destination container for certificate
     * @return error code or OK
     */
    virtual result_t getClientTLSCertificate(std::vector<uint8_t>& dst) {
        return NOT_IMPLEMENTED;
    }

    /**
     * @brief get a list of peer TLS certificates in der format
     * @param dst a destination container for certificate
     * @return error code or OK
     */
    virtual result_t getPeerTLSCertificates(std::vector<std::vector<uint8_t>> &dst) {
        return NOT_IMPLEMENTED;
    }

    /**
     * @brief get a list of peer TLS certificates in der format
     * @param dst a destination container for certificate
     * @param url the base url ("https://servername:port/")
     * @return error code or OK
     */
    virtual result_t getPeerTLSCertificates(std::vector<std::vector<uint8_t>> &dst, const std::string& url) {
        return getPeerTLSCertificates(dst);
    }

    /**
     * @brief Get proxy configuration currently set
     * @param credentials output for proxy credentials
     */
    virtual result_t getProxyCredentials(ProxyCredentials& credentials) const {
        return NOT_IMPLEMENTED;
    }

    /**
     * @brief sign TLS digest with client's private key
     * @param dst a destination container for signature
     * @param algorithm signing algorithm
     * @param digest data to be signed
     * @return error code or OK
     */
    virtual result_t signTLS(std::vector<uint8_t>& dst, CryptoBackend::HashAlgorithm algorithm, const std::vector<uint8_t> &digest) {
        return NOT_IMPLEMENTED;
    }

    /**
     * @brief show MID/SID verification code
     * 
     * Show SID/MID verification code. The default implementation logs it with level INFO.
     * @param code verification code
     * @return error code or OK
     */
    virtual result_t showVerificationCode(unsigned int code);

    /**
     * @brief Sign digest with SmartID authentication key
     * 
     * @param dst a container for signature
     * @param cert a container for certificate
     * @param url SmartID gateway base URL
     * @param rp_uuid relying party UUID
     * @param rp_name relying party name
     * @param rcpt_id recipient id (etsi/PNOEE-XYZXYZXYZXY)
     * @param digest digest to sign
     * @param algo algorithm type (SHA256, SHA385, SHA512)
     * @return error code or OK
     */
    result_t signSID(std::vector<uint8_t>& dst, std::vector<uint8_t>& cert,
        const std::string& url, const std::string& rp_uuid, const std::string& rp_name,
        const std::string& rcpt_id, const std::vector<uint8_t>& digest, CryptoBackend::HashAlgorithm algo);

    /**
     * @brief Sign digest with Mobile ID authentication key
     * 
     * @param dst a container for signature
     * @param cert a container for certificate
     * @param url Mobile ID gateway base URL
     * @param rp_uuid relying party UUID
     * @param rp_name relying party name
     * @param phone recipient's phone number
     * @param rcpt_id recipient id (etsi/PNOEE-XYZXYZXYZXY)
     * @param digest digest to sign
     * @param algo algorithm type (SHA256, SHA385, SHA512)
     * @return error code or OK
     */
    result_t signMID(std::vector<uint8_t>& dst, std::vector<uint8_t>& cert,
        const std::string& url, const std::string& rp_uuid, const std::string& rp_name, const std::string& phone,
        const std::string& rcpt_id, const std::vector<uint8_t>& digest, CryptoBackend::HashAlgorithm algo);

#if LIBCDOC_TESTING
    virtual int64_t test(std::vector<std::vector<uint8_t>> &dst);
#endif
};

} // namespace libcdoc

#endif // NETWORKBACKEND_H
