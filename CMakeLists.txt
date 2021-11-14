cmake_minimum_required(VERSION 3.10.2)
project(libstoken C)

SET(LIBSTOKEN 0 CACHE BOOL "Build as library")
SET(CLISTOKEN 1 CACHE BOOL "Build as CLI")

if(${LIBSTOKEN})
    message("Building as library")
endif()
if(${CLISTOKEN})
    message("Building as cli")
endif()

if(NOT(${LIBSTOKEN}) AND NOT(${CLISTOKEN}))
    message(WARNING "Warning: You have opted to build neither the cli or library")
endif()

set(clistoken "stoken$ENV{SUFFIX}")
set(libstoken "libstoken$ENV{SUFFIX}")
set(libtommath "libtommath$ENV{SUFFIX}")
set(libtomcrypt "libtomcrypt$ENV{SUFFIX}")

set(CMAKE_STATIC_LIBRARY_PREFIX "")
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-O3")

include_directories(./libs/libtommath)
file(GLOB libtommath_sources ./libs/libtommath/*.c)
add_library(${libtommath} ${libtommath_sources})

include_directories(./libs/libtomcrypt/src/headers)
file(GLOB_RECURSE libtomcrypt_sources ./libs/libtomcrypt/src/*.c)
add_library(${libtomcrypt} ${libtomcrypt_sources})
add_definitions(-DUSE_LTM -DLTC_SOURCE -DLTM_DESC)
target_link_libraries(${libtomcrypt} ${libtommath})

find_package(LibXml2 REQUIRED)

file(GLOB sources ./src/*.c)
list(FILTER sources EXCLUDE REGEX ".*(gui.c|jni.c|stc-nettle.c)$")

if(${CLISTOKEN})
    add_executable(${clistoken} ${sources})
    target_link_libraries(${clistoken} ${libtomcrypt})
    target_link_libraries(${clistoken} ${LIBXML2_LIBRARIES})
endif()
if(${LIBSTOKEN})
    list(FILTER sources EXCLUDE REGEX ".*(cli.c)$")
    add_library(${libstoken} ${sources})
    target_link_libraries(${libstoken} ${libtomcrypt})
    target_link_libraries(${libstoken} ${LIBXML2_LIBRARIES})
endif()
