# Azure Voice Services Startup Script for PowerShell
Write-Host "🎙️ Starting Azure Voice Services Server" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Get script directory and change to it
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "📁 Current directory: $(Get-Location)" -ForegroundColor Cyan

# Check if environment variables are set
if (-not $env:AZURE_SPEECH_KEY) {
    Write-Host "❌ AZURE_SPEECH_KEY environment variable not set!" -ForegroundColor Red
    Write-Host "Please set it with:" -ForegroundColor Yellow
    Write-Host '$env:AZURE_SPEECH_KEY="your_key_here"' -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not $env:AZURE_SPEECH_REGION) {
    Write-Host "❌ AZURE_SPEECH_REGION environment variable not set!" -ForegroundColor Red
    Write-Host "Please set it with:" -ForegroundColor Yellow
    Write-Host '$env:AZURE_SPEECH_REGION="your_region_here"' -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Environment variables are set" -ForegroundColor Green
Write-Host "🚀 Starting voice server..." -ForegroundColor Cyan

try {
    python "ATLAS_APP_voice\start_voice_server.py"
}
catch {
    Write-Host "❌ Error starting server: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "⏹️ Server stopped" -ForegroundColor Yellow
Read-Host "Press Enter to exit"
