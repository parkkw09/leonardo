# includes
include(ExternalProject)

set(OPENSSL_BUILDER "${CMAKE_CURRENT_SOURCE_DIR}/cmake/builder/openssl")
set(CMAKE_MODULE_PATH "${OPENSSL_BUILDER}" "${CMAKE_MODULE_PATH}")

# set(OPENSSL_ROOT_DIR ${CMAKE_INSTALL_PREFIX})
# set(OPENSSL_LIBRARIES_DIR ${OPENSSL_ROOT_DIR}/${CMAKE_INSTALL_LIBDIR})
# set(OPENSSL_CRYPTO_LIBRARY ${OPENSSL_ROOT_DIR}/${CMAKE_INSTALL_LIBDIR})
# set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
# set(OPENSSL_LIBRARIES "${OPENSSL_LIBRARIES_DIR}/libssl.a" "${OPENSSL_LIBRARIES_DIR}/libcrypto.a")
# set(OPENSSL_LIBRARIES "ssl" "crypto")
set(OPENSSL_BUILD_VERSION "1.0.2q")
# LINK_DIRECTORIES(${OPENSSL_LIBRARIES_DIR})

# set(CONFIGURE_OPENSSL_MODULES no-cast no-md2 no-md4 no-mdc2 no-rc5 no-engine no-idea no-mdc2 no-rc5 no-camellia no-ssl3 no-heartbeats no-gost no-deprecated no-capieng no-comp no-dtls no-psk no-srp no-dso no-dsa no-rc2 no-des no-tests no-asm)
# set(CONFIGURE_OPENSSL_MODULES no-tests no-asm)
set(CONFIGURE_OPENSSL_MODULES no-shared)

set(OPENSSL_ARCH "")
set(PRE_BUILD "")
list(APPEND OPENSSL_CONFIGURE_OPTIONS "")
list(APPEND OPENSSL_BUILD_OPTIONS all install_sw)

if (ANDROID)
    set(OPENSSL_ARCH "android")
    set(PRE_BUILD ${OPENSSL_BUILDER}/pre_build_android.sh -t ${ANDROID_TOOLCHAIN_ROOT} -h ${ANDROID_TARGET_HOST} -a ${ANDROID_TARGET_HOST_API})
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
        set(SED_COMMAND "gsed")
    else()
        set(SED_COMMAND "sed")
    endif()

    list(APPEND OPENSSL_CONFIGURE_OPTIONS "-fPIC")
    list(APPEND OPENSSL_CONFIGURE_OPTIONS && ${SED_COMMAND} -i "s/-mandroid//g" Makefile)
elseif (IOS)
    if(LEONARDO_ARCH STREQUAL "x86")
        set(OPENSSL_ARCH "iossimulator-xcrun")
    elseif(LEONARDO_ARCH STREQUAL "x86_64")
        set(OPENSSL_ARCH "iossimulator-xcrun")
    elseif(LEONARDO_ARCH STREQUAL "armeabi-v7a")
        set(OPENSSL_ARCH "ios-cross")
    elseif(LEONARDO_ARCH STREQUAL "arm64-v8a")
        set(OPENSSL_ARCH "ios64-cross")
    else()
        message(FATAL_ERROR "Unknown LEONARDO_ARCH = [${LEONARDO_ARCH}]")
    endif()
    set(OPENSSL_BUILD_VERSION "1.1.1d")
    list(APPEND OPENSSL_CONFIGURE_OPTIONS "--prefix=${OUT_DIR}")
    # list(APPEND OPENSSL_BUILD_OPTIONS install_ssldirs)
    set(PRE_BUILD ${OPENSSL_BUILDER}/pre_build_ios.sh -t ${TOOLCHAIN_PATH} -p ${TOOLCHAIN_CROSS_TOP} -s ${TOOLCHAIN_CROSS_IPHONE_SDK})
endif()
 
# add openssl target
ExternalProject_Add(OPENSSL-EXTERNAL
    URL https://www.openssl.org/source/openssl-${OPENSSL_BUILD_VERSION}.tar.gz
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND cd <SOURCE_DIR> && source ${PRE_BUILD}
    CONFIGURE_COMMAND && ./Configure ${OPENSSL_ARCH} --openssldir=${OUT_DIR} ${CONFIGURE_OPENSSL_MODULES} ${OPENSSL_CONFIGURE_OPTIONS}
    BUILD_COMMAND cd <SOURCE_DIR> && source ${PRE_BUILD}
    BUILD_COMMAND && make ${OPENSSL_BUILD_OPTIONS}
    INSTALL_COMMAND ""
)