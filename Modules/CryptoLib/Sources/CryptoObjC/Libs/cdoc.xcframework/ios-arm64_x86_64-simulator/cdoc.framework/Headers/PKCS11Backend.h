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

#ifndef __PKCS11_BACKEND_H__
#define __PKCS11_BACKEND_H__

#include <cdoc/CryptoBackend.h>

#include <memory>

namespace libcdoc {

/**
 * @brief A convenience class for PKCS11 based cryptographic operations
 *
 * It has default implementations of all CryptoBackend methods. Instead the user has to implement
 * connectToKey method. The latter should find the correct private or secret key for the lock and
 * then call either usePrivateKey or useSecretKey to load the key.
 */
struct CDOC_EXPORT PKCS11Backend : public CryptoBackend {
	struct Handle {
		uint32_t slot = 0;
		std::vector<uint8_t> id;
	};

    /**
     * @brief Construct a new PKCS11Backend object
     * 
     * @param path a path to PKCS11 library to use (usually .so or .dll depending on operating system)
     */
	PKCS11Backend(const std::string &path);
	~PKCS11Backend();

    /**
     * @brief find all certificates with given label
     *
     * A convenience method to fetch all certificates in all slots with given label. If the label is empty, returns all certificates.
     * @param label a certificate label or empty string
     * @return a vector of handles
     */
    std::vector<Handle> findCertificates(const std::string& label);

    /**
     * @brief find all certificates for given public key
     *
     * A convenience method to fetch all certificates in all slots with given public key.
     * @param public_key public key (short form)
     * @return a list of handles
     */
    std::vector<Handle> findCertificates(const std::vector<uint8_t>& public_key);

    /**
     * @brief find all secret keys with given label
     *
     * A convenience method to fetch all secret keys in all slots with given label. If the label is empty, returns all secret keys.
     * @param label a certificate label or empty string
     * @return a vector of handles
     */
    std::vector<Handle> findSecretKeys(const std::string& label);

    /**
     * @brief load secret key
     *
     * Opens slot, logs in with pin and finds the correct secret key.
     * Both key id and label have to match unless either one is empty.
     * If the key is found, it is loaded internally for subsequent cryptographic operations.
     * @param slot a PKCS11 slot to use
     * @param pin a user pin
     * @param id the key id or empty vector
     * @param label the key label or empty string
     * @return error code or OK
     */
    result_t useSecretKey(int slot, const std::vector<uint8_t>& pin, const std::vector<uint8_t>& id, const std::string& label);
    /**
     * @brief loads private key
     *
     * Opens slot, logs in with pin and finds the correct private key.
     * Both key id and label have to match unless either one is empty.
     * If the key is found, it is loaded internally for subsequent cryptographic operations.
     * @param slot a PKCS11 slot to use
     * @param pin a user pin
     * @param id the key id
     * @param label the key label
     * @return error code or OK
     */
    result_t usePrivateKey(int slot, const std::vector<uint8_t>& pin, const std::vector<uint8_t>& id, const std::string& label);

    /**
     * @brief get certificate value
     *
     * Get a certificate value given slot, label and id.
     * Both key id and label have to match unless either one is empty.
     * @param val a destination container for value
     * @param rsa will be set true is certificate uses RSA key
     * @param slot the slot to use
     * @param pin the pin code
     * @param id certificate id or empty vector
     * @param label certificate label or empty vector
     * @return error code or OK
     */
    result_t getCertificate(std::vector<uint8_t>& val, bool& rsa, int slot, const std::vector<uint8_t>& pin, const std::vector<uint8_t>& id, const std::string& label);
    /**
     * @brief get public key value
     *
     * Get a public key value given slot, label and id.
     * Both key id and label have to match unless either one is empty.
     * @param val a destination container for value
     * @param rsa will be set true is public key uses RSA key
     * @param slot the slot to use
     * @param pin the pin code
     * @param id public key id or empty vector
     * @param label public key label or empty vector
     * @return error code or OK
     */
    result_t getPublicKey(std::vector<uint8_t>& val, bool& rsa, int slot, const std::vector<uint8_t>& pin, const std::vector<uint8_t>& id, const std::string& label);

    /**
     * @brief loads key for encryption/decryption
     *
     * A method to load the correct private/secret key for given capsule or receiver. The subclass implementation should
     * call either useSecretKey or usePrivateKey with proper pin, PKCS11 label and/or id to actually load the key for subsequent
     * cryptographic operation.
     * @param idx lock or recipient index (0-based) in CDoc container
     * @param priv whether to connect to private or secret key
     * @return error code or OK
     */
    virtual result_t connectToKey(int idx, bool priv) { return NOT_IMPLEMENTED; };
    /**
     * @brief whether to use PSS RSA padding
     *
     * A subclass should overwrite this to inform the backend about the correct padding.
     * @param idx a lock idx
     * @return true if PSS padding is sued
     */
    virtual result_t usePSS(int idx) {return true;}

    virtual result_t deriveECDH1(std::vector<uint8_t>& dst, const std::vector<uint8_t> &public_key, unsigned int idx) override;
    virtual result_t decryptRSA(std::vector<uint8_t>& dst, const std::vector<uint8_t> &data, bool oaep, unsigned int idxl) override;
    virtual result_t extractHKDF(std::vector<uint8_t>& kek, const std::vector<uint8_t>& salt, const std::vector<uint8_t>& pw_salt, int32_t kdf_iter, unsigned int idx) override;
    virtual result_t sign(std::vector<uint8_t>& dst, HashAlgorithm algorithm, const std::vector<uint8_t> &digest, unsigned int idx) override;
private:
	struct Private;
	std::unique_ptr<Private> d;
};

} // namespace libcdoc

#endif // PKCS11BACKEND_H
