@echo off
REM Quick deployment script for DEV environment (unmanaged)
REM Usage: deploy-dev.bat SolutionName

if "%1"=="" (
    echo Error: Solution name required
    echo Usage: deploy-dev.bat SolutionName
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File .\deploy-solution.ps1 -SolutionName "%1" -TargetEnv DEV -Export
