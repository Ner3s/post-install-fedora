#!/bin/bash

# Source constants
SCRIPT_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/lib/constants.sh"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log levels
LOG_LEVEL_INFO=0
LOG_LEVEL_WARN=1
LOG_LEVEL_ERROR=2
LOG_LEVEL_SUCCESS=3

# Logging functions
log_message() {
  local level=$1
  local message=$2
  local prefix=""
  local color=$NC
  
  case $level in
    $LOG_LEVEL_INFO)
      prefix="INFO"
      color=$BLUE
      ;;
    $LOG_LEVEL_WARN)
      prefix="WARN"
      color=$YELLOW
      ;;
    $LOG_LEVEL_ERROR)
      prefix="ERROR"
      color=$RED
      ;;
    $LOG_LEVEL_SUCCESS)
      prefix="SUCCESS"
      color=$GREEN
      ;;
  esac
  
  echo -e "${color}[${prefix}]${NC} $message"
}

log_info() {
  log_message $LOG_LEVEL_INFO "$1"
}

log_warn() {
  log_message $LOG_LEVEL_WARN "$1"
}

log_error() {
  log_message $LOG_LEVEL_ERROR "$1"
}

log_success() {
  log_message $LOG_LEVEL_SUCCESS "$1"
}

# Error handling
handle_error() {
  local exit_code=$?
  local error_message=$1
  local exit_on_error=${2:-true}
  
  if [ $exit_code -ne 0 ]; then
    log_error "$error_message (Exit code: $exit_code)"
    if [[ "$exit_on_error" == "true" ]]; then
      exit $exit_code
    fi
    return 1
  fi
  return 0
}

# Resource management
download_resource() {
  local url=$1
  local output_path=$2
  local description=${3:-"resource"}
  
  log_info "Downloading $description from $url..."
  curl -fsSL "$url" -o "$output_path"
  handle_error "Failed to download $description" false
  
  if [ -f "$output_path" ]; then
    log_success "$description downloaded successfully"
    return 0
  else
    log_error "$description could not be downloaded"
    return 1
  fi
}

check_command() {
  local cmd=$1
  command -v "$cmd" &>/dev/null
  return $?
}

install_if_missing() {
  local cmd=$1
  local pkg=${2:-$cmd}
  
  if ! check_command "$cmd"; then
    log_info "$cmd not found. Installing $pkg..."
    sudo dnf install -y "$pkg"
    handle_error "Failed to install $pkg" false
  fi
}

ensure_directory() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    handle_error "Failed to create directory: $dir" false
  fi
}