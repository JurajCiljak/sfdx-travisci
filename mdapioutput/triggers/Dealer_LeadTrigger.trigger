trigger Dealer_LeadTrigger on Lead (before insert, after insert, before update, after update) {
    if(Trigger.isInsert){
        if(trigger.isBefore){
            
        }else{
            
        }
    }else if(Trigger.isUpdate){
        if(trigger.isBefore){
            Dealer_LeadService.changeStatus(Trigger.newMap, Trigger.oldMap);
        }else{
            
        }
    }
}