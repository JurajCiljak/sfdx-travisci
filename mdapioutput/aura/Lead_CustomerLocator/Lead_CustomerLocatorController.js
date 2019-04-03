({
    onInitLead : function(component, event, helper) {
        var ld = component.get("v.simpleLead");
        var action = component.get("c.locateCustomer");
        action.setParams({ 
            FirstName : component.get("v.simpleLead").FirstName,
            LastName : component.get("v.simpleLead").LastName
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS" ){
                component.set('v.accounts',response.getReturnValue());
                component.set('v.showSpinner',false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message":" Oops, something went wrong"
                });
                toastEvent.fire(); 
            }
        });
        $A.enqueueAction(action);
    },
    openAccount: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        var selectedItem = event.currentTarget;
          var recId = selectedItem.getAttribute('data-accId');

        navEvt.setParams({
            "recordId": recId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    merge : function (component, event, helper){
        var action = component.get("c.mergeWithAccount");
        action.setParams({ 
            leadId : component.get("v.recordId"),
            accId : event.getSource().get("v.value")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS" ){
                var ld = response.getReturnValue();
                component.set('v.showSpinner',false);
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Lead was Successfully merged with Account."
                });
                toastEvent.fire(); 
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message":" Oops, something went wrong"
                });
                toastEvent.fire(); 
            }
        });
        component.set('v.showSpinner',true);
        $A.enqueueAction(action);
        
    }
})