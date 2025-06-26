@echo off
echo Setting up environment for Wine Quality Prediction Project

echo.
echo This script will help you set up the DAGSHUB_TOKEN environment variable
echo required for MLflow integration with DagsHub.
echo.

REM Check if token is already set
if not "%DAGSHUB_TOKEN%"=="" (
    echo DAGSHUB_TOKEN is already set: %DAGSHUB_TOKEN:~0,10%...
    echo.
    choice /C YN /M "Do you want to update it"
    if errorlevel 2 goto :end
)

echo.
echo Please enter your DagsHub token:
echo You can find it at: https://dagshub.com/user/settings/tokens
echo.
set /p "DAGSHUB_TOKEN=Enter token: "

if "%DAGSHUB_TOKEN%"=="" (
    echo No token provided. Exiting.
    goto :end
)

REM Set the environment variable for current session
set DAGSHUB_TOKEN=%DAGSHUB_TOKEN%

REM Also set it permanently for the user
setx DAGSHUB_TOKEN "%DAGSHUB_TOKEN%" >nul

echo.
echo ========================================
echo Environment setup complete!
echo ========================================
echo DAGSHUB_TOKEN has been set for current session and permanently.
echo.
echo You can now run:
echo   - test-docker-local.bat (to test Docker locally)
echo   - docker-compose up (to run with docker-compose)
echo.
echo Your MLflow experiments will be tracked at:
echo https://dagshub.com/jagadeshchilla/datascienceProject.mlflow
echo.

:end
pause 