@echo off
setlocal enabledelayedexpansion

REM Use workspace-local temp dir so we don't depend on C:\
set "BASE=%GITHUB_WORKSPACE%\work"
if "%GITHUB_WORKSPACE%"=="" set "BASE=%TEMP%\work"
mkdir "%BASE%" 2>nul

set "LOG=%BASE%\run.log"
echo [%date% %time%] Starting the loop process... > "%LOG%"
echo Running 150 iterations of npm install inside numbered folders. >> "%LOG%"

for /l %%i in (1,1,150) do (
    echo. >> "%LOG%"
    echo [%date% %time%] Iteration %%i of 150 >> "%LOG%"

    set "ITER=%BASE%\%%i"
    mkdir "%%ITER%%" 2>nul

    pushd "%%ITER%%"
      call npm cache clean --force >> "%LOG%" 2>&1

      REM Create a minimal package context so npm install is happy
      call npm init -y >> "%LOG%" 2>&1

      REM Your install
      call npm install --save-dev cypress-intercept-search >> "%LOG%" 2>&1
    popd

    REM Brief pause between iterations
    timeout /t 2 /nobreak >nul 2>&1

    REM Clean up the iteration folder
    rmdir /s /q "%%ITER%%" 2>nul
    echo [%date% %time%] Iteration %%i completed. >> "%LOG%"
)

echo [%date% %time%] All iterations completed. >> "%LOG%"

endlocal
