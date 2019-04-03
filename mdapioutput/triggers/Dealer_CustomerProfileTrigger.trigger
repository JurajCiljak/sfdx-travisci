trigger Dealer_CustomerProfileTrigger on CustomerProfile__c (before insert, before update, after insert, after update) {
if(Trigger.isInsert){
        if(trigger.isBefore){
            Dealer_CustomerProfileService.mapCpToAccount(Trigger.new);
        }else{
            Dealer_CustomerProfileService.mapAccountToCp(Trigger.new);
        }
    }else if(Trigger.isUpdate){
        if(trigger.isBefore){
            Dealer_CustomerProfileService.blockChangingCustomerGlobalId(Trigger.newMap, Trigger.oldMap);
            Dealer_CustomerProfileService.cleanFields(Trigger.newMap, Trigger.oldMap);
        }else{
            
        }
    }
}