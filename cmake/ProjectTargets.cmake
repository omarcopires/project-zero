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
        protocol
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/protocol/binary/adler32.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/binary/length_prefixed_string.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/binary/little_endian.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/handshake/world_challenge_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/handshake/world_login_block_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/framing/modern_frame.cpp"
    )
    target_include_directories(
        protocol
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(protocol PRIVATE core)
    project_apply_cpp_options(protocol)

    add_library(
        diagnostic_support
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/diagnostics/fixture_inspector.cpp"
    )
    target_include_directories(
        diagnostic_support
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(diagnostic_support PUBLIC protocol PRIVATE core)
    project_apply_cpp_options(diagnostic_support)

    add_library(
        session
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/session/authentication/authentication_coordinator.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/session/authentication/login_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/session/selection/character_selector.cpp"
    )
    target_include_directories(
        session
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(session PUBLIC Qt6::Core PRIVATE core)
    project_apply_cpp_options(session)

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
        http_transport
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/infrastructure/http/http_transport.cpp"
    )
    target_include_directories(
        http_transport
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(http_transport PUBLIC Qt6::Core Qt6::Network PRIVATE core)
    project_apply_cpp_options(http_transport)
    set_target_properties(http_transport PROPERTIES AUTOMOC ON)

    add_library(
        authentication_application
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/application/authentication/authentication_service.cpp"
    )
    target_include_directories(
        authentication_application
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(authentication_application PUBLIC session Qt6::Core PRIVATE core http_transport)
    project_apply_cpp_options(authentication_application)
    set_target_properties(authentication_application PROPERTIES AUTOMOC ON)

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
    target_link_libraries(
        diagnostics
        PRIVATE
            core
            diagnostic_support
            logging
            protocol
            transport
            Qt6::Core
    )
    project_apply_cpp_options(diagnostics)
endfunction()
