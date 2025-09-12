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

#ifndef __EXPORTS_H__
#define __EXPORTS_H__

#ifdef WIN32
  #include <winapifamily.h>
  #ifdef cdoc_STATIC
	    #define CDOC_EXPORT
  #elif defined(cdoc_EXPORTS)
	    #define CDOC_EXPORT __declspec(dllexport)
  #else
      #define CDOC_EXPORT __declspec(dllimport)
  #endif
  #if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)
	#define CDOC_DEPRECATED __declspec(deprecated)
  #else
	#define CDOC_DEPRECATED
  #endif
  #define CDOC_WARNING_PUSH __pragma(warning(push))
  #define CDOC_WARNING_POP __pragma(warning(pop))
  #define CDOC_WARNING_DISABLE_CLANG(text)
  #define CDOC_WARNING_DISABLE_GCC(text)
  #define CDOC_WARNING_DISABLE_MSVC(number) __pragma(warning(disable: number))
  #define STDCALL __stdcall
#else
  #define CDOC_EXPORT __attribute__ ((visibility("default")))
  #define CDOC_DEPRECATED __attribute__ ((__deprecated__))
  #define CDOC_DO_PRAGMA(text) _Pragma(#text)
  #define CDOC_WARNING_PUSH CDOC_DO_PRAGMA(GCC diagnostic push)
  #define CDOC_WARNING_POP CDOC_DO_PRAGMA(GCC diagnostic pop)
  #if __clang__
  #define CDOC_WARNING_DISABLE_CLANG(text) CDOC_DO_PRAGMA(clang diagnostic ignored text)
  #else
  #define CDOC_WARNING_DISABLE_CLANG(text)
  #endif
  #define CDOC_WARNING_DISABLE_GCC(text) CDOC_DO_PRAGMA(GCC diagnostic ignored text)
  #define CDOC_WARNING_DISABLE_MSVC(text)
  #define STDCALL
#endif

#define CDOC_DISABLE_MOVE(Class) \
    Class(Class&&) noexcept = delete; \
    Class& operator=(Class&&) noexcept = delete;
#define CDOC_DISABLE_COPY(Class) \
    Class(const Class&) noexcept = delete; \
    Class& operator=(const Class&) noexcept = delete;
#define CDOC_DISABLE_MOVE_COPY(Class) \
    CDOC_DISABLE_MOVE(Class) \
    CDOC_DISABLE_COPY(Class)

#endif // EXPOORTS_H
