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

#ifndef __CONFIGURATION_H__
#define __CONFIGURATION_H__

#include "Exports.h"

#include <string>
#include <vector>

#include <cstdint>

namespace libcdoc {

/**
 * @brief A configuration provider.
 *
 * Subclasses can implement different configuration systems (registry, .ini files etc.) by overriding getValue.
 */
struct CDOC_EXPORT Configuration {
    /**
     * @brief Send URL of keyserver (Domain is server id)
     */
    static constexpr char const *KEYSERVER_SEND_URL = "KEYSERVER_SEND_URL";
    /**
     * @brief Fetch URL of keyserver (Domain is server id)
     */
    static constexpr char const *KEYSERVER_FETCH_URL = "KEYSERVER_FETCH_URL";
    /**
     * @brief JSON array of share server base urls (Domain is server id)
     */
    static constexpr char const *SHARE_SERVER_URLS = "SHARE_SERVER_URLS";
    /**
     * @brief Method for signing keyshare tickets (SMART_ID or MOBILE_ID)
     */
    static constexpr char const *SHARE_SIGNER = "SHARE_SIGNER";
    /**
     * @brief Domain of SmartID settings
     */
    static constexpr char const *SID_DOMAIN = "SMART_ID";
    /**
     * @brief Domain of Mobile ID settings
     */
    static constexpr char const *MID_DOMAIN = "MOBILE_ID";
    /**
     * @brief MID/SID base url (domain is SMART_ID or MOBILE_ID)
     */
    static constexpr char const *BASE_URL = "BASE_URL";
    /**
     * @brief MID/SID relying party UUID (domain is SMART_ID or MOBILE_ID)
     */
    static constexpr char const *RP_UUID = "RP_UUID";
    /**
     * @brief MID/SID relying party name (domain is SMART_ID or MOBILE_ID)
     */
    static constexpr char const *RP_NAME = "RP_NAME";
    /**
     * @brief Mobile ID phone number (domain is MOBILE_ID)
     */
    static constexpr char const *PHONE_NUMBER = "PHONE_NUMBER";

	Configuration() = default;
	virtual ~Configuration() noexcept = default;
    Configuration(const Configuration&) = delete;
    Configuration& operator=(const Configuration&) = delete;
    CDOC_DISABLE_MOVE(Configuration);

    /**
     * @brief get a value of configuration parameter
     *
     * Get a string value of configuration parameter.
     * @param domain the parameter domain. For keyservers this is the server ID.
     * @param param the parameter name.
     * @return a string value or empty string if parameter is not defined.
     */
    virtual std::string getValue(std::string_view domain, std::string_view param) const {return {};}

    /**
     * @brief get a value of configuration parameter from default domain
     * @param param the parameter name.
     * @return a string value or empty string if parameter is not defined.
     */
    std::string getValue(std::string_view param) const {return getValue({}, param);}
    /**
     * @brief get boolean value of configuration parameter from default domain
     * @param param the parameter name
     * @param def_val the default value to return if parameter is not set
     * @return the parameter value
     */
    bool getBoolean(std::string_view param, bool def_val = false) const;
    /**
     * @brief get integer value of configuration parameter from default domain
     * @param param the parameter name
     * @param def_val the default value to return if parameter is not set
     * @return the key value
     */
    int getInt(std::string_view param, int def_val = 0) const;

#if LIBCDOC_TESTING
    virtual int64_t test(std::vector<uint8_t>& dst) { return OK; }
#endif
};

/**
 * @brief A Configuration object implementation that reads values from JSON file
 * 
 * The file should represent a single object with key/value pairs
 * Domain should contain sub-objects with corresponding key/value pairs
 * Strings are returned unquoted, everything else is returned as JSON
 * 
 */
struct CDOC_EXPORT JSONConfiguration : public Configuration {
    struct Private;

    /**
     * @brief Construct a new empty JSONConfiguration object
     * 
     */
    JSONConfiguration();
    /**
     * @brief Construct a new JSONConfiguration object from input stream
     * 
     * @param ifs input stream
     */
    JSONConfiguration(std::istream& ifs);
    /**
     * @brief Construct a new JSONConfiguration object from file
     * 
     * @param file file name
     */
    JSONConfiguration(const std::string& file);
    /**
     * @brief Construct a new JSONConfiguration object from bytes
     * 
     * @param data input data
     */
    JSONConfiguration(const std::vector<uint8_t>& data);
    ~JSONConfiguration();

    /**
     * @brief Read configuration data from input stream
     * 
     * Existing values are replaced
     * 
     * @param ifs input stream
     * @return true if successful
     */
    bool parse(std::istream& ifs);
    /**
     * @brief Read configuration data from file
     * 
     * Existing values are replaced
     * 
     * @param file file name
     * @return true if successful
     */
    bool parse(const std::string& file);
    /**
     * @brief Read configuration data from byte vector
     * 
     * Existing values are replaced
     * 
     * @param data input data
     * @return true if successful
     */
    bool parse(const std::vector<uint8_t>& data);

    std::string getValue(std::string_view domain, std::string_view param) const override;
private:
    Private *d;
};

} // namespace libcdoc

#endif // CONFIGURATION_H
