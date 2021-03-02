/*
 
Author: Neha Aggrawal
Created Date: 18-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026
 */

@IsTest
public with sharing class AS_ImageCapture_test {
@TestSetup
    static void setData() {
        Department__c dt= TestDataSetFactory.createDepartment('DT001','TestDepartment');
        Asset ast = TestDataSetFactory.createAsset('TestAsset',dt.Id);
        Repair__c rpr = TestDataSetFactory.createRepair(ast.Id);
        StatusConfirmation__c sc = TestDataSetFactory.createStatusConfirmation(rpr.Id);

    }

   
    static testMethod void testCase01() {
         Test.startTest();
        StatusConfirmation__c sc = [SELECT Id FROM StatusConfirmation__c];
     
       ContentVersion contv=new ContentVersion(PathOnClient='test',VersionData=Blob.valueOf('Test Content'),Title='testTitle');
       insert contv;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contv.Id].ContentDocumentId;
        System.debug(conDoc);
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = sc.Id; 
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
       AS_ImageCapture.saveFile(sc.Id,conDoc);
    
        
     
        System.assertNotEquals(contv.Id, null);
        Test.stopTest();
    }
}