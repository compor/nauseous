#!/usr/bin/env bash

[[ -z $1 ]] && echo "error: source directory was not provided" && exit 1
SRC_DIR=$1

INSTALL_PREFIX=${2:-../install/}

BMK_CONFIG_FILE="${SRC_DIR}/config/suite_all.txt"
BMK_TYPE="OMP"
BMK_CLASS="B"
MG_BMK_CLASS="C"
IS_BMK_CLASS="C"

#

C_FLAGS="-g -Wall -O2 -mcmodel=medium -fopenmp=libomp"
LINKER_FLAGS="-Wl,-L$(llvm-config --libdir) -Wl,-rpath=$(llvm-config --libdir)"
LINKER_FLAGS="${LINKER_FLAGS} -lc++ -lc++abi -lomp" 

CC=clang CXX=clang++ \
cmake \
  -DCMAKE_POLICY_DEFAULT_CMP0056=NEW \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=On \
  -DLLVM_DIR=$(llvm-config --prefix)/share/llvm/cmake/ \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_FLAGS="${C_FLAGS}" \
  -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_SHARED_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_MODULE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DHARNESS_USE_LLVM=On \
  -DHARNESS_BMK_CONFIG_FILE=${BMK_CONFIG_FILE} \
  -DBMK_TYPE=${BMK_TYPE} \
  -DBMK_CLASS=${BMK_CLASS} \
  -DMG_BMK_CLASS="${MG_BMK_CLASS}" \
  -DIS_BMK_CLASS="${IS_BMK_CLASS}" \
  "${SRC_DIR}"

