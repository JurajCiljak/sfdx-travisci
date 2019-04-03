({
    onInitAccount : function(component, event, helper) {
        var action = component.get("c.getAllVehicles"); 
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var vehicles = a.getReturnValue();
            component.set("v.vehicles", vehicles);
            helper.loaded(component);
        });
        $A.enqueueAction(action);
    },
    
    
    onInitLead : function(component, event, helper) {
        var action = component.get("c.getAllVehiclesLead"); 
        action.setParams({
            customerGlobalId: component.get("v.simpleLead").CustomerGlobalId__c,
        });
        action.setCallback(this, function(a) {
            var vehicles = a.getReturnValue();
            component.set("v.vehicles", vehicles);
            helper.loaded(component);
        });
        $A.enqueueAction(action);
    },
    
    
    
    newVehicle : function(component, event, helper){
        if(component.get("v.sObjectName") == 'Account'){
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "VehicleOwnership__c",
                "defaultFieldValues": {
                    "Account_ref__c" : component.get("v.recordId"),
                }
            });
            createRecordEvent.fire();
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Access denied",
                "type": "warning",
                "message": "This action is not supported for "+component.get('v.sObjectName')+" object"
            });
            toastEvent.fire();
        }
    },
    navigateTo : function (component, event, helper) {
        var id = event.target.getAttribute('data-index');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})