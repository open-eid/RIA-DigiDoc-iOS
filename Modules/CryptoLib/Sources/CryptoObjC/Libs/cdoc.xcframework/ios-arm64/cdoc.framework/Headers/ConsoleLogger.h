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

#include "ILogger.h"

#include <iostream>

namespace libcdoc
{

/**
 * @brief Console logger
 *
 * An ILogger subclass that logs text to console.
 *
 * Info messages are logged to cout, all others to cerr.
 */
class ConsoleLogger : public ILogger
{
public:
    virtual void LogMessage(LogLevel level, std::string_view file, int line, std::string_view message) override
    {
        // We ignore by default the file name and line number, and call LogMessage with the level and message.
        if (level <= minLogLevel)
        {
            std::ostream& ofs = (level == LEVEL_INFO) ? std::cout : std::cerr;
            ofs << message << '\n';
        }
    }
};


}
