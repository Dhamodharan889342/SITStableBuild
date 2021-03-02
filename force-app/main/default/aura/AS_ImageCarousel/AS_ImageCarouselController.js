({
    init : function(component, event, helper) {
        var speed=component.get("v.interval");
         var action = component.get("c.getCameraFiles");
        var recordId=component.get('v.recordId');
        action.setParams({"recordId": recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
//            console.log('state ::', state);
            if (state === "SUCCESS") {
              component.set('v.Files', response.getReturnValue());
 			console.log(response.getReturnValue());
            } 
        });

      $A.enqueueAction(action);
     
    }
 
    
})