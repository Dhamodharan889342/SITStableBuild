/*
 Author: Neha Aggrawal
Created Date: 03-02-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1015
*/

public without sharing class AS_RepairQuotePDF {


    @AuraEnabled
    public static Map<String, Object> doInit(Map<String, Object> pmap) {
        Id recordId = (String)pmap.get('recordId');
        String localName = recordId.getSobjectType().getDescribe().localName;
Map<String, Object> rmap = new Map<String, Object>();

       
        // Custom Setting 이용.
        if ('RepairQuote__c'.equals(localName)) { // 상태확인서.
            rmap.put('initUrl', '/apex/AS_RepairQuotePDF?id=' + recordId);
        }

        return rmap;
    }

    @AuraEnabled
    public static Map<String, Object> doSavePDF(Map<String, Object> pmap) {
        System.debug('pmap :: ' + JSON.serialize(pmap));
        Id recordId = (String) pmap.get('recordId');

        String localName = recordId.getSobjectType().getDescribe().localName;
        // Custom Setting 이용.
        PageReference pdf = null;
        if ('RepairQuote__c'.equals(localName)) { // 상태확인서.
             pdf = Page.AS_RepairQuotePDF;
        } 

        pdf.getParameters().put('Id', recordId);
//
        Blob body = Test.isRunningTest() ? Blob.valueOf('unit.Test') : pdf.getContentAsPDF();

        Datetime d = Datetime.now();
//        String s = d.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');

        if ('RepairQuote__c'.equals(localName)) {
            String label = RepairQuote__c.getSObjectType().getDescribe().getLabel(); // 상태확인서
			 s = label + '.' + s;
        }
        //Save generated PDF as file
        ContentVersion cv = new ContentVersion();

        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;//contentDocumentId;
        cv.VersionData = body;//EncodingUtil.base64Decode(base64Data);
        cv.Title = s + '.pdf';
        cv.PathOnClient = s + '.pdf';

        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';

        insert cdl;

        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('ContentVersion', cv.Id);
        rmap.put('ContentDocumentLink', cdl.Id);
        return rmap;
    }

 
}