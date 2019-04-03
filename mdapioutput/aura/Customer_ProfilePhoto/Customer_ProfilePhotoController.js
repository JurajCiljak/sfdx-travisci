({
    onInit : function(component,event,helper){
        
    },onInitAccount : function(component, event, helper) {
        var action = component.get("c.getProfilePicture"); 
        action.setParams({
            parentId: component.get("v.simpleAccount").Id,
        });
        action.setCallback(this, function(a){
            var attachment = a.getReturnValue();
            if (attachment && attachment.Id) {
                component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file=' 
                              + attachment.Id);
            }
            helper.loaded(component);
        });
        $A.enqueueAction(action); 
        
    },onInitLead : function(component, event, helper) {
        var action = component.get("c.getProfilePictureLead"); 
        action.setParams({
            customerGlobalId: component.get("v.simpleLead").CustomerGlobalId__c,
        });
        
        action.setCallback(this, function(a) {
            var attachment = a.getReturnValue();
            if (attachment && attachment.Id) {
                component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file=' 
                              + attachment.Id);
                
            }
            helper.loaded(component);
        });
        $A.enqueueAction(action); 
        
    }, onDragOver: function(component, event) {
        event.preventDefault();
    },
    
    onDrop: function(component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("You can only upload one profile picture");
        }
        helper.readFile(component, helper, files[0]);
    }
})