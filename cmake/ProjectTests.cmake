include_guard(GLOBAL)

function(project_add_tests)
    add_executable(
        unit_tests
        "${PROJECT_SOURCE_DIR}/client/tests/bootstrap_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/logger_test.cpp"
        "${PROJECT_SOURCE_DIR}/client/tests/message_formatter_test.cpp"
    )
    target_link_libraries(unit_tests PRIVATE core logging GTest::gtest_main)
    project_apply_cpp_options(unit_tests)

    include(GoogleTest)
    gtest_discover_tests(unit_tests)

    add_executable(
        qt_integration_tests
        "${PROJECT_SOURCE_DIR}/client/tests/qt_bootstrap_test.cpp"
    )
    target_link_libraries(qt_integration_tests PRIVATE Qt6::Core Qt6::Test)
    project_apply_cpp_options(qt_integration_tests)
    set_target_properties(qt_integration_tests PROPERTIES AUTOMOC ON)

    add_test(NAME qt_integration_tests COMMAND qt_integration_tests)
endfunction()
