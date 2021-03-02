/*
 * Author: Neha Aggrawal
Created Date: 18-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026
*/

public without sharing class AS_ImageCarousel { 
  
     @AuraEnabled
    public static List<String> getCameraFiles(String recordId)
    {
        //Get all files attached to record with 'CameraPhoto_' in their titles
        List<String> contentVersionList =new List<String>();
        Set<Id> cdlSet= new Set<Id>();
       ContentDocumentLink[] cdl =[SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =:recordId];
        
        for(ContentDocumentLink cd:cdl)
        {
            cdlSet.add(cd.ContentDocumentId); 
        }
        ContentVersion[] cdo = [Select Id from ContentVersion where Title like '%CameraPhoto_%' and ContentDocumentId in:cdlSet];
        for(ContentVersion c:cdo)
        {
            contentVersionList.add(c.Id); 
        }
           return  contentVersionList;                       
     }
    
}