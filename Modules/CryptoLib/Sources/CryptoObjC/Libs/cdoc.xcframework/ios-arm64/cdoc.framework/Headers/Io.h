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

#ifndef __IO_H__
#define __IO_H__

#include <cdoc/CDoc.h>

#include <filesystem>
#include <fstream>

namespace libcdoc {

class DataSource;

/**
 * @brief The DataConsumer class
 *
 * An abstact base class for ouput objects
 */
struct CDOC_EXPORT DataConsumer {
	DataConsumer() = default;
	virtual ~DataConsumer() = default;

	/**
	 * @brief write write bytes to output object
	 *
	 * The following invariant holds:
	 * If there was no error then result == size
	 * If there was an error then result < 0
	 * @param src source block
	 * @param size the number of bytes to write
	 * @return size or error code
	 */
    virtual result_t write(const uint8_t *src, size_t size) = 0;
	/**
     * @brief informs DataConsumer that the writing is finished
	 * @return error code or OK
	 */
    virtual result_t close() = 0;
	/**
	 * @brief checks whether DataSource is in error state
     * @return true if error state
	 */
	virtual bool isError() = 0;
	/**
     * @brief get textual description of the last error
	 *
	 * Implementation can decide whether to store the actual error string or
     * return the generic text based on error code. It is undefined what will
	 * be returned if the last error code is not the one used as the argument.
	 * @param code the last returned error code
	 * @return error text
	 */
	virtual std::string getLastErrorStr(result_t code) const;
    /**
     * @brief write all bytes in vector
     * @param src a vector
     * @return vector size or error code
     */
    result_t write(const std::vector<uint8_t>& src) {
		return write(src.data(), src.size());
	}
    /**
     * @brief write all bytes in string
     * @param src a string
     * @return string length or error code
     */
    result_t write(const std::string& src) {
		return write((const uint8_t *) src.data(), src.size());
	}
    /**
     * @brief write all data from input object
     *
     * Copies all bytes from input source (until EOF or error) to the consumer. If error occurs
     * while reading source, the source objects' error code is returned.
     * @param src the input DataSource
     * @return the number of bytes copied or error
     */
    result_t writeAll(DataSource& src);

	DataConsumer (const DataConsumer&) = delete;
	DataConsumer& operator= (const DataConsumer&) = delete;
};

/**
 * @brief The DataSource class
 *
 * An abstact base class for input objects
 */
struct CDOC_EXPORT DataSource {
	DataSource() = default;
	virtual ~DataSource() = default;

	/**
     * @brief set stream input pointer
	 *
	 * Positions the read pointer at the specific distance from the stream start.
	 * If the stream does not support seeking NOT_IMPLEMENTED is returned.
	 * @param pos the position from the beggining of data
	 * @return error code or OK
	 */
    virtual result_t seek(size_t pos) { return NOT_IMPLEMENTED; }
	/**
     * @brief read bytes from input object
	 *
	 * The following invariant holds:
     * - if there is neither error nor eof then result == size
     * - if there is no errors but end of stream is reached then 0 <= result <= size
     * - if there is error then result < 0
	 * @param dst the destination block
	 * @param size the number of bytes to read
     * @return the number of bytes read or error code
	 */
    virtual result_t read(uint8_t *dst, size_t size) { return NOT_IMPLEMENTED; }
    /**
     * @brief check whether DataConsumer is in error state
     * @return true if error state
     */
    virtual bool isError() { return true; }
    /**
     * @brief check whether DataConsumer is reached to the end of data
     * @return true if end of stream
     */
    virtual bool isEof() { return true; }
    /**
     * @brief get textual description of the last error
     *
     * Implementation can decide whether to store the actual error string or
     * return the generic text based on error code. It is undefined what will
     * be returned if the last error code is not the one used as the argument.
     * @param code the last returned error code
     * @return error text
     */
    virtual std::string getLastErrorStr(result_t code) const;

