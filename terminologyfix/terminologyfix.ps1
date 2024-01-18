# Check if $args[0] is empty
if (-not $args) {
    Write-Error "Error: Please provide a filename as a command-line argument."
    exit
}

$filename = $args[0]

# Check if the file exists
if (-not (Test-Path $filename)) {
    Write-Error "Error: File '$filename' not found."
    exit
}

# Check if the file has a .opt extension
if (-not ($filename -match '\.opt$')) {
    Write-Error "Error: The file must have a .opt extension."
    exit
}

$fileContent = Get-Content $filename -encoding "UTF8"

# Check if the content was read successfully
if ($null -eq $fileContent) {
    Write-Error "Error: Failed to read content from the file."
    exit
} else {
    Write-Host "Successfully read content from '$filename'."
}

# Define match regexes in an array
$matchRegexes = @(
    '(<code_string>).*::(.*)\](<\/code_string>)',
    '(<term_definitions code=").*::(.*)(">)',
    '(<items code=").*::(.*)(">)'
)

# Check if there are any matches in the entire file
$matchesFound = $false
foreach ($regex in $matchRegexes) {
    if ($fileContent -match $regex) {
        $matchesFound = $true
        break
    }
}

if ($matchesFound) {
    Write-Host "Found matches in the file."

    $outputFilePath = "$filename.tmp"
    $modifiedContent = @()

    foreach ($line in $fileContent) {
        $lineModified = $false  # Track if the line is modified

        # Process the line with matches
        foreach ($regex in $matchRegexes) {
            if ($line -match $regex) {
                $outputLine = $line -replace '^\s+'
                Write-Host "Found match: '$outputLine'"
                $line = $line -replace $regex, "`$1`$2`$3"
                $outputLine = $line -replace '^\s+'
                Write-Host "Replaced line with: '$outputLine'"
                $lineModified = $true
                break  # exit the loop after processing the first match
            }
        }

        # Collect the modified or unmodified line in the array
        $modifiedContent += $line

        #if ($lineModified) {
        #    Write-Host "Modified line added to the array."
        #}
    }

    # Output the array content to the file
    $modifiedContent | Out-File -FilePath $outputFilePath -Encoding "UTF8" -Force

    # Replace the input file with the output file
    Move-Item -Path $outputFilePath -Destination $filename -Force

    Write-Host "Modifications written to '$filename'."

} else {
    Write-Host "No matches found in the entire file. Exiting."
}
