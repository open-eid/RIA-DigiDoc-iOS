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

#ifndef __CDOCWRITER_H__
#define __CDOCWRITER_H__

#include "CDoc.h"

#include <cstdint>

namespace libcdoc {
    struct Configuration;
    struct CryptoBackend;
    struct DataConsumer;
    struct MultiDataSource;
    struct NetworkBackend;
    struct Recipient;

/**
 * @brief Provides encryption interface
 *
 * An abstract base class of CDoc1 and CDoc2 writers. Provides an unified interface for file creation and encryption.
 */
class CDOC_EXPORT CDocWriter {
public:
	virtual ~CDocWriter();

    /**
     * @brief The container version (1 or 2)
     */
	const int version;

	/* Push interface */
    /**
     * @brief Add recipient to container
     *
     * This adds new recipient to the list of container recipients. FMK (File Master Key) is encrypted separately for each
     * recipient, using corresponding methods. All recipients should be added before the encryption starts.
     * @param rcpt a Recipient object
     * @return error code or OK
     */
    virtual result_t addRecipient(const Recipient& rcpt) = 0;
    /**
     * @brief Prepares the stream for encryption
	 *
     * This may involve creating cryptographic ciphers, building headers and writing the initial part of the stream. All
     * recipients should be added before a call to beginEncryption.
	 * @return error code or OK
	 */
    virtual result_t beginEncryption() = 0;
	/**
     * @brief Add a new file to the container
	 *
     * Start streaming a new file into the container output stream. The name will be written to stream exactly as is.
     * If size is >= 0 the number of bytes subsequently written has to match exactly. Otherwise the final size is determined by
     * the actual number of bytes written.
     * @param name the name to be used in container
	 * @param size the size of the file
     * @return error code or OK
	 */
    virtual result_t addFile(const std::string& name, size_t size) = 0;
	/**
     * @brief Write data to the encrypted stream
	 *
     * Writes data to the current file (created with addFile) in container.
     * A single file may safely be written in multiple parts as long as the total size matches the one provided
     * in addFile (or the total size was left indeterminate).
     * @param src the source buffer
	 * @param size the size of data in buffer
	 * @return size or error code
	 */
    virtual result_t writeData(const uint8_t *src, size_t size) = 0;
	/**
     * @brief Finalizes the encryption stream
	 *
	 * This may involve flushing file, calculating checksum and closing the stream (if owned by CDocWriter)
	 * @return error code or OK
	 */
    virtual result_t finishEncryption() = 0;

	/* Pull interface */
	/**
     * @brief Encrypt data and send to the output stream
     *
     * Encrypts the data, provided by MultiDataSource, in one go.
	 * @param src MultiDataSource providing input files (named chunks)
	 * @param recipients a list of recipients for whom locks will be encoded into file
	 * @return error code or OK
	 */
    virtual result_t encrypt(MultiDataSource& src, const std::vector<libcdoc::Recipient>& recipients) { return NOT_IMPLEMENTED; }
    /**
     * @brief Get the error text of the last failed operation
     *
     * Get the error message of the last failed operation. It should be called immediately after getting
     * error code as certain methods may reset the error.
     * @return error description, empty string if no errors
     */
    std::string getLastErrorStr() { return last_error; }

	/**
     * @brief Create CDoc document writer
     *
     * Creates a new CDoc document writer for DataConsumer.
     * Configuration and NetworkBackend may be null if keyservers are not used.
     * @param version (1 or 2)
     * @param dst output DataConsumer
	 * @param take_ownership whether to close dst at the end of encryption and delete with CDocWiter
     * @param conf a configuration object
     * @param crypto a cryptographic backend implementation
     * @param network a network backend implementation
     * @return a new CDocWriter or null
	 */
	static CDocWriter *createWriter(int version, DataConsumer *dst, bool take_ownership, Configuration *conf, CryptoBackend *crypto, NetworkBackend *network);
    /**
     * @brief Create CDoc document writer
     *
     * Creates a new CDoc document writer for outputstream.
     * Configuration and NetworkBackend may be null if keyservers are not used.
     * @param version (1 or 2)
     * @param ofs output stream
     * @param conf a configuration object
     * @param crypto a cryptographic backend implementation
     * @param network a network backend implementation
     * @return a new CDocWriter or null
     */
    static CDocWriter *createWriter(int version, std::ostream& ofs, Configuration *conf, CryptoBackend *crypto, NetworkBackend *network);
    /**
     * @brief Create CDoc document writer
     *
     * Creates a new CDoc document writer for file.
     * Configuration and NetworkBackend may be null if keyservers are not used.
     * @param version (1 or 2)
     * @param path output file path
     * @param conf a configuration object
     * @param crypto a cryptographic backend implementation
     * @param network a network backend implementation
     * @return a new CDocWriter or null
     */
    static CDocWriter *createWriter(int version, const std::string& path, Configuration *conf, CryptoBackend *crypto, NetworkBackend *network);
protected:
	explicit CDocWriter(int _version, DataConsumer *dst, bool take_ownership);

	void setLastError(const std::string& message) { last_error = message; }

	std::string last_error;
	DataConsumer *dst;
	bool owned;

	Configuration *conf = nullptr;
	CryptoBackend *crypto = nullptr;
	NetworkBackend *network = nullptr;
};

} // namespace libcdoc

#endif // CDOCWRITER_H
