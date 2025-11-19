# task.ps1
# Script to find unattached managed disks in the task resource group
# and save information about them to result.json

$ErrorActionPreference = 'Stop'

# 1. Назва ресурс-групи, де розгорнута VM з попереднього завдання
$resourceGroupName = 'MATE-AZURE-TASK-5-DST-NORTHEUROPE'

# 2. Шлях до файлу result.json в корені репозиторію
$resultPath = Join-Path $PSScriptRoot 'result.json'

# 3. Отримуємо всі managed disks у цій ресурс-групі
$allDisks = Get-AzDisk -ResourceGroupName $resourceGroupName

# 4. Фільтруємо тільки unattached диски
#    Логіка:
#      - ManagedBy має бути порожнім
#      - DiskState має бути 'Unattached'
$unattachedDisks = $allDisks | Where-Object {
    (-not $_.ManagedBy) -and ($_.DiskState -eq 'Unattached')
}

# 5. Вибираємо лише основну інформацію для експорту
$projection = $unattachedDisks | Select-Object `
    Name,
    ResourceGroupName,
    Location,
    DiskSizeGB,
    DiskState,
    ManagedBy,
    Id

# 6. Конвертуємо в JSON і записуємо у result.json
$projection |
    ConvertTo-Json -Depth 5 |
    Set-Content -Path $resultPath -Encoding utf8
