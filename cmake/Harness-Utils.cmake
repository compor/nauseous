# cmake file

include(CMakeParseArguments)

function(add_prefix outvar prefix files)
  set(tmplist "")

  foreach(f ${files})
    list(APPEND tmplist "${prefix}${f}")
  endforeach()

  set(${outvar} "${tmplist}" PARENT_SCOPE)
endfunction()

