# PowerApps Solution Deployment Script
# Handles export, pack, import across DEV -> TEST -> PROD environments
# Usage: .\deploy-solution.ps1 -SolutionName "YourSolution" -TargetEnv "TEST" [-Export] [-Managed]

param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("DEV", "TEST", "PROD")]
    [string]$TargetEnv,

    [switch]$Export = $false,
    [switch]$Managed = $false,
    [switch]$SkipChecks = $false,
    [string]$ExportPath = ".\exports",
    [string]$SourcePath = ".\src"
)

# Configuration
$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Color output functions
function Write-Success { param([string]$Message) Write-Host $Message -ForegroundColor Green }
function Write-Warning { param([string]$Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param([string]$Message) Write-Host $Message -ForegroundColor Cyan }

# Verify PAC CLI is installed
function Test-PacCli {
    try {
        $version = pac --version 2>&1
        Write-Success "✓ PAC CLI found: $version"
        return $true
    } catch {
        Write-Error "✗ PAC CLI not found. Install from: https://aka.ms/PowerAppsCLI"
        exit 1
    }
}

# Get current authenticated environment
function Get-CurrentEnvironment {
    try {
        $orgInfo = pac org who 2>&1 | Out-String
        if ($orgInfo -match "Friendly Name\s+:\s+(.+)") {
            return $matches[1].Trim()
        }
        return "Unknown"
    } catch {
        return "Not authenticated"
    }
}

# List available environments and select
function Select-Environment {
    param([string]$EnvType)

    Write-Info "`n📋 Available environments:"
    pac auth list

    Write-Host "`nSelect $EnvType environment by index: " -NoNewline
    $index = Read-Host

    try {
        pac auth select --index $index
        $currentEnv = Get-CurrentEnvironment
        Write-Success "✓ Connected to: $currentEnv"
        return $currentEnv
    } catch {
        Write-Error "✗ Failed to select environment"
        exit 1
    }
}

# Export solution from current environment
function Export-Solution {
    param([string]$Name, [bool]$AsManaged)

    $managedFlag = if ($AsManaged) { "--managed" } else { "" }
    $exportType = if ($AsManaged) { "managed" } else { "unmanaged" }
    $zipFile = Join-Path $ExportPath "$Name-$exportType-$timestamp.zip"

    Write-Info "`n📦 Exporting solution '$Name' ($exportType)..."

    # Create export directory if needed
    if (!(Test-Path $ExportPath)) {
        New-Item -ItemType Directory -Path $ExportPath | Out-Null
    }

    try {
        pac solution export --name $Name --path $zipFile $managedFlag --overwrite
        Write-Success "✓ Exported to: $zipFile"
        return $zipFile
    } catch {
        Write-Error "✗ Export failed: $_"
        exit 1
    }
}

# Unpack solution to source control
function Unpack-Solution {
    param([string]$ZipFile)

    Write-Info "`n📂 Unpacking solution to source control..."

    try {
        pac solution unpack --zipfile $ZipFile --folder $SourcePath --packagetype Both --allowDelete
        Write-Success "✓ Unpacked to: $SourcePath"

        # Git status check
        Write-Info "`n📊 Git changes:"
        git status --short
    } catch {
        Write-Error "✗ Unpack failed: $_"
        exit 1
    }
}

# Pack solution from source control
function Pack-Solution {
    param([string]$Name, [bool]$AsManaged)

    $managedFlag = if ($AsManaged) { "Managed" } else { "Unmanaged" }
    $zipFile = Join-Path $ExportPath "$Name-$(if ($AsManaged) { 'managed' } else { 'unmanaged' })-$timestamp.zip"

    Write-Info "`n📦 Packing solution from source ($managedFlag)..."

    try {
        pac solution pack --folder $SourcePath --zipfile $zipFile --packagetype $managedFlag
        Write-Success "✓ Packed to: $zipFile"
        return $zipFile
    } catch {
        Write-Error "✗ Pack failed: $_"
        exit 1
    }
}

# Import solution to current environment
function Import-Solution {
    param([string]$ZipFile)

    Write-Info "`n📥 Importing solution..."
    Write-Warning "⚠ This will modify the current environment!"

    if (!$SkipChecks) {
        Write-Host "Continue? (y/n): " -NoNewline
        $confirm = Read-Host
        if ($confirm -ne "y") {
            Write-Warning "Import cancelled"
            exit 0
        }
    }

    try {
        pac solution import --path $ZipFile --activate-plugins --force-overwrite
        Write-Success "✓ Import completed successfully"
    } catch {
        Write-Error "✗ Import failed: $_"
        exit 1
    }
}

# Run solution checker
function Test-Solution {
    param([string]$ZipFile)

    Write-Info "`n🔍 Running solution checker..."
    Write-Warning "(This may take several minutes)"

    try {
        pac solution check --path $ZipFile --outputDirectory "$ExportPath\checker-results"
        Write-Success "✓ Solution checker completed. Review results in: $ExportPath\checker-results"
    } catch {
        Write-Warning "⚠ Solution checker failed or found issues. Review logs."
    }
}

# Validate environment rules
function Test-EnvironmentRules {
    param([string]$EnvType, [bool]$IsManaged)

    # PROD must use managed solutions
    if ($EnvType -eq "PROD" -and !$IsManaged) {
        Write-Error "✗ PROD environment requires managed solutions. Use -Managed flag."
        exit 1
    }

    # TEST should use managed solutions
    if ($EnvType -eq "TEST" -and !$IsManaged) {
        Write-Warning "⚠ TEST environment should use managed solutions. Consider using -Managed flag."
    }

    # DEV typically uses unmanaged
    if ($EnvType -eq "DEV" -and $IsManaged) {
        Write-Warning "⚠ DEV environment typically uses unmanaged solutions."
    }

    Write-Success "✓ Environment rules validated"
}

# Main deployment workflow
function Start-Deployment {
    Write-Host @"

╔════════════════════════════════════════════╗
║   Power Platform Solution Deployment       ║
╚════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

    Write-Info "Solution:  $SolutionName"
    Write-Info "Target:    $TargetEnv"
    Write-Info "Export:    $Export"
    Write-Info "Managed:   $Managed"
    Write-Info "Timestamp: $timestamp"

    # Step 1: Verify PAC CLI
    Test-PacCli

    # Step 2: Validate rules
    Test-EnvironmentRules -EnvType $TargetEnv -IsManaged $Managed

    # Step 3: Export from source (if requested)
    $zipFile = $null
    if ($Export) {
        Write-Info "`n🔄 STEP 1: Export from source environment"
        Write-Host "Connect to SOURCE environment (typically DEV):"
        Select-Environment -EnvType "SOURCE" | Out-Null
        $zipFile = Export-Solution -Name $SolutionName -AsManaged $Managed

        # Optional: Unpack to source control (for DEV exports)
        if ($TargetEnv -eq "DEV" -and !$Managed) {
            Write-Host "`nUnpack to source control? (y/n): " -NoNewline
            $unpack = Read-Host
            if ($unpack -eq "y") {
                Unpack-Solution -ZipFile $zipFile
            }
        }
    } else {
        # Pack from source control
        Write-Info "`n🔄 STEP 1: Pack from source control"
        $zipFile = Pack-Solution -Name $SolutionName -AsManaged $Managed
    }

    # Step 4: Optional solution checker (for TEST/PROD)
    if (($TargetEnv -eq "TEST" -or $TargetEnv -eq "PROD") -and !$SkipChecks) {
        Test-Solution -ZipFile $zipFile
        Write-Host "`nContinue with import? (y/n): " -NoNewline
        $continue = Read-Host
        if ($continue -ne "y") {
            Write-Warning "Deployment cancelled"
            exit 0
        }
    }

    # Step 5: Import to target environment
    Write-Info "`n🔄 STEP 2: Import to $TargetEnv environment"
    Write-Host "Connect to TARGET ($TargetEnv) environment:"
    $targetEnvName = Select-Environment -EnvType $TargetEnv
    Import-Solution -ZipFile $zipFile

    # Success summary
    Write-Host @"

╔════════════════════════════════════════════╗
║          ✓ Deployment Successful           ║
╚════════════════════════════════════════════╝

"@ -ForegroundColor Green

    Write-Info "Solution:     $SolutionName"
    Write-Info "Environment:  $targetEnvName"
    Write-Info "Package:      $zipFile"
    Write-Info "Type:         $(if ($Managed) { 'Managed' } else { 'Unmanaged' })"
}

# Execute deployment
try {
    Start-Deployment
} catch {
    Write-Error "`n✗ Deployment failed: $_"
    exit 1
}
