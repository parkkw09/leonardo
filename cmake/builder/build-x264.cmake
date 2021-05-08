# includes
include(ExternalProject)

set(PRE_BUILDER "${CMAKE_CURRENT_SOURCE_DIR}/cmake/builder/prebuild")
set(CMAKE_MODULE_PATH "${PRE_BUILDER}" "${CMAKE_MODULE_PATH}")

set(X264_ARCH "")
set(PRE_BUILD "")
list(APPEND X264_CONFIGURE_OPTIONS "")
list(APPEND X264_BUILD_OPTIONS all install)

if (ANDROID)
    set(X264_ARCH "android")
    set(PRE_BUILD ${PRE_BUILDER}/pre_build_android.sh -t ${ANDROID_TOOLCHAIN_ROOT} -h ${ANDROID_TARGET_HOST} -a ${ANDROID_TARGET_HOST_API})
elseif (IOS)
    if(LEONARDO_ARCH STREQUAL "x86")
        set(X264_ARCH "iossimulator-xcrun")
    elseif(LEONARDO_ARCH STREQUAL "x86_64")
        set(X264_ARCH "iossimulator-xcrun")
    elseif(LEONARDO_ARCH STREQUAL "armeabi-v7a")
        set(X264_ARCH "ios-cross")
    elseif(LEONARDO_ARCH STREQUAL "arm64-v8a")
        set(X264_ARCH "ios64-cross")
    else()
        message(FATAL_ERROR "Unknown LEONARDO_ARCH = [${LEONARDO_ARCH}]")
    endif()
    set(X264_BUILD_VERSION "1.1.1d")
    list(APPEND X264_CONFIGURE_OPTIONS "--prefix=${OUT_DIR}")
    # list(APPEND X264_BUILD_OPTIONS install_ssldirs)
    set(PRE_BUILD ${X264_BUILDER}/pre_build_ios.sh -t ${TOOLCHAIN_PATH} -p ${TOOLCHAIN_CROSS_TOP} -s ${TOOLCHAIN_CROSS_IPHONE_SDK})
endif()
 
# add X264 target
ExternalProject_Add(X264-EXTERNAL
    GIT_REPOSITORY "https://code.videolan.org/videolan/x264.git" 
    UPDATE_COMMAND ""
    # CONFIGURE_COMMAND cd <SOURCE_DIR> && source ${PRE_BUILD}
    CONFIGURE_COMMAND cd <SOURCE_DIR>
    CONFIGURE_COMMAND && ./Configure --host=${ANDROID_TARGET_HOST} --sysroot=${ANDROID_TOOLCHAIN_ROOT} --prefix=${OUT_DIR} --enable-pic --enable-static --enable-strip --disable-cli --disable-win32thread --disable-avs --disable-swscale --disable-lavf --disable-ffms --disable-gpac --disable-lsmash
    BUILD_COMMAND cd <SOURCE_DIR> && source ${PRE_BUILD}
    BUILD_COMMAND && make ${X264_BUILD_OPTIONS}
    INSTALL_COMMAND ""
)