    /**
     * @brief skip specified number of bytes
     *
     * The following invariant holds:
     * - if there is neither error nor eof then result == size
     * - if there is no errors but end of stream is reached then 0 <= result <= size
     * - if there is error then result < 0
     * @param size the number of bytes to skip
     * @return the number of bytes skipped
     */
    result_t skip(size_t size);
    /**
     * @brief read all data and writes to output object
     *
     * Copies all bytes (until EOF or error) to the output object. If error occurs
     * while writing data, the destination objects' error code is returned.
     * @param dst the destination DataConsumer
     * @return error code or OK
     */
    result_t readAll(DataConsumer& dst) {
		return dst.writeAll(*this);
	}

	DataSource (const DataSource&) = delete;
	DataSource& operator= (const DataSource&) = delete;
};

/**
 * @brief An abstract base class for multi-stream consumers
 *
 * A new sub-stream is created by open and finished either by the next open or by closing
 * the whole stream.
 *
 */
struct CDOC_EXPORT MultiDataConsumer : public DataConsumer {
	virtual ~MultiDataConsumer() = default;
    /**
     * @brief create a new named sub-stream
     *
     * Creates a new named sub-stream. It is up to implementation to handle the name and optional size.
     * @param name the name of sub-stream
     * @param size the size of sub-stream or -1 if unknown at creation time
     * @return error code or OK
     */
    virtual result_t open(const std::string& name, int64_t size) = 0;
};

/**
 * @brief An abstract base class for multi-stream sources
 *
 * A next sub-stream is made available by nextFile. The initial state of MultiDataSource does
 * not have any sub-stream open (i.e. the to get the first one, nextFile has to be called).
 */
struct CDOC_EXPORT MultiDataSource : public DataSource {
    virtual result_t getNumComponents() { return NOT_IMPLEMENTED; }
    virtual result_t next(std::string& name, int64_t& size) = 0;
    result_t next(FileInfo& info) { return next(info.name, info.size); }
};

struct CDOC_EXPORT ChainedConsumer : public DataConsumer {
	ChainedConsumer(DataConsumer *dst, bool take_ownership) : _dst(dst), _owned(take_ownership) {}
	~ChainedConsumer() {
		if (_owned) delete _dst;
	}
    result_t write(const uint8_t *src, size_t size) override {
		return _dst->write(src, size);
	}
    result_t close() override {
		if (_owned) return _dst->close();
        return OK;
	}
	bool isError() override {
		return _dst->isError();
	}
protected:
	DataConsumer *_dst;
	bool _owned;
};

struct CDOC_EXPORT ChainedSource : public DataSource {
	ChainedSource(DataSource *src, bool take_ownership) : _src(src), _owned(take_ownership) {}
	~ChainedSource() {
		if (_owned) delete _src;
	}
    result_t read(uint8_t *dst, size_t size) {
		return _src->read(dst, size);
	}
	bool isError() {
		return _src->isError();
	}
	bool isEof() {
		return _src->isEof();
	}
protected:
	DataSource *_src;
	bool _owned;
};

struct CDOC_EXPORT IStreamSource : public DataSource {
	IStreamSource(std::istream *ifs, bool take_ownership = false) : _ifs(ifs), _owned(take_ownership) {}
	IStreamSource(const std::string& path);
	~IStreamSource() {
        if (_owned) delete _ifs;
	}

    result_t seek(size_t pos) {
        if(_ifs->bad()) return INPUT_STREAM_ERROR;
        _ifs->clear();
		_ifs->seekg(pos);
        //std::cerr << "Stream bad:" << _ifs->bad() << " eof:" << _ifs->eof() << " fail:" << _ifs->fail() << std::endl;
        //std::cerr << "tell:" << _ifs->tellg() << std::endl;
        return bool(_ifs->bad()) ? INPUT_STREAM_ERROR : OK;
	}

    result_t read(uint8_t *dst, size_t size) {
		_ifs->read((char *) dst, size);
		return (_ifs->bad()) ? INPUT_STREAM_ERROR : _ifs->gcount();
	}

