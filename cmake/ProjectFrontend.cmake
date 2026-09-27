include_guard(GLOBAL)

function(project_sanitize_qmldir_resources files_variable resource_base name_prefix)
    set(resource_files "${${files_variable}}")

    foreach(resource_file IN LISTS resource_files)
        get_filename_component(resource_filename "${resource_file}" NAME)
        if(NOT resource_filename STREQUAL "qmldir")
            continue()
        endif()

        file(STRINGS "${resource_file}" qmldir_lines)
        set(qmldir_content "")
        set(has_plugin_metadata FALSE)
        foreach(qmldir_line IN LISTS qmldir_lines)
            if(qmldir_line MATCHES "^(linktarget|plugin|classname|typeinfo)[ \t]|^optional[ \t]+plugin[ \t]")
                set(has_plugin_metadata TRUE)
            else()
                string(APPEND qmldir_content "${qmldir_line}\n")
            endif()
        endforeach()

        if(has_plugin_metadata)
            file(RELATIVE_PATH resource_alias "${resource_base}" "${resource_file}")
            string(MAKE_C_IDENTIFIER "${name_prefix}_${resource_alias}" generated_name)
            set(generated_qmldir "${PROJECT_BINARY_DIR}/${generated_name}")
            file(GENERATE OUTPUT "${generated_qmldir}" CONTENT "${qmldir_content}")
            set_source_files_properties(
                "${generated_qmldir}"
                PROPERTIES QT_RESOURCE_ALIAS "${resource_alias}"
            )

            list(REMOVE_ITEM resource_files "${resource_file}")
            list(APPEND resource_files "${generated_qmldir}")
        endif()
    endforeach()

    set(${files_variable} "${resource_files}" PARENT_SCOPE)
endfunction()

function(project_add_frontend_resources)
    # Qt's resource macros build the rcc target name from this namespace.
    # The vcpkg Qt package leaves it unset, which otherwise emits a Ninja
    # dependency on the invalid target "::rcc".
    set(QT_CMAKE_EXPORT_NAMESPACE Qt6)

    add_library(
        frontend_resources
        OBJECT
            "${PROJECT_SOURCE_DIR}/client/src/composition/frontend_resources.cpp"
    )

    file(
        GLOB_RECURSE client_frontend_qml_files
        CONFIGURE_DEPENDS
        "${PROJECT_SOURCE_DIR}/things/qt/qml/qmlcomponents/*"
    )
    file(
        GLOB_RECURSE client_legacy_qml_files
        CONFIGURE_DEPENDS
        "${PROJECT_SOURCE_DIR}/things/qt/qml/QtQuick/LegacyControls/*"
    )
    file(
        GLOB_RECURSE client_frontend_image_files
        CONFIGURE_DEPENDS
        "${PROJECT_SOURCE_DIR}/things/images/*"
    )

    project_sanitize_qmldir_resources(
        client_frontend_qml_files
        "${PROJECT_SOURCE_DIR}/things/qt/qml/qmlcomponents"
        frontend_qml
    )
    project_sanitize_qmldir_resources(
        client_legacy_qml_files
        "${PROJECT_SOURCE_DIR}/things/qt/qml"
        legacy_qml
    )

    qt6_add_resources(
        frontend_resources frontend_qml
        PREFIX "/qt/qml/qmlcomponents"
        BASE "${PROJECT_SOURCE_DIR}/things/qt/qml/qmlcomponents"
        FILES ${client_frontend_qml_files}
    )
    qt6_add_resources(
        frontend_resources legacy_controls_qml
        PREFIX "/qt/qml"
        BASE "${PROJECT_SOURCE_DIR}/things/qt/qml"
        FILES ${client_legacy_qml_files}
    )
    qt6_add_resources(
        frontend_resources frontend_images
        PREFIX "/images"
        BASE "${PROJECT_SOURCE_DIR}/things/images"
        FILES ${client_frontend_image_files}
    )
    qt6_add_resources(
        frontend_resources frontend_classic_skin_images
        PREFIX "/images/skin/classic"
        BASE "${PROJECT_SOURCE_DIR}/things/images"
        FILES ${client_frontend_image_files}
    )
    qt6_add_resources(
        frontend_resources frontend_translations
        PREFIX "/translations"
        BASE "${PROJECT_SOURCE_DIR}/client/translations"
        FILES "${PROJECT_SOURCE_DIR}/client/translations/en.json"
    )
    qt6_add_resources(
        frontend_resources client_qml
        PREFIX "/qt/qml/clientui"
        BASE "${PROJECT_SOURCE_DIR}/client/qml"
        FILES "${PROJECT_SOURCE_DIR}/client/qml/SingleObjectAppearanceInstanceRenderer.qml"
    )
    qt6_add_resources(
        frontend_resources client_icon
        PREFIX "/icons"
        BASE "${PROJECT_SOURCE_DIR}/client/icon"
        FILES "${PROJECT_SOURCE_DIR}/client/icon/client.ico"
    )
    target_link_libraries(frontend_resources PRIVATE Qt6::Core)
