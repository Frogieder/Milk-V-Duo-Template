cmake_minimum_required(VERSION 3.15)
project(example C CXX)

# === User platform selection ===
# Uncomment ONLY ONE of the following lines to select target platform
# set(TARGET_PLATFORM "Duo")
# set(TARGET_PLATFORM "Duo256M")
set(TARGET_PLATFORM "DuoS")

set(TARGET_ARCHITECTURE "RISCV64")
# set(TARGET_ARCHITECTURE "ARM64"

# -- Set paths --
set(SCRIPT_DIR $ENV{MILK_V_PATH})
#set (SCRIPT_DIR "/home/EXAMPLE/PATH/duo-examples")
if(NOT SCRIPT_DIR)
    message(FATAL_ERROR "Environment variable MILK_V_PATH is not set.")
endif()
message("Detected MILK_V_PATH=${SCRIPT_DIR}")

set(HOST_TOOLS ${SCRIPT_DIR}/host-tools)
set(SYS_INC ${SCRIPT_DIR}/include/system)

# -- Set board-specific toolchain
if(TARGET_PLATFORM STREQUAL "Duo")
    set(SYS_LIB ${SCRIPT_DIR}/libs/system/musl_riscv64)
    set(TOOLCHAIN_DIR ${HOST_TOOLS}/gcc/riscv64-linux-musl-x86_64)
    set(TOOLCHAIN_PREFIX ${TOOLCHAIN_DIR}/bin/riscv64-unknown-linux-musl-)
    set(ARCH_CFLAGS "-mcpu=c906fdv -march=rv64imafdcv0p7xthead -mcmodel=medany -mabi=lp64d")
    set(ARCH_LDFLAGS "-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64")

elseif(TARGET_ARCHITECTURE STREQUAL "RISCV64")
    set(SYS_LIB ${SCRIPT_DIR}/libs/system/musl_riscv64)
    set(TOOLCHAIN_DIR ${HOST_TOOLS}/gcc/riscv64-linux-musl-x86_64)
    set(TOOLCHAIN_PREFIX ${TOOLCHAIN_DIR}/bin/riscv64-unknown-linux-musl-)
    set(ARCH_CFLAGS "-mcpu=c906fdv -march=rv64imafdcv0p7xthead -mcmodel=medany -mabi=lp64d")
    set(ARCH_LDFLAGS "-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64")

elseif(TARGET_ARCHITECTURE STREQUAL "ARM64")
    set(SYS_LIB ${SCRIPT_DIR}/libs/system/glibc_arm64)
    set(TOOLCHAIN_DIR ${HOST_TOOLS}/gcc/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu)
    set(TOOLCHAIN_PREFIX ${TOOLCHAIN_DIR}/bin/aarch64-linux-gnu-)
    set(ARCH_CFLAGS "-march=armv8-a")
    set(ARCH_LDFLAGS "")

else()
    message(FATAL_ERROR "TARGET_ARCHITECTURE is not set. Please uncomment one of the set(TARGET_ARCHITECTURE ...) lines.")
endif()

if(TARGET_PLATFORM STREQUAL "Duo")
    add_compile_definitions(BOARD_DUO=1)
    add_compile_definitions(BOARD_NAME="milkv_duo")
elseif (TARGET_PLATFORM STREQUAL "Duo256M")
    add_compile_definitions(BOARD_DUO256M=1)
    add_compile_definitions(BOARD_NAME="milkv_duo256m")
elseif (TARGET_PLATFORM STREQUAL "DuoS")
    add_compile_definitions(BOARD_DUOS=1)
    add_compile_definitions(BOARD_NAME="milkv_duos")
else ()
    message(FATAL_ERROR "TARGET_PLATFORM is not set. Please uncomment one of the set(TARGET_PLATFORM ...) lines.")
endif ()

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)

# -- Compiler & Linker Flags --
set(DEBUG_CFLAGS "-O3 -DNDEBUG")
set(CMAKE_C_FLAGS "${ARCH_CFLAGS} ${DEBUG_CFLAGS} -I${SYS_INC}")
set(CMAKE_EXE_LINKER_FLAGS "${ARCH_LDFLAGS} -L${SYS_LIB} -lwiringx")

# -- Source files --
file(GLOB SOURCES CONFIGURE_DEPENDS src/*.cpp src/*.c)

# -- Target --
add_executable(${PROJECT_NAME} ${SOURCES})

# -- Output path --
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# -- Print size --
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${TOOLCHAIN_PREFIX}size ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}
)
