public class OEM_CaseService {
    public static void assignGlobalId(List<sObject> scope){
        for(sObject rec : scope){
            if( String.isEmpty((String)rec.get('CaseGlobalExternalId__c'))) 
                rec.put('CaseGlobalExternalId__c', GuidUtil.NewGuid());
        }
    }
    public static void assignDealership(List<Case> scope){
        Set<Id> voIds = new Set<id>();
        List<Case> filteredCases = new List<Case>();
        for(Case cs : scope){
            if(cs.VehicleOwnership_ref__c == null){
                cs.VehicleOwnership_ref__c.addError('Vehicle Ownership cannot be empty');
                continue;
            }
            if(cs.AssignedDealership_ref__c == null){
                voIds.add(cs.VehicleOwnership_ref__c);
                filteredCases.add(cs);
            }
        }
        if(!filteredCases.isEmpty()){
            Map<Id, Id> voIdToDlIdMap = new Map<Id,Id>(); 
            for(VehicleOwnership__c vo : [select Id, Account_ref__r.PreferredDealership_ref__c from VehicleOwnership__c where Id in :voIds]){
                voIdToDlIdMap.put(vo.Id, vo.Account_ref__r.PreferredDealership_ref__c);
            }
            for(Case cs : filteredCases){
                if(voIdToDlIdMap.containsKey(cs.VehicleOwnership_ref__c) && voIdToDlIdMap.get(cs.VehicleOwnership_ref__c) != null ){
                    cs.AssignedDealership_ref__c = voIdToDlIdMap.get(cs.VehicleOwnership_ref__c);
                }else{
                    cs.AssignedDealership_ref__c.addError('Assigned Dealership cannot be empty and could not be resolved via related Account');
                }
            }
        }
    }
    public static void syncCaseWithPreferredDealer(List<Case> scope){
        Map<Id,Case> toSendToDealers = new Map<Id, Case>();
        Set<Id> voIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> vhIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        set<Id> dlIds = new Set<Id>();
        
        for(Case cs : scope){
            if(true){
                toSendToDealers.put(cs.Id, cs);
                voIds.add(cs.VehicleOwnership_ref__c);
                dlIds.add(cs.AssignedDealership_ref__c);
            }
        }
        if(dlIds.size() > 10){
                throw new OEM_CaseServiceException('Current implementation supports maximum 10 dealerships accross all cases in one transaction');
            }
        if(!toSendToDealers.isEmpty()){
            Map<Id, VehicleOwnership__c> voMap = new Map<Id,VehicleOwnership__c>(
                [select Id, VehicleOwnershipGlobalExternalId__c,
                 StartDate__c, 
                 EndDate__c,
                 Account_ref__c,
                 Vehicle_ref__c
                 From VehicleOwnership__c
                 Where Id in :voIds]
            );
            for(VehicleOwnership__c vo : voMap.values()){
                accIds.add(vo.Account_ref__c);
                vhIds.add(vo.Vehicle_ref__c);
            }
            Map<Id, Account> accMap = new Map<Id, Account>();
            for(Account acc : [select Id,FirstName,LastName,CustomerGlobalId__c,PreferredDealership_ref__c From Account Where Id in :accIds]){
                accMap.put(acc.Id, acc);
            }
            
            
            Map<Id, Vehicle__c> vhMap = new Map<Id, Vehicle__c>();
            for(Vehicle__c vh : [select Id,VehicleIdentificationNumber__c, Name, Product_ref__c From Vehicle__c Where Id in :vhIds]){
                prodIds.add(vh.Product_ref__c);
                vhMap.put(vh.Id, vh);
            }
            Map<Id, Product2> prodMap = new Map<Id, Product2>(
                [select
                 Id,
                 Name,
                 Brand__c,
                 ProductGlobalExternalId__c
                 From Product2
                 Where Id in :prodIds]
            );
            Map<Id, DataSubscription__c> dlIdToDsMap = new Map<Id, DataSubscription__c>();
            for(DataSubscription__c ds :
                [select 
                 Id,
                 LoginUser__r.oAuthEndpoint__c,
                 LoginUser__r.oAuthUserName__c,
                 LoginUser__r.oAuthPassword__c,
                 LoginUser__r.SecurityToken__c,
                 DealershipOrganisation_ref__c
                 From DataSubscription__c where DealershipOrganisation_ref__c in :dlIds]){
                     dlIdToDsMap.put(ds.DealershipOrganisation_ref__c, ds);
                 }
            
            Map<Id, List<Map<String, Object>>> requests = new Map<Id, List<Map<String, Object>>>();
            for(Id csId : toSendToDealers.keySet()){
                Case cs = toSendToDealers.get(csId);
                VehicleOwnership__c vo = voMap.containsKey(cs.VehicleOwnership_ref__c) ? voMap.get(cs.VehicleOwnership_ref__c) : null;
                Account acc = accMap.containsKey(vo.Account_ref__c) ? accMap.get(vo.Account_ref__c) : null;
                Vehicle__c vh = vhMap.containsKey(vo.Vehicle_ref__c) ? vhMap.get(vo.Vehicle_ref__c) : null;
                Product2 prod = prodMap.containsKey(vh.Product_ref__c) ? prodMap.get(vh.Product_ref__c) : null;
                if(requests.containsKey(cs.AssignedDealership_ref__c)){
                    requests.get(cs.AssignedDealership_ref__c).add(createCaseRequestPayload(cs,vo,acc,vh,prod));
                }else{
                    requests.put(cs.AssignedDealership_ref__c, new List<Map<String, Object>>{createCaseRequestPayload(cs,vo,acc,vh,prod)});
                }
            }
            if(!requests.isEmpty()){
                for(Id dlId : requests.keySet()){
                    DataSubscription__c loginUser = dlIdToDsMap.get(dlId);
                    List<Map<String, Object>> jsonCaseList = requests.get(dlId);
                    Map<String, Object> jsonBodyMap = new Map<String, Object>();
                    jsonBodyMap.put('username', loginUser.LoginUser__r.oAuthUserName__c);
                    jsonBodyMap.put('password', loginUser.LoginUser__r.oAuthPassword__c);
                    jsonBodyMap.put('security', loginUser.LoginUser__r.SecurityToken__c);
                    jsonBodyMap.put('url', loginUser.LoginUser__r.oAuthEndpoint__c);
                    jsonBodyMap.put('cases', jsonCaseList);
                }
            }
            
        }
    }
    @future (callout = true)
    public static void makeCalloutToMulesoft(String payload){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Cloudhub_io/case/broadcast');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        request.setBody(payload);
        HttpResponse response = http.send(request);
        // Parse the JSON response;
        
        if (response.getStatusCode() != 200) {
            // handle errors for multiple cases
        } else {
            List<Object> lst_JsonParse = (List<Object>) Json.deserializeUntyped(response.getBody());
            Map<String, Object> lst_JsonParseObject = (Map<string,Object>)lst_JsonParse.get(0);
            system.debug(lst_JsonParseObject);
            Boolean success = (Boolean)lst_JsonParseObject.get('success');
            if(success){
                // handle success for multiple cases
            }else{
                // handle errors for multiple cases
            }
        }
    }
    private static Map<String, Object> createCaseRequestPayload(Case caseToSend, VehicleOwnership__c vehicleOwnership, Account account, Vehicle__c vehicle, Product2 product) {
        Map<String, Object> convertedCase = new Map<String, Object>();
        convertedCase.put('CaseGlobalExternalId__c', caseToSend.CaseGlobalExternalId__c);
        convertedCase.put('Subject', caseToSend.Subject);
        convertedCase.put('Description', caseToSend.Description);
        convertedCase.put('CustomerGlobalId__c', account.CustomerGlobalId__c);
        convertedCase.put('FirstName', account.FirstName);
        convertedCase.put('LastName', account.LastName);
        convertedCase.put('VehicleOwnershipGlobalExternalId__c', vehicleOwnership.VehicleOwnershipGlobalExternalId__c);
        convertedCase.put('StartDate__c', vehicleOwnership.StartDate__c);
        convertedCase.put('EndDate__c', vehicleOwnership.EndDate__c);
        convertedCase.put('VehicleIdentificationNumber__c', vehicle.VehicleIdentificationNumber__c);
        convertedCase.put('ProductName', product.Name);
        convertedCase.put('ProductGlobalExternalId__c', product.ProductGlobalExternalId__c);
        convertedCase.put('Brand__c', product.Brand__c);
        return convertedCase;
    }
    public class OEM_CaseServiceException extends Exception {}
}