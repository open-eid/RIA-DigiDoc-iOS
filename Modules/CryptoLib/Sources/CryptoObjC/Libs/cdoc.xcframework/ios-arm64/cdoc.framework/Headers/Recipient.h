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

#ifndef __RECIPIENT_H__
#define __RECIPIENT_H__

#include <cdoc/Exports.h>

#include <map>
#include <string>
#include <vector>
#include <cstdint>

namespace libcdoc {

/**
 * @brief A descriptor of encryption method and key to be used in container
 *
 * Recipient determines all the relevant properties to encrypt the FMK for a certain target.
 */
struct CDOC_EXPORT Recipient {
    /**
     * @brief The recipient type
     */
	enum Type : unsigned char {
        /**
         * Uninitialized recipient
         */
		NONE,
        /**
         * @brief Symmetric key (or password)
         */
		SYMMETRIC_KEY,
        /**
         * @brief Public key
         */
        PUBLIC_KEY,
        /**
         * @brief Full certificate
         */
        CERTIFICATE,
        /**
         * @brief public key on keyserver
         */
        SERVER,
        /**
         * @brief n of n shared symmetric key
         */
        KEYSHARE
	};

    /**
     * @brief The public key type
     */
    enum PKType : unsigned char {
        /**
         * Elliptic curve
         */
		ECC,
        /**
         * RSA
         */
		RSA
	};

    /**
     * @brief The EID type
     */
    enum EIDType {
        Unknown,
        IDCard,
        DigiID,
        DigiID_EResident
    };

	Recipient() = default;

    /**
     * @brief The recipient type
     */
	Type type = Type::NONE;
    /**
     * @brief The public key type
     */
	PKType pk_type = PKType::ECC;
    /**
     * @brief The number of iterations for PBKDF. Value 0 means directly provided symmetric key.
     */
	int32_t kdf_iter = 0;
    /**
     * @brief The recipient's label
     */
	std::string label;
    /**
     * @brief Recipient's public key (for all PKI types)
     */
    std::vector<uint8_t> rcpt_key;
    /**
     * @brief The recipient's certificate (if present)
     */
    std::vector<uint8_t> cert;
    /**
     * @brief The recipient id for share server (PNOEE-XXXXXXXXXXX)
     */
    std::string id;
    /**
     * @brief The keyserver or share server list id (if present)
     */
    std::string server_id;

    /**
     * @brief test whether the Recipient structure is initialized
     * @return true if not initialized
     */
	bool isEmpty() const { return type == Type::NONE; }
    /**
     * @brief check whether Recipient is based on symmetric key
     * @return true if type is SYMMETRIC_KEY
     */
    bool isSymmetric() const { return type == Type::SYMMETRIC_KEY; }
    /**
     * @brief check whether Recipient is based on public key
     * @return true if type is CERTIFICATE, PUBLIC_KEY or SERVER
     */
    bool isPKI() const { return (type == Type::CERTIFICATE) || (type == Type::PUBLIC_KEY) || (type == Type::SERVER); }
    /**
     * @brief check whether Recipient is based on certificate
     * @return true if type is CERTIFICATE
     */
    bool isCertificate() const { return (type == Type::CERTIFICATE); }
    /**
     * @brief check whether Recipient is keyserver
     * @return true if type is SERVER
     */
    bool isKeyServer() const { return (type == Type::SERVER); }
    /**
     * @brief check whether Recipient is keyshare
     * @return true if type is KEYSHARE
     */
    bool isKeyShare() const { return type == Type::KEYSHARE; }

    /**
     * @brief Clear all values and set type to NONE
     */
    void clear() { type = Type::NONE; pk_type = PKType::ECC; label.clear(); kdf_iter = 0; rcpt_key.clear(); cert.clear(); }

    /**
     * @brief A convenience method to check whether two recipients are both public key based and have the same keys.
     * @param other another Recipient
     * @return true if the public keys are identical
     */
	bool isTheSameRecipient(const Recipient &other) const;
    /**
     * @brief A convenience method to check whether a recipient is public key based and has the given keys.
     * @param public_key a public key to test
     * @return true if the public keys are identical
     */
    bool isTheSameRecipient(const std::vector<uint8_t>& public_key) const;

