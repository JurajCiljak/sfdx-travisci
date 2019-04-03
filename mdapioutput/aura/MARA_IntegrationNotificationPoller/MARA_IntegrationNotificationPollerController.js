({
    recordUpdated : function(component, event, helper) {
        console.log('recordUpdated');
        if(component.get('v.simpleRecord').IntegrationStatus__c != 'error'){
            component.find('standardController').reloadRecord(true)
        }else{
            var toastEvent = $A.get("e.force:showToast");
            
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": component.get('v.simpleRecord').IntegrationResponse__c
            });
            toastEvent.fire(); 
        }
    }
})