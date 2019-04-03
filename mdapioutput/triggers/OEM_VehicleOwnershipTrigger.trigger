/*
    @Author: Juraj Ciljak
    @CreateDate: 26.02.2019
    @Description: Handler class for VehicleOwnership
                  Task: SF-XX     - https://jira.mhp.be/browse/
     @LastModify:


    @Version: 1.0.1
*/
trigger OEM_VehicleOwnershipTrigger on VehicleOwnership__c (before insert, before update) {
    /*if( Trigger.isBefore ){
        if ( Trigger.isInsert)
        {
            OEM_VehicleOwnershipService.mainBeforeInsertLoop( Trigger.new, Trigger.oldMap, Trigger.newMap );
        } else if( Trigger.isUpdate ){
            OEM_VehicleOwnershipService.mainBeforeInsertLoop( Trigger.new, Trigger.oldMap, Trigger.newMap );
        }
    }*/
    if( Trigger.isBefore ){
        if(Trigger.isInsert){
            OEM_VehicleOwnershipService.assignVehicleOwnershipGlobalId(Trigger.new);
        }else if ( Trigger.isUpdate){
            
        } else{
            
        }
    } else{

    }
 
}