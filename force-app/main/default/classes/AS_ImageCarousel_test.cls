/*
 
Author: Neha Aggrawal
Created Date: 18-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026
 */

@IsTest
public with sharing class AS_ImageCarousel_test {

    @TestSetup
    static void setData() {
        Department__c dt= TestDataSetFactory.createDepartment('DT001','TestDepartment');
        Asset ast = TestDataSetFactory.createAsset('TestAsset',dt.Id);
        Repair__c rpr = TestDataSetFactory.createRepair(ast.Id);
        StatusConfirmation__c sc = TestDataSetFactory.createStatusConfirmation(rpr.Id);
        Datetime d = Datetime.now();
        String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');
       	ContentVersion contv=new ContentVersion(ContentLocation = 'S',Title='CameraPhoto_'+s+'_', PathOnClient = 'CameraPhoto_'+s +'.jpg', VersionData=Blob.valueOf('Test Content'));
        insert contv;
        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contv.Id].ContentDocumentId;
        cdl.LinkedEntityId = sc.Id;
        cdl.ShareType = 'V';
		
        insert cdl;
    }

    static testMethod void testCase01() {
        Test.startTest();

        StatusConfirmation__c sc = [SELECT Id FROM StatusConfirmation__c];
		AS_ImageCarousel.getCameraFiles(sc.Id);
        Test.stopTest();
    }

}