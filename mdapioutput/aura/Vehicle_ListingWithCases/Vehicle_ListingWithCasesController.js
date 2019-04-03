({
    initCasesForVehicle: function(component) {
        var action = component.get("c.getCasesForVehicle");
        action.setParams({
            vehicleId: component.get("v.vehicleId")
        });
        action.setCallback(this, function(a) {
            var cases = a.getReturnValue();
            component.set("v.cases", cases);
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
    },
    handleSelect: function (cmp, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        alert("Menu item selected with value: " + selectedMenuItemValue);
    },
    handleClick : function (cmp, event, helper) {
        alert("You clicked: " + event.getSource().get("v.label"));
    }
})