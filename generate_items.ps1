$itemsDir = Join-Path $PSScriptRoot "assets\items"
$outputFile = Join-Path $PSScriptRoot "items_data.js"

$categories = @{
    'Grande premio' = 'grand'
    'Premio medio'  = 'medium'
    'Premio basico' = 'basic'
}

$database = @{
    grand  = @()
    medium = @()
    basic  = @()
}

function Format-Name($filename) {
    # Retorna o nome exato do arquivo, apenas sem a extensão
    return [System.IO.Path]::GetFileNameWithoutExtension($filename)
}

Write-Host "Varrendo diretórios..."

if (-not (Test-Path $itemsDir)) {
    Write-Error "Diretório não encontrado: $itemsDir"
    exit
}

foreach ($dirName in $categories.Keys) {
    $dirPath = Join-Path $itemsDir $dirName
    $type = $categories[$dirName]

    if (Test-Path $dirPath) {
        $files = Get-ChildItem -Path $dirPath -Include *.png, *.jpg, *.jpeg, *.gif, *.webp -Recurse

        foreach ($file in $files) {
            $webPath = "assets/items/$dirName/" + $file.Name
            # Corrige barras para web
            $webPath = $webPath -replace '\\', '/'
            
            $itemObj = @{
                name = Format-Name($file.Name)
                img  = $webPath
            }
            
            $database[$type] += $itemObj
        }
        Write-Host "Categoria '$type': $($database[$type].Count) itens encontrados."
    }
    else {
        Write-Warning "Pasta de categoria não encontrada: $dirName"
    }
}

# Converte para JSON manualmente com escape correto de variáveis
$jsonContent = "const ITEM_DATABASE = {"
foreach ($key in $database.Keys) {
    $jsonContent += "`n    ${key}: ["
    foreach ($item in $database[$key]) {
        $jsonContent += "`n        { name: `"$($item.name)`", img: `"$($item.img)`" },"
    }
    # Remove última vírgula se houver itens
    if ($database[$key].Count -gt 0) {
        $jsonContent = $jsonContent.TrimEnd(',')
    }
    $jsonContent += "`n    ],"
}
$jsonContent = $jsonContent.TrimEnd(',')
$jsonContent += "`n};"

Set-Content -Path $outputFile -Value $jsonContent -Encoding UTF8
Write-Host "Arquivo gerado com sucesso: $outputFile"
