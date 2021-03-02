({
    doInit : function(component, event, helper) {
        var action = component.get("c.getvisualforcedomain");
        action.setCallback(this, function(response) {
            var state = response.getState();
//            console.log('state ::', state);
            if (state === "SUCCESS") {
                var origin = response.getReturnValue(); 
                console.log("getvisualforcedomain > From server: ", origin);
                component.set('v.origin',origin);
 
            } 
        });

        $A.enqueueAction(action);
        
        var params = {
            recordId : component.get('v.recordId')
        };
//Get VF page URL based on object
        var action = component.get("c.doInit");
        action.setParams({"pmap": params});
        action.setCallback(this, function(response) {
            var state = response.getState();
//            console.log('state ::', state);
            if (state === "SUCCESS") {
                var rmap = response.getReturnValue(); 
                console.log("doInit > From server: ", rmap);
                var initUrl = rmap.initUrl;
				 console.log("doInit > initUrl: ", initUrl);
				var res = initUrl.split("=");
  				var len=res.length;
                var recordtypename=res[len-1];
                console.log(recordtypename);
                component.set('v.recordTypeName',recordtypename);
                var iframe = document.getElementById("my_iframe");
//                var iframe = component.find("my_iframe");
//                console.log('iframe :: ', iframe);
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
    doSave : function(component, event, helper) {
//        var my_iframe = document.getElementById("my_iframe");
//        console.log('my_iframe :: ', my_iframe);
        component.set('v.IsLoading',true);
        var recordId = component.get('v.recordId');
        var recordTypeName = component.get('v.recordTypeName');
        var data = component.get('v.data');

        var params = {
            recordId : recordId,
            base64Data : data
        };

        var action = component.get("c.doSave");
        console.log('action ::', action);
        if (action == undefined) return; // controller 의 addEventListener 에서 여러번 호출될 수 있다.

        action.setParams({"pmap": params,"recordTypeName":recordTypeName});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ::', state);
            component.set('v.IsLoading',false);
            if (state === "SUCCESS") {
                console.log("From server: ", response.getReturnValue());
//                component.set('v.data', '');// initialize the value of data.
                this.hideSpinner(component, event, helper);
                component.set("v.showoutsidemodal" , false);

               // $A.get('e.force:closeQuickAction').fire();
               // $A.get('e.force:refreshView').fire();
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

                this.hideSpinner(component, event, helper);
            }
        });

        $A.enqueueAction(action);
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})