let getCalendarEvent = function(calendarEventElement) {

    const textElement = calendarEventElement.querySelector("div[aria-label]");
    if(textElement === null)
    {
        return null;
    }
 
	const text = textElement.ariaLabel;

    if( text.startsWith("all day event for") )
    {
        return null;
    }
    
    if( !text.endsWith("shown as Busy") )
    {
        return null;
    }

    let shortenedText = text.replace("event shown as Busy", "");

    
    // "event from Sunday, June 12, 2022 11:30 PM to Monday, June 13, 2022 12:30 AM test yFb event shown as Busy"
    // "event from Monday, June 13, 2022 6:00 AM to 6:30 AM Read XX pages today  recurring event shown as Busy"
    // "event from Monday, June 13, 2022 9:30 AM to 10:00 AM SOS  organizer Liz Novak recurring event shown as Busy"

    const FULL_DURATION_TEXT_PATTERN = /event from ((.*) to (.*? (AM|PM)))/;
    const fullDurationRegexMatch = shortenedText.match(FULL_DURATION_TEXT_PATTERN);
    const startDateString = fullDurationRegexMatch[2];
    let endDateString = fullDurationRegexMatch[3]
    const fullDuration = fullDurationRegexMatch[1];

    const startDate = Date.parse(startDateString);
    let endDate = Date.parse(endDateString);
    if(isNaN(endDate))
    {
        const START_DATE_DAY_PATTERN = /(.+ )\d{1,2}:\d\d (AM|PM)/;
        const startDateDayRegexMatch = startDateString.match(START_DATE_DAY_PATTERN);

        endDateString = `${startDateDayRegexMatch[1]}${endDateString}`;
        endDate = Date.parse(endDateString);
        if(endDate === null)
        {
            throw `'${text}' endDate cannot be parsed`
        }
    }

    let duration = ((endDate - startDate) / 60000) / 60;


    shortenedText = shortenedText.replace(fullDurationRegexMatch[0], "");
    shortenedText = shortenedText.split("recurring")[0]; 
    shortenedText = shortenedText.split("yFb")[0]; 
    shortenedText = shortenedText.split("organizer")[0]; 
    shortenedText = shortenedText.split("location")[0]; 
    

  //  const EVENT_TEXT_PATTERN = /(from .* to .* (AM|PM))\s*(.*)\s*(organizer|yFb|today)/;
    
    const name = shortenedText;
//    const name = regexMatch[3]; 

    const categoryColorElement = calendarEventElement.querySelector("*[style*='border-color']");
	
	if(categoryColorElement === null)
	{
		return null;
	}
    
    const categoryColor = categoryColorElement.style.borderColor
    
    const calenderEvent = {
        name: name,
        startDate: startDateString, 
        endDate: endDateString, 
        duration: duration,
        category: categoryColor,
        fullText: text, 
        fullDuration: fullDuration 
    };

    return calenderEvent;	
}

let getAllCalendarEvents = function() {
	let calendarEventElements = [... document.querySelectorAll("div[data-calitemid]")];
	let calendarEvents = calendarEventElements.map(getCalendarEvent).filter(calendarEvent => calendarEvent !== null);
    return calendarEvents;
}


let calendarEvents = getAllCalendarEvents();
JSON.stringify(calendarEvents);

