#!/usr/bin/env bats

setup() {
  unset ORB_UTILS_DETECT_OS_VERBOSE
  unset ORB_UTILS_DETECT_OS_INVOKE
  OS_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
  case "$OS_NAME" in
    linux*) PLATFORM="$(grep -e "^ID=" /etc/os-release | cut -c4-)" ;;
    darwin*) PLATFORM="macos" ;;
    msys* | cygwin*) PLATFORM="windows" ;;
    *) PLATFORM="unknown" ;;
  esac
}

@test "detect_os - Detects the OS" {
  detect_os_script="$(cat "./detect-os.sh")"
  run eval "$detect_os_script"
  printf '%s\n' "Expected: $PLATFORM" "Actual: $output"
  [ "$status" -eq 0 ]
  [ "$output" = "$PLATFORM" ]
}

@test "detect_os - Print verbose output if \"ORB_UTILS_DETECT_OS_VERBOSE\" is true" {
  local expected="$(printf '%s\n' "OS name: $OS_NAME" "Platform: $PLATFORM" "$PLATFORM")"
  local detect_os_script="$(cat "./detect-os.sh")"
  ORB_UTILS_DETECT_OS_VERBOSE=true
  run eval "$detect_os_script"
  printf '%s\n' "Expected: $expected" "Actual: $output"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "detect_os - Doesn't invoke the command if \"ORB_UTILS_DETECT_OS_INVOKE\" is false" {
  ORB_UTILS_DETECT_OS_INVOKE=false
  local detect_os_script="$(cat "./detect-os.sh")"
  run eval "$detect_os_script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
