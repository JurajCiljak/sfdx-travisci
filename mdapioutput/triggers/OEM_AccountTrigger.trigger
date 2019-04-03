trigger OEM_AccountTrigger on Account (before insert, before update, after insert, after update) {
	if(Trigger.isInsert){
        if(trigger.isBefore){
            OEM_AccountService.assignGlobalId(Trigger.new);
        }else{
            
        }
    }else if(Trigger.isUpdate){
        if(trigger.isBefore){
            
        }else{
            
        }
    }
}