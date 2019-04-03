public class Lead_DealershipForwardController {
	@AuraEnabled
    public static List<DataSubscription__c> getDealersAccounts() {
        return [select LoginUser__r.oAuthUserName__c,
                LoginUser__r.oAuthPassword__c,
                LoginUser__r.SecurityToken__c,
                LoginUser__r.oAuthEndpoint__c,
                DealershipOrganisation_ref__r.Name,
                DealershipOrganisation_ref__r.Email__c,
                DealershipOrganisation_ref__r.Website__c,
                DealershipOrganisation_ref__r.Phone__c,
                DealershipOrganisation_ref__r.Location__latitude__s,
                DealershipOrganisation_ref__r.Location__longitude__s,
                DealershipOrganisation_ref__r.Country__c,
                DealershipOrganisation_ref__r.City__c,
                DealershipOrganisation_ref__r.Street__c,
                DealershipOrganisation_ref__r.ID
                from DataSubscription__c
               where DealershipOrganisation_ref__c != null];
    }
    
    @AuraEnabled
    public static void leadChangeRequest(List<Id> leadIds, String account, Id dealershipId) {
        List<Lead> databaseLeads = getAllFields(leadIds);
        List<Map<String, Object>> leads = convertLeadsToRequestLeads(databaseLeads);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Cloudhub_io/lead/broadcast');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        account= account.removeEnd('}');
        // Set the body as a JSON object
        String jsonBody = account + ',' +'"leads": ' +  JSON.serialize(leads) + '}';
        system.debug(jsonBody);
        request.setBody(jsonBody);
        HttpResponse response = http.send(request);
        // Parse the JSON response;
        
        if (response.getStatusCode() != 200) {
        	System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
             
            AuraExceptionData resData = new AuraExceptionData(' Oops, something went wrong!!!', 
            	response.getStatus() , response.getStatusCode() );
			throw new AuraHandledException(JSON.serialize(resData));
            
            
        } else {
            List<Object> lst_JsonParse = (List<Object>) Json.deserializeUntyped(response.getBody());
        	Map<String, Object> lst_JsonParseObject = (Map<string,Object>)lst_JsonParse.get(0);
            system.debug(lst_JsonParseObject);
            Boolean success = (Boolean)lst_JsonParseObject.get('success');
            if(success){
                updateLeadsStatus(databaseLeads, dealershipId);
            }else{
                AuraExceptionData resData = new AuraExceptionData('Oops, something went wrong on Dealer org!!!', 
            	response.getStatus() , response.getStatusCode() );
				throw new AuraHandledException(JSON.serialize(resData));
            }
            
        }
    }
    
    private static void updateLeadsStatus(List<Lead> leads, Id dealershipId) {
        List<Lead> toUpdate = new List<Lead>();
        
        for(Lead lead: leads) {
            toUpdate.add(new Lead(Id=lead.Id, Status = 'Send to Dealer', AssignedDealership_ref__c = dealershipId));
        }
        if(!toUpdate.isEmpty()){
            update toUpdate;
        }
    }
    
    private static List<Map<String, Object>> convertLeadsToRequestLeads(List<Lead> leads) {
        List<Map<String, Object>> requestLeads = new List<Map<String, Object>>();
        for(Lead lead : leads) {
            Map<String, Object> convertedLead = new Map<String, Object>();
            convertedLead.put('ZeroLightCode__c', lead.ZeroLightCode__c);
            convertedLead.put('LastName', lead.LastName);
            convertedLead.put('Id', lead.Id);
            convertedLead.put('Country', lead.Country);
            convertedLead.put('LeadSource', lead.LeadSource);
            convertedLead.put('SalaryOrientation__c', null);//Discuss with David why don;t we have salary
            convertedLead.put('LeadGlobalExternalId__c', lead.LeadGlobalExternalId__c);
            convertedLead.put('SystemModstamp', String.valueOf(lead.SystemModstamp.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')));
            convertedLead.put('type', 'Lead');
            convertedLead.put('Title', lead.Title);
            convertedLead.put('Website', lead.Website);
            convertedLead.put('CustomerGlobalId__c', lead.CustomerGlobalId__c);
            convertedLead.put('FirstName', lead.FirstName);
            convertedLead.put('CustomerProfile_ref__c', null);
            convertedLead.put('Email', lead.Email);
            convertedLead.put('Company', lead.Company);
            requestLeads.add(convertedLead);
        }
        return requestLeads;
    }
    
    public static List<Lead> getAllFields(List<Id> leadIds){
        String query ='';
        String SobjectApiName = 'Lead';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String strFields = '';
        
        for(String fieldName : fieldMap.keyset() )
        {
            if(strFields == null || strFields == '')
            {
                strFields = fieldName;
            }else{
                strFields = strFields + ', '  + fieldName;
            }
        }
        query = 'Select ' + strFields + ' from Lead where Id in :leadIds';
        try{
            return Database.query(query);
        } catch(QueryException e) {
            return new List<Lead>();
        }
    }
}