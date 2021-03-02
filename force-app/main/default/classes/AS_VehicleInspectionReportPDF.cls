/*
Author: Neha Aggrawal
Created Date: 28-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1257
*/


public without sharing class AS_VehicleInspectionReportPDF {


    @AuraEnabled
    public static Map<String, Object> doInit(Map<String, Object> pmap) {
        Id recordId = (String)pmap.get('recordId');
		String recordtypename='';
        String localName = recordId.getSobjectType().getDescribe().localName;
     
        Map<String, Object> rmap = new Map<String, Object>();

       
        // Custom Setting 이용.
        if ('Vehicle_Inspection_Report__c'.equals(localName)) { // 상태확인서.
            rmap.put('initUrl', '/apex/AS_PDFVehicleInspectionReport?id=' + recordId);
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
        if ('Vehicle_Inspection_Report__c'.equals(localName)) { // 상태확인서.
        
            pdf = Page.AS_PDFVehicleInspectionReport;
        } 

        pdf.getParameters().put('Id', recordId);
//
        Blob body = Test.isRunningTest() ? Blob.valueOf('unit.Test') : pdf.getContentAsPDF();

        Datetime d = Datetime.now();
//        String s = d.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');

        if ('Vehicle_Inspection_Report__c'.equals(localName)) {
            String label = Vehicle_Inspection_Report__c.getSObjectType().getDescribe().getLabel(); // 상태확인서
           
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
        
        Vehicle_Inspection_Report__c vir= new Vehicle_Inspection_Report__c();
            vir.Id= recordId;
            vir.Report_Completed__c=true;
            update vir;

        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('ContentVersion', cv.Id);
        rmap.put('ContentDocumentLink', cdl.Id);
		//update completed
		
        
        return rmap;
    }

 
}