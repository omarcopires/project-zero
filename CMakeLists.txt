cmake_minimum_required(VERSION 3.30)

project(client_engine LANGUAGES CXX)

include(CTest)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(ProjectDependencies)
include(ProjectOptions)
include(ProjectFrontend)
include(ProjectTargets)

project_find_dependencies()
project_add_targets()
project_add_frontend()

if(BUILD_TESTING)
    include(ProjectTests)
    project_add_tests()
endif()
