trigger OEM_CaseTrigger on Case (before insert, before update, after insert, after update) {
    if( Trigger.isBefore ){
        if(Trigger.isInsert){
            OEM_CaseService.assignGlobalId(Trigger.new);
            OEM_CaseService.assignDealership(Trigger.new);
        }else if ( Trigger.isUpdate){
            
        } else{
            
        }
    } else{
        if(Trigger.isInsert){
            OEM_CaseService.syncCaseWithPreferredDealer(Trigger.new);
        }else if ( Trigger.isUpdate){
            
        } else{
            
        }
    }
}