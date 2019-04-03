trigger Dealer_CaseTrigger on Case (before insert, before update, after insert, after update) {
    if( Trigger.isBefore ){
        if(Trigger.isInsert){
            //HLPR_Case.mainBeforeInsertLoop( Trigger.new,  Trigger.newMap );
        }else if ( Trigger.isUpdate){
            Dealer_CaseService.changeStatus(Trigger.newMap, Trigger.oldMap);
        } else{
            
        }
    } else{

    }
}