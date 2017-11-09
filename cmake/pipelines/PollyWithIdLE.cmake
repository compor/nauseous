# cmake file

macro(PollyWithIdLEPipelineSetupNames)
  set(PIPELINE_NAME "PollyWithIdLE")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()

macro(PollyWithIdLEPipelineSetup)
  PollyWithIdLEPipelineSetupNames()

  message(STATUS "setting up pipeline ${PIPELINE_NAME}")

  if(NOT DEFINED ENV{HARNESS_REPORT_DIR})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable HARNESS_REPORT_DIR is not defined")
  endif()

  if(NOT IS_DIRECTORY $ENV{HARNESS_REPORT_DIR})
    message(FATAL_ERROR "${PIPELINE_NAME} HARNESS_REPORT_DIR does not exist")
  endif()

  message(STATUS
    "${PIPELINE_NAME} uses env variable: HARNESS_REPORT_DIR=$ENV{HARNESS_REPORT_DIR}")

  #

  find_package(LLVMPolly REQUIRED)

  if(NOT LLVMPOLLY_FOUND)
    message(FATAL_ERROR "${PIPELINE_NAME} package Polly was not found")
  endif()
endmacro()

PollyWithIdLEPipelineSetup()

#

function(PollyWithIdLEPipeline trgt)
  PollyWithIdLEPipelineSetupNames()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "AnnotateLoopsLE_${trgt}_opt2")

  ## pipeline targets and chaining

  file(TO_CMAKE_PATH "$ENV{HARNESS_REPORT_DIR}/${BMK_NAME}-${PIPELINE_NAME}.txt"
    REPORT_FILE)

  llvmir_attach_opt_pass_target(
    TARGET ${PIPELINE_PREFIX}_link
    DEPENDS ${DEPENDEE_TRGT}
    -load ${LLVMPOLLY_SHARED_LIBRARY}
    -polly-canonicalize
    -polly-scops
    -polly-export-jscop
    -polly-codegen
    -polly-parallel
    -polly-export-parallel-id-loops=${REPORT_FILE})
  add_dependencies(${PIPELINE_PREFIX}_link ${DEPENDEE_TRGT})

  # do not produce binary because we need to link against a parallel lib
  #llvmir_attach_executable(
  #TARGET ${PIPELINE_PREFIX}_bc_exe
  #DEPENDS ${PIPELINE_PREFIX}_link)
  #add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)
  #target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${DEPENDEE_TRGT}
    ${PIPELINE_PREFIX}_link)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)
  set(DEST_DIR "${bmk_name}")

  install(TARGETS ${PIPELINE_PREFIX}_bc_exe
    DESTINATION ${DEST_DIR} OPTIONAL)

  set(BMK_BIN_NAME "${PIPELINE_PREFIX}_bc_exe")

  set(BMK_BIN_PREAMBLE "\"\"")

  configure_file("scripts/_run.sh.in" "scripts/${PIPELINE_PREFIX}_run.sh" @ONLY)

  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/scripts/
    DESTINATION ${DEST_DIR}
    PATTERN "*.sh"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)

  # IR installation
  if(NOT TARGET ${PIPELINE_INSTALL_TARGET})
    add_custom_target(${PIPELINE_INSTALL_TARGET})
  endif()

  InstallPipelineLLVMIR(DEPENDS ${PIPELINE_PREFIX}_link
    ATTACH_TO_TARGET ${PIPELINE_INSTALL_TARGET} BMK_NAME ${bmk_name})
endfunction()

