cmake_minimum_required(VERSION 3.21)

project(D_DeskPilotC VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11 REQUIRED COMPONENTS Quick Test Sql)

qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(DeskPilotC
    src/main.cpp
)

target_sources(DeskPilotC
    PRIVATE
        src/clock_model.cpp
        src/clock_model.h
        src/clock_service.cpp
        src/clock_service.h
        src/date_service.cpp
        src/date_service.h
        src/date_model.cpp
        src/date_model.h
        src/window_input_mask_controller.cpp
        src/window_input_mask_controller.h
        src/battery_state.h
        src/battery_service.h
        src/battery_model.cpp
        src/battery_model.h
    src/settings_schema.cpp
    src/settings_schema.h
    src/startup_service.cpp
    src/startup_service.h
        src/todo_domain.cpp
        src/todo_domain.h
        src/todo_model.cpp
        src/todo_model.h
        src/todo_model.cpp
        src/todo_model.h
        src/todo_repository.cpp
        src/todo_repository.h
)

if(WIN32)
    target_sources(DeskPilotC
        PRIVATE
            src/windows_battery_service.cpp
            src/windows_battery_service.h
    )
endif()

set_source_files_properties(qml/DesignTokens.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

file(GLOB DESKPILOT_FONT_FILES CONFIGURE_DEPENDS
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/*"
)

file(GLOB DESKPILOT_IMAGE_FILES CONFIGURE_DEPENDS
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/img/icons/*"
    "${CMAKE_CURRENT_SOURCE_DIR}/img/logos/*"
)

qt_add_qml_module(DeskPilotC
    URI DeskPilot
    VERSION 1.0
    QML_FILES
        qml/BaseText.qml
        qml/BatteryIcon.qml
        qml/BatterySettingsPopup.qml
        qml/ClockSettingsPopup.qml
        qml/DateSettingsPopup.qml
        qml/DesignTokens.qml
        qml/FreeLayout.qml
        qml/GroupedLayout.qml
        qml/LayoutSettingsPopup.qml
        qml/Main.qml
        qml/ModuleWindow.qml
        qml/NotificationSettingsPopup.qml
        qml/QuickActions.qml
        qml/QuickActionsSettingsPopup.qml
        qml/TodoPanel.qml
        qml/TodoCard.qml
        qml/NewTaskDialog.qml
        qml/EditTaskDialog.qml
    RESOURCES
        ${DESKPILOT_IMAGE_FILES}
        ${DESKPILOT_FONT_FILES}
)

set_target_properties(DeskPilotC PROPERTIES
    OUTPUT_NAME "main"
)

target_link_libraries(DeskPilotC
    PRIVATE Qt6::Quick Qt6::Sql
)

include(CTest)

if(BUILD_TESTING)
    qt_add_executable(BatteryModelTest
        tests/battery_model_test.cpp
        src/battery_model.cpp
        src/battery_model.h
        src/battery_service.h
        src/battery_state.h
    )

    target_include_directories(BatteryModelTest PRIVATE src)
    target_link_libraries(BatteryModelTest PRIVATE Qt6::Gui Qt6::Test)

    if(WIN32)
        foreach(qt_runtime IN ITEMS Qt6::Core Qt6::Gui Qt6::Test)
            add_custom_command(TARGET BatteryModelTest POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "$<TARGET_FILE:${qt_runtime}>"
                        "$<TARGET_FILE_DIR:BatteryModelTest>"
                VERBATIM
            )
        endforeach()
    endif()

    add_test(NAME BatteryModelTest COMMAND BatteryModelTest)

    qt_add_executable(SettingsSchemaTest
        tests/settings_schema_test.cpp
        src/settings_schema.cpp
        src/settings_schema.h
    )

    target_include_directories(SettingsSchemaTest PRIVATE src)
    target_link_libraries(SettingsSchemaTest PRIVATE Qt6::Core Qt6::Gui Qt6::Test)

    if(WIN32)
        foreach(qt_runtime IN ITEMS Qt6::Core Qt6::Test)
            add_custom_command(TARGET SettingsSchemaTest POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "$<TARGET_FILE:${qt_runtime}>"
                        "$<TARGET_FILE_DIR:SettingsSchemaTest>"
                VERBATIM
            )
        endforeach()
    endif()

    add_test(NAME SettingsSchemaTest COMMAND SettingsSchemaTest)

    qt_add_executable(TodoDomainTest
        tests/todo_domain_test.cpp
        src/todo_domain.cpp
        src/todo_domain.h
    )

    target_include_directories(TodoDomainTest PRIVATE src)
    target_link_libraries(TodoDomainTest PRIVATE Qt6::Core Qt6::Test)

    if(WIN32)
        foreach(qt_runtime IN ITEMS Qt6::Core Qt6::Test)
            add_custom_command(TARGET TodoDomainTest POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "$<TARGET_FILE:${qt_runtime}>"
                        "$<TARGET_FILE_DIR:TodoDomainTest>"
                VERBATIM
            )
        endforeach()
    endif()

    add_test(NAME TodoDomainTest COMMAND TodoDomainTest)

    qt_add_executable(TodoRepositoryTest
        tests/todo_repository_test.cpp
        src/todo_repository.cpp
        src/todo_repository.h
        src/todo_domain.cpp
        src/todo_domain.h
    )

    target_include_directories(TodoRepositoryTest PRIVATE src)
    target_link_libraries(TodoRepositoryTest PRIVATE Qt6::Core Qt6::Sql Qt6::Test)

    if(WIN32)
        foreach(qt_runtime IN ITEMS Qt6::Core Qt6::Sql Qt6::Test)
            add_custom_command(TARGET TodoRepositoryTest POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "$<TARGET_FILE:${qt_runtime}>"
                        "$<TARGET_FILE_DIR:TodoRepositoryTest>"
                VERBATIM
            )
        endforeach()
        add_custom_command(TARGET TodoRepositoryTest POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory
                    "$<TARGET_FILE_DIR:TodoRepositoryTest>/sqldrivers"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    "$<IF:$<CONFIG:Debug>,$<TARGET_FILE_DIR:Qt6::Sql>/../plugins/sqldrivers/qsqlited.dll,$<TARGET_FILE_DIR:Qt6::Sql>/../plugins/sqldrivers/qsqlite.dll>"
                    "$<TARGET_FILE_DIR:TodoRepositoryTest>/sqldrivers/$<IF:$<CONFIG:Debug>,qsqlited.dll,qsqlite.dll>"
            VERBATIM
        )
    endif()

    add_test(NAME TodoRepositoryTest COMMAND TodoRepositoryTest)

    qt_add_executable(TodoModelTest
        tests/todo_model_test.cpp
        src/todo_model.cpp
        src/todo_model.h
        src/todo_repository.cpp
        src/todo_repository.h
        src/todo_domain.cpp
        src/todo_domain.h
    )

    target_include_directories(TodoModelTest PRIVATE src)
    target_link_libraries(TodoModelTest PRIVATE Qt6::Core Qt6::Sql Qt6::Test)

    if(WIN32)
        foreach(qt_runtime IN ITEMS Qt6::Core Qt6::Sql Qt6::Test)
            add_custom_command(TARGET TodoModelTest POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "$<TARGET_FILE:${qt_runtime}>"
                        "$<TARGET_FILE_DIR:TodoModelTest>"
                VERBATIM
            )
        endforeach()
        add_custom_command(TARGET TodoModelTest POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory
                    "$<TARGET_FILE_DIR:TodoModelTest>/sqldrivers"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    "$<IF:$<CONFIG:Debug>,$<TARGET_FILE_DIR:Qt6::Sql>/../plugins/sqldrivers/qsqlited.dll,$<TARGET_FILE_DIR:Qt6::Sql>/../plugins/sqldrivers/qsqlite.dll>"
                    "$<TARGET_FILE_DIR:TodoModelTest>/sqldrivers/$<IF:$<CONFIG:Debug>,qsqlited.dll,qsqlite.dll>"
            VERBATIM
        )
    endif()

    add_test(NAME TodoModelTest COMMAND TodoModelTest)

    if(WIN32)
        qt_add_executable(WindowsBatteryServiceTest
            tests/windows_battery_service_test.cpp
            src/windows_battery_service.cpp
            src/windows_battery_service.h
            src/battery_service.h
            src/battery_state.h
        )

        target_include_directories(WindowsBatteryServiceTest PRIVATE src)
        target_link_libraries(WindowsBatteryServiceTest PRIVATE Qt6::Gui Qt6::Test)

        foreach(qt_runtime IN ITEMS Qt6::Core Qt6::Gui Qt6::Test)
            add_custom_command(TARGET WindowsBatteryServiceTest POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "$<TARGET_FILE:${qt_runtime}>"
                        "$<TARGET_FILE_DIR:WindowsBatteryServiceTest>"
                VERBATIM
            )
        endforeach()

        add_test(NAME WindowsBatteryServiceTest COMMAND WindowsBatteryServiceTest)
    endif()
endif()

if(WIN32)
    find_program(QT_DEPLOY_TOOL
        NAMES windeployqt
        HINTS "${CMAKE_PREFIX_PATH}/bin"
        REQUIRED
    )

    add_custom_command(TARGET DeskPilotC POST_BUILD
        COMMAND "${QT_DEPLOY_TOOL}"
                --qmldir "${CMAKE_CURRENT_SOURCE_DIR}/qml"
                "$<TARGET_FILE:DeskPilotC>"
        COMMENT "Deploying Qt runtime"
        VERBATIM
    )
endif()
