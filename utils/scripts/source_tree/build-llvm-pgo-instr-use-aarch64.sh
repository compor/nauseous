#!/usr/bin/env bash

PRJ_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
SRC_DIR=${1:-$PRJ_ROOT_DIR}
INSTALL_PREFIX=${2:-../install/}

BMK_CONFIG_FILE="${SRC_DIR}/config/suite_all.txt"
BMK_CLASS="B"
DC_BMK_CLASS="A"
MG_BMK_CLASS="C"
IS_BMK_CLASS="C"

#

C_FLAGS=""
C_FLAGS="${C_FLAGS} -g -Wall"
C_FLAGS="${C_FLAGS} -O2 -mcmodel=large"
C_FLAGS="${C_FLAGS} -fsave-optimization-record"
C_FLAGS="${C_FLAGS} -nobuiltininc"
C_FLAGS="${C_FLAGS} -isystem /usr/lib/gcc-cross/aarch64-linux-gnu/5.4.0/include/"
C_FLAGS="${C_FLAGS} -isystem /usr/aarch64-linux-gnu/include/"
C_FLAGS="${C_FLAGS} -mcpu=cortex-a73"
C_FLAGS="${C_FLAGS} -mfpu=neon"

PGO_FLAGS=""
PGO_FLAGS="${PGO_FLAGS} -fprofile-instr-use=data.prof"

#LINKER_FLAGS="-Wl,-L$(llvm-config --libdir) -Wl,-rpath=$(llvm-config --libdir)"
#LINKER_FLAGS="${LINKER_FLAGS} -lc++ -lc++abi"

#

cmake \
  -GNinja \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_POLICY_DEFAULT_CMP0056=NEW \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=On \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_FLAGS="${C_FLAGS}" \
  -DCMAKE_PGO_FLAGS="${PGO_FLAGS}" \
  -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_SHARED_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_MODULE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DHARNESS_BMK_CONFIG_FILE="${BMK_CONFIG_FILE}" \
  -DBMK_CLASS=${BMK_CLASS} \
  -DDC_BMK_CLASS=${DC_BMK_CLASS} \
  -DMG_BMK_CLASS=${MG_BMK_CLASS} \
  -DIS_BMK_CLASS=${IS_BMK_CLASS} \
  "${SRC_DIR}"

