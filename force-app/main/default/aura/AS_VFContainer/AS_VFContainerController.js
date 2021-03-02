({
    init : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId :: ', recordId);
        function eventHandler(event) {
            var origin = component.get('v.origin');//"https://genesismotoreurope--dev--c.visualforce.com"; // All event in window, so try to capture a visualforce page event.

            if (event.origin !== origin) return;
            var param = event.data;
           console.log('message param ::', param);
            var command = param.command;
            if (command == 'save') {
                var data = param.data;
               // console.log('image ::', data);
                component.set('v.data', data);
                helper.doSave(component, event, helper);
            }
        }

        window.addEventListener("message", eventHandler, false); // message event is reserved so cannot change it.

        helper.doInit(component, event, helper);
    },
    save : function(component, event, helper) {
//        this.sendToVF(component, event, helper);
//        helper.doSave(component, event, helper);
    },
    sendToVF : function(component, event, helper) {
        var message = component.get("v.message");
        var param = {};
        param.command = 'save';
        console.log('param :: ', param);
        var origin = component.get('v.origin');//"https://genesismotoreurope--dev--c.visualforce.com";// vf page domain
        var iframe = component.find("aura_iframe").getElement().contentWindow;
        iframe.postMessage(param, origin);
    },
    onRender : function(component, event, helper) {
//        console.log('onRender');
    },
    cancel: function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },
     next: function(component, event, helper) {
         component.set("v.showuploadphotos" , true);
    },
    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
       // alert("Files uploaded : " + uploadedFiles.length);

        // Get the file name
       // uploadedFiles.forEach(file => console.log(file.documentId));
		var recordId = component.get("v.recordId");
         var recordTypeName = component.get('v.recordTypeName');
        var action = component.get("c.saveFile");
    		action.setParams(
            {
                "recordTypeName":recordTypeName,
                "recordId": recordId,
                "DocumentId":uploadedFiles[0].documentId
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
         
        });

        $A.enqueueAction(action);
     $A.get('e.force:closeQuickAction').fire();
	},

})