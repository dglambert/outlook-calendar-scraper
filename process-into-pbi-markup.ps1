$groupedEventsContent = Get-Content -Path .\dist\grouped-results.json
$groupedEvents = $groupedEventsContent | ConvertFrom-Json 

$DAY_HEADER_PATTERN = @"

<p style="margin:0in 0in;font-size:12pt;font-family:inherit;">
	<span style="font-family:Symbol;">&middot;</span>
	<span><b>{DAY} (0.0 / 0.0)</b></span>
</p>
<ul style="margin:0in 0in;font-family:inherit;">
"@ 
Write-Output $DAY_HEADER_PATTERN

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

    $eventsGroupedByDate = $groupedEvent.Group | Group-Object -Property {$_.Date.ToString("dddd M/dd") }

    #$eventsByDate = $eventsGroupedByDate[0]
    foreach($eventsByDate in $eventsGroupedByDate)
    {
        $dailyDuration = ($eventsByDate.Group | Measure-Object -Property duration -Sum).Sum
        
        $dayHeader = $DAY_HEADER_PATTERN.Replace("{DAY}", $eventsByDate.Name)
        $dayHeader = $dayHeader.Replace("(0.0 /", "($($dailyDuration.tostring("0.0#")) /")

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
