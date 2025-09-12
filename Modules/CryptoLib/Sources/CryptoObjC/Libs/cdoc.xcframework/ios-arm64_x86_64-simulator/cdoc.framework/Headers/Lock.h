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

#ifndef __LOCK_H__
#define __LOCK_H__

#include <cdoc/Exports.h>

#include <cstdint>
#include <string>
#include <vector>
#include <map>

namespace libcdoc {

/**
 * @brief A descriptor of decryption scheme in container
 *
 * A Lock represents an encryption scheme with certain key and mechanism in encrypted container. A single container
 * may contain many locks (for example one lock for one intended recipient).
 *
 * To decrypt the container, the FMK (File Master Key) has to be obtained from a lock. Lock type determines, which
 * exact procedures and cryptographic keys are needed for that.
 */
struct CDOC_EXPORT Lock
{
    /**
     * @brief The lock type
     */
	enum Type : unsigned char {
        /**
         * @brief Invalid value
         */
		INVALID,
        /**
         * @brief Symmetric AES key
         */
		SYMMETRIC_KEY,
        /**
         * @brief PBKDF key (derived from password)
         */
        PASSWORD,
        /**
         * @brief Public key (ECC or RSA)
         */
        PUBLIC_KEY,
        /**
         * @brief CDoc1 lock
         */
        CDOC1,
        /**
         * @brief Public key stored on keyserver
         */
        SERVER,
        /**
         * @brief Symmetric key distributed on several servers
         */
        SHARE_SERVER
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
     * @brief Extra parameters depending on key type
     */
	enum Params : unsigned int {
        /**
         * @brief HKDF salt (SYMMETRIC_KEY, PASSWORD and SHARE_SERVER)
         */
        SALT,
        /**
         * @brief PBKDF salt (PASSWORD)
         */
        PW_SALT,
        /**
         * @brief PBKDF iteration count (PASSWORD)
         */
        KDF_ITER,
        /**
         * @brief Recipient's public key (PUBLIC_KEY, CDOC1, SERVER)
         */
        RCPT_KEY,
        /**
         * @brief Recipient's certificate (CDOC1)
         */
        CERT,
        /**
         * @brief ECC ephemereal key or RSA encrypted KEK
         */
        KEY_MATERIAL,
        /**
         * @brief Keyserver Id
         */
        KEYSERVER_ID,
        /**
         * @brief Keyserver transaction Id
         */
        TRANSACTION_ID,
        /**
         * @brief Keyshare recipient ID
         */
        RECIPIENT_ID,
        /**
         * @brief Keyshare server urls (separated by ';')
         */
        SHARE_URLS,
        /**
         * @brief CDoc1 specific
         */
        CONCAT_DIGEST,
        /**
         * @brief CDoc1 specific
         */
        METHOD,
        /**
         * @brief CDoc1 specific
         */
        ALGORITHM_ID,
        /**
         * @brief CDoc1 specific
         */
        PARTY_UINFO,
        /**
         * @brief CDoc1 specific
         */
        PARTY_VINFO
	};

    /**
     * @brief get lock parameter value
     * @param param a parameter type
     * @return the parameter value
     */
    const std::vector<uint8_t>& getBytes(Params param) const { return params.at(param); };
    /**
     * @brief get lock parameter as string
     * @param key a parameter type
     * @return the parameter value
     */
    std::string getString(Params key) const;
    /**
     * @brief get lock parameter as integer
     * @param key a parameter type
     * @return the parameter value
     */
    int32_t getInt(Params key) const;

    /**
     * @brief The lock type
     */
	Type type = Type::INVALID;
    /**
     * @brief algorithm type for public key based locks
     */
	PKType pk_type = PKType::ECC;

    /**
     * @brief the lock label
     */
	std::string label;
    /**
     * @brief encrypted FMK (File Master Key)
     */
	std::vector<uint8_t> encrypted_fmk;

    /**
     * @brief check whether lock is valid
     * @return true if valid
     */
    bool isValid() const noexcept { return (type != Type::INVALID) && !label.empty() && !encrypted_fmk.empty(); }
    /**
     * @brief check whether lock is based on symmetric key
     * @return true if type is SYMMETRIC_KEY or PASSWORD
     */
    constexpr bool isSymmetric() const noexcept { return (type == Type::SYMMETRIC_KEY) || (type == Type::PASSWORD); }
    /**
     * @brief check whether lock is based on public key
     * @return true if type is CDOC1, PUBLIC_KEY or SERVER
     */
    constexpr bool isPKI() const noexcept { return (type == Type::CDOC1) || (type == Type::PUBLIC_KEY) || (type == Type::SERVER); }
    /**
     * @brief check whether lock is based on certificate
     * @return true if type is CDOC1
     */
    constexpr bool isCertificate() const noexcept { return (type == Type::CDOC1); }
    /**
     * @brief check whether lock is CDoc1 version
     * @return true if type is CDOC1
     */
    constexpr bool isCDoc1() const noexcept { return type == Type::CDOC1; }
    /**
     * @brief check whether public key lock uses RSA algorithm
     * @return true if pk_type is RSA
     */
    constexpr bool isRSA() const noexcept { return pk_type == PKType::RSA; }

    /**
     * @brief check whether two locks have the same public key
     *
     * This convenience method checks whether both locks are public key based, and if they are,
     * whether the RCPT_KEY parameters are identical (i.e. both can be decrypted by the same private key)
     * @param other the other lock
     * @return true if both have the same public key
     */
    bool hasTheSameKey(const Lock &other) const;
    /**
     * @brief check whether lock has the given public key
     *
     * This convenience method checks whether lock is public key based, and if it is,
     * whether the RCPT_KEY parameters is identical to ptovided key(i.e. it can be decrypted by the corresponding private key)
     * @param public_key the public key (short format)
     * @return true if lock has the same public key
     */
    bool hasTheSameKey(const std::vector<uint8_t>& public_key) const;

	Lock() noexcept = default;
	Lock(Type _type) noexcept : type(_type) {};

    /**
     * @brief Set lock parameter value
     * @param param a parameter type
     * @param val the value
     */
    void setBytes(Params param, const std::vector<uint8_t>& val) { params[param] = val; }
    /**
     * @brief Set lock parameter value from string
     * @param param a parameter type
     * @param val the value
     */
    void setString(Params param, const std::string& val) { params[param] = std::vector<uint8_t>(val.cbegin(), val.cend()); }
    /**
     * @brief Set lock parameter value from integer
     * @param param a parameter type
     * @param val the value
     */
    void setInt(Params param, int32_t val);

    /**
     * @brief A convenience method to initialize CERTIFICATE, RCPT_KEY and PK_TYPE values from given certificate
     * @param cert the certificate (der-encoded)
     */
	void setCertificate(const std::vector<uint8_t>& cert);

    bool operator== (const Lock& other) const = default;

private:
	std::map<Params,std::vector<uint8_t>> params;
};

} // namespace libcdoc

#endif // LOCK_H
