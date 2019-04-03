trigger OEM_ProductTrigger on Product2 (before insert, before update, after insert, after update) {
    if( Trigger.isBefore ){
        if(Trigger.isInsert){
            OEM_ProductService.assignGlobalId(Trigger.new);
        }else if ( Trigger.isUpdate){
            
        } else{
            
        }
    } else{

    }
}