({
	// Load current profile picture
    onInit: function(component) {
        var action = component.get("c.getVehiclePictures"); 
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var contents = a.getReturnValue();
	       component.set('v.pictures', contents);
        });
        $A.enqueueAction(action); 
    },
})