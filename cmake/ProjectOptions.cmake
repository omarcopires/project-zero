include_guard(GLOBAL)

function(project_apply_cpp_options target)
    target_compile_features(${target} PUBLIC cxx_std_20)
    set_target_properties(
        ${target}
        PROPERTIES
            CXX_EXTENSIONS OFF
    )

    if(MSVC)
        target_compile_options(${target} PRIVATE /permissive- /W4 /Zc:__cplusplus)
    endif()
endfunction()
