#!/usr/bin/env bash

set -eo pipefail

BUILD_DIR="${1:-build}"
GENERATOR="Ninja"
BUILD_TYPE="Release"

cmake -B"$BUILD_DIR" \
    -S . -DCMAKE_BUILD_TYPE="$BUILD_TYPE"\
    -G"$GENERATOR"\
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    
# We need to build the project at least once to generate some of the source files.
cmake --build "$BUILD_DIR" 

FILES=(
    "third_party/converter/pyconverter.cc"
    "win/rl/pynethack.cc"
)

printf '%s\n' "${FILES[@]}" | xargs clang-tidy -p "$BUILD_DIR" \
    -header-filter='' \
    -extra-arg='-isysroot' \
    -extra-arg="-I$(clang -print-resource-dir)/include" \
    --fix-errors
