({
    leadChangeRequestJS : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get("c.leadChangeRequest");
        var leadIds = component.get("v.recordId");
        var selectedDealership = component.get("v.selectedValue");
        selectedDealership = JSON.parse(selectedDealership);
        var dealershipId = selectedDealership.id;
        delete selectedDealership.dealershipname;
        delete selectedDealership.address;
        delete selectedDealership.id;
        action.setParams({
            leadIds: [leadIds],
            account: JSON.stringify(selectedDealership),
            dealershipId: dealershipId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS" ){
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "It was successfully sent to the dealership."
                });
                toastEvent.fire();   
            }else{
                var toastEvent = $A.get("e.force:showToast");
                
                // ERROR Messaging
                let errors = response.getError();
        		let message ; // Default error message
                
                try{
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        var i = 0;
                        for (i = 0; i < errors.length; i++) { 
                            message = JSON.parse(errors[i].message);
                        }
                    } 
                    
                    // Display the message
                    console.log( JSON.stringify( message ));
                }catch(err){
                	console.log( err.message );    
                }
                
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": message.Name
                });
                toastEvent.fire(); 
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    loadOptionsJS: function (component, event, helper) {
        var action = component.get("c.getDealersAccounts");
        
        action.setCallback(this,function(response){
            var opts = [];
            response.getReturnValue().map(user => {
                ;
                let userDetails = JSON.stringify({
                	username: user.LoginUser__r.oAuthUserName__c,
                	password: user.LoginUser__r.oAuthPassword__c,
                	security: user.LoginUser__r.SecurityToken__c,
                    url: user.LoginUser__r.oAuthEndpoint__c,
                	dealershipname: user.DealershipOrganisation_ref__r.Name,
                	address: {
                		country: user.DealershipOrganisation_ref__r.Country__c,
                		city: user.DealershipOrganisation_ref__r.City__c,
                		street: user.DealershipOrganisation_ref__r.Street__c
            		},
					email: user.DealershipOrganisation_ref__r.Email__c,
                    website: user.DealershipOrganisation_ref__r.Website__c,
                    phone: user.DealershipOrganisation_ref__r.Phone__c,
                    location: {
                    	latitude: user.DealershipOrganisation_ref__r.Location__Latitude__s,
                        longitude: user.DealershipOrganisation_ref__r.Location__Longitude__s
					},
                    id: user.DealershipOrganisation_ref__c
            	});
            opts.push({
                value: userDetails,
                label: user.DealershipOrganisation_ref__r.Name
            });
            
        });
        component.set("v.listOfDealers", opts);
    });
    $A.enqueueAction(action);
},

 getDealershipDetailsJS: function (component, event, helper) {
    var selectedValue = JSON.parse(component.get("v.selectedValue"));
    component.set("v.selectedDealership", selectedValue);
    let mapMarkers = 
            [{
                location: {
                	Latitude: selectedValue.location.latitude,
                	Longitude: selectedValue.location.longitude,
                },

                icon: 'utility:salesforce1',
                title: selectedValue.dealershipname,
                description: selectedValue.address.country +  ', ' 
                                          + selectedValue.address.city+  ', ' 
                                          +	selectedValue.address.street
            }];
    helper.showMap(component, helper, mapMarkers);
    
},
})