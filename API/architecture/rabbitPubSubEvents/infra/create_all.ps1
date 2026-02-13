# When the script is run, get it's location so everything can be relative to it
Set-Location $PSScriptRoot

# A place to store all output files. If it doesn't exist then create it. | out-null means 
# don't write anyting to thr screen
$outputDir = "$PSScriptRoot\infra_details"
if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }

# Function to run terraform apply and capture output
function Run-TerraformModule {

    # Weird syntax for function parameters
    param(
        [string]$ModuleName,
        [string]$Path
    )

    # More windows weird syntax 'n for new line. Output the module name in cyan
    Write-Host "`n=== Deploying $ModuleName ===" -ForegroundColor Cyan

    # Change dir to the location passed in as a param then run apply
    Set-Location $Path
    terraform apply -auto-approve

    # Capture the output by writing to a file for each app named after the app
    # The output comes from terraform output vm-details structure
    $outputFile = "$outputDir\$ModuleName-output.txt"
    terraform output > $outputFile

    Write-Host "Captured output for $ModuleName -> $outputFile" -ForegroundColor Green
}

# --- Run each module sequentially and capture outputs ---
Run-TerraformModule -ModuleName "vnet"     -Path (Join-Path -Path $PSScriptRoot -ChildPath "vnet")
Run-TerraformModule -ModuleName "RabbitMQ" -Path (Join-Path -Path $PSScriptRoot -ChildPath "RabbitMQ")
Run-TerraformModule -ModuleName "App1"     -Path (Join-Path -Path $PSScriptRoot -ChildPath "App1")
Run-TerraformModule -ModuleName "App2"     -Path (Join-Path -Path $PSScriptRoot -ChildPath "App2")
Run-TerraformModule -ModuleName "App3"     -Path (Join-Path -Path $PSScriptRoot -ChildPath "App3")

# --- Final summary ---
Write-Host "`n================ FINAL DEPLOYMENT SUMMARY ================" -ForegroundColor Yellow

# Get-ChildItem lists files and folders in a dir
# $outputDir is the one creeated at the start to save all the individual outputs into
# -Filter "*-output.txt" restricts the collected files to those matching the filter. All of them in this case
# These are all returned in a FileInfo object and is piped into the forEach
# For each FileInfo object get the filename and remove the -output.txt to leav just the app name
# Output on a new line 'n in colour to stand out
# $_ is the current FileObject and BaseName is a property hoding the filename without an extension so just remove -output
# Get-Content reads the cintent of a file and writes it to the console
# $_ is again the current FileObject but its full name e.g. write app1-outout.txt to the screen
Get-ChildItem $outputDir -Filter "*-output.txt" | ForEach-Object {
    Write-Host "`n--- $($_.BaseName.Replace('-output','')) ---" -ForegroundColor Blue
    Get-Content $_.FullName
}

Set-Location $PSScriptRoot  # Go back to start dir