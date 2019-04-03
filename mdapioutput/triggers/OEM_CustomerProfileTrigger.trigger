trigger OEM_CustomerProfileTrigger on CustomerProfile__c (before insert, before update, after insert, after update) {
	if(Trigger.isInsert){
        if(trigger.isBefore){
            OEM_CustomerProfileService.assignGlobalId(Trigger.new);
            OEM_CustomerProfileService.copyFieldFromAccount(Trigger.new);
        }else{
            
        }
    }else if(Trigger.isUpdate){
        if(trigger.isBefore){
            
        }else{
            
        }
    }
}