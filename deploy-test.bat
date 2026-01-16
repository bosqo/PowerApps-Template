@echo off
REM Quick deployment script for TEST environment (managed)
REM Usage: deploy-test.bat SolutionName

if "%1"=="" (
    echo Error: Solution name required
    echo Usage: deploy-test.bat SolutionName
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File .\deploy-solution.ps1 -SolutionName "%1" -TargetEnv TEST -Managed
