({
	init : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        console.log("FlowRedirectController navEvt");
		navEvt.setParams({
		  "recordId": component.get("v.recId"),
		  "slideDevName": "related"
		});
		navEvt.fire(); 
		
	}
})