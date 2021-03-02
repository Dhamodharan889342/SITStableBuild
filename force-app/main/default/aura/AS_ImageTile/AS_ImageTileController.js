({
	  previewFile :function(c,e,h){
		var selectedPillId = e.getSource().get("v.name");
		$A.get('e.lightning:openFiles').fire({
		        recordId: [selectedPillId]
	        });
      }
})