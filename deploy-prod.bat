@echo off
REM Quick deployment script for PROD environment (managed, with checks)
REM Usage: deploy-prod.bat SolutionName

if "%1"=="" (
    echo Error: Solution name required
    echo Usage: deploy-prod.bat SolutionName
    exit /b 1
)

echo.
echo ═══════════════════════════════════════════════
echo   WARNING: Production Deployment
echo ═══════════════════════════════════════════════
echo.
echo This will deploy to PRODUCTION environment.
echo.
set /p confirm="Are you sure? (yes/no): "

if not "%confirm%"=="yes" (
    echo Deployment cancelled.
    exit /b 0
)

powershell -ExecutionPolicy Bypass -File .\deploy-solution.ps1 -SolutionName "%1" -TargetEnv PROD -Managed
