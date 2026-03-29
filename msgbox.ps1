# Show message box
Add-Type -AssemblyName System.Windows.Forms

[System.Windows.Forms.MessageBox]::Show(
    "Hello, this is a message box!",
    "My Title",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information
)

try {
    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    # Path to link.txt
    $linkFile = Join-Path $scriptDir "output1.txt"

    # Read the URL from the file
    $url = Get-Content $linkFile -ErrorAction Stop
    $url = $url.Trim()

    if (-not $url) {
        throw "link.txt is empty."
    }

    # Get the file name from the URL
    $fileName = Split-Path $url -Leaf

    # Set output path (same directory)
    $outputPath = Join-Path $scriptDir $fileName

    # Download the file
    Invoke-WebRequest -Uri $url -OutFile $outputPath -ErrorAction Stop

    Write-Host "Downloaded: $fileName"

    # Check if the file is a .zip
    if ($fileName.ToLower().EndsWith(".zip")) {
        $extractPath = Join-Path $scriptDir "extracted"

        # Create extraction folder if it doesn't exist
        if (-not (Test-Path $extractPath)) {
            New-Item -ItemType Directory -Path $extractPath | Out-Null
        }

        # Extract the zip
        Expand-Archive -Path $outputPath -DestinationPath $extractPath -Force

        Write-Host "Extracted to: $extractPath"
    }
}
catch {
    Write-Error "An error occurred: $_"
}
