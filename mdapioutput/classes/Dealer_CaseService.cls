public class Dealer_CaseService {
    @future (callout = true)
    public static void handleRequest( String caseGlobalExternalId, String status){
        Http http = new Http(); 
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Cloudhub_io/case/changeStatus/'+caseGlobalExternalId);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        request.setBody('{ \"value\":\"'+status+'\"}');
        
        HttpResponse response = http.send(request);
        Case cs = new Case(CaseGlobalExternalId__c = caseGlobalExternalId);
        if (response.getStatusCode() != 200){
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            cs.IntegrationResponse__c = response.getBody();
            cs.IntegrationStatus__c = 'error';
            system.debug('1');
        } else {
            List<Object> lst_JsonParse = (List<Object>)Json.deserializeUntyped(response.getBody());
            Map<String, Object> lst_JsonParseObject = (Map<string,Object>)lst_JsonParse.get(0);
            system.debug(lst_JsonParseObject);
            Boolean success = (Boolean)lst_JsonParseObject.get('success');
            
            if(success){
                cs.Status = status;
                cs.IntegrationStatus__c = null;
                cs.IntegrationResponse__c = null;
                system.debug('2');
            }else{
                List<Object> errors = (List<Object>)lst_JsonParseObject.get('errors');
                Map<String, Object> errorMessages = (Map<String, Object>)errors.get(0);
                cs.IntegrationStatus__c = 'error';
                cs.IntegrationResponse__c =  (String)errorMessages.get('message');
                system.debug('3');
            }
        }
        system.debug(cs);
        Database.upsert(cs, Case.CaseGlobalExternalId__c);
    }
    public static void changeStatus(Map<Id, Case> newMap, Map<Id, Case> oldMap){
        Map<String, String> caseGlobalIdToStatus = new Map<String, String>();
        if(newMap.size() > 10){
            throw new Dealer_CaseServiceException('MARA demo optimized for up to 10 cases');
        }
        for(Case cs : newMap.values()){
            if(cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Maintenance').getRecordTypeId()){
                if(!String.isEmpty(cs.IntegrationStatus__c) && cs.IntegrationStatus__c != 'error'){
                    cs.addError('Case is locked while waiting for integration');
                    continue;
                }else if(cs.Status != oldMap.get(cs.Id).Status){
                    if(String.IsEmpty(oldMap.get(cs.Id).IntegrationStatus__c) || cs.IntegrationStatus__c == 'error'){
                        if(String.isEmpty(cs.CaseGlobalExternalId__c)){
                            cs.addError('Maintenance Case cannot have empty Case Global External Id');
                        }else{
                            caseGlobalIdToStatus.put(cs.CaseGlobalExternalId__c, cs.Status);
                            cs.IntegrationStatus__c = cs.Status;
                            cs.Status = oldMap.get(cs.Id).Status;
                            cs.IntegrationResponse__c = null;
                        }
                    }
                }
            }
        }
        if(!caseGlobalIdToStatus.isEmpty()){
            for(String globalExternalId : caseGlobalIdToStatus.keySet()){
                String value = caseGlobalIdToStatus.get(globalExternalId);
                if(!String.isEmpty(value)){
                    handleRequest(globalExternalId, value);
                }
            }
        }
    }
    
    public static void handleRequest(Map<String,String> cases){
        for(String globalExternalId : cases.keySet()){
            String value = cases.get(globalExternalId);
            if(!String.isEmpty(value)){
                handleRequest(globalExternalId, value);
            }
        }
        
    }
    public class Dealer_CaseServiceException extends Exception {
        
    }
}