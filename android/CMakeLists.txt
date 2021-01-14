cmake_minimum_required(VERSION 3.6)

include("${CMAKE_CURRENT_SOURCE_DIR}/../cxx/CMakeLists.txt")

include_directories(../cxx/headers)

add_library( ffiqjs

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ../ios/Classes/ffi.cpp )

target_link_libraries( 
                       ffiqjs
                       quickjs
                     )