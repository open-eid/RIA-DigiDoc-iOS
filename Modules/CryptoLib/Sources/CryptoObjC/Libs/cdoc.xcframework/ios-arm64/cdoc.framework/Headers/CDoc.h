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

#ifndef __CDOC_H__
#define __CDOC_H__
 
#include "Exports.h"

#include <string>
#include <vector>

#ifndef LIBCDOC_TESTING
// Remove this in production code
#define LIBCDOC_TESTING 1
#endif

namespace libcdoc {

/**
 * @brief A typedef that indicates that integer value may contain libcdoc result code
 */
typedef int64_t result_t;

enum {
    /**
     * @brief Operation completed successfully
     */
    OK = 0,
    /**
     * @brief No more input data
     *
     * A pseudo-error that indicates that there are no more streams in MultiDataSource
     */
    END_OF_STREAM = 1,
    /**
     * @brief A method is not implemented
     */
    NOT_IMPLEMENTED = -100,
    /**
     * @brief An operation is not supported
     */
    NOT_SUPPORTED = -101,
    /**
     * @brief Conflicting or invalid arguments for a method
     */
    WRONG_ARGUMENTS = -102,
    /**
     * @brief Components of multi-method workflow are called in wrong order
     */
    WORKFLOW_ERROR = -103,
    /**
     * @brief A generic input/output error
     */
    IO_ERROR = -104,
    /**
     * @brief A generic output error
     */
    OUTPUT_ERROR = -105,
    /**
     * @brief An error while writing output stream
     */
    OUTPUT_STREAM_ERROR = -106,
    /**
     * @brief A generic input error
     */
    INPUT_ERROR = -107,
    /**
     * @brief An error while reading input stream
     */
    INPUT_STREAM_ERROR = -108,
    /**
     * @brief The supplied decryption key is wrong
     */
    WRONG_KEY = -109,
    /**
     * @brief Data format of a file (or sub-object inside a file) is wrong
     */
    DATA_FORMAT_ERROR = -110,
    /**
     * @brief Generic error in cryptography subsystem
     */
    CRYPTO_ERROR = -111,
    /**
     * @brief Comppression/decompression error in zlib
     */
    ZLIB_ERROR = -112,
    /**
     * @brief Generic error in PKCS11 subsystem
     */
    PKCS11_ERROR = -113,
    /**
     * @brief The value of cryptographic hash is not correct
     */
    HASH_MISMATCH = -114,
    /**
     * @brief Generic error in configuration susbsytem
     */
    CONFIGURATION_ERROR = -115,
    /**
     * @brief Object not found
     */
    NOT_FOUND = -116,
    /**
     * @brief Unspecified error
     */
    UNSPECIFIED_ERROR = -199,
};

CDOC_EXPORT std::string getErrorStr(int64_t code);

CDOC_EXPORT std::string getVersion();

/**
 * @brief A simple container of file name and size
 *
 * A container struct to store file name and size, needed for wrapper interfaces
 */
struct FileInfo {
    std::string name;
    int64_t size;
};

}; // namespace libcdoc

#endif // CDOC_H
