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

#ifndef __CDOCREADER_H__
#define __CDOCREADER_H__

#include "CDoc.h"

#include <cstdint>

namespace libcdoc {

struct Configuration;
struct CryptoBackend;
struct DataSource;
struct Lock;
struct MultiDataConsumer;
struct NetworkBackend;

/**
 * @brief Provides decryption interface
 *
 * An abstract base class of CDoc1 and CDoc2 readers. Provides unified interface for loading and decryption of containers.
 */
class CDOC_EXPORT CDocReader {
public:
	virtual ~CDocReader() = default;

    /**
     * @brief The container version (1 or 2)
     */
    const int version;

	/**
	 * @brief Get decryption locks in given document
	 * @return a vector of locks
	 */
    virtual const std::vector<Lock>& getLocks() = 0;
	/**
     * @brief Finds the lock index for given certificate
	 *
	 * Returns the first lock that can be opened by the private key of the certificate holder.
	 * @param cert a x509 certificate (der)
     * @return lock index or error code
	 */
    virtual result_t getLockForCert(const std::vector<uint8_t>& cert) = 0;
	/**
     * @brief Obtain FMK of given lock
	 *
     * Obtains FMK (File Master Key) of the lock with given index. Depending on the lock type it uses a relevant CryptoBackend and/or
     * NetworkBackend methods to either fetch secret and derive key or perform external decryption of encrypted KEK.
	 * @param fmk The FMK of the document
     * @param lock_idx the index of a lock (in the document lock list)
	 * @return error code or OK
	 */
    virtual result_t getFMK(std::vector<uint8_t>& fmk, unsigned int lock_idx) = 0;

	// Pull interface
    /**
     * @brief Start decrypting container
     *
     * Starts decryption of the container. This may involve parsing and decrypting headers, checking
     * file and key integrity etc.
     * @param fmk File Master Key of the document
     * @return error code or OK
     */
    virtual result_t beginDecryption(const std::vector<uint8_t>& fmk) = 0;
    /**
     * @brief Go to the next file in container
     *
     * Begins decrypting the next file in container. On success the file name and size are filled and the
     * method returns OK. If there are no more file in the document, END_OF_STREAM is returned.
     * It is OK to call nextFile before reading the whole data from the previous one.
     * It has to be called always (even for single-file container) immediately after beginDecryption to get access to the
     * first file.
     * @param name the name of the next file
     * @param size the size of the next file
     * @return error code, OK or END_OF_STREAM
     */
    virtual result_t nextFile(std::string& name, int64_t& size) = 0;
    /**
     * @brief Read data from the current file
     *
     * Read bytes from the current file (opened with nextFile) inside of the container into the buffer. The number of bytes read is always the
     * requested number, unless end of file is reached or error occurs. Thus the end of file is marked
     * by returning 0.
     * @param dst destination byte buffer
     * @param size the number of bytes to read
     * @return the number of bytes actually read or error code
     */
    virtual result_t readData(uint8_t *dst, size_t size) = 0;
    /**
     * @brief Finish decrypting container
     *
     * Finishes the decryption of the container. This may onvolve releasing buffers, closing hardware keys etc.
     * @return error code or OK
     */
    virtual result_t finishDecryption() = 0;

    /**
     * @brief Go to the next file in container
     *
     * Begins decrypting the next file in container. On success the FileInfo struct is filled and the
     * method returns OK. If there are no more file in the document, END_OF_STREAM is returned.
     * It is OK to call nextFile before reading the whole data from the previous one.
     * @param info a FileInfo structure
     * @return error code, OK or END_OF_STREAM
     */
    result_t nextFile(FileInfo& info) { return nextFile(info.name, info.size); }

	// Push interface
	/**
     * @brief Decrypt document in one step
     *
     * Decrypts the encrypted content and writes files to provided output object.
	 * @param fmk The FMK of the document
	 * @param consumer a consumer of decrypted files
	 * @return error code or OK
	 */
    virtual result_t decrypt(const std::vector<uint8_t>& fmk, MultiDataConsumer *consumer) = 0;

	/**
     * @brief Get the error text of the last failed operation
     *
     * Get the error message of the last failed operation. It should be called immediately after getting
     * error code as certain methods may reset the error.
	 * @return error description, empty string if no errors
	 */
	std::string getLastErrorStr() const { return last_error; }

	/**
     * @brief Try to determine the cdoc file version
     *
     * Tries to open the file and find CDoc format descriptors inside it.
	 * @param path a path to file
     * @return version or error code if not a readable CDoc file
	 */
    static int getCDocFileVersion(const std::string& path);
    /**
     * @brief  Try to determine the cdoc file version
     *
     * Tries to read the source and find CDoc format descriptors inside it.
     * @param src the container source
     * @return version or error code if not a readable CDoc file
     */
    static int getCDocFileVersion(DataSource *src);

    /**
     * @brief Create CDoc document reader
     *
     * Creates a new document reader if source is a valid CDoc container (either version 1 or 2).
     * Configuration and NetworkBackend may be null if keyservers are not used.
     * If take_ownership is true, the source is deleted by the reader destructor. If src is not a valid CDoc file,
     * the source is deleted before returning null.
     * @param src the container source
     * @param take_ownership if true the source is deleted in reader destructor
     * @param conf a configuration object
     * @param crypto a cryptographic backend implementation
     * @param network a network backend implementation
     * @return a new CDocReader or null
     */
    static CDocReader *createReader(DataSource *src, bool take_ownership, Configuration *conf, CryptoBackend *crypto, NetworkBackend *network);
    /**
     * @brief Create CDoc document reader
     *
     * Creates a new document reader if file is a valid CDoc container (either version 1 or 2)
     * Configuration and NetworkBackend may be null if keyservers are not used.
     * @param path the path to file
     * @param conf a configuration object
     * @param crypto a cryptographic backend implementation
     * @param network a network backend implementation
     * @return a new CDocReader or null
     */
    static CDocReader *createReader(const std::string& path, Configuration *conf, CryptoBackend *crypto, NetworkBackend *network);
    /**
     * @brief Create CDoc document reader
     *
     * Creates a new document reader if inputstream is a valid CDoc container (either version 1 or 2)
     * Configuration and NetworkBackend may be null if keyservers are not used.
     * @param ifs the input stream
     * @param conf a configuration object
     * @param crypto a cryptographic backend implementation
     * @param network a network backend implementation
     * @return a new CDocReader or null
     */
    static CDocReader *createReader(std::istream& ifs, Configuration *conf, CryptoBackend *crypto, NetworkBackend *network);

#if LIBCDOC_TESTING
    virtual int64_t testConfig(std::vector<uint8_t>& dst);
    virtual int64_t testNetwork(std::vector<std::vector<uint8_t>>& dst);
#endif
protected:
	explicit CDocReader(int _version) : version(_version) {};

	void setLastError(const std::string& message) { last_error = message; }

	std::string last_error;

	Configuration *conf = nullptr;
	CryptoBackend *crypto = nullptr;
	NetworkBackend *network = nullptr;
};

} // namespace libcdoc

#endif // CDOCREADER_H
