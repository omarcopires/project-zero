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
        qml_enum_values
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/presentation/qml/qml_enum_values.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/presentation/qml/qml_enum_values.h"
            "${PROJECT_SOURCE_DIR}/client/src/presentation/qml/map_antialiasing_mode.h"
            "${PROJECT_SOURCE_DIR}/client/src/presentation/qml/split_resize_preference.h"
    )
    target_include_directories(
        qml_enum_values
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(qml_enum_values PUBLIC Qt6::Qml)
    project_apply_cpp_options(qml_enum_values)
    set_target_properties(qml_enum_values PROPERTIES AUTOMOC ON)

    add_library(
        client_translations
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/presentation/translations/json_catalog_translator.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/presentation/translations/json_catalog_translator.h"
    )
    target_include_directories(
        client_translations
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(client_translations PUBLIC Qt6::Core)
    project_apply_cpp_options(client_translations)

    add_library(appearance_proto STATIC)
    target_sources(
        appearance_proto
        PRIVATE
            "${PROJECT_SOURCE_DIR}/client/protobuf/shared.proto"
            "${PROJECT_SOURCE_DIR}/client/protobuf/appearances.proto"
    )
    protobuf_generate(
        TARGET appearance_proto
        LANGUAGE cpp
        IMPORT_DIRS "${PROJECT_SOURCE_DIR}/client/protobuf"
        PROTOC_OUT_DIR "${PROJECT_BINARY_DIR}/generated/protobuf"
    )
    target_include_directories(
        appearance_proto
        PUBLIC
            "${PROJECT_BINARY_DIR}/generated/protobuf"
    )
    target_link_libraries(appearance_proto PUBLIC protobuf::libprotobuf)
    project_apply_cpp_options(appearance_proto)

    add_library(
        appearance_catalog
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/assets/appearance_catalog.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/assets/appearance_catalog_loader.cpp"
    )
    target_include_directories(
        appearance_catalog
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(appearance_catalog PUBLIC appearance_proto Qt6::Core PRIVATE core)
    project_apply_cpp_options(appearance_catalog)

    add_library(
        asset_compression
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/assets/lzma_stream_decoder.cpp"
    )
    target_include_directories(
        asset_compression
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(asset_compression PRIVATE LibLZMA::LibLZMA)
    project_apply_cpp_options(asset_compression)

    add_library(
        sprite_sheet_assets
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/assets/sprite_sheet_loader.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/assets/sprite_sheet_loader.h"
            "${PROJECT_SOURCE_DIR}/client/src/assets/sprite_sheet_type.h"
            "${PROJECT_SOURCE_DIR}/client/src/assets/sprite_sheet_catalog_status.h"
            "${PROJECT_SOURCE_DIR}/client/src/assets/sprite_sheet_image_result.h"
            "${PROJECT_SOURCE_DIR}/client/src/assets/sprite_image_status.h"
    )
    target_include_directories(
        sprite_sheet_assets
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(sprite_sheet_assets PUBLIC asset_compression Qt6::Core Qt6::Gui)
    project_apply_cpp_options(sprite_sheet_assets)

    add_library(
        protocol
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/protocol/binary/adler32.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/binary/length_prefixed_string.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/binary/little_endian.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/compression/raw_deflate.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/crypto/raw_rsa.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/crypto/xtea.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/handshake/world_challenge_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/handshake/world_login_block_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/handshake/world_login_packet_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/framing/modern_frame.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/framing/modern_session_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/game/initial_world_response_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/game/map_description_header_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/game/map_description_codec.cpp"
            "${PROJECT_SOURCE_DIR}/client/src/protocol/game/map_tile_terminator_codec.cpp"
    )
    target_include_directories(
        protocol
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(protocol PRIVATE core OpenSSL::Crypto ZLIB::ZLIB)
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
        world_session_application
        STATIC
            "${PROJECT_SOURCE_DIR}/client/src/application/world/world_session_service.cpp"
    )
    target_include_directories(
        world_session_application
        PUBLIC
            "${PROJECT_SOURCE_DIR}/client/src"
    )
    target_link_libraries(world_session_application PUBLIC appearance_catalog protocol transport Qt6::Core PRIVATE core)
    project_apply_cpp_options(world_session_application)
    set_target_properties(world_session_application PROPERTIES AUTOMOC ON)

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
