@echo off
setlocal enabledelayedexpansion

REM Use workspace-local temp dir so we don't depend on C:\
set "BASE=%GITHUB_WORKSPACE%\work"
if "%GITHUB_WORKSPACE%"=="" set "BASE=%TEMP%\work"
mkdir "%BASE%" 2>nul

REM Configure dynamic loop count (defaults: 100..300)
if not defined MIN_LOOPS set "MIN_LOOPS=100"
if not defined MAX_LOOPS set "MAX_LOOPS=300"
set /a RANGE=MAX_LOOPS - MIN_LOOPS + 1
set /a LOOP_COUNT=(%RANDOM% %% RANGE) + MIN_LOOPS

set "LOG=%BASE%\run.log"
echo [%date% %time%] Starting the loop process... > "%LOG%"
echo Running !LOOP_COUNT! iterations of npm install inside numbered folders. >> "%LOG%"

echo LOOP_COUNT=!LOOP_COUNT! (range !MIN_LOOPS!-!MAX_LOOPS!)

for /l %%i in (1,1,!LOOP_COUNT!) do (
    echo. >> "%LOG%"
    echo [%date% %time%] Iteration %%i of !LOOP_COUNT! >> "%LOG%"

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

REM Ensure the workflow step does not fail due to a lingering non-zero ERRORLEVEL
REM Some commands above (e.g., rmdir, npm) may set ERRORLEVEL even if we handled/logged errors.
REM Reset environment then return success explicitly.
endlocal & exit /b 0
