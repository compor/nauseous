# cmake file

message(STATUS "setting up pipeline BasicBitcodeGen")

# configuration

macro(BasicBitcodeGenPipelineSetup)
  set(PIPELINE_NAME "BasicBitcodeGen")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


function(BasicBitcodeGenPipeline trgt)
  BasicBitcodeGenPipelineSetup()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  ## pipeline targets and chaining
  llvmir_attach_bc_target(
    TARGET ${PIPELINE_PREFIX}_bc
    DEPENDS ${trgt})
  add_dependencies(${PIPELINE_PREFIX}_bc ${trgt})

  llvmir_attach_link_target(
    TARGET ${PIPELINE_PREFIX}_link
    DEPENDS ${PIPELINE_PREFIX}_bc)
  add_dependencies(${PIPELINE_PREFIX}_link ${PIPELINE_PREFIX}_bc)

  llvmir_attach_executable(
    TARGET ${PIPELINE_PREFIX}_bc_exe
    DEPENDS ${PIPELINE_PREFIX}_link)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)


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

