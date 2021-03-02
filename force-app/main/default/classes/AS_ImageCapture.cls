/*
Author: Neha Aggrawal
Created Date: 18-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026
*/

public class AS_ImageCapture {
 @AuraEnabled
    public static void saveFile(String recordId, String DocumentId)
    {
      
        System.debug(recordId);
        Datetime d = Datetime.now();
        String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');
       
	 	ContentVersion cont=[Select Id,Title from ContentVersion where ContentDocumentId=:DocumentId];
        cont.Title='CameraPhoto_'+s+'_'+cont.Title;
        update cont;

        
		
     
		cont.VersionData=null;
		cont=null;     
    }
}