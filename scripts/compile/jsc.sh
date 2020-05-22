#!/bin/bash -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)
source $SCRIPT_DIR/common.sh

CMAKE_FOLDER=$(cd $ANDROID_HOME/cmake && ls -1 | sort -r | head -1)
PATH=$TOOLCHAIN_DIR/bin:$ANDROID_HOME/cmake/$CMAKE_FOLDER/bin/:$PATH

CMAKE_FOLDER=${ANDROID_HOME}/cmake/${CMAKE_FOLDER}/bin

rm -rf $TARGETDIR/webkit/$CROSS_COMPILE_PLATFORM-${FLAVOR}
rm -rf $TARGETDIR/webkit/WebKitBuild
cd $TARGETDIR/webkit/Tools/Scripts

CMAKE_CXX_FLAGS=" \
$SWITCH_JSC_CFLAGS_COMPAT \
$JSC_CFLAGS \
$PLATFORM_CFLAGS \
-I$TARGETDIR/icu/source/i18n \
"

#todo, move c++_shared to c++_static
CMAKE_LD_FLAGS=" \
-latomic \
-lm \
-lc++_shared \
$JSC_LDFLAGS \
$PLATFORM_LDFLAGS \
"

#export AR=$CROSS_COMPILE_PLATFORM-ar
#export AS=$CROSS_COMPILE_PLATFORM-clang
#export CC=$CROSS_COMPILE_PLATFORM-clang
#export CXX=$CROSS_COMPILE_PLATFORM-clang++
#export LD=$CROSS_COMPILE_PLATFORM-ld
#export STRIP=$CROSS_COMPILE_PLATFORM-strip


if [[ "$BUILD_TYPE" = "Release" ]]
then
    BUILD_TYPE_CONFIG="--release"
    BUILD_TYPE_FLAGS=""
else
    BUILD_TYPE_CONFIG="--debug"
    BUILD_TYPE_FLAGS="-DDEBUG_FISSION=OFF"
fi

if [[ "$JSC_ARCH" = "x86" ]]
then
    JSC_FEATURE_FLAGS=" \
      -DENABLE_JIT=OFF \
      -DENABLE_C_LOOP=ON \
    "
else
    JSC_FEATURE_FLAGS=" \
      -DENABLE_JIT=ON \
      -DENABLE_C_LOOP=OFF \
    "
fi

$TARGETDIR/webkit/Tools/Scripts/build-webkit \
  --jsc-only \
  $BUILD_TYPE_CONFIG \
  --jit \
  "$SWITCH_BUILD_WEBKIT_OPTIONS_INTL" \
  --no-webassembly \
  --no-xslt \
  --no-netscape-plugin-api \
  --no-tools \
  --cmakeargs="-DCMAKE_MAKE_PROGRAM=${CMAKE_FOLDER}/ninja             \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake   \
  -DANDROID_ABI=${ANDROID_ABI}                                                \
  -DANDROID_NATIVE_API_LEVEL=${ANDROID_API}                               \
  $SWITCH_BUILD_WEBKIT_CMAKE_ARGS_COMPAT \
  -DWEBKIT_LIBRARIES_INCLUDE_DIR=$TARGETDIR/icu/source/common \
  -DWEBKIT_LIBRARIES_LINK_DIR=$TARGETDIR/icu/${CROSS_COMPILE_PLATFORM}-${FLAVOR}/lib \
  -DCMAKE_CXX_FLAGS='${CMAKE_CXX_FLAGS} $COMMON_CXXFLAGS $CMAKE_CXX_FLAGS' \
  -DCMAKE_C_FLAGS='${CMAKE_C_FLAGS} $CMAKE_CXX_FLAGS' \
  -DCMAKE_C_FLAGS_DEBUG='${DEBUG_SYMBOL_LEVEL}' \
  -DCMAKE_CXX_FLAGS_DEBUG='${DEBUG_SYMBOL_LEVEL}' \
  -DCMAKE_SHARED_LINKER_FLAGS='${CMAKE_SHARED_LINKER_FLAGS} $CMAKE_LD_FLAGS' \
  -DCMAKE_EXE_LINKER_FLAGS='${CMAKE_MODULE_LINKER_FLAGS} $CMAKE_LD_FLAGS' \
  -DCMAKE_VERBOSE_MAKEFILE=on \
  -DENABLE_API_TESTS=OFF \
  -DENABLE_SAMPLING_PROFILER=OFF \
  -DENABLE_DFG_JIT=OFF \
  -DENABLE_FTL_JIT=OFF \
  -DUSE_SYSTEM_MALLOC=OFF \
  -DJSC_VERSION=\"${JSC_VERSION}\" \
  $JSC_FEATURE_FLAGS \
  $BUILD_TYPE_FLAGS \
  "

cp $TARGETDIR/webkit/WebKitBuild/$BUILD_TYPE/lib/libjsc.so $INSTALL_DIR
mv $TARGETDIR/webkit/WebKitBuild $TARGETDIR/webkit/${CROSS_COMPILE_PLATFORM}-${FLAVOR}
