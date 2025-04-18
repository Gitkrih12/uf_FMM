'***************************************************************
' Function: Adjudicate the claim(status, capture, info, details)
' Date Created: 07/02/2021
' Date Modifed: 07/02/2021
' Created By:  Hariprasad
' Description:  Adjudicates the claim
'***************************************************************

subStep = 1


Function ClaimsUtility_Adjudicate(stepNum, stepName, expectedResult, page, object, expected, args)
    
	'Set up log results

	logObject = "Step: " &stepNum &" - "&stepName&CHR(13)& "Page: " &page &CHR(13) &" Object: " &object
	If (args = "") Then
		logDetails= "Expected:  " &sValue &CHR(13)
	Else
		logDetails= "Expected: (" &args &")  " &sValue &CHR(13)
	End If
	
	'Navigating to the pay tab and Adjudicate the claim
	
	Browser("Claims Module").Page("Claims Module").WebElement("Pay").Click
    Browser("Claims Module").Page("Claims Module").Frame("Pay").WebButton("Adjudicate").Click
    
	'DMMC 2024-03-07 - The "ReAdjudicateMsg" WebElement object was not found in the Object Repository.
    'If  Browser("Claims Module").Page("Claims Module").WebElement("ReAdjudicateMsg").Exist(30) Then
    ' 	Browser("Claims Module").Page("Claims Module").WebButton("OK").Click
    'End If
    
    If  Browser("Claims Module").Page("Claims Module").WebElement("WarningEditMSG").Exist(80) Then
    	If Environment("RunFrom") = "LOCAL" Then
			Reporter.ReportEvent micPass, logObject, logDetails
		ElseIf Environment("RunFrom") = "ALM" Then
			verifyResultsInALM "Claims Module", stepNum&"."&subStep, "Passed", "Click on Adjudicate button", "The warning pop-up should be displayed", "The result is as expected"
			subStep = subStep+1
		End If
        Browser("Claims Module").Page("Claims Module").WebButton("OK").Click
        Browser("Claims Module").Page("Claims Module").WebElement("Edits").Click
        Call PendEditsOverride(stepNum, stepName, expectedResult, page, object, expected, args)
		'DMMC-2024-03-27 Added AdjjudicateOnly condition.
    Elseif  Browser("Claims Module").Page("Claims Module").Frame("Pay").WebButton("Finalize Claim").Exist(3) and UCase(args) <> "ADJUDICATEONLY" Then
        Browser("Claims Module").Page("Claims Module").Frame("Pay").WebButton("Finalize Claim").Click
        Browser("Claims Module").Page("Claims Module").Frame("Log Date").WebButton("Cancel").Click
    Else 
      	If Environment("RunFrom") = "LOCAL" Then
			Reporter.ReportEvent micFail, logObject, logDetails
		ElseIf Environment("RunFrom") = "ALM" Then
			verifyResultsInALM "Claims Module", stepNum&"."&subStep, "Failed", "Click on Adjudicate button", "The warning pop-up should be displayed", "The result is not as expected"
			subStep = subStep+1
		End If
        End If
	
End Function

'***************************************************************
' Function: Overrides the Pend edits(status, capture, info, details)
' Date Created: 07/02/2021
' Date Modifed: 07/02/2021
' Created By:  Hariprasad
' Description:  Overrides the outstanding pend edits by clicking okay selected if outstanding pend edits are not cleared then it will overrides from carries module rules tab
'***************************************************************

Function PendEditsOverride(stepNum, stepName, expectedResult, page, object, expected, args)
	
	'Set up log results

	logObject = "Step: " &stepNum &" - "&stepName&CHR(13)& "Page: " &page &CHR(13) &" Object: " &object
	If (args = "") Then
		logDetails= "Expected:  " &sValue &CHR(13)
	Else
		logDetails= "Expected: (" &args &")  " &sValue &CHR(13)
	End If
	
    TotalEditNumber = 0
    TotalEditNumber = SelectEdits(TotalEditNumber)


	If Browser("Claims Module").Page("Claims Module").Frame("Edits").Link("2").exist Then
		
		
		Browser("Claims Module").Page("Claims Module").Frame("Edits").Link("2").Click
		TotalEditNumber = SelectEdits(TotalEditNumber)
		Browser("Claims Module").Page("Claims Module").Frame("Edits").Link("1").Click
	
		
	End If
	
	
	    Environment("TotalEdits") = TotalEditNumber-1
		status = Browser("Claims Module").Page("Claims Module").Frame("Edits").WebButton("Okay Selected").GetROProperty("Disabled")
		If status = 0 then
			Browser("Claims Module").Page("Claims Module").Frame("Edits").WebButton("Okay Selected").Click
		End If
     If Browser("Claims Module").Page("Claims Module").WebButton("OK").Exist Then
        If Environment("RunFrom") = "LOCAL" Then
			Reporter.ReportEvent micPass, logObject, logDetails
		ElseIf Environment("RunFrom") = "ALM" Then
			verifyResultsInALM "Claims Module", stepNum&"."&subStep, "Passed", "Click on Okay selected", "you don't have permission to override should be displayed", "The result is as expected"
			subStep = subStep+1
		End If
        Browser("Claims Module").Page("Claims Module").WebButton("OK").Click
        
        'capturing the plan name from claims home page
        
        Browser("Claims Module").Page("Claims Module").WebElement("Claim").Click
		PlanName1 = Browser("Claims Module").Page("Claims Module").Frame("Claim").WebTable("Send Encounter to").GetCellData(1,1)
    	Print PlanName1
    	PlanName = Split(PlanName1,"Send Encounter to ")
    	Environment("PlanName") = PlanName(1)
    	Print Environment("PlanName")
    	
    	'Resolving the outstanding edits by loggin to Carriers module
    	
    	Browser("MAIN").Page("Start Page").Link("Carriers").Click
    	Browser("Carriers Module").Page("Carriers Module").WebElement("Health Plans").Click

    If Browser("Carriers Module").Page("Carriers Module").WebElement("PlanDataPPMO").Exist Then
       If Environment("RunFrom") = "LOCAL" Then
			Reporter.ReportEvent micPass, logObject, logDetails
		ElseIf Environment("RunFrom") = "ALM" Then
			verifyResultsInALM "Claims Module", stepNum&"."&subStep, "Passed", "Click on Healthplans", "The healthplan should be displayed", "The result is as expected"
			subStep = subStep+1
		End If
       Browser("Carriers Module").Page("Carriers Module").Frame("Health Plans").WebList("Health Plans").Select "TRIPLE S ADVANTAGE, INC."
    Else
       Browser("Carriers Module").Page("Carriers Module").Frame("Health Plans").WebList("Health Plans").Select "Triple-S Salud"
      
       
    End If
    
    wait (5)

    Browser("Carriers Module").Page("Carriers Module").Frame("Health Plans").WebList("Program").Select(Environment("PlanName"))
	wait (5)
    Browser("Carriers Module").Page("Carriers Module").Frame("Health Plans").WebList("PlansRules").Select "Program Rules"
	wait (5)
    Browser("Carriers Module").Page("Carriers Module").Frame("Health Plans").WebRadioGroup("Plans").Select "101"
