({
    doSaveSign: function (component, event, helper) {
   	var signername='';
        console.log('helper doSave');
       var selectedoption= component.get("v.selectedoption");
        console.log(selectedoption);
        var recordTypeName=component.get("v.recordTypeName");
        console.log(recordTypeName);
        if(component.get("v.showsignerfield"))
       	signername=component.find("Signer_name").get("v.value");  
        console.log(signername);
        component.set('v.IsLoading',true);
        var recordId = component.get("v.recordId");
        console.log(recordId);
		var canvas = component.find('padd').getElements()[0];
        console.log(canvas);
		var dataURI = canvas.toDataURL.apply(canvas);
		console.log('dataURI :: ', dataURI);
		var base64Data = dataURI.replace(/^data:image\/(png|jpg);base64,/, '');
        console.log('base64Data :: ', base64Data);
       
         if((component.get("v.showsignerfield") && signername!=="") || (component.get("v.showsignerfield")===false && signername===""))
         { 
             console.log('here');
       		
        var params = {
            recordId : recordId,
            base64Data : base64Data
        };

        var action = component.get("c.doSaveSign");
        action.setParams(
            {
                "pmap": params,
                "selected": selectedoption,
                "recordTypeName":recordTypeName,
                "signername":signername
            }
        );
      
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.IsLoading',false);
            if( state === 'SUCCESS' ){
                var returnData      = response.getReturnValue();
                var responseStatus  = returnData.responseStatus;

                if( responseStatus.result === 'SUCCESS' ){
                    $A.get("e.force:showToast").setParams({"title": "Success","type": "success","message": "Success"}).fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get('e.force:closeQuickAction').fire();
                }else{
                    $A.get("e.force:showToast").setParams({"title": "Error","type": "error","message": responseStatus.message}).fire();
                }
            }else{
                $A.get("e.force:showToast").setParams({"title": "Error","type": "error","message": "Error occurred."}).fire();
            }
        });

        $A.enqueueAction(action);
        }
        else
        {
        component.set("v.showerror", true);
		component.set("v.errormessage", "Please fill the mandatory fields.");
        }
    },
     doNext: function (component, event, helper) {
 		component.set("v.showRadioScreen" , false);
       component.set("v.selectedoption",component.find("radiooptions").get("v.value"));
         console.log(component.find("radiooptions").get("v.value"));
         if(component.find("radiooptions").get("v.value")=='Signer_On_Behalf')
             component.set("v.showsignerfield" , true);
     }
})