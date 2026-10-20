cmake_minimum_required(VERSION 4.0 FATAL_ERROR)

include(cmake/CPM.cmake)

# ==========================
#	Workspace/root setup
# ==========================
project(Hazel LANGUAGES CXX)

# Global configuration defaults
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# staticruntime setting
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# Configure default build types (single-config generators)
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
	set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose build type" FORCE)
endif()

# Different project versions
set(CMAKE_CONFIGURATION_TYPES "Debug;Release;Dist" CACHE STRING "" FORCE)

# ==========================
#	Output directory tokens
# ==========================
set(CONFIG_NAME "$<LOWER_CASE:$<CONFIG>>")
set(SYSTEM_NAME "$<LOWER_CASE:$<PLATFORM_ID>>")

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ARCH_NAME "x64")
else()
    set(ARCH_NAME "x86")
    message(FATAL_ERROR "This project must be compiled as a 64-bit (x64) application! Please reconfigure your generator.")
endif()

# creates output dir string
set(OUTPUT_DIR "${CONFIG_NAME}-${SYSTEM_NAME}-${ARCH_NAME}/$<0:>")


# ==========================
#	HAZEL engine library
# ==========================
set(ENGINE_PROJECT_NAME "Hazel")

# Dependency setup
CPMAddPackage(
	NAME spdlog
	SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${ENGINE_PROJECT_NAME}/vendor/spdlog"
)

# Set up
file(GLOB_RECURSE HAZEL_SOURCES
	"${CMAKE_CURRENT_SOURCE_DIR}/${ENGINE_PROJECT_NAME}/src/*.h"
	"${CMAKE_CURRENT_SOURCE_DIR}/${ENGINE_PROJECT_NAME}/src/*.cpp"
)

# Create Hazel shared library
add_library(Hazel SHARED ${HAZEL_SOURCES})

# Optimize/symbols for the different version releases
target_compile_options(Hazel PRIVATE
    $<$<CONFIG:Debug>:$<IF:$<CXX_COMPILER_ID:MSVC>,/Zi,-g>>
    $<$<OR:$<CONFIG:Release>,$<CONFIG:Dist>>:$<IF:$<CXX_COMPILER_ID:MSVC>,/O2 /Oi /Ot /Z7,-O3 -g>>
)

set_target_properties(Hazel PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/${OUTPUT_DIR}/${ENGINE_PROJECT_NAME}"
	LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/${OUTPUT_DIR}/${ENGINE_PROJECT_NAME}"
	ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/${OUTPUT_DIR}/${ENGINE_PROJECT_NAME}"
)

# Include base folder for referencing
target_include_directories(
	Hazel PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Hazel/src>
)

# Link spdlog library link
target_link_libraries(
	Hazel PUBLIC spdlog::spdlog
)

# Version config mapping
target_compile_definitions(Hazel PRIVATE
	$<$<PLATFORM_ID:Windows>:HZ_PLATFORM_WINDOWS>
	$<$<PLATFORM_ID:Windows>:HZ_BUILD_DLL>
	$<$<CONFIG:Debug>:HZ_DEBUG>
	$<$<CONFIG:Release>:HZ_RELEASE>
	$<$<CONFIG:Dist>:HZ_DIST>
)

# =================================
#	sandbox application set up
# =================================
set(SANDBOX_NAME "Sandbox")
file(GLOB_RECURSE SANDBOX_SOURCES
	"${CMAKE_CURRENT_SOURCE_DIR}/${SANDBOX_NAME}/src/*.h"
	"${CMAKE_CURRENT_SOURCE_DIR}/${SANDBOX_NAME}/src/*.cpp"
)
add_executable(Sandbox ${SANDBOX_SOURCES})

# Optimize/symbols for version releases
target_compile_options(Sandbox PRIVATE
    $<$<CONFIG:Debug>:$<IF:$<CXX_COMPILER_ID:MSVC>,/Zi,-g>>
    $<$<OR:$<CONFIG:Release>,$<CONFIG:Dist>>:$<IF:$<CXX_COMPILER_ID:MSVC>,/O2 /Oi /Ot /Z7,-O3 -g>>
)

# Get output directory
set_target_properties(Sandbox PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/${OUTPUT_DIR}/${SANDBOX_NAME}"
)

# Dependency link to Hazel
target_link_libraries(Sandbox PRIVATE Hazel)

target_compile_definitions(Sandbox PRIVATE
	$<$<PLATFORM_ID:Windows>:HZ_PLATFORM_WINDOWS>
	$<$<CONFIG:Debug>:HZ_DEBUG>
	$<$<CONFIG:Release>:HZ_RELEASE>
	$<$<CONFIG:Dist>:HZ_DIST>
)

target_include_directories(Sandbox PRIVATE
	"${CMAKE_CURRENT_SOURCE_DIR}/${ENGINE_PROJECT_NAME}/src"
)

# Configuration mapping
target_compile_definitions(Sandbox PRIVATE
	$<$<PLATFORM_ID:Windows>:HZ_PLATFORM_WINDOWS>
	$<$<CONFIG:Debug>:HZ_DEBUG>
	$<$<CONFIG:Release>:HZ_RELEASE>
	$<$<CONFIG:Dist>:HZ_DIST>
)


# Copies hazel library files into sandbox
add_custom_command(TARGET Sandbox POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:Hazel>"
        "$<TARGET_FILE_DIR:Sandbox>/"
    COMMENT "Copying Hazel dynamic library to Sandbox executable folder..."
)