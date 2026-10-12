# =========================================================================
# 			CONFIGURATION 
# =========================================================================
$DescPrefix     = "Compile Hazel and Sandbox as"

# Configuration types
$Debug        = "Debug"
$Release      = "Release"
$Distribution = "Dist"

function Run-CMakeBuild([string]$Config) {
    Write-Host "Executing $Config..." -ForegroundColor Cyan
    # Run configuration, then build if configuration succeeds
    cmake -S . -B bin-int
    if ($LASTEXITCODE -eq 0) {
        cmake --build bin-int --config $Config
    }
}

# =========================================================================
# MENU DISPLAY
# =========================================================================
do {
    Clear-Host
    Write-Host "========================================="
    Write-Host "          POWERSHELL COMMAND MENU        "
    Write-Host "========================================="
    Write-Host "1. $DescPrefix $Debug"
    Write-Host "2. $DescPrefix $Release"
    Write-Host "3. $DescPrefix $Distribution"
    Write-Host "4. Exit"
    Write-Host "========================================="
    
    $Choice = Read-Host "Enter your choice (1-4)"

    switch ($Choice) {
        "1" { Run-CMakeBuild $Debug }
        "2" { Run-CMakeBuild $Release }
        "3" { Run-CMakeBuild $Distribution }
        "4" { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid choice, please try again." -ForegroundColor Red }
    }
    
    if ($Choice -ne "4") {
        Read-Host "Press Enter to continue..."
    }
} while ($Choice -ne "4")