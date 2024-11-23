# CMakeLists.txt for the #3081 drone project 
# by Blane Herndon

# Openssl and libwebsockets are required for this project
# CMake variables for OpenSSL: https://cmake.org/cmake/help/latest/module/FindOpenSSL.html

cmake_minimum_required(VERSION 3.14)
project(transit_service)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set C++ Standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set the desired port for localhost
set(PORT 8081)

# Find OpenSSL
find_package(OpenSSL REQUIRED)

# Platform-specific OpenSSL and library configurations
if (APPLE)
    set(OPENSSL_INCLUDE_DIR "/opt/homebrew/include/openssl")
    set(OPENSSL_SSL_LIBRARY "/opt/homebrew/lib/libssl.dylib")
    set(OPENSSL_CRYPTO_LIBRARY "/opt/homebrew/lib/libcrypto.dylib")
    set(LIBWEBSOCKETS_INCLUDE_DIR "/opt/homebrew/include")
    set(LIBWEBSOCKETS_LIBRARY "/opt/homebrew/lib/libwebsockets.dylib")
elseif(UNIX AND NOT APPLE)
    # TODO: Add Linux-specific paths if needed
elseif(WIN32)
    # TODO: Add Windows-specific paths if needed
endif()

# Include directories
include_directories(
    dependencies/include
    dependencies/include/libwebsockets
    service/include/routing
    service/include/routing/parsers
    service/include/routing/strategy
    service/include/simulationmodel
    service/include/simulationmodel/entity
    service/include/simulationmodel/entity/decorator
    service/include/simulationmodel/factory
    service/include/simulationmodel/math
    service/include/simulationmodel/strategy
    service/include/simulationmodel/strategy/decorator
    service/include/simulationmodel/util
    service/include/simulationmodel/observer
)

# Add source files recursively
file(GLOB_RECURSE SOURCES "service/src/*.cc")

# Create the executable
add_executable(${PROJECT_NAME} ${SOURCES})

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE 
    ${OPENSSL_SSL_LIBRARY}
    ${OPENSSL_CRYPTO_LIBRARY}
    ${LIBWEBSOCKETS_LIBRARY}
)

# Include directories for linked libraries
target_include_directories(${PROJECT_NAME} PRIVATE
    ${OPENSSL_INCLUDE_DIR}
    ${LIBWEBSOCKETS_INCLUDE_DIR}
)

# Install and audit npm dependencies
add_custom_command(
    TARGET ${PROJECT_NAME} POST_BUILD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/web
    COMMAND npm install
    COMMAND npm run build
    COMMENT "Configuring front-end with npm"
)

# Run the transit_service executable on desired port
add_custom_target(run_app
    DEPENDS ${PROJECT_NAME} 
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMAND build/${PROJECT_NAME} ${PORT} web/dist
    COMMENT "Running transit service on http://localhost:${PORT}"
)

# Debug the transit_service executable on desired port
# Only works on x64
add_custom_target(debug
    DEPENDS ${PROJECT_NAME} 
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMAND gdb --args build/${PROJECT_NAME} ${PORT} web/dist
    COMMENT "Debugging transit service on http://localhost:${PORT}"
)
