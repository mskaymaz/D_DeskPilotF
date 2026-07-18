cmake_minimum_required(VERSION 3.21)

project(D_DeskPilotC VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(DeskPilotC
    src/main.cpp
)

qt_add_qml_module(DeskPilotC
    URI DeskPilot
    VERSION 1.0
    QML_FILES
        qml/Main.qml
)

target_link_libraries(DeskPilotC
    PRIVATE Qt6::Quick
)
