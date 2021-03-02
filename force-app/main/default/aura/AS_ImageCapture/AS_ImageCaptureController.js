({
handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
       // alert("Files uploaded : " + uploadedFiles.length);

        // Get the file name
       // uploadedFiles.forEach(file => console.log(file.documentId));
		var recordId = component.get("v.recordId");
        var action = component.get("c.saveFile");
    		action.setParams(
            {
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