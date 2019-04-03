({
    doInit : function(component, event, helper) {
        
        jQuery("document").ready(function(){
            console.log('jquery loaded');
            
        });
        component.set("v.height", $(window).height()-92);
    },
    openNav : function(component, event, helper) {
        $('#mySidenav').css("width",250);
    },
    closeNav : function(component, event, helper) {
        $('#mySidenav').css("width",0);
    }
})