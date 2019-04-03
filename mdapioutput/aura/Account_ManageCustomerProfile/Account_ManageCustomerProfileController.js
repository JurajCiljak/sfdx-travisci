({
    loadPersonAccountsJS: function (component, event, helper) {
        var action = component.get("c.getPersonAccounts");
        var recordId = component.get("v.recordId") ? component.get("v.recordId") : component.get("v.accountId");
        action.setParams({
            masterAccountId: recordId
        });
        action.setCallback(this,function(response){
            component.set("v.customerProfiles", response.getReturnValue());
            component.set("v.customerProfilesToUpdate", helper.deepCopy(response.getReturnValue()));
        });
        $A.enqueueAction(action);
    },
    
    refreshPageJS: function(component, event, helper) {
        $A.enqueueAction(component.get("c.loadPersonAccountsJS"));
    },
    
    handleToggleChangedJS: function(component, event, helper) {
        var customerProfilesUpdated = component.get("v.customerProfilesToUpdate");
        var customerProfiles = component.get("v.customerProfiles");
        console.log(customerProfiles === customerProfilesUpdated);
        if(customerProfiles[event.target.dataset.idx].SyncStatus__c === "Synced"){
            customerProfilesUpdated[event.target.dataset.idx].SyncStatus__c = event.getParam("checked") ? "Synced" : "Pending for Unsync";
        } else if(customerProfiles[event.target.dataset.idx].SyncStatus__c === "Unsynced") {
        	customerProfilesUpdated[event.target.dataset.idx].SyncStatus__c = event.getParam("checked") ? "Pending for Sync" : "Unsynced";
        }
        component.set("v.customerProfilesToUpdate", customerProfilesUpdated);
    },
    
    updateCustomerProfilesJS : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get("c.updateCustomerProfiles");
        var customerProfiles = component.get("v.customerProfilesToUpdate");
        action.setParams({
            customerProfiles: customerProfiles
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS" ){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "It was successfully sent to the dealership."
                });
                toastEvent.fire();
                $A.enqueueAction(component.get("c.loadPersonAccountsJS"));
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message":" Oops, something went wrong"
                });
                toastEvent.fire(); 
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    }
})