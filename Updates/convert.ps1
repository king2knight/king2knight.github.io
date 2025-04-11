# Set your folder path here
$sourceFolder = "C:\Users\User\king2knight.github.io\Updates\updatedgirlsbbfiles\"

# Start Word COM object
$word = New-Object -ComObject Word.Application
$word.Visible = $false

# Get all .doc files (excluding .docx)
$files = Get-ChildItem -Path $sourceFolder -Filter *.doc -File

foreach ($file in $files) {
    $inputPath = $file.FullName
    $outputPath = [System.IO.Path]::ChangeExtension($inputPath, ".html")

    try {
        $doc = $word.Documents.Open($inputPath, [ref]$false, [ref]$true)
        $doc.SaveAs([ref] $outputPath, [ref] 10)  # 10 = wdFormatFilteredHTML
        $doc.Close()
        Write-Host "Converted: $inputPath -> $outputPath"
    }
    catch {
        Write-Warning "Failed to convert: $inputPath"
    }
}

# Quit Word
$word.Quit()
