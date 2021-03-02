({
    SearchHelper: function(component, event) {
        
        var searchProductCode = component.get("v.searchKeyWord").trim(); 
        // alert(searchProductCode.length);
        if(searchProductCode.length>0 && searchProductCode.length!=0){  
            
            component.set("v.isModalOpen", true); 
            var action = component.get("c.getRequestProductNewItem");               
            action.setParams({            
                'searchKeyWord':'%'+ component.get("v.searchKeyWord").trim() +'%'  
                
            });
            
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                // console.log(''+state);
                if (state === "SUCCESS") {
                    
                    var storeResponse = response.getReturnValue();
                    //    console.log('tedt'+JSON.stringify(response.getReturnValue()));
                    if (storeResponse.length == 0) {
                        component.set("v.Message", true);
                    } else {
                        component.set("v.Message", false);
                    }
                    component.set("v.searchResult", storeResponse);  
                    //  alert(storeResponse);
                    console.log('Search Result'+storeResponse);                
                    
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
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'Error',
                "mode" : 'dismissible',
                "duration" : 5000,
                "message": "Please enter the Product Code."
            });       
        }
        
    },
    saveHelper: function(component, event){
      /* var allValid = component.find('searchProductCode').reduce(function (validSoFar, inputCmp) 
                                                                  {
                                                                      inputCmp.showHelpMessageIfInvalid();
                                                                      return validSoFar && !inputCmp.get('v.validity').valueMissing;
                                                                  }, true);
        if (allValid) {*/
            
            component.set("v.newProductRequestLineItem.ParentId", component.get("v.recordId"));
            component.set("v.newProductRequestLineItem.Product2Id", component.get("v.selectedProductId"));
            //  alert(component.get("v.recordId"));
            //  alert(component.get("v.selectedProductId"));
            var newListItem = component.get("v.newProductRequestLineItem");         
            var action = component.get("c.saveProductRequestLineItem");
            action.setParams({ 
                "objProductRequestLineItem": newListItem});
            action.setCallback(this, function(a) {
                var state = a.getState();          
                if (state === "SUCCESS") {               
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'This is a success message',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    component.set("v.isModalOpen", false);   
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                else
                {
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
                }
            });
            $A.enqueueAction(action)
       /* }else
        {
            if()
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please enter Product Name, Qty and Description',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }*/
    },
    
    SaveAndNewHelper: function(component, event){
        var allValid = component.find('searchProductCode').reduce(function (validSoFar, inputCmp) 
                                                                  {
                                                                      inputCmp.showHelpMessageIfInvalid();
                                                                      return validSoFar && !inputCmp.get('v.validity').valueMissing;
                                                                  }, true);
        if (allValid) {
            
            component.set("v.newProductRequestLineItem.ParentId", component.get("v.recordId"));
            component.set("v.newProductRequestLineItem.Product2Id", component.get("v.selectedProductId"));
            var newListItem = component.get("v.newProductRequestLineItem");         
            var action = component.get("c.saveProductRequestLineItem");
            action.setParams({ 
                "objProductRequestLineItem": newListItem});
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {                
                    
                    component.set("v.searchKeyWord", "");
                    component.set("v.newProductRequestLineItem.QuantityRequested","");
                    component.set("v.newProductRequestLineItem.Description","");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'This is a success message',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                else
                {
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
                }
            });
            $A.enqueueAction(action)
        }else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please enter Product Name, Qty and Description',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    }
    
    
})