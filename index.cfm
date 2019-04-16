<!---Built using CommandBox: http://cmdbox.cayton.local:40011/CFIDE/administrator/index.cfm--->
<cfset setLocale("English (UK)") />

<head>
	<link rel="stylesheet" type="text/css" href="/assets/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="/assets/css/jquery-ui-1.8.7.custom.css" />
</head>

<body>
	<div class="container-fluid">
		<div class="row-fluid margintop5">
			<h2>Cf & JS Test questions answered...</h2>
		</div>
	</div>
	<div class="container-fluid">
		<div class="row-fluid margintop5">
			<cfoutput>
			<input type="button" id="testProduct" value="3 Products" >
					
<!---				<h4>Cf Q1 answer</h4><p>#Cf_q1([{tokenUuid=createUUID(),RequestTime=DateAdd("h",-4,Now()),errorCode=1}
											,{tokenUuid=createUUID(),RequestTime=DateAdd("h",-2,Now()),errorCode=1}])# </p>
											
				<h4>Cf Q2 answer</h4><p>#Cf_q2("01/01/2000")#</p>
			
				<h4>Cf Q3 answer</h4><p>#Cf_q3()#</p>
				
				<h4>SQL Q1 answer</h4><p>#SQL_q1(5)#</p>
				
				<h4>SQL Q2 answer</h4><p>#SQL_q2(3)#</p>
--->			</cfoutput>
		</div>
	</div>
</body>
<footer>
	<script type="text/javascript" src="/assets/javascript/bootstrap/jquery.js"></script>
	<script type="text/javascript" src="/assets/javascript/bootstrap/bootstrap-modal.js"></script>
	<script type="text/javascript" src="/assets/javascript/bootstrap/bootstrap.min.js"></script>
	
	<script type="text/javascript" src="/assets/javascript/seniorJSQ.js"></script>
</footer>

