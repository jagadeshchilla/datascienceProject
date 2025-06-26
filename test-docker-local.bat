@echo off
echo Starting local Docker test for Wine Quality Prediction Project...

REM Stop and remove any existing container
docker stop wine-quality-test 2>nul
docker rm wine-quality-test 2>nul

REM Build the image locally
echo Building Docker image...
docker build -t datascienceproject:local .

if errorlevel 1 (
    echo Failed to build Docker image
    exit /b 1
)

REM Check if DAGSHUB_TOKEN is set
if "%DAGSHUB_TOKEN%"=="" (
    echo WARNING: DAGSHUB_TOKEN environment variable is not set
    echo Please set it with: set DAGSHUB_TOKEN=your_token_here
    echo Continuing without DagsHub integration...
    set MLFLOW_ENV_VARS=
) else (
    echo DagsHub token found, setting up MLflow environment...
    set MLFLOW_ENV_VARS=-e MLFLOW_TRACKING_URI=https://dagshub.com/jagadeshchilla/datascienceProject.mlflow -e MLFLOW_TRACKING_USERNAME=jagadeshchilla -e MLFLOW_TRACKING_PASSWORD=%DAGSHUB_TOKEN%
)

REM Run the container
echo Starting container...
docker run -d ^
    --name wine-quality-test ^
    -p 8080:8080 ^
    %MLFLOW_ENV_VARS% ^
    datascienceproject:local

if errorlevel 1 (
    echo Failed to start container
    exit /b 1
)

echo Container started. Waiting for application to be ready...
timeout /t 15 /nobreak >nul

REM Check container status
echo Checking container status...
docker ps | findstr wine-quality-test

REM Show container logs
echo Container logs:
docker logs wine-quality-test

REM Test health endpoint
echo Testing health endpoint...
curl -f http://localhost:8080/health
if errorlevel 1 (
    echo Health check failed. Container logs:
    docker logs wine-quality-test
    goto cleanup
)

REM Test homepage
echo Testing homepage...
curl -f http://localhost:8080/
if errorlevel 1 (
    echo Homepage test failed
    goto cleanup
)

echo.
echo ========================================
echo SUCCESS: Container is running properly!
echo ========================================
echo Access the application at: http://localhost:8080
echo Health check: http://localhost:8080/health
echo.
echo To stop the container: docker stop wine-quality-test
echo To view logs: docker logs wine-quality-test
echo.
goto end

:cleanup
echo Cleaning up failed container...
docker stop wine-quality-test
docker rm wine-quality-test

:end
pause 