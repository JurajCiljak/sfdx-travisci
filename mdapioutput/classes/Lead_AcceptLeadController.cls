public class Lead_AcceptLeadController {
    @AuraEnabled
    public static String acceptLead(Id ldId, String leadGlobalExternalId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Cloudhub_io/lead/accept/'+leadGlobalExternalId);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        system.debug('asd');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        system.debug(response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> ob = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            system.debug(ob);
            List<Object> lst_JsonParse = (List<Object>) ob.get('upsertResponse');
        	Map<String, Object> lst_JsonParseObject = (Map<string,Object>)lst_JsonParse.get(0);
            system.debug(lst_JsonParseObject);
            Boolean success = (Boolean)lst_JsonParseObject.get('success');
            if(success){
                List<Object> lst_LeadParse = (List<Object>)ob.get('lead');
                Map<String, Object> lst_LeadParseObject = (Map<string,Object>)lst_LeadParse.get(0);
                upsert new Lead(Id = ldId, 
                                Status = 'Open - Accepted', 
                                LinkedIn__c = (String)  lst_LeadParseObject.get('LinkedIn__c'),
                                SalaryOrientation__c = Decimal.valueOf((String) lst_LeadParseObject.get('SalaryOrientation__c')),
                               	Phone = (String) lst_LeadParseObject.get('Phone')
                               );
            }else{
				throw new AuraHandledException('Oops, something went wrong in OEM org!!!');
            }
            
        } else {
            throw new AuraHandledException(response.getStatus()+ ' '+response.getBody());
        }
        return response.getStatusCode() + ' ' + response.getStatus();
    }
}