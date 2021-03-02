/*
 
Author: Neha Aggrawal
Created Date: 15-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026

*Update: Daniel Varhidi - add Courtesy_Car_Contract__c
 */

public without sharing class AS_VFContainer { 
    @AuraEnabled
    public static String getvisualforcedomain()
    {
       String hostname= Url.getSalesforceBaseUrl().getHost();
        hostname=hostname.replace('.my.salesforce.com', '--c.visualforce.com');
        hostname='https://'+hostname;
        System.debug(hostname);
        return hostname;
    }
    @AuraEnabled
    public static Map<String, Object> doInit(Map<String, Object> pmap) {
        Id recordId = (String)pmap.get('recordId');
		//return the visual force page URL
        Map<String, Object> rmap = new Map<String, Object>();

        String localName = recordId.getSobjectType().getDescribe().localName;
        System.debug('AS_VFContainer > doInit > localName: '  + localName);
        // Custom Setting 이용.
        if ('StatusConfirmation__c'.equals(localName)) {
            Id RecordtypeId = [SELECT Id, RecordtypeId FROM StatusConfirmation__c where Id =:recordId].RecordtypeId;
            String Name=[Select Id,Name from RecordType where Id=:RecordtypeId and SobjectType='StatusConfirmation__c'].Name;
            rmap.put('initUrl', '/apex/AS_StatusConfirmation?id=' + recordId +'&recordtypename='+Name);
        } /*else if ('PreInspection__c'.equals(localName)) { 
            rmap.put('initUrl', '/apex/PreInspection?id=' + recordId);
        }*/
		else if ('Courtesy_Car_Contract__c'.equals(localName)) {
            Id RecordtypeId = [SELECT Id, RecordtypeId FROM Courtesy_Car_Contract__c where Id =:recordId].RecordtypeId;
            String Name=[Select Id,Name from RecordType where Id=:RecordtypeId and SobjectType='Courtesy_Car_Contract__c'].Name;
			System.debug('AS_VFContainer > doInit > Name: '  +Name);
            rmap.put('initUrl', '/apex/AS_StatusConfirmation?id=' + recordId +'&recordtypename='+Name);
        }

        return rmap;
    }

    @AuraEnabled
    public static Map<String, Object> doSave(Map<String, Object> pmap, String recordTypeName) {
        Id recordId = (String)pmap.get('recordId');
        system.debug('record id is '+recordId);
		Account a = new Account();
        a = [select id,name from account where id ='0017a00001J8nTdAAJ'];
        a.name=a.name+'1';
        update a;
        Map<String, Object> rmap = new Map<String, Object>();

        String localName = recordId.getSobjectType().getDescribe().localName;
        // Custom Setting 이용.
        if ('StatusConfirmation__c'.equals(localName)) {
            return AS_StatusConfirmation.doSaveOutsideCheck(pmap,recordTypeName);
        } /*else if ('PreInspection__c'.equals(localName)) {
            return PreInspection.doSaveOutsideCheck(pmap);
        }*/
		else if ('Courtesy_Car_Contract__c'.equals(localName)) {
			 return AS_CourtesyCarContract.doSaveOutsideCheck(pmap,recordTypeName);
		}

        return null;
    }
    @AuraEnabled
    public static void saveFile(String recordTypeName, String recordId, String DocumentId)
    {
      
        System.debug(recordId);
        Datetime d = Datetime.now();
        String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');
       
	 	ContentVersion cont=[Select Id,Title from ContentVersion where ContentDocumentId=:DocumentId];
        cont.Title='CameraPhoto_'+recordTypeName+'_'+s+'_'+cont.Title;
        update cont;

        
		
     
		cont.VersionData=null;
		cont=null;     
    }

}