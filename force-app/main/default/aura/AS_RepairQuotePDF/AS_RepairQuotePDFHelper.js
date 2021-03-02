({
    fn_init: function (component, event, helper) {
        var params = {
            recordId : component.get('v.recordId')
        };
		//generate VF page URL
        var action = component.get("c.doInit");
        action.setParams({"pmap": params});
        action.setCallback(this, function(response) {
            var state = response.getState();
//            console.log('state ::', state);
            if (state === "SUCCESS") {
                var rmap = response.getReturnValue();
                console.log("From server: ", rmap);
                var initUrl = rmap.initUrl;

                var iframe = document.getElementById("my_iframe");
                iframe.src = initUrl;

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    fn_save: function (component, event, helper) {
        console.log('helper doSave');
        //Save generated PDF
        component.set('v.IsLoading',true);
        var recordId = component.get('v.recordId');
        var params = {
            recordId : recordId
        };

        var action = component.get("c.doSavePDF");
        action.setParams({"pmap": params});
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.IsLoading',false);
            console.log('state ::', state);
            if (state === "SUCCESS") {
                console.log("From server: ", response.getReturnValue());
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

})