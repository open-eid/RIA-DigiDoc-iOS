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

#pragma once

#include <cdoc/CDoc.h>

namespace libcdoc
{

/**
 * @brief Generic interface to implement a logger.
 */
class CDOC_EXPORT Logger
{
public:
    virtual ~Logger() noexcept = default;

    /**
     * @brief Logs given message with given severity, file name and line number.
     * 
     * It tests the log level and if <= min_level invokes logMessage
     * 
     * @param level Severity of the log message.
     * @param file File name where the log message was recorded.
     * @param line Line number in the file where the log message was recorded.
     * @param msg The log message.
     */
    void log(LogLevel level, std::string_view file, int line, std::string_view msg) {
        if (level <= min_level) logMessage(level, file, line, msg);
    }

    /**
     * @brief Sets minimum log level for the logger.
     * @param level minimum level to log.
     *
     * Sets minimum level of log messages to log. For example, if the minimum log level is set
     * to LEVEL_INFO (default), then LEVEL_FATAL, LEVEL_ERROR, LEVEL_WARNING and LEVEL_INFO
     * messages are logged, but not LEVEL_DEBUG or LEVEL_TRACE messages.
     */
    constexpr void setMinLogLevel(LogLevel level) noexcept { min_level = level; }

protected:
    /**
     * @brief Logs given message with given severity, file name and line number.
     * 
     * Every class implementing the ILogger interface must implement this member function.
     * The efault implementation does nothing.
     * The level should be checked by caller, thus the implementation should expect that level <= min_level
     * 
     * @param level Severity of the log message.
     * @param file File name where the log message was recorded.
     * @param line Line number in the file where the log message was recorded.
     * @param msg The log message.
     */
    virtual void logMessage(LogLevel level, std::string_view file, int line, std::string_view msg) {}

    /**
     * @brief Minimum level of log messages to log.
     */
    LogLevel min_level = LEVEL_WARNING;
};

}
