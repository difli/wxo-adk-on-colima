#!/usr/bin/env bash
#
# Installs and configures the IBM watsonx Orchestrate Agent Development Kit (ADK)
# for use with Colima on macOS.
#
# This script is designed to be idempotent and can be run multiple times.
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail # Return value of a pipeline is the value of the last command to exit with a non-zero status.

# --- Helper Functions ---

# Print a message in a consistent format.
#
# @param $1 - The message to print.
function msg() {
  echo -e "💬  $1"
}

# Print an error message and exit.
#
# @param $1 - The error message to print.
function err() {
  echo -e "🚨  ERROR: $1" >&2
  exit 1
}

# Check if a command exists.
#
# @param $1 - The command to check.
# @return 0 if the command exists, 1 otherwise.
function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Prerequisite Checks ---

function check_prerequisites() {
  msg "Checking prerequisites..."

  local missing_packages=()

  if ! command_exists "brew"; then
    msg "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if ! command_exists "colima"; then
    missing_packages+=("colima")
  fi

  if ! command_exists "docker"; then
    missing_packages+=("docker")
  fi

  if ! command_exists "python3.11"; then
    missing_packages+=("python@3.11")
  fi

  if [ ${#missing_packages[@]} -gt 0 ]; then
    msg "Installing missing packages: ${missing_packages[*]}..."
    brew install "${missing_packages[@]}"
  else
    msg "All prerequisites are already installed."
  fi

  # Ensure Python 3.11 is the default python3
  if ! brew list python@3.11 &>/dev/null; then
      brew install python@3.11
  fi
  if [[ $(python3 --version) != *"3.11"* ]]; then
      msg "Linking python@3.11 to be the default 'python3'. You may be asked for your password."
      brew link --overwrite python@3.11
   fi
}

# --- Colima Configuration ---

function setup_colima() {
  msg "Setting up Colima machine..."

  local cpus=8
  local memory=16 # in GiB
  
  # Check if colima is running
  if colima status &>/dev/null; then
    msg "Colima is already running. Stopping it to apply new configuration..."
    colima stop
  fi

  msg "Starting Colima with VZ, VirtioFS, 8 CPUs, and 16GB RAM..."
  # This command is idempotent. If the machine exists, it will start it with the specified settings.
  # If it doesn't exist, it will create it.
  colima start --cpu-type host --arch host --vm-type=vz --mount-type virtiofs -c "${cpus}" -m "${memory}"

  msg "Colima started successfully."
}

# --- Docker Verification ---

function verify_docker() {
  msg "Verifying Docker socket and connection..."
  
  if ! docker info > /dev/null 2>&1; then
    err "Could not connect to the Docker daemon. Please ensure Colima started correctly."
  fi

  msg "Docker daemon is accessible."
}

# --- Python Environment Setup ---

function setup_python_venv() {
  if [ -d ".venv" ]; then
    msg "Python virtual environment '.venv' already exists."
  else
    msg "Creating Python virtual environment..."
    python3.11 -m venv .venv
  fi

  msg "Activating virtual environment..."
  source .venv/bin/activate

  msg "Upgrading pip..."
  pip install --upgrade pip

  msg "Installing dependencies from requirements.txt..."
  pip install -r requirements.txt
}

# --- Sanity Checks ---

function run_sanity_checks() {
  msg "Running sanity checks..."

  msg "Checking Docker version..."
  docker version

  msg "Running hello-world container..."
  docker run --rm hello-world

  msg "Checking orchestrate CLI..."
  orchestrate --help
}

# --- Main Execution ---

function main() {
  check_prerequisites
  setup_colima
  verify_docker
  setup_python_venv
  run_sanity_checks

  echo ""
  msg "✅ Installation and setup completed successfully!"
  echo ""
  msg "Next Steps:"
  echo "1. Copy the example environment file:"
  echo "   cp .env.example .env"
  echo "2. Edit '.env' and add your WO_ENTITLEMENT_KEY to run the local server."
  echo "3. Activate the Python virtual environment:"
  echo "   source .venv/bin/activate"
  echo "4. Start the Orchestrate development server:"
  echo "   orchestrate server start -e .env"
  echo ""
  msg "Happy orchestrating!"
}

main "$@"

