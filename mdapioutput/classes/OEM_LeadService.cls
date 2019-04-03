public class OEM_LeadService {
    public static void assignGlobalId(List<sObject> scope){
        for(sObject rec : scope){
            if( String.isEmpty((String)rec.get('LeadGlobalExternalId__c'))) 
                rec.put('LeadGlobalExternalId__c', GuidUtil.NewGuid());
        }
    }
    public static void searchZerolightDatabase(List<Lead> scope){
        Map<Id, String> zerolightCodes = new Map<Id, String>();
        for(Lead ld : scope){
            if(ld.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('ZeroLightLead').getRecordTypeId()){
                if(!String.isEmpty(ld.ZerolightCode__c)){
                    zerolightCodes.put(ld.Id, ld.ZeroLightCode__c);
                }else{
                    ld.addError('ZeroLight Lead must have configuration code');
                }
            }
        }
        system.debug(zerolightCodes);
        if(!zerolightCodes.isEmpty() ){
            if(zeroLightCodes.size() < 10){
                for(Id key : zerolightCodes.keySet()){
                    OEM_LeadService.zeroLightCallout(key,zerolightCodes.get(key));
                }
            }else{
                throw new OEM_LeadServiceException('Zerolight Lead Process does not support more than 10 leads in one transaction');
            }
            
        }
    }
    /* Trigger Code - Bulkified version similar to public static void zeroLightCallout(Id ldId, String code) functionality. Potentially for delete
public static void relateLeadBasedOnZerolightEmail(Map<Id, Lead> scope, Map<Id,Lead> oldMap){
Map<Id, String> idToEmails = new Map<Id, String>();
for(Lead ld : scope.values()){
if(ld.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('ZeroLightLead').getRecordTypeId()){
if(oldMap != null && oldMap.containsKey(ld.Id)){
Lead oldLead = oldMap.get(ld.Id);
if(oldLead.Email != ld.Email && !String.isEmpty(ld.Email)){
idToEmails.put(ld.Id, ld.Email);
}
}
}
}
Map<String, Account> emailToAccount = new Map<String, Account>();
if(!idToEmails.isEmpty()){
for(Account acc : [Select Id, CustomerGlobalId__c, Firstname, Lastname, PersonEmail, Website, Phone, SalaryOrientation__c, CustomerProfile_ref__c from Account where PersonEmail in :idToEmails.values()]){
emailToAccount.put(acc.PersonEmail, acc);
}
}
for(Id ldId : idToEmails.keySet()){
Lead ld = scope.get(ldId);
if(emailToAccount.containsKey(ld.Email)){
OEM_LeadService.copy(ld, emailToAccount.get(ld.Email));
}
}
}*/
    public static void relateLead(List<Lead> scope){
        
        Set<String> emails = new Set<String>();
        Set<Id> emailsLead = new Set<Id> ();
        
        Set<String> ldCGID = new Set<String>();
        for(Lead ld : scope){
            if(ld.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('ZeroLightLead').getRecordTypeId()){
                if(String.isEmpty(ld.CustomerGlobalId__c)){
                    if(!String.isEmpty(ld.Email)){
                        emails.add(ld.Email);
                        emailsLead.add(ld.Id);
                    }
                }else{
                    ldCGID.add(ld.CustomerGlobalId__c);
                }
            }
        }
        Map<String, Account> emailToAccount = new Map<String, Account>();
        if(!emails.isEmpty()){
            for(Account acc : [Select Id,BillingStreet, BillingCity, BillingCountry, BillingPostalCode, CustomerGlobalId__c, Firstname, Lastname, PersonEmail, Website, Phone, SalaryOrientation__c, CustomerProfile_ref__c from Account where PersonEmail in :emails]){
                emailToAccount.put(acc.PersonEmail, acc);
            }
        }
        system.debug(emailToAccount);
        Map<string, Account> cgidToAccount = new Map<String, Account>();
        if(!ldCGID.isEmpty()){
            for(Account acc : [Select Id,BillingStreet, BillingCity, BillingCountry, BillingPostalCode, CustomerGlobalId__c, Firstname, Lastname, PersonEmail, Website, Phone, SalaryOrientation__c, CustomerProfile_ref__c from Account where CustomerGlobalId__c in :ldCGID]){
                cgidToAccount.put(acc.CustomerGlobalId__c, acc);
            }
        }
        for(Lead ld : scope){
            if(!String.isEmpty(ld.CustomerGlobalId__c)){
                if(cgidToAccount.containsKey(ld.CustomerGlobalId__c)){
                    OEM_LeadService.copy(ld, cgidToAccount.get(ld.CustomerGlobalId__c));
                }
            }else{
                if(emailToAccount.containsKey(ld.Email)){
                    OEM_LeadService.copy(ld, emailToAccount.get(ld.Email));
                }
            }
        }
        
    }
    
    public static void copy(Lead ld, Account acc){

        ld.FirstName = acc.FirstName;
        ld.LastName = acc.LastName;
        ld.LinkedIn__c = acc.Website;
        ld.Email = acc.PersonEmail;
        ld.Phone = acc.Phone;
        ld.CustomerGlobalId__c = acc.CustomerGlobalId__c;
        ld.CustomerProfile_ref__c = acc.CustomerProfile_ref__c;
        ld.SalaryOrientation__c = acc.SalaryOrientation__c;
        ld.Street = acc.BillingStreet;
        ld.City = acc.BillingCity;
        ld.Country = acc.BillingCountry;
        ld.PostalCode = acc.BillingPostalCode;
        ld.RelatedAccount_ref__c = acc.id;
    }
    @AuraEnabled
    public static Lead mergeWithAccount(Id leadId, Id accId){
        Account acc = [Select Id,BillingStreet, BillingCity, BillingCountry, BillingPostalCode, CustomerGlobalId__c, Firstname, Lastname, PersonEmail, Website, Phone, SalaryOrientation__c, CustomerProfile_ref__c from Account where Id =: accId];
        Lead ld = new Lead(Id = leadId);
        OEM_LeadService.copy(ld, acc);
        update ld;
        return ld;
    }
    @AuraEnabled
    public static List<Account> locateCustomer(String FirstName, String LastName ){
        String searchInput = FirstName + ' ' + LastName;
        system.debug(searchInput);
        List<List<SObject>> ret = [FIND :searchInput in name fields returning Account (Id, CustomerGlobalId__c, Firstname, Lastname, PersonEmail, Website, Phone, SalaryOrientation__c, CustomerProfile_ref__c)];
        
        return ret.get(0);
    }
    @future (callout = true)
    public static void zeroLightCallout(Id ldId, String code){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Cloudhub_io/zerolight/'+code);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        HttpResponse response = http.send(request);
        
        system.debug(response.getBody());
        Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(response.getBody());
        system.debug(lst_JsonParse.get('email'));
        Lead ld = new Lead(Id = ldId, Email = (String)lst_JsonParse.get('email'));
        Map<String, Account> emailToAccount = new Map<String, Account>();
        if(!String.isEmpty(ld.Email)){
            for(Account acc : [Select Id,BillingStreet, BillingCity, BillingCountry, BillingPostalCode, CustomerGlobalId__c, Firstname, Lastname, PersonEmail, Website, Phone, SalaryOrientation__c, CustomerProfile_ref__c from Account where PersonEmail =: ld.Email]){
                emailToAccount.put(acc.PersonEmail, acc);
            }
            if(emailToAccount.containsKey(ld.Email)){
                OEM_LeadService.copy(ld, emailToAccount.get(ld.Email));
            }
            update ld;
        }
        
    }
    public class OEM_LeadServiceException extends Exception {}
}