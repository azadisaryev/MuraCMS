<!--- This file is part of Mura CMS.

Mura CMS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, Version 2 of the License.

Mura CMS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Mura CMS. If not, see <http://www.gnu.org/licenses/>.

Linking Mura CMS statically or dynamically with other modules constitutes
the preparation of a derivative work based on Mura CMS. Thus, the terms and 	
conditions of the GNU General Public License version 2 (GPL) cover the entire combined work.

However, as a special exception, the copyright holders of Mura CMS grant you permission
to combine Mura CMS with programs or libraries that are released under the GNU Lesser General Public License version 2.1.

In addition, as a special exception, the copyright holders of Mura CMS grant you permission
to combine Mura CMS with independent software modules that communicate with Mura CMS solely
through modules packaged as Mura CMS plugins and deployed through the Mura CMS plugin installation API,
provided that these modules (a) may only modify the /plugins/ directory through the Mura CMS
plugin installation API, (b) must not alter any default objects in the Mura CMS database
and (c) must not alter any files in the following directories except in cases where the code contains
a separately distributed license.

/admin/
/tasks/
/config/
/requirements/mura/

You may copy and distribute such a combined work under the terms of GPL for Mura CMS, provided that you include
the source code of that other code when and as the GNU GPL requires distribution of source code.

For clarity, if you create a modified version of Mura CMS, you are not obligated to grant this special exception
for your modified version; it is your choice whether to do so, or to make such modified version available under
the GNU General Public License version 2 without this exception. You may, if you choose, apply this exception
to your own modified versions of Mura CMS.
--->
<cfsilent>

</cfsilent>
<cfoutput><#$.getHeaderTag('headline')#>#$.rbKey('search.searchresults')#</#$.getHeaderTag('headline')#></cfoutput>
<div id="svSearchResults">
<cfsilent>
<cfparam name="variables.rsnewsearch" default="#queryNew('empty')#"/>
<cfparam name="request.aggregation" default="false">
<cfparam name="request.searchSectionID" default="">
<cfparam name="session.rsSearch" default="#queryNew('empty')#">
<cfif (len(request.keywords) or len(request.tag) ) and isdefined('request.newSearch')>
<cfset session.aggregation=request.aggregation />
<cfset variables.rsNewSearch=application.contentManager.getPublicSearch($.event('siteID'),request.keywords,request.tag,request.searchSectionID) /> 

<cfif getSite().getExtranet() eq 1>
	<cfset session.rsSearch=$.queryPermFIlter(variables.rsnewsearch)/>
<cfelse>
	<cfset session.rsSearch=variables.rsnewsearch/>
</cfif>

<cfelseif request.keywords eq '' and isdefined('request.newSearch')>
<cfset session.rsSearch=newResultQuery()/>
</cfif>

<cfset variables.TotalRecords=session.rsSearch.RecordCount>
<cfset variables.RecordsPerPage=10> 
<cfset variables.NumberOfPages=Ceiling(TotalRecords/RecordsPerPage)>
<cfset variables.CurrentPageNumber=Ceiling(request.StartRow/RecordsPerPage)> 
<cfset variables.next=evaluate((request.startrow+recordsperpage))	>
<cfset variables.previous=evaluate((request.startrow-recordsperpage))	>
<cfset variables.through=iif(variables.totalRecords lt variables.next,totalrecords,variables.next-1)> 

<cfset variables.iterator=$.getBean("contentIterator")>
<cfset variables.iterator.setQuery(session.rsSearch,RecordsPerPage)>
<cfset variables.iterator.setStartRow($.event("startrow"))>

<cfif len(request.searchSectionID)>
<cfset variables.sectionBean=application.contentManager.getActiveContent(request.searchSectionID,$.event('siteID')) />
</cfif>

<cfset variables.contentListFieldsType="Search">
<cfset variables.contentListFields="Title,Summary,Tags,Credits">

</cfsilent>

