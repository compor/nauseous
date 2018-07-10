# cmake file

include(CMakeParseArguments)

function(SamplePGO)
  set(options)
  set(oneValueArgs TARGET INPUT_DIR PROFILE_FILE)
  set(multiValueArgs)

  cmake_parse_arguments(SP
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

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

  target_compile_options(${SP_TARGET} PUBLIC
    -fprofile-sample-use=${SP_TARGET_PROFDATA})
endfunction()

SamplePGO(
  TARGET ${BMK_PROJECT_NAME}
  INPUT_DIR $ENV{HARNESS_PGO_INPUT_DIR}
  PROFILE_FILE ${PGO_FILE})

