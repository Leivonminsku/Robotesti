*** Settings ***
Documentation     Robot for completing the certification level II  
...               Logs in to intra, orders new robot
...               Looks good while doing it.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive



*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Maximize Browser Window
    Set Selenium Speed    0.2
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
         Close the annoying modal
         Fill the form    ${row}
         Preview the robot
         Wait Until Keyword Succeeds    2min    500ms     Submit the Order
         ${Order_string}=    Convert To String    ${row}[Order number]
         ${pdf}=    Store the receipt as a PDF file    ${row}   
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
          Go to order another robot
     END
    Create a ZIP file of the receipts



*** Keywords ***
Open the robot order website
     Open Available Browser    https://robotsparebinindustries.com/#/robot-order  

     
Get Orders 
    Download     https://robotsparebinindustries.com/orders.csv   overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    Log   Found columns: ${orders.columns}
    [Return]     ${orders}
    
Close the annoying modal
    Click Button    OK
    
    
Fill the form
    [Arguments]      ${row}
    Select From List By Value   id:head        ${row}[Head]
    Select Radio Button         body           ${row}[Body]
    Press keys                  none           TAB
    Press Keys                  none           ${row}[Legs] 
    Input text                  id:address     ${row}[Address] 
    
Preview the robot
    click button      id:preview
    
Submit the Order
    Wait Until Keyword Succeeds    10x    3s    click button      id:order
    Wait until page contains       Receipt

      
Store the receipt as a PDF file
    [Arguments]    ${row}
    Capture Element Screenshot    robot-preview-image    ${OUTPUTDIR}/images/Order ${row}[Order number].png
    Wait Until Element Is Visible    receipt
    ${order_info}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${order_info}    ${OUTPUT_DIR}${/}pdf/Order ${row}[Order number].pdf
    ${robotPNG}=    Create List    ${OUTPUT_DIR}${/}pdf/Order ${row}[Order number].pdf
    ...    ${OUTPUTDIR}/images/Order ${row}[Order number].png
    Add Files To Pdf    ${robotPNG}    ${OUTPUT_DIR}${/}pdf/Order ${row}[Order number].pdf

Go to order another robot
    Click Button     id:order-another
    Sleep    2


Create a ZIP file of the receipts
     Archive Folder With ZIP       ${OUTPUT_DIR}${/}pdf     receipts.zip      overwrite=True    