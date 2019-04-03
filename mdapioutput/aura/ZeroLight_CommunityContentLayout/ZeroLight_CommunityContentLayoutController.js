({
	doInit : function(component, event, helper) {
        
        jQuery("document").ready(function(){
            console.log('jquery loaded');
            
        });
        component.set("v.height", $(window).height()-92);
    },
})