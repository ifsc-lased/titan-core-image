#!/bin/bash

echo "Run entrypoint"

# Define variables
BIN_DIR="bin"
EXECUTABLE="ets.bin"
WORKDIR="/home/titan/data"
SRC_TEMP_DIR="/tmp/src"

# List of possible extensions to be searched to generate makefile (separated by space)"
EXTENSIONS="*.ttcn *.asn *.cc *.hh *.hpp *.cpp *.c *.h"

# Check if the temporary directory exists before deleting it
if [ -d "$SRC_TEMP_DIR" ]; then
  echo "The directory $SRC_TEMP_DIR exists. Deleting..."
  rm -r $SRC_TEMP_DIR
fi

# Create the temporary directory
echo "Creating temporary directory in $SRC_TEMP_DIR."
mkdir $SRC_TEMP_DIR


# List to store found extensions
FOUND_EXTENSIONS=""

# Copy files with specific extensions
echo "Copying files to directory $SRC_TEMP_DIR."
for ext in $EXTENSIONS; do
  if find $WORKDIR -type f -name "$ext" | grep -q .; then
    FOUND_EXTENSIONS+="$ext "
    find $WORKDIR -type f -name "$ext" -exec cp {} "$SRC_TEMP_DIR" \;
  fi
done

# Generate the Makefile
cd $SRC_TEMP_DIR
ttcn3_makefilegen -sSfwi $FOUND_EXTENSIONS -e $EXECUTABLE -o $SRC_TEMP_DIR > /dev/null
if [ $? -ne 0 ]; then
   echo "Error: Failed to execute ttcn3_makefilegen"
   exit 1
fi

# Compile the project
make > /dev/null
if [ $? -ne 0 ]; then
  echo "Error: Failed to execute make"
  exit 1
fi

# Check if the bin directory exists before deleting it
cd $WORKDIR
if [ -d "$BIN_DIR" ]; then
  echo "The directory $BIN_DIR already exists. Deleting..."
  rm -r $BIN_DIR
fi

# Create the bin directory
mkdir $BIN_DIR

# Check if the binary ets.bin was generated before copying it
if [ -f "$SRC_TEMP_DIR/$EXECUTABLE" ]; then
  mv $SRC_TEMP_DIR/$EXECUTABLE $BIN_DIR/
  echo "Executable generated in ./$BIN_DIR/$EXECUTABLE"
else
  echo "Error: $EXECUTABLE not found!"
  exit 1
fi
