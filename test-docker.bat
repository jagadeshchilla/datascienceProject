@echo off
echo Testing Docker setup for Data Science Project...
echo.

REM Check if Docker is running
docker --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ❌ Docker is not installed or not running
    echo Please install Docker Desktop and make sure it's running
    exit /b 1
)

echo ✅ Docker is installed and running
docker --version

echo.
echo Testing Dockerfile syntax...
docker build --dry-run -t datascienceproject:test . >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo ✅ Dockerfile syntax is valid
) ELSE (
    echo ❌ Dockerfile has syntax errors
    exit /b 1
)

echo.
echo Testing requirements.txt...
IF EXIST requirements.txt (
    echo ✅ requirements.txt found
    echo Dependencies:
    type requirements.txt
) ELSE (
    echo ❌ requirements.txt not found
    exit /b 1
)

echo.
echo Testing project structure...
IF EXIST src\datascience_project (
    echo ✅ Source code structure is correct
) ELSE (
    echo ❌ Source code structure is missing
    exit /b 1
)

IF EXIST templates\index.html (
    echo ✅ Flask templates found
) ELSE (
    echo ❌ Flask templates missing
    exit /b 1
)

IF EXIST app.py (
    echo ✅ Flask app found
) ELSE (
    echo ❌ Flask app missing
    exit /b 1
)

echo.
echo 🎉 All tests passed! Ready for Docker deployment.
echo.
echo Next steps:
echo 1. Set your DagsHub token: set DAGSHUB_TOKEN=your_token_here
echo 2. Build and run: run.bat run
echo 3. Open http://localhost:8080 