	bool isError() { return _ifs->bad(); }
	bool isEof() { return _ifs->eof(); }
protected:
	std::istream *_ifs;
	bool _owned;
};

struct CDOC_EXPORT OStreamConsumer : public DataConsumer {
	static constexpr int STREAM_ERROR = -500;

	OStreamConsumer(std::ostream *ofs, bool take_ownership = false) : _ofs(ofs), _owned(take_ownership) {}
	OStreamConsumer(const std::string& path);
	~OStreamConsumer() {
		if (_owned) delete _ofs;
	}

    result_t write(const uint8_t *src, size_t size) {
		_ofs->write((const char *) src, size);
		return (_ofs->bad()) ? OUTPUT_STREAM_ERROR : size;
	}

    result_t close() {
		_ofs->flush();
        return (_ofs->bad()) ? OUTPUT_STREAM_ERROR : OK;
	}

	bool isError() { return _ofs->bad(); }
protected:
	std::ostream *_ofs;
	bool _owned;
};

struct CDOC_EXPORT VectorSource : public DataSource {
	VectorSource(const std::vector<uint8_t>& data) : _data(data), _ptr(0) {}

    result_t seek(size_t pos) override {
		if (pos > _data.size()) return INPUT_STREAM_ERROR;
		_ptr = pos;
        return OK;
	}

    result_t read(uint8_t *dst, size_t size) override {
		size = std::min<size_t>(size, _data.size() - _ptr);
		std::copy(_data.cbegin() + _ptr, _data.cbegin() + _ptr + size, dst);
		_ptr += size;
		return size;
	}

    bool isError() override { return false; }
    bool isEof() override { return _ptr >= _data.size(); }
protected:
	const std::vector<uint8_t>& _data;
	size_t _ptr;
};

struct CDOC_EXPORT VectorConsumer : public DataConsumer {
	VectorConsumer(std::vector<uint8_t>& data) : _data(data) {}
    result_t write(const uint8_t *src, size_t size) override final {
		_data.insert(_data.end(), src, src + size);
		return size;
	}
    result_t close() override final { return OK; }
	virtual bool isError() override final { return false; }
protected:
    std::vector<uint8_t>& _data;
};

struct CDOC_EXPORT FileListConsumer : public MultiDataConsumer {
    FileListConsumer(const std::string& base_path) {
		base = base_path;
	}
    result_t write(const uint8_t *src, size_t size) override final {
		ofs.write((const char *) src, size);
		return (ofs.bad()) ? OUTPUT_STREAM_ERROR : size;
	}
    result_t close() override final {
		ofs.close();
        return (ofs.bad()) ? OUTPUT_STREAM_ERROR : OK;
	}
	bool isError() override final {
		return ofs.bad();
	}
    result_t open(const std::string& name, int64_t size) override final {
        std::string fileName;
        if (ofs.is_open()) {
            ofs.close();
        }
        size_t lastSlashPos = name.find_last_of("\\/");
        if (lastSlashPos != std::string::npos)
        {
            fileName = name.substr(lastSlashPos + 1);
        }
        else
        {
            fileName = name;
        }
        std::filesystem::path path(base);
        path /= fileName;
		ofs.open(path.string(), std::ios_base::binary);
        return ofs.bad() ? OUTPUT_STREAM_ERROR : OK;
	}

protected:
	std::filesystem::path base;
	std::ofstream ofs;
};

struct CDOC_EXPORT FileListSource : public MultiDataSource {
	FileListSource(const std::string& base, const std::vector<std::string>& files);
    result_t read(uint8_t *dst, size_t size) override final;
	bool isError() override final;
	bool isEof() override final;
    result_t getNumComponents() override final;
    result_t next(std::string& name, int64_t& size) override final;
protected:
	std::filesystem::path _base;
	const std::vector<std::string>& _files;
	int64_t _current;
	std::ifstream _ifs;
};

} // namespace libcdoc

#endif // IO_H
