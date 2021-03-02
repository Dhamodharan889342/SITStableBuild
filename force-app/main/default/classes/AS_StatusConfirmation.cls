/*
 
Author: Neha Aggrawal
Created Date: 15-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026
 */

public with sharing class AS_StatusConfirmation {

//    public StatusConfirmation(ApexPages.StandardController stdController){}

    @AuraEnabled
    public static Map<String, Object> doSaveOutsideCheck (Map<String, Object> pmap,String recordTypeName) {
        System.debug('pmap :: ' + JSON.serialize(pmap));
		//Save the outside check image as attachment
        String recordId = (String) pmap.get('recordId');
        String base64Data = (String)pmap.get('base64Data');
        System.debug('doSaveOutsideCheck recordId ::' + recordId);

        Attachment attach = new Attachment();

        attach.Body = EncodingUtil.base64Decode(base64Data);
        Datetime d = Datetime.now();
//        String s = d.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');
        attach.Name = recordTypeName+'_OutsideCheck_' + s + '.png';
        attach.IsPrivate = false;
        attach.ParentId = recordId;

        insert attach;
		// update the outside check id fields as per record type
        StatusConfirmation__c sc = [SELECT Id, OutsideCheckId__c,Delivery_OutsideCheckId__c FROM StatusConfirmation__c WHERE Id = :recordId];
       if(recordTypeName=='Pickup')
        sc.OutsideCheckId__c = attach.Id;
        else
        sc.Delivery_OutsideCheckId__c=attach.Id;

        update sc;

        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('attach', attach.Id);

        return rmap;
    }
}