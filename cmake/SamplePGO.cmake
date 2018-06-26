# cmake file

include(CMakeParseArguments)

function(SamplePGO)
  set(options)
  set(oneValueArgs TARGET INPUT_DIR)
  set(multiValueArgs FLAGS)

  cmake_parse_arguments(SPU
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  set(SPU_CUSTOM_TARGET1 "${SPU_TARGET}_pgo_profdata_copy")
  set(SPU_CUSTOM_TARGET2 "${SPU_TARGET}_pgo_profdata_rename")

  add_custom_target(${SPU_CUSTOM_TARGET1}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${SPU_INPUT_DIR}/${SPU_TARGET}.prof ${CMAKE_CURRENT_BINARY_DIR})

  add_custom_target(${SPU_CUSTOM_TARGET2}
    COMMAND ${CMAKE_COMMAND} -E rename
    ${CMAKE_CURRENT_BINARY_DIR}/${SPU_TARGET}.prof
    ${CMAKE_CURRENT_BINARY_DIR}/data.prof)

  add_dependencies(${SPU_TARGET} ${SPU_CUSTOM_TARGET2})
  add_dependencies(${SPU_CUSTOM_TARGET2} ${SPU_CUSTOM_TARGET1})

  target_compile_options(${SPU_TARGET} PUBLIC
    -fprofile-sample-use=${CMAKE_CURRENT_BINARY_DIR}/data.prof)
endfunction()

SamplePGO(
  TARGET ${BMK_PROJECT_NAME}
  INPUT_DIR $ENV{HARNESS_PGO_INPUT_DIR}
  FLAGS ${CMAKE_PGO_FLAGS})

