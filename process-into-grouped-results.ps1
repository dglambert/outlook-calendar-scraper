$outlookEventsContent = Get-Content -Path .\inputData\results.json
$outlookEvents = $outlookEventsContent | ConvertFrom-Json 

$categorySwapContent = Get-Content -Path .\categoryswap.json
$categorySwap = $categorySwapContent | ConvertFrom-Json

$categorySwapHash = @{}
$categorySwap | ForEach-Object { $categorySwapHash[$_.rgb] = $_.text }

foreach($outlookEvent in $outlookEvents)
{
    $outlookEvent.category = $categorySwapHash[$outlookEvent.category]
}

$deduppedOutlookEvents = $outlookEvents | Sort-Object -Property @{Expression={$_.fullText}} -Unique 
$filteredOutlookEvents = $deduppedOutlookEvents | Where-Object {$_.category -ne "Social/Personal" -and $_.category -ne "Exercise"}

$groupedOutlookEvents = $filteredOutlookEvents | Group-Object -Property category

$groupedOutlookEvents | ConvertTo-Json -Depth 10 | Out-File .\dist\grouped-results.json -Force