@echo off
REM Data Science Project Docker Runner for Windows
REM Usage: run.bat [build|run|stop|logs|clean]

SET PROJECT_NAME=datascienceproject
SET CONTAINER_NAME=datascienceproject-container
SET IMAGE_NAME=datascienceproject:latest
SET PORT=8080

IF "%1"=="" GOTO print_usage
IF "%1"=="build" GOTO build_image
IF "%1"=="run" GOTO run_container
IF "%1"=="stop" GOTO stop_container
IF "%1"=="logs" GOTO show_logs
IF "%1"=="clean" GOTO clean_all
GOTO print_usage

:print_usage
echo Usage: %0 [build^|run^|stop^|logs^|clean]
echo.
echo Commands:
echo   build   - Build the Docker image
echo   run     - Run the container (builds if needed)
echo   stop    - Stop and remove the container
echo   logs    - Show container logs
echo   clean   - Remove container and image
echo.
echo Environment Variables:
echo   DAGSHUB_TOKEN - Your DagsHub access token (required)
GOTO end

:check_dagshub_token
IF "%DAGSHUB_TOKEN%"=="" (
    echo Error: DAGSHUB_TOKEN environment variable is not set!
    echo Please set your DagsHub token:
    echo set DAGSHUB_TOKEN=your_token_here
    exit /b 1
)
GOTO :EOF

:build_image
echo Building Docker image...
docker build -t %IMAGE_NAME% .
IF %ERRORLEVEL% EQU 0 (
    echo ✅ Docker image built successfully!
) ELSE (
    echo ❌ Failed to build Docker image
    exit /b 1
)
GOTO end

:run_container
CALL :check_dagshub_token
IF %ERRORLEVEL% NEQ 0 GOTO end

REM Stop existing container if running
FOR /f %%i IN ('docker ps -q -f name^=%CONTAINER_NAME% 2^>nul') DO (
    echo Stopping existing container...
    docker stop %CONTAINER_NAME%
)

REM Remove existing container if exists
FOR /f %%i IN ('docker ps -aq -f name^=%CONTAINER_NAME% 2^>nul') DO (
    echo Removing existing container...
    docker rm %CONTAINER_NAME%
)

REM Check if image exists, build if not
FOR /f %%i IN ('docker images -q %IMAGE_NAME% 2^>nul') DO SET image_exists=%%i
IF "%image_exists%"=="" (
    echo Image not found, building...
    CALL :build_image
    IF %ERRORLEVEL% NEQ 0 GOTO end
)

echo Starting container...
docker run -d --name %CONTAINER_NAME% -p %PORT%:8080 -e MLFLOW_TRACKING_PASSWORD="%DAGSHUB_TOKEN%" -v "%CD%\artifacts:/app/artifacts" -v "%CD%\logs:/app/logs" %IMAGE_NAME%

IF %ERRORLEVEL% EQU 0 (
    echo ✅ Container started successfully!
    echo 🌐 Application available at: http://localhost:%PORT%
    echo 📋 Use '%0 logs' to view logs
) ELSE (
    echo ❌ Failed to start container
    exit /b 1
)
GOTO end

:stop_container
echo Stopping container...
docker stop %CONTAINER_NAME% 2>nul
docker rm %CONTAINER_NAME% 2>nul
echo ✅ Container stopped and removed
GOTO end

:show_logs
FOR /f %%i IN ('docker ps -q -f name^=%CONTAINER_NAME% 2^>nul') DO SET container_running=%%i
IF "%container_running%"=="" (
    echo ❌ Container is not running
    exit /b 1
) ELSE (
    echo Container logs (Ctrl+C to exit):
    docker logs -f %CONTAINER_NAME%
)
GOTO end

:clean_all
echo Cleaning up...
docker stop %CONTAINER_NAME% 2>nul
docker rm %CONTAINER_NAME% 2>nul
docker rmi %IMAGE_NAME% 2>nul
echo ✅ Cleanup completed
GOTO end

:end 