<cfoutput>
	<cfset variables.args=arrayNew(1)>
	<cfset variables.args[1]=session.rsSearch.recordcount>
	<cfif len(request.tag)>
		<cfset variables.args[2]=htmlEditFormat(request.tag)>
		<cfif len(request.searchSectionID)>
			<cfset variables.args[3]=htmlEditFormat(variables.sectionBean.getTitle())>
			<p>#$.siteConfig("rbFactory").getResourceBundle().messageFormat($.rbKey('search.searchtagsection'),variables.args)#</p>
		<cfelse>
			<p>#$.siteConfig("rbFactory").getResourceBundle().messageFormat($.rbKey('search.searchtag'),variables.args)#</p>
		</cfif>
	<cfelse>
		<cfset variables.args[2]=htmlEditFormat(request.keywords)>
		<cfif len(request.searchSectionID)>
			<cfset variables.args[3]=htmlEditFormat(variables.sectionBean.getTitle())>
	 		<p>#$.siteConfig("rbFactory").getResourceBundle().messageFormat($.rbKey('search.searchkeywordsection'),variables.args)#</p>
		<cfelse>
			<p>#$.siteConfig("rbFactory").getResourceBundle().messageFormat($.rbKey('search.searchkeyword'),variables.args)#</p>
		</cfif>
	</cfif>
</cfoutput>
<cfif totalrecords>
<cfoutput>
	<div class="moreResults top">
		<ul>
		<li class="resultsFound">#$.rbKey('search.displaying')#: #request.startrow# - #variables.through# #$.rbKey('search.of')# #session.rsSearch.recordcount#</li>
		<cfif previous gte 1>
		<li class="navPrev"><a href="?startrow=#previous#&display=search&keywords=#HTMLEditFormat(request.keywords)#&searchSectionID=#HTMLEditFormat(request.searchSectionID)#&tag=#HTMLEditFormat(request.tag)#">&laquo;#$.rbKey('search.prev')#</a></li>
		</cfif>
		<cfif session.rsSearch.recordcount gt 0 and  variables.through lt session.rsSearch.recordcount>
		<li class="navNext"><a href="?startrow=#next#&display=search&keywords=#HTMLEditFormat(request.keywords)#&searchSectionID=#HTMLEditFormat(request.searchSectionID)#&tag=#HTMLEditFormat(request.tag)#">#$.rbKey('search.next')#&raquo;</a></li>
		</cfif>
		</ul>
	</div>
	
	<div id="svPortal" class="svIndex">
		#$.dspObject_Include(
			thefile='dsp_content_list.cfm',
			fields=variables.contentListFields,
			type=variables.contentListFieldsType, 
			iterator= variables.iterator
			)#
	</div>
		
	<div class="moreResults bottom">
		<ul>
		<li class="resultsFound">#$.rbKey('search.displaying')#: #request.startrow# - #variables.through# #$.rbKey('search.of')# #session.rsSearch.recordcount#</li>
		<cfif previous gte 1>
		<li class="navPrev"><a href="?startrow=#previous#&display=search&keywords=#HTMLEditFormat(request.keywords)#&searchSectionID=#HTMLEditFormat(request.searchSectionID)#&tag=#HTMLEditFormat(request.tag)#">&laquo;#$.rbKey('search.prev')#</a></li>
		</cfif>
		<cfif session.rsSearch.recordcount gt 0 and  through lt session.rsSearch.recordcount>
		<li class="navNext"><a href="?startrow=#next#&display=search&keywords=#HTMLEditFormat(request.keywords)#&searchSectionID=#HTMLEditFormat(request.searchSectionID)#&tag=#HTMLEditFormat(request.tag)#">#$.rbKey('search.next')#&raquo;</a></li>
		</cfif></ul>
	</div>
	</cfoutput>
	</cfif>	
	
<cfoutput>
	<form id="svSearchAgain" name="searchFrm" action="" method="get">
		<p>#$.rbKey('search.didnotfind')#</p>
		#$.rbKey('search.search')#: <input type="text" name="keywords" value="#HTMLEditFormat(request.keywords)#" /><input name="newSearch" value="true" type="hidden"/><input name="nocache" value="1" type="hidden"/><input name="searchSectionID" value="#HTMLEditFormat(request.searchSectionID)#" type="hidden"/>  <input name="display" value="search" type="hidden"/><input type="submit" class="submit" value="#htmlEditFormat($.rbKey('search.go'))#" alt="submit" />
	</form>
</cfoutput>
</div>