endfunction()

function(project_attach_frontend_resources target)
    target_link_libraries(${target} PRIVATE frontend_resources)
endfunction()

function(project_add_frontend)
    add_executable(
        client_app
        "${PROJECT_SOURCE_DIR}/client/src/composition/main.cpp"
    )

    if(WIN32)
        target_sources(
            client_app
            PRIVATE
                "${PROJECT_SOURCE_DIR}/client/icon/client.rc"
                "${PROJECT_SOURCE_DIR}/client/icon/client.ico"
        )
    endif()

    project_add_frontend_resources()
    project_attach_frontend_resources(client_app)

    target_link_libraries(
        client_app
        PRIVATE
            logging
            appearance_image_provider
            world_map_presentation
            qml_enum_values
            client_translations
            Qt6::Gui
            Qt6::Qml
            Qt6::Quick
            Qt6::QuickControls2
    )
    project_apply_cpp_options(client_app)

    set_target_properties(
        client_app
        PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}"
            ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}"
            PDB_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}"
            COMPILE_PDB_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}"
            RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PROJECT_SOURCE_DIR}"
            ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_SOURCE_DIR}"
            PDB_OUTPUT_DIRECTORY_RELEASE "${PROJECT_SOURCE_DIR}"
            COMPILE_PDB_OUTPUT_DIRECTORY_RELEASE "${PROJECT_SOURCE_DIR}"
    )

    if(WIN32)
        file(
            GLOB qt_runtime_dlls
            CONFIGURE_DEPENDS
            "${Qt6Core_DIR}/../../bin/Qt6*.dll"
        )
        file(
            GLOB qt_image_codec_dlls
            CONFIGURE_DEPENDS
            "${Qt6Core_DIR}/../../bin/*jpeg*.dll"
        )
        file(
            GENERATE
            OUTPUT "${PROJECT_BINARY_DIR}/client_qt.conf"
            CONTENT "[Paths]\nPrefix=.\nPlugins=plugins\nQmlImports=qml\n"
        )
        add_custom_command(
            TARGET client_app
            POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                "$<TARGET_RUNTIME_DLLS:client_app>"
                "$<TARGET_FILE_DIR:client_app>"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                ${qt_runtime_dlls}
                "$<TARGET_FILE_DIR:client_app>"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                ${qt_image_codec_dlls}
                "$<TARGET_FILE_DIR:client_app>"
            COMMAND "${CMAKE_COMMAND}" -E copy_directory
                "$<TARGET_FILE_DIR:Qt6::Core>/../Qt6/plugins"
                "$<TARGET_FILE_DIR:client_app>/plugins"
            COMMAND "${CMAKE_COMMAND}" -E copy_directory
                "$<TARGET_FILE_DIR:Qt6::Core>/../Qt6/qml"
                "$<TARGET_FILE_DIR:client_app>/qml"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                "${PROJECT_BINARY_DIR}/client_qt.conf"
                "$<TARGET_FILE_DIR:client_app>/qt.conf"
            COMMAND_EXPAND_LISTS
            COMMENT "Deploying client_app runtime dependencies to the project root"
            VERBATIM
        )
    endif()
endfunction()
