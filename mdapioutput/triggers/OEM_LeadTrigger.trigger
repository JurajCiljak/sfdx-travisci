trigger OEM_LeadTrigger on Lead (before insert, after insert, before update, after update) {
    if(Trigger.isInsert){
        if(trigger.isBefore){
            OEM_LeadService.assignGlobalId(Trigger.new);
            OEM_LeadService.relateLead(Trigger.new);
        }else{
            OEM_LeadService.searchZerolightDatabase(Trigger.new);
        }
    }else if(Trigger.isUpdate){
        if(trigger.isBefore){
            
        }
    }
}