    /**
     * @brief Create a new symmetric key based Recipient
     * @param label the label text
     * @param kdf_iter the number of PBKDF iterations (0 if full key is provided)
     * @return a new Recipient structure
     */
	static Recipient makeSymmetric(const std::string& label, int32_t kdf_iter);
    /**
     * @brief Create a new public key based Recipient
     * @param label the label text
     * @param public_key the public key value
     * @param pk_type the algorithm type (either ECC or RSA)
     * @return a new Recipient structure
     */
    static Recipient makePublicKey(const std::string& label, const std::vector<uint8_t>& public_key, PKType pk_type);
    /**
     * @brief Create a new certificate based Recipient
     * @param label the label text
     * @param cert the certificate value (der-encoded)
     * @return a new Recipient structure
     */
    static Recipient makeCertificate(std::string label, std::vector<uint8_t> cert);
    /**
     * @brief Create a new certificate based Recipient filling label from certificate
     * @see makeCertificate, BuildLabelEID
     * @param cert the certificate value (der-encoded)
     * @return a new Recipient structure
     */
    static Recipient makeEID(std::vector<uint8_t> cert);
    /**
     * @brief Create new server based Recipient
     * @param label the label text
     * @param public_key the public key value
     * @param pk_type the algorithm type (either ECC or RSA)
     * @param server_id the keyserver id
     * @return a new Recipient structure
     */
    static Recipient makeServer(std::string label, std::vector<uint8_t> public_key, PKType pk_type, std::string server_id);
    /**
     * @brief Create new server based Recipient filling label from certificate
     * @see makeServer, BuildLabelEID
     * @param cert the certificate value (der-encoded)
     * @param server_id the keyserver id
     * @return a new Recipient structure
     */
    static Recipient makeEIDServer(std::vector<uint8_t> cert, std::string server_id);
    /**
     * @brief Create new keyshare recipient
     * 
     * @param label the label text
     * @param server_id the id of share server group
     * @param recipient_id the recipient id (PNOEE-01234567890)
     * @return Recipient a new Recipient structure
     */
    static Recipient makeShare(const std::string& label, const std::string& server_id, const std::string& recipient_id);

    /**
     * @brief build machine-readable CDoc2 label
     * @param components a list of string pairs
     * @return a composed label
     */
    static std::string buildLabel(std::vector<std::pair<std::string_view, std::string_view>> components);
    /**
     * @brief build machine-readable CDoc2 label for EID recipient
     * @param version the label version
     * @param type EID type
     * @param cn the common name
     * @param serial_number the serial number
     * @param last_name the last name
     * @param first_name the first name
     * @return a composed label
     */
    static std::string BuildLabelEID(int version, EIDType type, std::string_view cn, std::string_view serial_number, std::string_view last_name, std::string_view first_name);
    /**
     * @brief build machine-readable CDoc2 label for EID recipient filling info from certificate
     * @see BuildLabelEID
     * @param cert the certificate value (der-encoded)
     * @return a composed label
     */
    static std::string BuildLabelEID(const std::vector<uint8_t> &cert);
    /**
     * @brief build machine-readable CDoc2 label for certificate-based recipient
     * @param version the label version
     * @param file the name of certificate file
     * @param cn the common name
     * @param cert_sha1 the certificate SHA1 hash
     * @return a composed label
     */
    static std::string BuildLabelCertificate(int version, std::string_view file, std::string_view cn, const std::vector<uint8_t>& cert_sha1);
    /**
     * @brief build machine-readable CDoc2 label for certificate-based recipient filling info from certificate
     * @see BuildLabelCertificate
     * @param file the name of certificate file
     * @param cert the certificate value (der-encoded)
     * @return a composed label
     */
    static std::string BuildLabelCertificate(std::string_view file, const std::vector<uint8_t> &cert);
    /**
     * @brief build machine-readable CDoc2 label for public key based recipient
     * @param version the label version
     * @param file the name of public key file
     * @return a composed label
     */
    static std::string BuildLabelPublicKey(int version, const std::string file);
    /**
     * @brief build machine-readable CDoc2 label for symmetric key based recipient
     * @param version the label version
     * @param label the key label
     * @param file the name of key file
     * @return a composed label
     */
    static std::string BuildLabelSymmetricKey(int version, const std::string& label, const std::string file);
    /**
     * @brief build machine-readable CDoc2 label for password key based recipient
     * @param version the label version
     * @param label the password label
     * @return a composed label
     */
    static std::string BuildLabelPassword(int version, const std::string& label);

    /**
     * @brief get EID type from policies list
     * @param policies the list of policies
     * @return EID type
     */
    static EIDType getEIDType(const std::vector<std::string>& policies);

    /**
     * @brief parse machine-readable CDoc2 label
     * @param label the label
     * @return a map of key-value pairs
     */
    static std::map<std::string, std::string> parseLabel(const std::string& label);

    bool operator== (const Recipient& other) const = default;
protected:
	Recipient(Type _type) : type(_type) {};
private:
};

} // namespace libcdoc

#endif // RECIPIENT_H
