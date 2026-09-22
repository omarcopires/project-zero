include_guard(GLOBAL)

function(project_add_targets)
    add_library(core INTERFACE)
    target_compile_features(core INTERFACE cxx_std_20)
    target_include_directories(
        core
        INTERFACE
            "${PROJECT_SOURCE_DIR}/client/src"
    )

    add_library(
        transport
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/infrastructure/transport/tcp_transport.cpp"
    )
    target_include_directories(
        transport
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(transport PUBLIC Qt6::Core Qt6::Network PRIVATE core)
    project_apply_cpp_options(transport)
    set_target_properties(transport PROPERTIES AUTOMOC ON)

    add_library(
        logging
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/infrastructure/logging/logger.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/infrastructure/logging/message_formatter.cpp"
    )
    target_include_directories(
        logging
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(logging PUBLIC fmt::fmt PRIVATE spdlog::spdlog)
    project_apply_cpp_options(logging)

    add_executable(
        diagnostics
        "${PROJECT_SOURCE_DIR}/client/src/diagnostics/main.cpp"
    )
    target_link_libraries(diagnostics PRIVATE core transport logging Qt6::Core)
    project_apply_cpp_options(diagnostics)
endfunction()
