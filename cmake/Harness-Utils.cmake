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

