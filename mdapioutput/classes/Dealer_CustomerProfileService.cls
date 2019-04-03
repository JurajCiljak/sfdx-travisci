public class Dealer_CustomerProfileService {
    static public void  blockChangingCustomerGlobalId(Map<Id, CustomerProfile__c> newMap, Map<Id, CustomerProfile__c> oldMap){
        for (CustomerProfile__c cp : newMap.values()) {
            CustomerProfile__c oldRec = oldMap.get(cp.Id);
            if(cp.CustomerGlobalId__c != oldRec.CustomerGlobalId__c)
                cp.CustomerGlobalId__c.addError('Customer Global Id cannot be modified');
        }
    }
    static public void mapCpToAccount(List<CustomerProfile__c> scope){
        Map<String, CustomerProfile__c> cpCache = new Map<String, CustomerProfile__c>();
        for (CustomerProfile__c cp : scope){
            if(cp.CustomerGlobalId__c != null){
                cpCache.put(cp.CustomerGlobalId__c, cp);
            }
        }
        if(!cpCache.isEmpty()){
            Map<String, Account> accs = new Map<String, Account>();
            for(Account acc: [Select Id, CustomerGlobalId__c from Account where CustomerGlobalId__c =:cpCache.keySet()]){
                accs.put(acc.CustomerGlobalId__c, acc);
            }
            Map<String, Account> newAccounts = new Map<string, Account>();
            for(String k : cpCache.keySet()){
                CustomerProfile__c cp = cpCache.get(k);
                if(accs.containsKey(cp.CustomerGlobalId__c)){
                    cp.Customer_ref__c = accs.get(cp.CustomerGlobalId__c).Id;
                }else{
                    Account acc = new Account();
                    acc.BillingCity = cp.BillingCity__c;
                    acc.BillingCity = cp.BillingCountry__c;
                    acc.BillingPostalCode = cp.BillingPostalCode__c;
                    acc.BillingStreet= cp.BillingStreet__c;
                    acc.CustomerGlobalId__c = cp.CustomerGlobalId__c;
                    acc.FirstName= cp.FirstName__c;
                    acc.LastName= cp.LastName__c;
                    acc.SalaryOrientation__c= cp.SalaryOrientation__c;
                    acc.Industry= cp.Industry__c;
                    newAccounts.put(cp.CustomerGlobalId__c, acc);
                }
            }
            if(!newAccounts.isEmpty()){
                insert newAccounts.values();
                for(String k : cpCache.keySet()){
                    CustomerProfile__c cp = cpCache.get(k);
                    if(cp.Customer_ref__c == null){
                        if(newAccounts.containsKey(cp.CustomerGlobalId__c)){
                            cp.Customer_ref__c = newAccounts.get(cp.CustomerGlobalId__c).Id;
                        }
                    }
                }
            }
        } 
    }
    static public void mapAccountToCp(List<CustomerProfile__c> scope){
        List<Account> accToUpdate = new List<Account>();
        for (CustomerProfile__c cp : scope){
            if(cp.Customer_ref__c != null){
                accToUpdate.add(new Account(CustomerProfile_ref__c = cp.Id, Id = cp.Customer_ref__c));
            }
        }
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
    static public void cleanFields(Map<Id, CustomerProfile__c> newMap, Map<id, CustomerProfile__c> oldMap){
        for(CustomerProfile__c cp: newMap.values()){
            CustomerProfile__c oldRec = oldMap.get(cp.Id);
            if (cp.SyncStatus__c == 'Unsynced' && oldRec.SyncStatus__c != cp.SyncStatus__c) {
                cp.BillingCity__c = null;
                cp.BillingCountry__c = null;
                cp.BillingPostalCode__c = null;
                cp.BillingStreet__c = null;
                cp.FirstName__c = null;
                cp.LastName__c = null;
                cp.SalaryOrientation__c = null;
                cp.Industry__c = null;
            }
        }
    }
}