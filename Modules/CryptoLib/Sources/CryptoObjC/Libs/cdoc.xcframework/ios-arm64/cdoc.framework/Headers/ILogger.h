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

#ifndef __ILOGGER_H__INCLUDED__
#define __ILOGGER_H__INCLUDED__

#include <cdoc/Exports.h>

#include <string>

#ifdef __cpp_lib_format
#include <format>
namespace fmt = std;
#else
#define FMT_HEADER_ONLY
#include "fmt/format.h"
#endif

#define FORMAT fmt::format

namespace libcdoc
{

/**
 * @brief Generic interface to implement a logger.
 */
class CDOC_EXPORT ILogger
{
public:
    /**
     * @brief Log-level enumeration to indicate severity of the log message.
     */
    enum LogLevel
    {
        /**
         * @brief Most critical level. Application is about to abort.
         */
        LEVEL_FATAL,

        /**
         * @brief Errors where functionality has failed or an exception have been caught.
         */
        LEVEL_ERROR,

        /**
         * @brief Warnings about validation issues or temporary failures that can be recovered.
         */
        LEVEL_WARNING,

        /**
         * @brief Information that highlights progress or application lifetime events.
         */
        LEVEL_INFO,

        /**
         * @brief Debugging the application behavior from internal events of interest.
         */
        LEVEL_DEBUG,

        /**
         * @brief Most verbose level. Used for development, NOP in production code.
         */
        LEVEL_TRACE
    };

    ILogger() : minLogLevel(LEVEL_WARNING) {}
    virtual ~ILogger() {}

    /**
     * @brief Logs given message with given severity, file name and line number.
     * @param level Severity of the log message.
     * @param file File name where the log message was recorded.
     * @param line Line number in the file where the log message was recorded.
     * @param message The log message.
     *
     * Every class implementing the ILogger interface must implement the member function.
     * Default implementation does nothing.
     */
    virtual void LogMessage(LogLevel level, std::string_view file, int line, std::string_view message) {}

    /**
     * @brief Returns current minimum log level of the logger.
     * @return Minimum log level.
     */
    LogLevel GetMinLogLevel() const noexcept { return minLogLevel; }

    /**
     * @brief Sets minimum log level for the logger.
     * @param level minimum level to log.
     *
     * Sets minimum level of log messages to log. For example, if the minimum log level is set
     * to LogLevelInfo (default), then LogLevelFatal, LogLevelError, LogLevelWarning and LogLevelInfo
     * messages are logged, but not LogLevelDebug or LogLevelTrace messages.
     */
    void SetMinLogLevel(LogLevel level) noexcept { minLogLevel = level; }

    /**
     * @brief Adds ILogger implementation to logging queue.
     * 
     * This function does not take ownership of the logger's instance.
     * It is up to the caller to free the resources of the logger's instance and 
     * keep it alive until removed from the queue.
     * 
     * @param logger Logger's instance to be added.
     * @return Unique cookie identifying the logger's instance in the logging queue.
     */
    static int addLogger(ILogger* logger);

    /**
     * @brief Removes logger's instance from the logging queue.
     * @param cookie Unique cookie returned by the add_logger function when the logger was added.
     * @return Pointer to ILogger object that is removed. It's up to user to free the resources.
     */
    static ILogger* removeLogger(int cookie);

    /**
     * @brief Returns global logger's instance.
     * @return Global logger's instance.
     */
    static ILogger* getLogger();

protected:
    /**
     * @brief Minimum level of log messages to log.
     */
    LogLevel minLogLevel;
};

#ifndef SWIG
template<typename... Args>
static inline void LogFormat(ILogger::LogLevel level, std::string_view file, int line, fmt::format_string<Args...> fmt, Args&&... args)
{
    auto msg = fmt::format(fmt, std::forward<Args>(args)...);
    ILogger::getLogger()->LogMessage(level, file, line, msg);
}

static inline void LogFormat(ILogger::LogLevel level, std::string_view file, int line, std::string_view msg)
{
    ILogger::getLogger()->LogMessage(level, file, line, msg);
}
#endif

#define LOG(l,...) LogFormat((l), __FILE__, __LINE__, __VA_ARGS__)
#define LOG_ERROR(...) LogFormat(libcdoc::ILogger::LEVEL_ERROR, __FILE__, __LINE__, __VA_ARGS__)
#define LOG_WARN(...) LogFormat(libcdoc::ILogger::LEVEL_WARNING, __FILE__, __LINE__, __VA_ARGS__)
#define LOG_INFO(...) LogFormat(libcdoc::ILogger::LEVEL_INFO, __FILE__, __LINE__, __VA_ARGS__)
#define LOG_DBG(...) LogFormat(libcdoc::ILogger::LEVEL_DEBUG, __FILE__, __LINE__, __VA_ARGS__)

#ifdef NDEBUG
#define LOG_TRACE(...)
#define LOG_TRACE_KEY(MSG, KEY)
#else
#define LOG_TRACE(...) LogFormat(libcdoc::ILogger::LEVEL_TRACE, __FILE__, __LINE__, __VA_ARGS__)
#define LOG_TRACE_KEY(MSG, KEY) LogFormat(libcdoc::ILogger::LEVEL_TRACE, __FILE__, __LINE__, MSG, toHex(KEY))
#endif

}

#endif
