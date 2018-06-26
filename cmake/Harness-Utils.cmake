# cmake file

include(CMakeParseArguments)

function(harness_list_prepend)
  set(options)
  set(oneValueArgs OUTPUT_LIST PREFIX)
  set(multiValueArgs INPUT_LIST)

  cmake_parse_arguments(HLP
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  set(TMPLIST "")

  foreach(LISTITEM ${HLP_INPUT_LIST})
    list(APPEND TMPLIST "${HLP_PREFIX}${LISTITEM}")
  endforeach()

  set(${HLP_OUTPUT_LIST} ${TMPLIST} PARENT_SCOPE)
endfunction()

function(harness_detect_pgo)
  set(options)
  set(oneValueArgs TYPE MODE PROFILE_FILE)
  set(multiValueArgs FLAGS)

  cmake_parse_arguments(HDP
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  foreach(LISTITEM ${HDP_FLAGS})
    if(NOT ${LISTITEM} MATCHES "-fprofile-.*")
      message(FATAL_ERROR "Not a valid PGO flag.")
    endif()
  endforeach()

  list(LENGTH HDP_FLAGS HDP_FLAGS_LEN)

  if(NOT HDP_FLAGS_LEN EQUAL 1)
    message(FATAL_ERROR "Incorrect number of profiling flags.")
  endif()

  if("${HDP_FLAGS}" MATCHES "-fprofile-instr.*")
    set(${HDP_TYPE} "INSTRUMENTATION" PARENT_SCOPE)

    if("${HDP_FLAGS}" MATCHES "-fprofile-instr-gen.*")
      set(${HDP_MODE} "GENERATE" PARENT_SCOPE)
    elseif("${HDP_FLAGS}" MATCHES "-fprofile-instr-use.*")
      set(${HDP_MODE} "USE" PARENT_SCOPE)
    else()
      message(FATAL_ERROR "Uknown PGO mode.")
    endif()
  elseif("${HDP_FLAGS}" MATCHES "-fprofile-sample.*")
    set(${HDP_TYPE} "SAMPLE" PARENT_SCOPE)

    if("${HDP_FLAGS}" MATCHES "-fprofile-sample-use.*")
      set(${HDP_MODE} "USE" PARENT_SCOPE)
    else()
      message(FATAL_ERROR "Uknown PGO mode.")
    endif()
  else()
    message(FATAL_ERROR "Uknown PGO type.")
  endif()

  # TODO profile file needs to parsed
endfunction()

