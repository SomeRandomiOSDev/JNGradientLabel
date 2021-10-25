#!/usr/bin/env bash
#
# xcframework.sh
# Usage example: ./xcframework.sh -output <some_path>/JNGradientLabel.xcframework

# Parse Arguments

while [[ $# -gt 0 ]]; do
    case "$1" in
        -output)
        OUTPUT_DIR="$2"
        shift # -output
        shift # <output_dir>
        ;;

        -configuration)
        CONFIGURATION="$2"
        shift # -configuration
        shift # <configuration>
        ;;

        *)
        echo "Unknown argument: $1"
        echo "./xcframework.sh [-output <output_xcframework>]"]
        exit 1
    esac
done

if [ -z ${OUTPUT_DIR+x} ]; then
    OUTPUT_DIR="$(dirname "$0")/build/JNGradientLabel.xcframework"
fi

if [ -z ${CONFIGURATION+x} ]; then
    CONFIGURATION="Release"
fi

# Create Temporary Directory

TMPDIR=`mktemp -d /tmp/.jngradientlabel.xcframework.build.XXXXXX`
cd "$(dirname "$(dirname "$0")")"

check_result() {
    if [ $1 -ne 0 ]; then
        rm -rf "${TMPDIR}"
        exit $1
    fi
}

# Build iOS
xcodebuild -project "JNGradientLabel.xcodeproj" -scheme "JNGradientLabel" -destination "generic/platform=iOS" -archivePath "${TMPDIR}/iphoneos.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="armv7 armv7s arm64 arm64e" archive
check_result $?

# Build iOS Simulator
xcodebuild -project "JNGradientLabel.xcodeproj" -scheme "JNGradientLabel" -destination "generic/platform=iOS Simulator" -archivePath "${TMPDIR}/iphonesimulator.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="i386 x86_64 arm64" archive
check_result $?

# Build Mac Catalyst
xcodebuild -project "JNGradientLabel.xcodeproj" -scheme "JNGradientLabel" -destination "generic/platform=macOS,variant=Mac Catalyst" -archivePath "${TMPDIR}/maccatalyst.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="x86_64 arm64 arm64e" archive
check_result $?

# Build tvOS
xcodebuild -project "JNGradientLabel.xcodeproj" -scheme "JNGradientLabel tvOS" -destination "generic/platform=tvOS" -archivePath "${TMPDIR}/appletvos.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="arm64 arm64e" archive
check_result $?

# Build tvOS Simulator
xcodebuild -project "JNGradientLabel.xcodeproj" -scheme "JNGradientLabel tvOS" -destination "generic/platform=tvOS Simulator" -archivePath "${TMPDIR}/appletvsimulator.xcarchive" -configuration ${CONFIGURATION} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ONLY_ACTIVE_ARCH=NO ARCHS="x86_64 arm64" archive
check_result $?

# Make XCFramework

if [[ -d "${OUTPUT_DIR}" ]]; then
    rm -rf "${OUTPUT_DIR}"
fi

ARGUMENTS=(-create-xcframework -output "${OUTPUT_DIR}")

for ARCHIVE in ${TMPDIR}/*.xcarchive; do
    ARGUMENTS=(${ARGUMENTS[@]} -framework "${ARCHIVE}/Products/Library/Frameworks/JNGradientLabel.framework")

    if [[ -d "${ARCHIVE}/dSYMs/JNGradientLabel.framework.dSYM" ]]; then
        ARGUMENTS=(${ARGUMENTS[@]} -debug-symbols "${ARCHIVE}/dSYMs/JNGradientLabel.framework.dSYM")
    fi

    if [[ -d "${ARCHIVE}/BCSymbolMaps" ]]; then
        for SYMBOLMAP in ${ARCHIVE}/BCSymbolMaps/*.bcsymbolmap; do
            ARGUMENTS=(${ARGUMENTS[@]} -debug-symbols "${SYMBOLMAP}")
        done
    fi
done

xcodebuild "${ARGUMENTS[@]}"
check_result $?

# Cleanup

rm -rf "${TMPDIR}"
exit 0
