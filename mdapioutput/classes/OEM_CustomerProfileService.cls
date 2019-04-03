public class OEM_CustomerProfileService {
    public static void assignGlobalId(List<sObject> scope){
        for(sObject rec : scope){
            if( String.isEmpty((String)rec.get('CustomerProfileGlobalExternalId__c'))) 
                rec.put('CustomerProfileGlobalExternalId__c', GuidUtil.NewGuid());
        }
    }
    public static void copyFieldFromAccount(List<CustomerProfile__c> scope){
        Map<Id, Account> accountCache = new Map<Id, Account>();
        for(CustomerProfile__c cp : scope){
            if(String.isEmpty( cp.Customer_ref__c)){
                cp.Customer_ref__c.addError('Customer reference cannot be null');
                continue;
            }
            if(String.isEmpty( cp.AssignedDealership_ref__c)){
                cp.AssignedDealership_ref__c.addError('Assigned Dealership reference cannot be null');
                continue;
            }
            accountCache.put(cp.Customer_ref__c, null);  
        }
        if(!accountCache.isEmpty()){
            accountCache = new Map<ID, Account>([Select Id, FirstName, LastName, Industry, BillingCity, BillingCountry, BillingPostalCode, BillingStreet,SalaryOrientation__c , CustomerGlobalId__c  From Account where Id =: accountCache.keySet()]);
            for (CustomerProfile__c cp : scope) {
                Account acc = accountCache.get( cp.Customer_ref__c);
                if( acc != null ) {
                    if( String.isEmpty(cp.SyncStatus__c) ) cp.SyncStatus__c = 'Pending for Sync';
                    
                    cp.BillingCity__c = acc.BillingCity;
                    cp.BillingCountry__c = acc.BillingCity;
                    cp.BillingPostalCode__c = acc.BillingPostalCode;
                    cp.BillingStreet__c = acc.BillingStreet;
                    cp.CustomerGlobalId__c = acc.CustomerGlobalId__c;
                    cp.FirstName__c = acc.FirstName;
                    cp.LastName__c = acc.LastName;
                    cp.SalaryOrientation__c = acc.SalaryOrientation__c;
                    cp.Industry__c = acc.Industry;
                    
                }else{
                    cp.Customer_ref__c.addError('Could not query account for copy');
                }
            }
        }
    } 
}