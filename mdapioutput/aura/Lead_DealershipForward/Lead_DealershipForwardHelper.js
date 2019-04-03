({
	 showMap : function(component, helper, mapMarkers) {
        var mapComponent = component.find('mapComponent');
        $A.createComponent(
            "lightning:map",
            {
                "mapMarkers" : mapMarkers,
                "zoomLevel" : 4,
                "markersTitle" : 'Pick From These Locations',
                "showFooter" : 'false'
            },
            (newComponent) => {
            	mapComponent.set('v.body', [newComponent]);
        	}
		);
    }
})