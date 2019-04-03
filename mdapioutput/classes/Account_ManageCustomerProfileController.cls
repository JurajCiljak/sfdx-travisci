public class Account_ManageCustomerProfileController {
	@AuraEnabled
    public static List<CustomerProfile__c> getPersonAccounts(Id masterAccountId){
        return [SELECT Name, Customer_ref__r.Name, AssignedDealership_ref__r.Name, SyncStatus__c FROM CustomerProfile__c where Customer_ref__c = :masterAccountId];
    }
    
    @AuraEnabled
    public static void updateCustomerProfiles(List<CustomerProfile__c> customerProfiles) {
        List<CustomerProfile__c> toUpdate = new List<CustomerProfile__c>();
        for(CustomerProfile__c customerProfile: customerProfiles) {
            toUpdate.add(new CustomerProfile__c(Id=customerProfile.Id, SyncStatus__c = customerProfile.SyncStatus__c));
        }
        if(!toUpdate.isEmpty()){
            update toUpdate;
            externalCallout();
        }
    }
    @future(callout=true)
    public static void externalCallout(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Cloudhub_CustomerProfile/api/trigger');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        HttpResponse response = http.send(request);
    }
}