#!/bin/bash

# Define the project name
PROJECT_NAME="example"

# Parse arguments
CLEAN=false
ONLY_BUILD=false
RUN=false

for arg in "$@"; do
  case $arg in
    --clean)
      CLEAN=true
      ;;
    --only-build)
      ONLY_BUILD=true
      ;;
    --run)
      RUN=true
      ;;
    --help|-h)
      echo "Builds the project and uploads it to the Milk-V Duo"
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --clean       Clean the build directory before the build"
      echo "  --only-build  Build the project without uploading."
      echo "  --run         Run the binary on the remote device after uploading."
      echo "  --help, -h    Show this help message and exit."
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

# Clean the build directory if --clean is provided
if $CLEAN; then
  echo "Cleaning build directory..."
  rm -rf build
fi

# Create and navigate to the build directory
mkdir -p build
cd build || exit 1

# Run CMake and build the project
cmake .. || exit 1
make || { echo "Build failed"; exit 1; }

echo "Build finished"

# Exit if --only-build is provided
if $ONLY_BUILD; then
  exit 0
fi

# Check if sshpass is installed and password file exists
USE_SSHPASS=true
if ! command -v sshpass &> /dev/null || [ ! -f ../ssh_password.txt ]; then
  echo "Warning: sshpass is not available or password file is missing. Proceeding without sshpass."
  USE_SSHPASS=false
fi

# Upload the binary
if $USE_SSHPASS; then
  echo "Uploading binary using sshpass..."
  sshpass -f ../ssh_password.txt scp -O "$PROJECT_NAME" root@192.168.42.1:/root/ || { echo "Upload failed"; exit 1; }
else
  echo "Uploading binary using scp..."
  scp -O "$PROJECT_NAME" root@192.168.42.1:/root/ || { echo "Upload failed"; exit 1; }
fi

echo "Upload completed."

# Run the binary on the remote device if --run is provided
if $RUN; then
  if $USE_SSHPASS; then
    echo "Running binary on the remote device using sshpass..."
    sshpass -f ../ssh_password.txt ssh -t root@192.168.42.1 "/root/$PROJECT_NAME" || { echo "Execution failed"; exit 1; }
  else
    echo "Running binary on the remote device using ssh..."
    ssh root@192.168.42.1 -s "/root/$PROJECT_NAME" || { echo "Execution failed"; exit 1; }
  fi
fi