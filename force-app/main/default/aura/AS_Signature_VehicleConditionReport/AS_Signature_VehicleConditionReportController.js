({
	doInit: function(component, event, helper) {
       
		      console.log('doInit');
       
		var canvas = component.find('padd').getElements()[0], signaturePad;
		function resizeCanvas() {
			var ratio = Math.max(window.devicePixelRatio || 1, 1);
			canvas.width = canvas.offsetWidth * ratio;
			canvas.height = canvas.offsetHeight * ratio;
			canvas.getContext('2d').scale(ratio, ratio);
		}

		window.onresize = resizeCanvas;
		resizeCanvas();

        var options = {
//            dotSize : 50,
            minWidth : 2,
            maxWidth : 4
        };
		signaturePad = new SignaturePad(canvas, options);
	},
    init:function(component, event, helper) {
        console.log('init');
          var params = {
            recordId : component.get('v.recordId')
        };
		console.log(component.get('v.recordId'));
        var action = component.get("c.getRecordType");
        action.setParams({"pmap": params});
        action.setCallback(this, function(response) {
            var state = response.getState();
          console.log('state ::', state);
            if (state === "SUCCESS") {
                var recordtypename = response.getReturnValue();
                console.log("From server: ", recordtypename);
                component.set('v.recordTypeName',recordtypename);
                console.log(recordtypename);
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
	doSave: function(component, event, helper) {
		console.log('doSaveSign');
		helper.doSaveSign(component, event, helper);
	},
	doCancel: function(component, event, helper) {
		console.log('doCancel');
		$A.get('e.force:closeQuickAction').fire();
	},
    doNext: function(component, event, helper) {
		console.log('doNext');
		helper.doNext(component, event, helper);
	}
})