$filename = $args[0]
(Get-Content $filename -encoding "UTF8") `
    -replace '<code_string>(.*)(::)(.*)(\])<\/code_string>', '<code_string>$3</code_string>' `
    -replace '<term_definitions code="(.*)(::)(.*)">', '<term_definitions code="$3">' `
    -replace '<items code="(.*)(::)(.*)">', '<items code="$3">' |
  Out-File $filename -encoding "UTF8"