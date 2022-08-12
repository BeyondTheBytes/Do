#!/bin/sh

# example:
# ./scripts/build.sh prod ios

function build {
    echo "Building for $file"

    if [[ $1 == "ios" ]]; then
        flutter build ipa --release
    elif [[ $1 == "android" ]]; then
        flutter build appbundle --release
    else
        echo "No '$1' mode available. Choose either 'ios' or 'android'"
        exit 1
    fi

    echo "Build $1 $(date)" >> builds.txt
}

function test {
    if [[ $1 == "--no-test" ]]; then
        echo "Skiping tests..."
        return 0
    else
        echo "Testing all the packages..."
        flutter test
    fi
}

test $3 &&
echo "Building..." &&
build $1 $2
