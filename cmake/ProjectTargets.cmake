include_guard(GLOBAL)

function(project_add_targets)
    add_library(core INTERFACE)
    target_compile_features(core INTERFACE cxx_std_20)
    target_include_directories(
        core
        INTERFACE
            "${PROJECT_SOURCE_DIR}/client/src"
    )

    add_library(transport INTERFACE)
    target_link_libraries(transport INTERFACE core Qt6::Core Qt6::Network)

    add_executable(
        diagnostics
        "${PROJECT_SOURCE_DIR}/client/src/diagnostics/main.cpp"
    )
    target_link_libraries(diagnostics PRIVATE core transport Qt6::Core)
    project_apply_cpp_options(diagnostics)
endfunction()
