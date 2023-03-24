#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <user config> <version>" >&2
  exit 1
fi

if ! [ -x "$(command -v vivado)" ]; then
	echo "vivado does NOT exist in the environment."
	exit 1
fi

if [ -z "$SHELL_DIR" ]; then
	echo "Please provide shell directory with env variable SHELL_DIR"
	exit 1
fi

if [ -z "$FPGA_PART_NAME" ]; then
	FPGA_PART_NAME=xcu55c-fsvh2892-2L-e
fi
echo "FPGA_PART_NAME = $FPGA_PART_NAME"

if ! [ -f "$SHELL_DIR/dcp/static_shell.dcp" ]; then
	echo "static_shell.dcp does NOT exist in $SHELL_DIR/dcp"
	exit 1
fi

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
USER_CONFIG=$1
VERSION=$2

BUILD_DIR=perfhost_dyn_${USER_CONFIG}_${VERSION}

rm -rf $BUILD_DIR && mkdir $BUILD_DIR
cd $BUILD_DIR

# create user top project
vivado -mode batch -source $SCRIPT_DIR/gen_proj.tcl -tclargs $USER_CONFIG $FPGA_PART_NAME
# 
vivado -mode batch -source $SCRIPT_DIR/build_user.tcl -tclargs $USER_CONFIG $SHELL_DIR $FPGA_PART_NAME

echo "Done"