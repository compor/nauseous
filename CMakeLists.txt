# cmake file

cmake_minimum_required(VERSION 3.0)

project(npb-3.3 C CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")

include(Harness-Utils)
include(Harness-Setparams)
include(Harness-Version)

get_version(NPB_VERSION)
message(STATUS "Nauseous harness version: ${NPB_VERSION}")

message(STATUS "C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX compiler: ${CMAKE_CXX_COMPILER}")


#
# project options
#

option(HARNESS_USE_LLVM "use LLVM bitcode processing tools" OFF)

set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY TRUE)

set(HARNESS_BMK_SOURCE_SUBDIR "src")

set(HARNESS_BUILD_TREE_SCRIPTS_SRC_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/scripts/build_tree/")

set(HARNESS_BUILD_TREE_SCRIPTS_DEST_DIR
  "${CMAKE_CURRENT_BINARY_DIR}/scripts/")

set(HARNESS_INSTALL_TREE_SCRIPTS_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/scripts/install_tree/")

set(HARNESS_CONFIG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/config")


# project options checks and processing

if(HARNESS_USE_LLVM)
  if("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang" OR
      "${CMAKE_C_COMPILER_ID}" STREQUAL "AppleClang")
    find_package(LLVM REQUIRED CONFIG)

    if(LLVM_FOUND)
      set(LLVM_LIB_DIR ${LLVM_TOOLS_BINARY_DIR}/../lib/)

      list(APPEND CMAKE_MODULE_PATH
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvm-ir-cmake-utils/cmake/")

      include(LLVMIRUtil RESULT_VARIABLE LLVM_IR_UTIL_FOUND)
    endif()
  else()
    message(FATAL_ERROR "Selected compiler cannot generate LLVM IR")
  endif()
endif()

set(HARNESS_CMAKE_FRAGMENT_FILES "")

if(LLVM_IR_UTIL_FOUND)
  list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvm-ir-cmake-pipelines/cmake/")
  include(LLVMIRPipelines)

  set(FRAGMENT_FILE "main_fragment")

  llvmir_pipelines_setup(
    DEPENDS BMK_PROJECT_NAME
    OUTPUT_FILE ${FRAGMENT_FILE})

  # check if there are any pipelines configured
  if(LLVMIR_PIPELINES_TO_INCLUDE)
    list(APPEND HARNESS_CMAKE_FRAGMENT_FILES "${FRAGMENT_FILE}")
  endif()
endif()

if(CMAKE_PGO_FLAGS)
  string(REPLACE " " ";" CMAKE_PGO_FLAGS ${CMAKE_PGO_FLAGS})

  harness_detect_pgo(
    FLAGS "${CMAKE_PGO_FLAGS}"
    TYPE PGO_TYPE
    MODE PGO_MODE
    PROFILE_FILE PGO_FILE)

  if(PGO_MODE STREQUAL "USE")
    list(INSERT HARNESS_CMAKE_FRAGMENT_FILES 0 "pgo")
  endif()
endif()


#
# project user options
#

if(NOT BMK_TYPE)
  set(BMK_TYPE "SER")
endif()

if(NOT BMK_CLASS)
  set(BMK_CLASS "U")
endif()

message(STATUS "using default benchmark class: ${BMK_CLASS}")

if(NOT BMK_RAND)
  set(BMK_RAND "randdp")
endif()

if(NOT BMK_WTIME)
  set(BMK_WTIME "wtime")
endif()

# project user options checks and processing

if(NOT HARNESS_BMK_CONFIG_FILE)
  message(FATAL_ERROR
    "Benchmark config file HARNESS_BMK_CONFIG_FILE is not set")
elseif(NOT EXISTS ${HARNESS_BMK_CONFIG_FILE})
  message(FATAL_ERROR
    "Benchmark config file does not exist: ${HARNESS_BMK_CONFIG_FILE}")
endif()


#
# configuration
#

# set options for make.def file
set(HARNESS_CC ${CMAKE_C_COMPILER})
set(HARNESS_CFLAGS ${CMAKE_C_FLAGS})
set(HARNESS_CLINKFLAGS ${CMAKE_EXE_LINKER_FLAGS})

file(MAKE_DIRECTORY config)
configure_file(config/make.def.in config/make.def @ONLY)


set(COMMON_SOURCES
  ${CMAKE_SOURCE_DIR}/common/c_print_results.c
  ${CMAKE_SOURCE_DIR}/common/c_timers.c
  ${CMAKE_SOURCE_DIR}/common/print_results.c
  ${CMAKE_SOURCE_DIR}/common/${BMK_WTIME}.c)

set(COMMON_RAND_SOURCES
  ${CMAKE_SOURCE_DIR}/common/${BMK_RAND}.c)

set(CMAKE_INSTALL_MESSAGE "LAZY")

if(NOT HARNESS_SETPARAMS_UTILITY)
  set(SETPARAMS_UTILITY "setparams")
  add_executable(${SETPARAMS_UTILITY} sys/setparams.c)
else()
  set(SETPARAMS_UTILITY "${HARNESS_SETPARAMS_UTILITY}")
endif()

file(STRINGS ${HARNESS_BMK_CONFIG_FILE} BENCHMARKS)

foreach(BMK ${BENCHMARKS})
  message(STATUS "adding subdir: ${BMK}")
  add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/${BMK}/)
endforeach()


# installation

install(DIRECTORY ${HARNESS_CONFIG_DIR} DESTINATION .)
install(DIRECTORY ${HARNESS_INSTALL_TREE_SCRIPTS_DIR} DESTINATION scripts)

add_custom_target(install-build-scripts
  ALL
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  ${HARNESS_BUILD_TREE_SCRIPTS_SRC_DIR}
  ${HARNESS_BUILD_TREE_SCRIPTS_DEST_DIR}
  COMMENT "copying build-tree related scripts")

