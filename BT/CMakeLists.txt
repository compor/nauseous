# cmake file

set(BMK_NAME "BT")
string(TOLOWER ${BMK_NAME} BMK_NAME_LOWER)
set(BMK_PROJECT_NAME ${BMK_NAME_LOWER})

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}") 
  return()
endif()

set(VEC "")

set(SOURCES
  add.c
  adi.c
  bt.c
  error.c
  exact_rhs.c                                    
  exact_solution.c                               
  initialize.c                                   
  rhs.c                                          
  set_constants.c                                
  solve_subs.c                                   
  verify.c                                       
  x_solve${VEC}.c                                      
  y_solve${VEC}.c                                      
  z_solve${VEC}.c)

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

attach_setparams_target(TARGET ${BMK_PROJECT_NAME} BMK_CLASS ${CLASS}
  UTILITY_TARGET ${SETPARAMS_UTILITY} UTILITY_EXE ${SETPARAMS_UTILITY})


if(LLVM_IR_UTIL_FOUND)
  foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
    include(${FRAGMENT})
  endforeach()
endif()

