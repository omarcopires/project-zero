include_guard(GLOBAL)

function(project_add_tests)
    add_executable(
        unit_tests
        "${PROJECT_SOURCE_DIR}/client/tests/bootstrap_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/fixture_inspector_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/logger_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/message_formatter_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/modern_frame_test.cpp"
    )
    target_link_libraries(
        unit_tests
        PRIVATE
            core
            diagnostic_support
            logging
            protocol
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
endfunction()
