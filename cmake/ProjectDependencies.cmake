include_guard(GLOBAL)

function(project_find_dependencies)
    find_package(Qt6 6.11.1 EXACT REQUIRED COMPONENTS Core Network Test)
    find_package(spdlog CONFIG REQUIRED)

    if(BUILD_TESTING)
        find_package(GTest CONFIG REQUIRED)
    endif()
endfunction()
