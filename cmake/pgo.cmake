# cmake file

include(CMakeParseArguments)

function(pgo)
  set(options)
  set(oneValueArgs TARGET TYPE INPUT_DIR PROFILE_FILE)
  set(multiValueArgs)

  cmake_parse_arguments(SP
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  if(NOT SP_TARGET)
    message(FATAL_ERROR "Missing TARGET option.")
  endif()

  if(NOT SP_TYPE)
    message(FATAL_ERROR "Missing TYPE option.")
  endif()

  if(NOT SP_INPUT_DIR)
    message(FATAL_ERROR "Missing INPUT_DIR option.")
  endif()

  if(NOT SP_PROFILE_FILE)
    message(FATAL_ERROR "Missing PROFILE_FILE option.")
  endif()

  set(SP_CUSTOM_TARGET1 "${SP_TARGET}_pgo_profdata_copy")
  set(SP_CUSTOM_TARGET2 "${SP_TARGET}_pgo_profdata_rename")

  set(SP_PROFDATA_SUFFIX ".prof")

  set(SP_SOURCE_PROFDATA
    ${SP_INPUT_DIR}/${SP_TARGET}${SP_PROFDATA_SUFFIX})
  set(SP_BINARY_PROFDATA
    ${CMAKE_CURRENT_BINARY_DIR}/${SP_TARGET}${SP_PROFDATA_SUFFIX})
  set(SP_TARGET_PROFDATA
    ${CMAKE_CURRENT_BINARY_DIR}/${SP_PROFILE_FILE})

  if(NOT IS_ABSOLUTE ${SP_INPUT_DIR})
    message(FATAL_ERROR "${SP_INPUT_DIR} is not provided as an absolute path.")
  endif()

  if(NOT IS_DIRECTORY ${SP_INPUT_DIR})
    message(FATAL_ERROR "${SP_INPUT_DIR} is not a directory.")
  endif()

  if(NOT EXISTS ${SP_SOURCE_PROFDATA})
    message(FATAL_ERROR "${SP_SOURCE_PROFDATA} does not exist.")
  endif()

  add_custom_target(${SP_CUSTOM_TARGET1}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${SP_SOURCE_PROFDATA} ${CMAKE_CURRENT_BINARY_DIR})

  add_custom_target(${SP_CUSTOM_TARGET2}
    COMMAND ${CMAKE_COMMAND} -E rename
    ${SP_BINARY_PROFDATA}
    ${SP_TARGET_PROFDATA})

  add_dependencies(${SP_TARGET} ${SP_CUSTOM_TARGET2})
  add_dependencies(${SP_CUSTOM_TARGET2} ${SP_CUSTOM_TARGET1})

  if(${SP_TYPE} STREQUAL "SAMPLE")
    target_compile_options(${SP_TARGET} PUBLIC
      -fprofile-sample-use=${SP_TARGET_PROFDATA})
  elseif(${SP_TYPE} STREQUAL "INSTRUMENTATION")
    target_compile_options(${SP_TARGET} PUBLIC
      -fprofile-instr-use=${SP_TARGET_PROFDATA})
  else()
    message(FATAL_ERROR "Unknown profiling type: ${SP_TYPE}.")
  endif()
endfunction()

pgo(
  TARGET ${BMK_PROJECT_NAME}
  INPUT_DIR $ENV{HARNESS_PGO_INPUT_DIR}
  TYPE ${PGO_TYPE}
  PROFILE_FILE ${PGO_FILE})

