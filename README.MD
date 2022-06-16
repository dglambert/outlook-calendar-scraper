# Instructions
1. Go to outlook web client, navigate to calender, week view. 
2. Copy `.\extract-outlook-events.js` code into Chrome Developer Tools Console and run
3. Copy the resulting json string generated in the Console, and save as `.\inputData\results.json`
4. Execute `.\process-into-grouped-results.ps1` to generate `.\dist\grouped-results.json`
5. Execute `.\process-into-pbi-markup.ps1` to generate `.\dist\{CATEGORY_NAME}.html` for each category. 

# Configurations
`.\categoryswap.json` is a config to control mapping from html rgb style to friendly name. Modify this file to map from your configured outlook category color, to name of your choosing.  
