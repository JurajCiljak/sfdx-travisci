({
    doInit : function(component, event, helper){
        $A.createComponent(
            "wave:waveDashboard",
            {
                "dashboardId": component.get('v.dashboardId'),
                "height" : component.get('v.height'),
                "showTitle" : true,
                "showSharing" :false,
                "openLinksInNewWindow" : false,
                "filter" : component.get('v.filter').replace('$Id',component.get('v.recordId'))
            },
            function(newInp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newInp);
                    component.set("v.body", newInp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    }
    
})