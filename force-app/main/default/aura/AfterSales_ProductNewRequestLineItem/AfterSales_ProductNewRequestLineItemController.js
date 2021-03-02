({
    doInit : function(component, event) {   
        
        var action = component.get("c.getRequestProductNumber");       
        action.setParams({            
            'recordId':component.get("v.recordId")         
        });
        action.setCallback(this, function(response) {  
            var state = response.getState();           
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                console.log('Store Response'+storeResponse);
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }             
                component.set("v.RequestProductParentId", storeResponse); 
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    Search: function(component, event, helper) {    
        
        helper.SearchHelper(component, event);
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {      
        component.set("v.isModalOpen", false);
    },
    
    submitDetails: function(component, event, helper) {   
        component.set("v.isModalOpen", false);
    },    
    handleSelect: function(component, event, helper) {        
        var selectedId = event.target.dataset.id;           
        component.set("v.searchKeyWord",selectedId);
        var selectedProductId=event.target.dataset['pname'];      
        component.set("v.selectedProductId", event.target.dataset['pname']);   
        component.set("v.isModalOpen", false);      
    },
    createProductRequestLineItem:function(component, event, helper) {       
        helper.saveHelper(component, event);        
    },   
    
    saveAndNewRecord:function(component, event, helper) {  
        helper.SaveAndNewHelper(component, event);      
        
    },
    
    openSupersessionRecord : function (component, event, helper) {
        var selectedSupersessionId=event.target.dataset['pname'];  
        
        var action = component.get("c.getSupersessionProductNewItem");       
        action.setParams({            
            'searchSupersessionKeyWord':selectedSupersessionId         
        });
        action.setCallback(this, function(response) {  
            var state = response.getState();           
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                //  alert('Store Response'+storeResponse);
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }   
                var navEvt = $A.get("e.force:navigateToSObject");        
                navEvt.setParams({
                    "recordId":  storeResponse,
                    "slideDevName": "related"
                });
                navEvt.fire();                 
                
            }else if (state === "INCOMPLETE") {           
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  
        
    }
})