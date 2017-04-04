#!/bin/bash

#
#  Build Script for RenderZenith Kernel for OnePlus 3!
#  Based off AK's build script - Thanks!
#

# Bash Color
rm .version
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL_IMAGE="Image.gz-dtb"
DEFCONFIG="zenith_oneplus3_defconfig"
DTBIMAGE="dtb"

# Kernel Details
KERNEL=RenderZenith
DEVICE="OP3"
VERSION="008"
RELEASE="${KERNEL}.${DEVICE}.EAS.${VERSION}"

# Vars
TOOLCHAIN_DIR="${HOME}/vertex/prebuilts/gcc/linux-x86/aarch64"
export CROSS_COMPILE="$TOOLCHAIN_DIR/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=joshuous
export KBUILD_BUILD_HOST=vertexos
export CCACHE=ccache

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/kernel/AnyKernel2"
PATCH_DIR="${HOME}/kernel/AnyKernel2/patch"
MODULES_DIR="${HOME}/kernel/AnyKernel2/modules/"
ZIP_MOVE="${HOME}/kernel/zips"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"

# Functions
function clean_all {
    cd $REPACK_DIR
    if [ -f "$MODULES_DIR/*.ko" ]; then
      rm `echo $MODULES_DIR"/*.ko"`
    fi
    rm -rf $KERNEL_IMAGE
    rm -rf $DTBIMAGE
    rm -rf zImage
    cd $KERNEL_DIR
    echo
    make clean && make mrproper
}

function make_kernel {
    echo
    make $DEFCONFIG
    make $THREAD
    cp -vr $ZIMAGE_DIR/$KERNEL_IMAGE $REPACK_DIR/zImage
}

function make_modules {
    if [ -f "$MODULES_DIR/*.ko" ]; then
      rm `echo $MODULES_DIR"/*.ko"`
    fi
    find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_dtb {
    $REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm64/boot/
}

function make_zip {
    cd $REPACK_DIR
    zip -r9 "$RELEASE"-"$(date -u +%Y%m%d)".zip *
    mv "$RELEASE"-"$(date -u +%Y%m%d)".zip $ZIP_MOVE
    cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "Zenith Kernel Creation Script:"
echo -e "${restore}"

echo "---------------"
echo "Kernel Version:"
echo "---------------"

echo -e "${red}"; echo "$RELEASE"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making Zenith Kernel:"
echo "-----------------"
echo -e "${restore}"

echo "Pick Toolchain..."
select choice in default LINARO-aarch64-linux-gnu-6.x 
do
case "$choice" in
  "default")
    break;;
  "LINARO-aarch64-linux-gnu-6.x")
    export CROSS_COMPILE="$TOOLCHAIN_DIR/aarch64-linux-gnu-6.x-kernel-linaro/bin/aarch64-linux-gnu-"
    RELEASE="${RELEASE}-LINARO-6.x"
    break;;
esac
done

# Export local version
export CONFIG_LOCALVERSION=~`echo -$RELEASE`

while read -p "Do you want to clean stuff (y/n)? " cchoice
do
case "$cchoice" in
  y|Y )
    clean_all
    echo
    echo "All Cleaned now."
    break
    ;;
  n|N )
    break
    ;;
  * )
    echo
    echo "Invalid try again!"
    echo
    ;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
  y|Y)
    make_kernel
    make_modules
    make_dtb
    break
    ;;
  n|N )
    break
    ;;
  * )
    echo
    echo "Invalid try again!"
    echo
    ;;
esac
done

while read -p "Do you want to ZIP kernel (y/n)? " dchoice
do
case "$dchoice" in
  y|Y)
    make_zip
    break
    ;;
  n|N )
    break
    ;;
  * )
    echo
    echo "Invalid try again!"
    echo
    ;;
esac
done

while read -p "Do you want to clean stuff again (y/n)? " cchoice
do
  case "$cchoice" in
    y|Y )
      clean_all
      echo
      echo "All Cleaned now."
      break
      ;;
    n|N )
      break
      ;;
    * )
      echo
      echo "Invalid try again!"
      echo
      ;;
  esac
done

echo ""
echo "Generating changelog..."
echo ""
./changelog.sh

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
