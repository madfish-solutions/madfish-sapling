#!/bin/bash

function help () {
  echo "Build the FFI."
  echo
  echo "Usage: build-ffi [option]"
  echo "Options:"
  echo "  -h, --help    show help text"
  echo
}

while [ -n "$1" ]; do

  case "$1" in
  -h|--help) 
    help
    exit
    ;;
  esac

  shift

done

ARM_64=arm64
X86_64=x86_64
ARM_64_SIMULATOR=arm64-sim

CURR_DIR=${BASH_SOURCE[0]%/build-ffi.sh}
CORE_MANIFEST_PATH="$CURR_DIR/../sapling/Cargo.toml"

function ios_target () {
  case $1 in
    "$ARM_64")
      echo ios-arm64
      ;;
    "$ARM_64_SIMULATOR" | "$X86_64")
      echo ios-arm64_x86_64-simulator
      ;;
    *)
      echo "Error: Unknown iOS target."
      exit 1
      ;;
  esac
}

function rust_target () {
  case $1 in
    "$ARM_64")
      echo aarch64-apple-ios
      ;;
    "$ARM_64_SIMULATOR")
      echo aarch64-apple-ios-sim
      ;;
    "$X86_64")
      echo x86_64-apple-ios
      ;;
    *)
      echo "Error: Unknown Rust target."
      exit 1
      ;;
  esac
}

function add_target () {
    rustup target add "$(rust_target "$1")"
  }

function manual_build () {
  ### CHECK begin ###

  echo "Checking the environment..."

  echo "  [commands]"
  if which xcode-select >/dev/null; then
    echo -e "    \xE2\x9C\x94 xcode-select"
  else
    echo -e "    \xE2\x9C\x97 xcode-select"
    ERROR="xcode-select could not been found"
  fi

  if which xcodebuild >/dev/null; then
    echo -e "    \xE2\x9C\x94 xcodebuild"
  else
    echo -e "    \xE2\x9C\x97 xcodebuild"
    ERROR="xcode-select could not been found"
  fi

  if which rustup >/dev/null; then
    echo -e "    \xE2\x9C\x94 rustup"
  else
    echo -e "    \xE2\x9C\x97 rustup"
    ERROR="rustup could not been found"
  fi

  if which rustc >/dev/null; then
    echo -e "    \xE2\x9C\x94 rustc"
  else
    echo -e "    \xE2\x9C\x97 rustc"
    ERROR="rustc could not been found"
  fi

  if which cargo >/dev/null; then
    echo -e "    \xE2\x9C\x94 cargo-lipo"
  else
    echo -e "    \xE2\x9C\x97 cargo-lipo"
    ERROR="cargo-lipo could not been found"
  fi

  if [[ -n "${ERROR}" ]]; then
    echo "Error: $ERROR."
    exit 1
  fi

  ### CHECK end ###

  ### SETUP COMPILE begin ###

  echo -e "\nSetting up compile targets..."

  echo "  Adding Rust targets..."
  add_target $ARM_64
  add_target $X86_64
  add_target $ARM_64_SIMULATOR

  ### SETUP COMPILE end ###

  ### COMPILE begin ###

  echo -e "\nCompiling..."

  function build () {
    local target

    target=$(rust_target "$1")
    echo "  RUSTFLAGS='cargo build --manifest-path $CORE_MANIFEST_PATH --release --features \"c_bindings\" --target $target"

    cargo build --manifest-path "$CORE_MANIFEST_PATH" --release --features "c_bindings" --target "$target"
  }

  build $ARM_64
  build $X86_64
  build $ARM_64_SIMULATOR

  ### COMPILE end ###
}

function create_framework () {
  ### CREATE XCFRAMEWORK begin ###

  echo -e "\nCreating XCFramework..."

  LIB_NAME=$(grep -o "name\s\+.\+" "$CORE_MANIFEST_PATH" | awk '{ print $3 }' | sed -e 's/^"//' -e 's/"$//')

  INCLUDE_DIR="$CURR_DIR/../sapling/include"
  TARGET_DIR="$CURR_DIR/../../target"

  XCFRAMEWORK_DIR=$CURR_DIR/SaplingFFI.xcframework
  rm -rf $XCFRAMEWORK_DIR

  lipo -create \
  "$TARGET_DIR/$(rust_target "$X86_64")/release/lib$LIB_NAME.a" \
  "$TARGET_DIR/$(rust_target "$ARM_64_SIMULATOR")/release/lib$LIB_NAME.a" \
  -output /tmp/lib${LIB_NAME}_simulator.a

  xcodebuild -create-xcframework \
  -library "$TARGET_DIR/$(rust_target "$ARM_64")/release/lib$LIB_NAME.a" \
  -headers "$INCLUDE_DIR" \
  -library "/tmp/lib${LIB_NAME}_simulator.a" \
  -headers "$INCLUDE_DIR" \
  -output "$XCFRAMEWORK_DIR"

  function create_module () {
    local module_map_path

    module_map_path=$(ios_target "$1")/Headers/module.modulemap
    if printf "%s\n" \
      "module SaplingFFI {" \
      "$(echo -e "\theader \"madfish_sapling.h\"")" \
      "$(echo -e "\texport *")" \
      "}" > "$XCFRAMEWORK_DIR/$module_map_path"; then
      echo -e "  \xE2\x9C\x94 $1 module map ($module_map_path)"
    else
      echo -e "  \xE2\x9C\x97 $1 module map"
      exit 1
    fi
  }

  create_module $ARM_64
  create_module $X86_64
  create_module $ARM_64_SIMULATOR

  ### CREATE XCFRAMEWORK end ###
}

manual_build
create_framework

echo -e "\nDone."
