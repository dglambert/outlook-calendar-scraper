# Instructions
1. Go to outlook web client, navigate to calender, week view. 
2. Copy `.\extract-outlook-events.js` code into Chrome Developer Tools Console and run
3. Copy the resulting json string generated in the Console, and save as `.\inputData\results.json`
4. Repeat 1-3 for each additional week to be processed. Before repeating step 3, be sure to remove the opening `[` from the additional json; and remove the closing `]` and add a `,` after the last `}` from the previous json, while pasting additional jsons into `.\inputData\results.json` to ensure JSON is valid.  
4. Execute `.\process-into-grouped-results.ps1` to generate `.\dist\grouped-results.json`
5. Execute `.\process-into-pbi-markup.ps1` to generate `.\dist\{CATEGORY_NAME}.html` for each category. Use the `-From` and `-To` flags to filter dates. **Ex.** `.\process-into-pbi-markup.ps1 -From 7/8/2022 -To 7/21/2022` 

# Configurations
`.\categoryswap.json` is a config to control mapping from html rgb style to friendly name. Modify this file to map from your configured outlook category color, to name of your choosing.  
