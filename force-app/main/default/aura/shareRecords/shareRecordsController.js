({
    handleClick : function(component, event, helper) {
        component.set("v.isModalOpen", true);     
    },
    openModel: function(component, event, helper) {
        
        component.set("v.isModalOpen", true);
    },  
    closeModel: function(component, event, helper) {
        
        component.set("v.isModalOpen", false);
    },
    searchDetail:function(component, event, helper){
        debugger;
        
        /*var allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) 
                                                        {
                                                            inputCmp.showHelpMessageIfInvalid();
                                                            return validSoFar && !inputCmp.get('v.validity').valueMissing;
                                                        }, true); */
        // if (allValid ) {             
        var action = component.get("c.getPersonAccount1");
        // alert( component.get("v.firstName"));
        //alert( component.get("v.lastName"));
        //alert( component.get("v.VIN"));
        // alert( component.get("v.password"));
        
        action.setParams({ strfirstName :     component.get("v.firstName"),
                          strlastName : component.get("v.lastName"),
                          strVIN : component.get("v.VIN"),
                          strpassword : component.get("v.password")});
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            console.log(""+state);
            if (state === "SUCCESS") {                                  
                                      var accountId = [];             
                                      accountId = response.getReturnValue();   
                                      
                                      if(accountId.length>0)
                                      { 
                                       var navEvt = $A.get("e.force:navigateToSObject");
                                       navEvt.setParams({
                                           "recordId": accountId[0].Id
                                       });
                                       navEvt.fire();
                                      }
                                      else
                                      {   
                                          
                                          var toastEvent = $A.get("e.force:showToast");
                                          toastEvent.setParams({
                                              "title": "Error!",
                                              "type" : 'Error',
                                              "mode" : 'dismissible',
                                              "duration" : 5000,
                                              "message": "The Record does not match with the existing records."
                                          });                      
                                          toastEvent.fire();
                                          // component.set("v.isModalOpen", false);                   
                                      }
                                     }
            else if (state === "INCOMPLETE") {               
                                             }
                else if (state === "ERROR") {
                    //
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'This is an error message',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    //                                                  
                    /*  var errors = response.getError();
                        if (errors) { alert('in else part -3-error'+errors)
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else { alert('in else part -4'); 
                            console.log("Unknown error");
                        }*/
                    }
            });        
        $A.enqueueAction(action); 
        //}
        /* else {
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'Error',
                "mode" : 'dismissible',
                "duration" : 5000,
                "message": "Please enter the correct Value."
            });             
        } */     
    }
})