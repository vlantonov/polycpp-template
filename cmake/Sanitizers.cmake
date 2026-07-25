include_guard(GLOBAL)

if(POLYCPP_ENABLE_ASAN AND POLYCPP_ENABLE_TSAN)
  message(FATAL_ERROR "ASan and TSan are mutually exclusive")
endif()

function(polycpp_apply_sanitizers target)
  set(_polycpp_any_sanitizer OFF)
  set(_polycpp_sanitizer_flags)

  if(POLYCPP_ENABLE_ASAN)
    set(_polycpp_any_sanitizer ON)
    list(APPEND _polycpp_sanitizer_flags -fsanitize=address)
  endif()

  if(POLYCPP_ENABLE_UBSAN)
    set(_polycpp_any_sanitizer ON)
    list(APPEND _polycpp_sanitizer_flags -fsanitize=undefined -fno-sanitize-recover=undefined)
  endif()

  if(POLYCPP_ENABLE_TSAN)
    set(_polycpp_any_sanitizer ON)
    list(APPEND _polycpp_sanitizer_flags -fsanitize=thread)
  endif()

  if(NOT _polycpp_any_sanitizer)
    return()
  endif()

  if(MSVC)
    message(WARNING "Sanitizers not supported on MSVC in this template — skipping")
    return()
  endif()

  list(APPEND _polycpp_sanitizer_flags -fno-omit-frame-pointer -fno-optimize-sibling-calls)

  target_compile_options(${target} PRIVATE ${_polycpp_sanitizer_flags})
  target_link_options(${target} PRIVATE ${_polycpp_sanitizer_flags})
endfunction()