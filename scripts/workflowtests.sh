#!/usr/bin/env bash
#
# workflowtests.sh
# Usage example: ./workflowtests.sh --no-clean

# Set Script Variables

SCRIPT="$("$(dirname "$0")/resolvepath.sh" "$0")"
SCRIPTS_DIR="$(dirname "$SCRIPT")"
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"
CURRENT_DIR="$(pwd -P)"

EXIT_CODE=0
EXIT_MESSAGE=""

# Help

function print_help() {
    local HELP="workflowtests.sh [--help | -h] [--project-name <project_name>]\n"
    HELP+="                 [--no-clean | --no-clean-on-fail]\n"
    HELP+="                 [--is-running-in-temp-env]\n"
    HELP+="\n"
    HELP+="--help, -h)               Print this help message and exit.\n"
    HELP+="\n"
    HELP+="--project-name)           The name of the project to run tests against. If not\n"
    HELP+="                          provided it will attempt to be resolved by searching\n"
    HELP+="                          the working directory for an Xcode project and using\n"
    HELP+="                          its name.\n"
    HELP+="\n"
    HELP+="--no-clean)               When not running in a temporary environment, do not\n"
    HELP+="                          clean up the temporary project created to run these\n"
    HELP+="                          tests upon completion.\n"
    HELP+="\n"
    HELP+="--no-clean-on-fail)       Same as --no-clean with the exception that if the\n"
    HELP+="                          succeed clean up will continue as normal. This is\n"
    HELP+="                          mutually exclusive with --no-clean with --no-clean\n"
    HELP+="                          taking precedence.\n"
    HELP+="--is-running-in-temp-env) Setting this flag tells this script that the\n"
    HELP+="                          environment (directory) in which it is running is a\n"
    HELP+="                          temporary environment and it need not worry about\n"
    HELP+="                          dirtying up the directory or creating/deleting files\n"
    HELP+="                          and folders. USE CAUTION WITH THIS OPTION.\n"
    HELP+="\n"
    HELP+="                          When this flag is NOT set, a copy of the containing\n"
    HELP+="                          working folder is created in a temporary location and\n"
    HELP+="                          removed (unless --no-clean is set) after the tests\n"
    HELP+="                          have finished running."

    IFS='%'
    echo -e $HELP
    unset IFS

    exit 0
}

# Parse Arguments

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-name)
        PROJECT_NAME="$2"
        shift # --project-name
        shift # <project_name>
        ;;

        --is-running-in-temp-env)
        IS_RUNNING_IN_TEMP_ENV=1
        shift # --is-running-in-temp-env
        ;;

        --no-clean)
        NO_CLEAN=1
        shift # --no-clean
        ;;

        --no-clean-on-fail)
        NO_CLEAN_ON_FAIL=1
        shift # --no-clean-on-fail
        ;;

        --help | -h)
        print_help
        ;;

        *)
        echo "Unknown argument: $1"
        print_help
    esac
done

if [ -z ${PROJECT_NAME+x} ]; then
    PROJECTS=$(ls "$ROOT_DIR" | grep \.xcodeproj$)

    if [ "${#PROJECTS[@]}" == "0" ]; then
        echo "No Xcode projects found in root directory. Try specifying a project name:"
        print_help
    elif [ "${#PROJECTS[@]}" == "1" ]; then
        PROJECT_NAME="${PROJECTS[0]}"
        PROJECT_NAME="${PROJECT_NAME%.*}"
    else
        echo "More than 1 Xcode projects found in root directory. Specify which project to run tests against:"
        print_help
    fi
elif [ ! -e "$ROOT_DIR/$PROJECT_NAME.xcodeproj" ]; then
    echo "Unable to locate Xcode project to run tests against: $ROOT_DIR/$PROJECT_NAME.xcodeproj"
    print_help
fi

if [ -z ${IS_RUNNING_IN_TEMP_ENV+x} ]; then
    IS_RUNNING_IN_TEMP_ENV=0
fi

if [ -z ${NO_CLEAN+x} ]; then
    NO_CLEAN=0
fi

if [ -z ${NO_CLEAN_ON_FAIL+x} ]; then
    NO_CLEAN_ON_FAIL=0
fi

# Function Definitions

