#!/bin/sh

# constants
BUILD_TOP_DIR=`readlink -f `
BUILD_SCRIPT="build_package"
PACKAGE_FILE_STORE_PATH="~/temp"

# function implementation (change rel_config)
# function implementation (remove build_dir)
# function implementation (git reset --hard)
# function implementation (git co branch)

# for ( i = 0 ; i != 2 ; ++i)
  # build start for normal package(not factory image)
    # remove build directories (including metabuild)
    # execute BUILD_SCRIPT
    # check build error

  # move target file to store path
    # check target package file is created
    # move target file to PACKAGE_FILE_STORE_PATH

  # build start for factory image
    # remove build directories (including metabuild)
    # change rel_config
    # execute BUILD_SCRIPT
    # check build error

  # move target file to store path
    # check target package file is created
    # move target file to PACKAGE_FILE_STORE_PATH

  # checkout branch to commercial
# end of for loop


#end of file
