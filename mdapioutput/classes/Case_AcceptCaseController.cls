public class Case_AcceptCaseController {
    @AuraEnabled
    public static String acceptCase(Id csId, String caseGlobalExternalId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Cloudhub_io/case/accept/'+caseGlobalExternalId);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        system.debug('asd');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        system.debug(response.getBody());
        if (response.getStatusCode() == 200) {
            List<Object> lst_JsonParse = (List<Object>)Json.deserializeUntyped(response.getBody());
        	Map<String, Object> lst_JsonParseObject = (Map<string,Object>)lst_JsonParse.get(0);
            system.debug(lst_JsonParseObject);
            Boolean success = (Boolean)lst_JsonParseObject.get('success');
            if(success){
                upsert new Case(Id = csId, Status = 'Open - Accepted');
            }else{
				throw new AuraHandledException('Oops, something went wrong in OEM org!!!');
            }
        } else {
            throw new AuraHandledException(response.getStatus()+ ' '+response.getBody());
        }
        return response.getStatusCode() + ' ' + response.getStatus();
    }
}