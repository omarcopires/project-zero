include_guard(GLOBAL)

function(project_add_tests)
    add_executable(
        qml_integration_tests
        "${PROJECT_SOURCE_DIR}/client/tests/qml_bootstrap_test.cpp"
    )
    project_attach_frontend_resources(qml_integration_tests)
    target_link_libraries(
        qml_integration_tests
        PRIVATE
            qml_enum_values
            client_translations
            Qt6::Gui
            Qt6::Qml
            Qt6::Quick
            Qt6::QuickControls2
            Qt6::Test
    )
    project_apply_cpp_options(qml_integration_tests)
    set_target_properties(qml_integration_tests PROPERTIES AUTOMOC ON)
    add_test(NAME qml_integration.loadsOriginalClientWindow COMMAND qml_integration_tests)
    set_tests_properties(
        qml_integration.loadsOriginalClientWindow
        PROPERTIES
            ENVIRONMENT
                "QT_QPA_PLATFORM=minimal;QT_QPA_PLATFORM_PLUGIN_PATH=${Qt6Core_DIR}/../../Qt6/plugins/platforms;QT_PLUGIN_PATH=${Qt6Core_DIR}/../../Qt6/plugins;QML_IMPORT_PATH=${Qt6Core_DIR}/../../Qt6/qml"
            ENVIRONMENT_MODIFICATION
                "PATH=path_list_prepend:${Qt6Core_DIR}/../../bin"
    )

    add_executable(
        unit_tests
        "${PROJECT_SOURCE_DIR}/client/tests/authentication_coordinator_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/bootstrap_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/character_selector_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/appearance_catalog_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/lzma_stream_decoder_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/sprite_sheet_loader_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/fixture_inspector_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/initial_world_response_codec_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/logger_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/login_codec_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/map_description_codec_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/message_formatter_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/modern_frame_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/modern_session_codec_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/protocol_binary_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/raw_deflate_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/raw_rsa_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/world_challenge_codec_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/world_login_block_codec_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/world_login_packet_codec_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/xtea_test.cpp"
    )
    target_link_libraries(
        unit_tests
        PRIVATE
            core
            diagnostic_support
            appearance_catalog
            asset_compression
            sprite_sheet_assets
            LibLZMA::LibLZMA
            logging
            protocol
            session
            GTest::gtest_main
    )
    project_apply_cpp_options(unit_tests)

    include(GoogleTest)
    gtest_discover_tests(unit_tests)

    add_executable(
        qt_integration_tests
        "${PROJECT_SOURCE_DIR}/client/tests/qt_bootstrap_test.cpp"
    )
    target_link_libraries(
        qt_integration_tests
        PRIVATE
            transport
            Qt6::Core
            Qt6::Network
            Qt6::Test
    )
    project_apply_cpp_options(qt_integration_tests)
    set_target_properties(qt_integration_tests PROPERTIES AUTOMOC ON)

    foreach(
        test_case
        IN ITEMS
            providesCoreApplication
            connectsAndClosesCleanly
            buffersIncomingData
            rejectsInputBeyondConfiguredLimit
            rejectsOutputBeyondConfiguredLimit
            rejectsInvalidConfiguration
            reportsInactivityTimeout
            reportsRemoteClosure
            closesIdempotently
    )
        add_test(
            NAME "qt_integration.${test_case}"
            COMMAND qt_integration_tests "${test_case}"
        )
    endforeach()

    add_executable(
        http_integration_tests
        "${PROJECT_SOURCE_DIR}/client/tests/http_transport_test.cpp"
    )
    target_link_libraries(
        http_integration_tests
        PRIVATE
            http_transport
            Qt6::Core
            Qt6::Network
            Qt6::Test
    )
    project_apply_cpp_options(http_integration_tests)
    set_target_properties(http_integration_tests PROPERTIES AUTOMOC ON)

    foreach(
        test_case
        IN ITEMS
            completesBoundedRequest
            rejectsOversizedResponse
            reportsTimeout
            reportsCancellation
            rejectsRedirect
            rejectsInvalidConfiguration
            rejectsNonLoopbackPlainHttp
            rejectsConcurrentOperation
    )
        add_test(
            NAME "http_integration.${test_case}"
            COMMAND http_integration_tests "${test_case}"
        )
    endforeach()

    add_executable(
        authentication_integration_tests
        "${PROJECT_SOURCE_DIR}/client/tests/authentication_service_test.cpp"
    )
    target_link_libraries(
        authentication_integration_tests
        PRIVATE
            authentication_application
            Qt6::Core
            Qt6::Network
            Qt6::Test
    )
    project_apply_cpp_options(authentication_integration_tests)
    set_target_properties(authentication_integration_tests PROPERTIES AUTOMOC ON)

    foreach(
        test_case
        IN ITEMS
            authenticatesSyntheticSession
            classifiesRejectedCredentials
            stopsAtUnsupportedChallenge
            rejectsIncompatibleResponse
            reportsTimeout
            cancelsActiveRequest
            rejectsConcurrentAttempt
    )
        add_test(
            NAME "authentication_integration.${test_case}"
            COMMAND authentication_integration_tests "${test_case}"
        )
    endforeach()

    add_executable(
        world_session_integration_tests
        "${PROJECT_SOURCE_DIR}/client/tests/world_session_service_test.cpp"
    )
    target_link_libraries(
        world_session_integration_tests
        PRIVATE
            world_session_application
            protocol
            Qt6::Core
            Qt6::Network
            Qt6::Test
    )
    project_apply_cpp_options(world_session_integration_tests)
    set_target_properties(world_session_integration_tests PROPERTIES AUTOMOC ON)

    foreach(
        test_case
        IN ITEMS
            completesHandshakeAndPublishesFirstPayload
            buffersFragmentedChallenge
            rejectsMalformedChallenge
            rejectsConcurrentStart
    )
        add_test(
            NAME "world_session_integration.${test_case}"
            COMMAND world_session_integration_tests "${test_case}"
        )
    endforeach()
endfunction()
