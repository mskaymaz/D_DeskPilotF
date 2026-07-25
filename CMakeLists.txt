cmake_minimum_required(VERSION 3.21)

project(D_DeskPilotC VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11 REQUIRED COMPONENTS Quick)

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
        src/battery_state.h
        src/battery_service.h
        src/battery_model.cpp
        src/battery_model.h
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

qt_add_qml_module(DeskPilotC
    URI DeskPilot
    VERSION 1.0
    QML_FILES
        qml/BasePanel.qml
        qml/BaseText.qml
        qml/BatteryIcon.qml
        qml/DesignTokens.qml
        qml/FreeLayout.qml
        qml/GroupedLayout.qml
        qml/Main.qml
        qml/ModuleWindow.qml
    RESOURCES
        ${DESKPILOT_FONT_FILES}
)

set_target_properties(DeskPilotC PROPERTIES
    OUTPUT_NAME "main"
)

target_link_libraries(DeskPilotC
    PRIVATE Qt6::Quick
)

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