'    Browser("Carriers Module").Page("Carriers Module").Frame("Health Plans").WebButton("Edit").Click
    Browser("Carriers Module").Page("Carriers Module").Frame("HealthPlans1").WebButton("Edit").Click

    wait (5)

    For i= 0 To Environment("TotalEdits")

    Browser("Carriers Module").Page("Carriers Module").Frame("Rules").WebEdit("SearchValue").Set ""
    Browser("Carriers Module").Page("Carriers Module").Frame("Rules").WebEdit("SearchValue").Set Environment("EditNumber"&i)
    Browser("Carriers Module").Page("Carriers Module").Frame("Rules").WebButton("Search").Click
    If Browser("Carriers Module").Page("Carriers Module").WebElement("PlanDataPPMO").Exist Then
       If Environment("RunFrom") = "LOCAL" Then
			Reporter.ReportEvent micPass, logObject, logDetails
		ElseIf Environment("RunFrom") = "ALM" Then
			verifyResultsInALM "Claims Module", stepNum&"."&subStep, "Passed", "Click on search", "The PlanDataPPMO should be displayed", "The result is as expected"
			subStep = subStep+1
		End If
       Browser("Carriers Module").Page("Carriers Module").Frame("Rules").WebCheckBox("PlanAdministration").Set "ON"
    Else
       Browser("Carriers Module").Page("Carriers Module").Frame("Rules").WebCheckBox("SuperUser").Set "ON"
    End If
       Browser("Carriers Module").Page("Carriers Module").Frame("Rules").WebButton("Save").Click

    If     Browser("Carriers Module").Page("Carriers Module").WebButton("Yes").Exist then
           Browser("Carriers Module").Page("Carriers Module").WebButton("Yes").Click
    Elseif Browser("Carriers Module").Page("Carriers Module").WebButton("Save").Exist then
           Browser("Carriers Module").Page("Carriers Module").WebButton("Save").Click
    End If 
    Next
    
   
     Else
      	If Environment("RunFrom") = "LOCAL" Then
			Reporter.ReportEvent micPass, logObject, logDetails
		ElseIf Environment("RunFrom") = "ALM" Then
			verifyResultsInALM "Claims Module", stepNum&"."&subStep, "Passed", "Click on OkSelected button", "selected edit's status should be changed to Okay", "The result is as expected"
			subStep = subStep+1
		End If
    End If
	
	If Browser("Carriers Module").Exist then		
    Browser("Carriers Module").Close
	End If
    
    Call ClaimsUtility_Adjudicate(stepNum, stepName, expectedResult, page, object, expected, args)
    

End Function

'***************************************************************
' Function: SelectEdits (status, capture, info, details)
' Date Created: 07/02/2021
' Date Modifed: 07/02/2021
' Created By:  Hariprasad
' Description:  selects the pend edits generated after adjudication
'***************************************************************

Function SelectEdits(TotalEditNumber)
   
   'Selecting the PEND edits
   
   Set Table_OutstandingEdits = Browser("Claims Module").Page("Claims Module").Frame("Edits").WebTable("AllEdits")  
   StrRows = Table_OutstandingEdits.RowCount	
   
   If StrRows = 0 Then
   	Set Table_OutstandingEdits = Browser("Claims Module").Page("Claims Module").Frame("Edits").WebTable("Edits")
   	StrRows = Table_OutstandingEdits.RowCount
   End If
   
   For i=1 to StrRows
			Status = Trim(Table_OutstandingEdits.GetCellData(i,5))
			If Status= "PEND" Then
				Table_OutstandingEdits.ChildItem(i,1,"WebCheckBox",0).Click
				Environment("EditNumber"&TotalEditNumber) = Trim(Table_OutstandingEdits.GetCellData(i,3))
				Print Environment("EditNumber"&TotalEditNumber)
				TotalEditNumber = TotalEditNumber+1
			End If
		Next
   SelectEdits = TotalEditNumber
End Function
