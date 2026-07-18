@echo off
set "APP=%~dp0build-fresh\Release\main.exe"

if not exist "%APP%" (
    echo main.exe bulunamadi. Once build alin:
    echo cmake --build build-fresh --config Release
    exit /b 1
)

pushd "%~dp0build-fresh\Release"
main.exe %*
set "EXITCODE=%ERRORLEVEL%"
popd
exit /b %EXITCODE%
