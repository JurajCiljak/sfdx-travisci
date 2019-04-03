public class Dealer_LeadService {
    @future (callout = true)
    public static void handleRequest( String leadGlobalExternalId, String leadStatus){
        Http http = new Http(); 
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Cloudhub_io/lead/changeStatus/'+leadGlobalExternalId);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        request.setBody('{ \"value\":\"'+leadStatus+'\"}');
        
        HttpResponse response = http.send(request);
        Lead ld = new Lead(LeadGlobalExternalId__c = leadGlobalExternalId);
        if (response.getStatusCode() != 200){
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            ld.IntegrationResponse__c = response.getBody();
            ld.IntegrationStatus__c = 'error';
            system.debug('1');
        } else {
            List<Object> lst_JsonParse = (List<Object>)Json.deserializeUntyped(response.getBody());
            Map<String, Object> lst_JsonParseObject = (Map<string,Object>)lst_JsonParse.get(0);
            system.debug(lst_JsonParseObject);
            Boolean success = (Boolean)lst_JsonParseObject.get('success');
            
            if(success){
                ld.Status = leadStatus;
                ld.IntegrationStatus__c = null;
                ld.IntegrationResponse__c = null;
                system.debug('2');
            }else{
                List<Object> errors = (List<Object>)lst_JsonParseObject.get('errors');
                Map<String, Object> errorMessages = (Map<String, Object>)errors.get(0);
                ld.IntegrationStatus__c = 'error';
                ld.IntegrationResponse__c =  (String)errorMessages.get('message');
                system.debug('3');
            }
        }
        system.debug(ld);
        Database.upsert(ld, Lead.LeadGlobalExternalId__c);
    }
    public static void changeStatus(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        Map<String, String> leadGlobalIdToStatus = new Map<String, String>();
        if(newMap.size() > 10){
            throw new Dealer_LeadServiceException('MARA demo optimized for up to 10 leads');
        }
        for(Lead ld : newMap.values()){
            if(ld.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('ZeroLightLead').getRecordTypeId()){
                if(!String.isEmpty(ld.IntegrationStatus__c) && ld.IntegrationStatus__c != 'error'){
                    ld.addError('Lead is locked while waiting for integration');
                    continue;
                }else if(ld.Status != oldMap.get(ld.Id).Status){
                    if(String.IsEmpty(oldMap.get(ld.Id).IntegrationStatus__c) || ld.IntegrationStatus__c == 'error'){
                        if(String.isEmpty(ld.LeadGlobalExternalId__c)){
                            ld.addError('Zerolight Lead cannot have empty Lead Global External Id');
                        }else{
                            leadGlobalIdToStatus.put(ld.LeadGlobalExternalId__c, ld.Status);
                            ld.IntegrationStatus__c = ld.Status;
                            ld.Status = oldMap.get(ld.Id).Status;
                            ld.IntegrationResponse__c = null;
                        }
                    }
                }
            }
        }
        if(!leadGlobalIdToStatus.isEmpty()){
            for(String globalExternalId : leadGlobalIdToStatus.keySet()){
                String value = leadGlobalIdToStatus.get(globalExternalId);
                if(!String.isEmpty(value)){
                    handleRequest(globalExternalId, value);
                }
            }
        }
    }
    
    public static void handleRequest(Map<String,String> leads){
        for(String globalExternalId : leads.keySet()){
            String value = leads.get(globalExternalId);
            if(!String.isEmpty(value)){
                handleRequest(globalExternalId, value);
            }
        }
        
    }
    public class Dealer_LeadServiceException extends Exception {
        
    }
}