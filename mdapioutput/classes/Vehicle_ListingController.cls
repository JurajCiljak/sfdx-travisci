public with sharing class Vehicle_ListingController {
   
    @AuraEnabled
    public static List<Case> getCasesForVehicle(Id vehicleId) {
        return [select Id, ContactId, Subject, Priority from Case where VehicleOwnership_ref__r.Vehicle_ref__c=:vehicleId order by createdDate DESC limit 5];
    }
    
    @AuraEnabled
    public static List<Vehicle__c> getAllVehicles(Id parentId) {
        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Vehicle__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        
        return [select 
                VehicleIdentificationNumber__c, 
                Product_ref__r.Name, 
                Product_ref__r.Brand__c,
                Product_ref__r.Model__c,
                Product_ref__r.Picture__c,
                Product_ref__r.Year__c
                from 
                Vehicle__c 
                where Id in 
                (select Vehicle_ref__c from VehicleOwnership__c where Account_ref__c =: parentId)];
    }
    @AuraEnabled
    public static List<Vehicle__c> getAllVehiclesLead(String customerGlobalId) {
        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Vehicle__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        Account acc = [Select Id from Account where CustomerGlobalId__c =: customerGlobalId];
        if(acc != null)
        return [select 
                VehicleIdentificationNumber__c, 
                Product_ref__r.Name, 
                Product_ref__r.Brand__c,
                Product_ref__r.Model__c,
                Product_ref__r.Picture__c,
                Product_ref__r.Year__c
                from 
                Vehicle__c 
                where Id in 
                (select Vehicle_ref__c from VehicleOwnership__c where Account_ref__c =: acc.Id)];
         else
                 return new List<Vehicle__c>();
    }
}