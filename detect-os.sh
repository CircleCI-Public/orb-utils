#!/usr/bin/env sh
# shellcheck disable=SC3043 # While "local" is not POSIX, it is supported by all shells we care about.

# Public: Detect the operating system.
#
# Detects the operating system and writes it to ORB_UTILS_PLATFORM. If the OS is
# linux, the distribution is written instead.
#
# ORB_UTILS_DETECT_OS_VERBOSE - Whether to print verbose output. Defaults to false.
# ORB_UTILS_DETECT_OS_INVOKE - Whether to invoke the function on script execution. Defaults to true.
#
# Examples
#
#   detect_os
#   ORB_UTILS_DETECT_OS_VERBOSE=true detect_os
#   ORB_UTILS_DETECT_OS_INVOKE=false detect_os
#
# Writes the OS to stdout, exports to BASH_ENV and returns 0 if the OS is known.
# Otherwise, returns 1 and writes to stderr.
detect_os() {
  ORB_UTILS_DETECT_OS_VERBOSE="${ORB_UTILS_DETECT_OS_VERBOSE:-false}"
  local verbose="$ORB_UTILS_DETECT_OS_VERBOSE"

  local os_name
  os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
  [ "$verbose" = false ] || printf '%s\n' "OS name: $os_name"

  local platform
  case "$os_name" in
    linux*) platform="$(grep -e "^ID=" /etc/os-release | cut -c4-)" ;;
    darwin*) platform="macos" ;;
    msys* | cygwin*) platform="windows" ;;
    *) platform="unknown" ;;
  esac
  [ "$verbose" = false ] || printf '%s\n' "Platform: $platform"

  # Write to stderr and return 1 if the OS is not known.
  [ "$platform" = "unknown" ] && { >&2 printf '%s\n' "Could not identify the operating system."; return 1; }

  # Export to make it immediately available to the caller.
  export ORB_UTILS_PLATFORM="$platform"
  # Inject into the environment via $BASH_ENV to make it available in other steps.
  if [ -n "$BASH_ENV" ]; then printf '%s\n' "export ORB_UTILS_PLATFORM=$platform" >> "$BASH_ENV"; fi
  # Write to stdout and return 0.
  printf '%s\n' "$platform"
  return 0
}

ORB_UTILS_DETECT_OS_INVOKE="${ORB_UTILS_DETECT_OS_INVOKE:-true}"
[ "$ORB_UTILS_DETECT_OS_INVOKE" = false ] || detect_os