<cfscript>
	/*
		Error retries and Back off Algorithm.
		
		External API calls sometimes fail intermittently due to network connection errors and although we will 
		want to retry the call, we don’t want to overload the service.

		Your task is to write a function that accepts a single argument of the number of attempts previously made 
		and returns the next date and time to retry.

		The function should implement an exponential back off algorithm of your choosing, and we should never retry 
		calls more than 24 hours after the initial failure. Think about edge cases.
	*/
	private any function Cf_q1(required array failures){
		
		// Assume failures is an array of previous attempts from which we could derive the time in ms since the first call
		variables.exponentialBackoff = CreateObject("component", "exponentialBackoff");

		if (failures.len()){

			var retryInterval = variables.exponentialBackoff.calcTimeRetry(failures.len());
			var msSinceFirstApiCall = dateDiff('s',failures[1].RequestTime, Now())*1000;
			
			if ( retryInterval LTE (86400000 - msSinceFirstApiCall)){
				// perform operation again
				var arr = variables.exponentialBackoff.doOperationAndWaitForResult(1);
				for (i in arr) {
    				failures.append(i);
				}
				//	failures.append(variables.exponentialBackoff.doOperationAndWaitForResult(1) );	
			}else{
				// 24 hrs have lapsed since last tried
				writeOutPut("Too long to wait for retry");	
			}
		}
		
		// deliberately left this so there is something to see - obvioulsy would not leave in Production-ready code...
		writeDump(var=failures, label="Failures", expand=false);
		
		// have a get function getFailuress() in the cfc for unit testing before and after attempts array will tell us what happened.
		return retryInterval;
	}
	

	/*
	Find the next palindromatic date.
		i. Increments the date string one day at a time, until it finds the next legitimate	palindrome date string (i.e. 21/02/2012).
		ii. Prints the palindrome Date String, and the number of increments to the screen.
	*/
	private void function Cf_q2(source, limit){
		
		var cnt = 0;
		var thisDate = arguments.source;
		var formattedDate = arguments.source;
		
		if (isValid("date", thisDate)){
			
			thisDate = LSParseDateTime(arguments.source, getLocale(), "dd/mm/yyyy");
			cnt += 1;
			
			// arbitrary number to limit loop; could easily be sent as a parameter OR restricted via a 'maximum' date
			while (cnt LT 30000) {

				newDate = thisDate.add("d", 1);		
		
				formattedDate = LSDateFormat(newDate, "dd/mm/yyyy", getLocale());

				if ( isPalindrome(formattedDate) ){
					foundPalindrome = true;
					attempt = formattedDate;
					writeOutPut("After " & cnt & " tries I got #attempt#</br>");
				}
						
				thisDate = newDate;
				
				cnt += 1;
			}
		}
	}

	private boolean function isPalindrome(thisDate){
		
		var reverseDate = replace(reverse(arguments.thisDate),"/","","ALL");
		var thisdate2 = replace(arguments.thisDate,"/","","ALL");

		return (Compare(thisdate2,reverseDate) EQ 0);
	}
	
	
	/*
		Explain using examples if necessary, how you would write a Unit Test for the function in question 1.
	*/
	private void function Cf_q3(){
		
		writeOutPut("<p>I would mock the backoff component such that the control constants could be modified to much smaller values - we don't really want to be unit testing with large back-off values.");
		writeOutPut("To that end I would create getters and setters for all properties and move the variables.constants.Results values to component properties.");
		writeOutPut("I would mock varying failures arrays of differring lengths and check my algorithm yields exponential back-off times as the length increses."); 
		writeOutPut("I would test this independently of the actual call to doOperationAndWaitForResult().");
		writeOutPut("I would override the sleep function too (or allow in to be ignored by passing in an argument) in order to rapidly unit test the doOperationAndWaitForResult() method.");
		writeOutPut("Clearly we would also want to mock any actual asynchronous/http calls - either using mock api responses OR by overidding methods in our Unit testing framework (e.g. MXUnit or TestBox).");
		writeOutPut("Edge cases to consider are a) the failures array is empty b) extremely large values for back-off time are generated by a large array of failures c) whether the time delay would exceed the 24hr rule.</p>");
		
	}
	

	/*
		Find the Nth row based on a column value.
	*/
	private string function SQL_q1(target){
		
		var result = readSQL_q1();
		var arr = [];
		
		for (row in result){
			
			if (row.rank EQ arguments.target){
				
				ArrayAppend(arr, row.student_id);
			}
		}
		
		return Arraylen(arr) ? "Student ID's ranking 5th:" & ArrayToList(arr) : "None found"; 
	}
	
	/*
		Find a value that shows at least [N] times consecutively in a table.
	*/
	private void function SQL_q2(target){
	
		var x = -1;
		var cnt =0;
		var result = readSQL_q2();
		
		for (row in result){
			
			if (x EQ row.rank){
				cnt +=1;	
			}else{
				cnt = 1;
			}

			if (cnt GTE arguments.target){
				writeOutPut("First Num counted #target# consecutive times is: #row.num#");
				break;			
			}
			
			x = row.rank;
		}
	}
</cfscript>
<cfabort>

<!--- DAO --->
<cffunction name="readSQL_Q1" access="public" returntype="query" output="false" >
	
	<cfquery name="local.sql" datasource="#getDatasource()#">
		SELECT * 
		    ,RANK() OVER   
		    (ORDER BY MathScore.score ASC) AS Rank  
			FROM dbo.MathScore
			ORDER BY Score;
	</cfquery>
	
	<cfreturn local.sql />
</cffunction>

<cffunction name="readSQL_q2" access="public" returntype="query" output="false">
	<cfargument name="something" type="any" required="false" />

	<cfquery name="local.sql" datasource="#getDatasource()#">
		SELECT id,num 
		    ,RANK() OVER   
		    (ORDER BY t.num ASC) AS Rank  
			FROM dbo.t
			ORDER BY t.id
	</cfquery>
	
	<cfreturn local.sql />
</cffunction>

<cffunction name="getDatasource" returntype="String" output="false">
	<cfreturn "test" /> 
</cffunction>