function cleanup() {
    if [ "$IS_RUNNING_IN_TEMP_ENV" == "0" ]; then
        if [[ "$NO_CLEAN" == "1" ]] || [[ "$NO_CLEAN_ON_FAIL" == "1" && "$EXIT_CODE" != "0" ]]; then
            echo "Test Project: $OUTPUT_DIR"
        else
            cd "$CURRENT_DIR"
            rm -rf "$TEMP_DIR"
        fi
    fi

    #

    local CARTHAGE_CACHE="$HOME/Library/Caches/org.carthage.CarthageKit"
    if [ -e "$CARTHAGE_CACHE" ]; then
        if [ -e "$CARTHAGE_CACHE/dependencies/$PROJECT_NAME" ]; then
            rm -rf "$CARTHAGE_CACHE/dependencies/$PROJECT_NAME"
        fi

        for DIR in $(find "$CARTHAGE_CACHE/DerivedData" -mindepth 1 -maxdepth 1 -type d); do
            if [ -e "$DIR/$PROJECT_NAME" ]; then
                rm -rf "$DIR/$PROJECT_NAME"
            fi
        done
    fi

    #

    if [ ${#EXIT_MESSAGE} -gt 0 ]; then
        echo -e "$EXIT_MESSAGE"
    fi

    exit $EXIT_CODE
}

function checkresult() {
    if [ "$1" != "0" ]; then
        EXIT_MESSAGE="\033[31m$2\033[0m"
        EXIT_CODE=$1

        cleanup
    fi
}

function printstep() {
    echo -e "\033[32m$1\033[0m"
}

function setuptemp() {
    local TEMP_DIR="$(mktemp -d)"
    local TEMP_NAME="$(basename "$(mktemp -u "$TEMP_DIR/${PROJECT_NAME}Tests_XXXXXX")")"
    local OUTPUT_DIR="$TEMP_DIR/$TEMP_NAME"

    cp -R "$ROOT_DIR" "$OUTPUT_DIR"
    if [ "$?" != "0" ]; then exit $?; fi

    if [ -e "$OUTPUT_DIR/.build" ]; then
        rm -rf "$OUTPUT_DIR/.build"
    fi
    if [ -e "$OUTPUT_DIR/.swiftpm" ]; then
        rm -rf "$OUTPUT_DIR/.swiftpm"
    fi

    echo "$OUTPUT_DIR"
}

# Setup

if [ "$IS_RUNNING_IN_TEMP_ENV" == "1" ]; then
    OUTPUT_DIR="$ROOT_DIR"
else
    OUTPUT_DIR="$(setuptemp)"
    echo -e "Testing from Temporary Directory: \033[33m$OUTPUT_DIR\033[0m"
fi

# Check For Dependencies

cd "$OUTPUT_DIR"
printstep "Checking for Test Dependencies..."

### Carthage

if which carthage >/dev/null; then
    CARTHAGE_VERSION="$(carthage version)"
    echo "Carthage: $CARTHAGE_VERSION"

    "$SCRIPTS_DIR/versions.sh" "$CARTHAGE_VERSION" "0.37.0"

    if [ $? -lt 0 ]; then
        echo -e "\033[33mCarthage version of at least 0.37.0 is recommended for running these unit tests\033[0m"
    fi
else
    checkresult -1 "Carthage is not installed and is required for running unit tests: \033[4;34mhttps://github.com/Carthage/Carthage#installing-carthage"
fi

### CocoaPods

if which pod >/dev/null; then
    PODS_VERSION="$(pod --version)"
    "$SCRIPTS_DIR/versions.sh" "$PODS_VERSION" "1.7.3"

    if [ $? -ge 0 ]; then
        echo "CocoaPods: $(pod --version)"
    else
        checkresult -1 "These unit tests require version 1.7.3 or later of CocoaPods: \033[4;34mhttps://guides.cocoapods.org/using/getting-started.html#updating-cocoapods"
    fi
else
    checkresult -1 "CocoaPods is not installed and is required for running unit tests: \033[4;34mhttps://guides.cocoapods.org/using/getting-started.html#installation"
fi

# Run Tests

printstep "Running Tests..."

### Carthage Workflow

printstep "Testing 'carthage.yml' Workflow..."

git add .
git commit -m "Commit" --no-gpg-sign
git tag | xargs git tag -d
git tag --no-sign 1.0
checkresult $? "'Create Cartfile' step of 'carthage.yml' workflow failed."

echo "git \"file://$OUTPUT_DIR\"" > ./Cartfile

./scripts/carthage.sh update
checkresult $? "'Build' step of 'carthage.yml' workflow failed."

printstep "'carthage.yml' Workflow Tests Passed\n"

### CocoaPods Workflow

printstep "Testing 'cocoapods.yml' Workflow..."

pod lib lint
checkresult $? "'Lint (Dynamic Library)' step of 'cocoapods.yml' workflow failed."

pod lib lint --use-libraries
checkresult $? "'Lint (Static Library)' step of 'cocoapods.yml' workflow failed."

printstep "'cocoapods.yml' Workflow Tests Passed\n"

### XCFramework Workflow

printstep "Testing 'xcframework.yml' Workflow..."

./scripts/xcframework.sh -output "./$PROJECT_NAME.xcframework"
checkresult $? "'Build' step of 'xcframework.yml' workflow failed."

printstep "'xcframework.yml' Workflow Tests Passed\n"

### Upload Assets Workflow

printstep "Testing 'upload-assets.yml' Workflow..."

zip -rX "$PROJECT_NAME.xcframework.zip" "$PROJECT_NAME.xcframework"
checkresult $? "'Create Zip' step of 'upload-assets.yml' workflow failed."

tar -zcvf "$PROJECT_NAME.xcframework.tar.gz" "$PROJECT_NAME.xcframework"
checkresult $? "'Create Tar' step of 'upload-assets.yml' workflow failed."

printstep "'upload-assets.yml' Workflow Tests Passed\n"

### Xcodebuild Workflow

printstep "Testing 'xcodebuild.yml' Workflow..."

xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME" -destination "generic/platform=iOS" -configuration Debug
checkresult $? "'Build iOS' step of 'xcodebuild.yml' workflow failed."

xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME" -destination "generic/platform=iOS Simulator" -configuration Debug
checkresult $? "'Build iOS Simulator' step of 'xcodebuild.yml' workflow failed."

###

xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME" -destination "generic/platform=macOS,variant=Mac Catalyst" -configuration Debug
checkresult $? "'Build MacCatalyst' step of 'xcodebuild.yml' workflow failed."

###

xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME tvOS" -destination "generic/platform=tvOS" -configuration Debug
checkresult $? "'Build tvOS' step of 'xcodebuild.yml' workflow failed."

xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME tvOS" -destination "generic/platform=tvOS Simulator" -configuration Debug
checkresult $? "'Build tvOS Simulator' step of 'xcodebuild.yml' workflow failed."

printstep "'xcodebuild.yml' Workflow Tests Passed\n"

### Success

cleanup
