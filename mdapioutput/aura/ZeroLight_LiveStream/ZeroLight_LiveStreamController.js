({
    doInit : function(component, event, helper) {
        var action = component.get("c.getZeroLightCode"); 
        action.setParams({
            recordId: component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var zeroLightCode = a.getReturnValue();
            component.set("v.zeroLightCode",zeroLightCode);
        });
        $A.enqueueAction(action);  
    }
})