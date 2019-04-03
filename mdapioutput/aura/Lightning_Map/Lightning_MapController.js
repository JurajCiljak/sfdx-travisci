({
    onInitAccount: function (component, event, helper) {
        var acc = component.get('v.simpleAccount');
        var markers = [];
        if(acc.BillingStreet != null){
            markers.push({
                location: {
                    Street: acc.BillingStreet,
                    City: acc.BillingCity,
                    Country: acc.BillingCountry,
                },
				icon: 'custom:custom26',
                title: 'Billing Address',
                description: acc.BillingStreet+', '+acc.BillingPostalCode+' '+acc.BillingCity+', '+acc.BillingCountry,
            });
        }
        if(acc.ShippingStreet != null){
            markers.push({
                location: {
                    Street: acc.ShippingStreet,
                    City: acc.ShippingCity,
                    Country: acc.ShippingCountry,
                },
				icon: 'custom:custom26',
                title: 'Shipping Address',
                description: acc.ShippingStreet+', '+acc.ShippingPostalCode+' '+acc.ShippingCity+', '+acc.ShippingCountry,
            });
        }
        component.set('v.mapMarkers', markers);
        component.set('v.markersTitle', 'Customer Addresses');
        helper.loaded(component);
    },onInitLead: function (component, event, helper) {
        var lead = component.get('v.simpleLead');
        
        component.set('v.mapMarkers', [
            {
                location: {
                    Street: lead.Street,
                    City: lead.City,
                    Country: lead.Country,
                },

                title: lead.LastName+', '+lead.FirstName,
                description: lead.Street+', '+lead.PostalCode+' '+lead.City+', '+lead.Country,
            }
        ]);
        helper.loaded(component);
    }
})