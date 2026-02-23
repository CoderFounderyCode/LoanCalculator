# Script to fix the exported Visual Studio template

$templatePath = "D:\OneDrive\Documents\Visual Studio 18\My Exported Templates"
Write-Host "Looking for templates in: $templatePath" -ForegroundColor Cyan

# List available template files
$templates = Get-ChildItem -Path $templatePath -Filter "*.zip" -ErrorAction SilentlyContinue
if ($templates.Count -eq 0) {
    Write-Host "No template files found in $templatePath" -ForegroundColor Yellow
    exit
}

Write-Host "`nAvailable templates:" -ForegroundColor Green
for ($i = 0; $i -lt $templates.Count; $i++) {
    Write-Host "  [$i] $($templates[$i].Name)"
}

# Prompt for template selection
$selection = Read-Host "`nEnter the number of the template to fix"
$selectedTemplate = $templates[[int]$selection]

Write-Host "`nProcessing: $($selectedTemplate.Name)" -ForegroundColor Cyan

# Create temp directory
$tempDir = "$env:TEMP\VSTemplateEdit_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Extract the zip
Expand-Archive -Path $selectedTemplate.FullName -DestinationPath $tempDir -Force
Write-Host "Extracted to: $tempDir" -ForegroundColor Green

# Find and edit the .vstemplate file
$vstemplateFile = Get-ChildItem -Path $tempDir -Filter "*.vstemplate" -Recurse | Select-Object -First 1

if ($vstemplateFile) {
    Write-Host "Found template file: $($vstemplateFile.Name)" -ForegroundColor Green
    
    # Read and modify the content
    $content = Get-Content -Path $vstemplateFile.FullName -Raw

    # Fix _Imports.razor - change false to true
    $content = $content -replace '(<ProjectItem[^>]*TargetFileName="_Imports\.razor"[^>]*)ReplaceParameters="false"', '$1ReplaceParameters="true"'
    $content = $content -replace '(<ProjectItem[^>]*)ReplaceParameters="false"([^>]*TargetFileName="_Imports\.razor")', '$1ReplaceParameters="true"$2'

    # Fix App.razor - change false to true
    $content = $content -replace '(<ProjectItem[^>]*TargetFileName="App\.razor"[^>]*)ReplaceParameters="false"', '$1ReplaceParameters="true"'
    $content = $content -replace '(<ProjectItem[^>]*)ReplaceParameters="false"([^>]*TargetFileName="App\.razor")', '$1ReplaceParameters="true"$2'

    # Fix index.html - change false to true
    $content = $content -replace '(<ProjectItem[^>]*TargetFileName="index\.html"[^>]*)ReplaceParameters="false"', '$1ReplaceParameters="true"'
    $content = $content -replace '(<ProjectItem[^>]*)ReplaceParameters="false"([^>]*TargetFileName="index\.html")', '$1ReplaceParameters="true"$2'

    # Save the modified content
    Set-Content -Path $vstemplateFile.FullName -Value $content -Encoding UTF8
    Write-Host "Updated ReplaceParameters for _Imports.razor, App.razor, and index.html to 'true'" -ForegroundColor Green
    
    # Backup original
    $backupPath = "$($selectedTemplate.FullName).backup"
    Copy-Item -Path $selectedTemplate.FullName -Destination $backupPath -Force
    Write-Host "Created backup: $backupPath" -ForegroundColor Yellow
    
    # Create new zip
    $newZipPath = $selectedTemplate.FullName
    Remove-Item -Path $newZipPath -Force
    
    # Compress back to zip
    Get-ChildItem -Path $tempDir | Compress-Archive -DestinationPath $newZipPath -Force
    Write-Host "Created updated template: $newZipPath" -ForegroundColor Green
    
    # Show the changes
    Write-Host "`n=== Modified .vstemplate content (excerpt) ===" -ForegroundColor Cyan
    Get-Content -Path $vstemplateFile.FullName | Select-String -Pattern "_Imports|index.html|App\.razor" -Context 0,0
    
    Write-Host "`nTemplate fixed successfully!" -ForegroundColor Green
    Write-Host "Original backed up to: $backupPath" -ForegroundColor Yellow
    Write-Host "`nRestart Visual Studio to use the updated template." -ForegroundColor Cyan
    
} else {
    Write-Host "Could not find .vstemplate file in the extracted archive" -ForegroundColor Red
}

# Cleanup
Remove-Item -Path $tempDir -Recurse -Force
Write-Host "`nTemporary files cleaned up." -ForegroundColor Gray
