<cfcomponent output="false">

	<!--- Try and include global mappings --->
	<cfset canWriteMode = true />
	<cfset canWriteMappings = true />
	<cfset hasMappings = true />
	<cfset this.sessionManagement = true />

	<cffunction name="onApplicationStart" access="public" returntype="boolean" output="false">
		<!--- Session management --->
		
		<cfreturn true />
	</cffunction>


	<cffunction name="onRequestStart" access="public" returntype="boolean" output="true">

		<!--- setup request --->
		<cfparam name="request.page" default="#structNew()#">
		
		<cfif len(trim( cgi.path_info )) AND listLen(cgi.path_info, "/")>
			<!--- CMS managed page, so attempt to fetch the language from the URI --->
			<cfset request.page.language = listGetAt( cgi.path_info, 1, "/" ) />
		<cfelseif structKeyExists( session, "language" )>
			<cfset request.page.language = session.language />
		<cfelse>
			<cfset request.page.language = "en" />
		</cfif>

		<!--- fall back to English --->
		<cfif NOT listFindNoCase("en,es,nl,ru", request.page.language)>
			<cfset request.page.language = "en" />
		</cfif>

		<!--- session scope defaults --->
		<cflock scope="session" type="exclusive" timeout="2">
			<cfparam name="session.isLoggedIn" default="false" />
			<cfparam name="session.loungeSearch" default="#structNew()#">

			<cfif structKeyExists( request.page, "language" )>
				<cfset session.language = request.page.language />
			</cfif>
		</cflock>

		<!--- work out the URI of the current page as seen in the browser --->
		<cfif len( cgi.path_info )>
			<cfset request.page.uri = cgi.path_info />
		<cfelse>
			<cfset request.page.uri = cgi.script_name />
		</cfif>

		<cfset request.page.uri = encodeForHTMLAttribute( request.page.uri )>

		<cfreturn true />
	</cffunction>

	<cffunction name="onRequestEnd" access="public" returntype="boolean" output="true">

		<!--- strip out excess whitespace --->
		<cfset pageContent = trim( getPageContext().getOut().getString() )/>
		<cfset getPageContext().getOut().clearBuffer() />
		<cfset pageContent = replace( pageContent, chr(13), "", "all" ) />
		<cfset pageContent = reReplace( pageContent, "[[:space:]]{2,}", chr(10), "all" ) />
		<cfset writeOutput(trim( pageContent ))/>
		<cfset getPageContext().getOut().flush() />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="onError" access="public" returntype="void" output="true">
	    <cfargument name="exception" type="any" required="true">
	    <cfargument name="eventName" type="string" required="true">

		<!--- DEV - don't buglog the exception, just show it --->
		<cfdump var="#arguments#"/>
		<cfabort/>
		
	</cffunction>
	
</cfcomponent>
