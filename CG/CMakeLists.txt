# cmake file

set(BMK_NAME "CG")
string(TOLOWER ${BMK_NAME} BMK_NAME_LOWER)
set(BMK_PROJECT_NAME ${BMK_NAME_LOWER})

file(TO_CMAKE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}"
  SRC_DIR)

if(NOT EXISTS "${SRC_DIR}" AND NOT IS_DIRECTORY "${SRC_DIR}")
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}")
  return()
endif()

set(SOURCES
  cg.c)

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

list(APPEND SOURCES ${COMMON_SOURCES})
list(APPEND SOURCES ${COMMON_RAND_SOURCES})

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "npbparams.h")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_BINARY_DIR}")

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_SOURCE_DIR}/common")

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/")

target_link_libraries(${BMK_PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${BMK_PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

# this property is used internally by our harness
# because benchmark names and their main targets have different names
set_target_properties(${BMK_PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})

#

set(CLASS ${${BMK_NAME}_BMK_CLASS})
if(NOT ${BMK_NAME}_BMK_CLASS)
  set(CLASS ${BMK_CLASS})
endif()

message(STATUS "${BMK_NAME} benchmark class: ${CLASS}")

harness_attach_setparams_target(TARGET ${BMK_PROJECT_NAME} BMK_CLASS ${CLASS}
  UTILITY_TARGET ${SETPARAMS_UTILITY} UTILITY_EXE ${SETPARAMS_UTILITY})


foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

