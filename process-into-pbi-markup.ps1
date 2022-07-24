Param(
    [Parameter()]
    [DateTime]$From
    , 
    [Parameter()]
    [DateTime]$To
)

$groupedEventsContent = Get-Content -Path .\dist\grouped-results.json
$groupedEvents = $groupedEventsContent | ConvertFrom-Json 

$DAY_HEADER_PATTERN = @"

<p style="margin:0in 0in;font-size:12pt;font-family:inherit;">
	<span style="font-family:Symbol;">&middot;</span>
	<span><b>{DAY} ({DAILY_DURATION} / {SPRINT_DURATION})</b></span>
</p>
<ul style="margin:0in 0in;font-family:inherit;">
"@ 

$EVENT_LINE_PATTERN = @"

    <li>{REPLACE_ME}</li>
"@

$DAY_HEADER_PATTERN_END = @"

</ul>

"@

# $groupedEvent = $groupedEvents[4]
foreach($groupedEvent in $groupedEvents)
{
    $name = $groupedEvent.Name; # Code Review Buffer
    $output = ""

    #$event = $groupedEvent.Group[0]

    foreach($event in $groupedEvent.Group)
    {
        $date = [datetime]::parseexact($event.startDate, 'f', $null)
        $event | Add-Member -NotePropertyName Date -NotePropertyValue $date
    }

    $groupedEvent.Group = $groupedEvent.Group | Sort-Object -Property Date
    $firstDate = $groupedEvent.Group | select-object -First 1 -ExpandProperty Date
    $lastDate = $groupedEvent.Group | select-object -Last 1 -ExpandProperty Date

    $currentDate = $firstDate
    while($currentDate.Date -ne $lastDate.Date)
    {
        $currentDateEvents = $groupedEvent.Group | Where-Object {$_.Date.Date -eq $currentDate.Date}
        if($currentDateEvents.Count -eq 0)
        {
            Write-Output "Adding 'n/a' event for '$($currentDate.Date.ToString("dddd M/dd"))' with no events"
            $groupedEvent.Group += 
                    [PSCustomObject]@{
                        name  = "n/a"
                        duration = 0.0
                        Date = $currentDate
                    }
        }
        $currentDate = $currentDate.AddDays(1)
    }

    $groupedEvent.Group = $groupedEvent.Group | Sort-Object -Property Date

    $eventsGroupedByDate = $groupedEvent.Group | Group-Object -Property {$_.Date.ToString("dddd M/dd") }

    #$eventsByDate = $eventsGroupedByDate[0]
    $dailyDuration = 0.0
    $sprintDuration = 0.0
    foreach($eventsByDate in $eventsGroupedByDate)
    {
        
        if($From -ne $null -and $eventsByDate.Group[0].Date -lt $From)
        {
            continue
        }
        if($To -ne $null -and $eventsByDate.Group[0].Date.Date -gt $To.Date)
        {
            continue
        }

        $dailyDuration = ($eventsByDate.Group | Measure-Object -Property duration -Sum).Sum
        $sprintDuration = $sprintDuration + $dailyDuration
        
        $dayHeader = $DAY_HEADER_PATTERN.Replace("{DAY}", $eventsByDate.Name)
        $dayHeader = $dayHeader.Replace("{DAILY_DURATION}", $($dailyDuration.tostring("0.0#")))
        $dayHeader = $dayHeader.Replace("{SPRINT_DURATION}", $($sprintDuration.tostring("0.0#")))

        $output = $output + $dayHeader


        #$event = $eventsByDate.Group[0]
        foreach($event in $eventsByDate.Group)
        {
            $lineValue = "$($event.duration) - $($event.name)";
            $line = $EVENT_LINE_PATTERN.Replace("{REPLACE_ME}", $lineValue)
            $output = $output + $line;
        }
        $output = $output + $DAY_HEADER_PATTERN_END
    }
    $fileName = $name.Replace("/", "").Replace(" ", "")

    #Write-Output $output
    $output | Out-File -FilePath .\dist\$fileName.html -Force
}
