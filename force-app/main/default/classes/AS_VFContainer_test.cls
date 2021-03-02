/*
 
Author: Neha Aggrawal
Created Date: 18-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026
*Update Daniel Varhidi - add Courtesy_Car_Contract__c
 */

@IsTest
public with sharing class AS_VFContainer_test {

    @TestSetup
    static void setData() {
        Department__c dt= TestDataSetFactory.createDepartment('DT001','TestDepartment');
        Asset ast = TestDataSetFactory.createAsset('TestAsset',dt.Id);
        Repair__c rpr = TestDataSetFactory.createRepair(ast.Id);
        StatusConfirmation__c sc = TestDataSetFactory.createStatusConfirmation(rpr.Id);
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        Courtesy_Car_Contract__c ccc = TestDataSetFactory.createCourtesyCarContract(rpr.Id);
    }

    static testMethod void testCase01() {
        Test.startTest();

        StatusConfirmation__c sc = [SELECT Id FROM StatusConfirmation__c];
        ContentDocument cd=[Select Id from ContentDocument];
        Map<String, Object> pmap = new Map<String, Object>();
        pmap.put('recordId', sc.Id);
        pmap.put('base64Data', 'aaa');
        AS_VFContainer.getvisualforcedomain();
        AS_VFContainer.doInit(pmap);
        AS_VFContainer.doSave(pmap,'PickUp');
        AS_VFContainer.doSave(pmap,'Delivery');
        AS_VFContainer.saveFile('Delivery',sc.Id,cd.Id);
        AS_VFContainer.saveFile('Pickup',sc.Id,cd.Id);

        Test.stopTest();
    }

    static testMethod void testCaseCourtesyCarContract() {
        Test.startTest();

        Courtesy_Car_Contract__c ccc = [SELECT Id FROM Courtesy_Car_Contract__c];

        Map<String, Object> pmap = new Map<String, Object>();
        pmap.put('recordId', ccc.Id);
        pmap.put('base64Data', 'aaa');
        AS_VFContainer.getvisualforcedomain();
        AS_VFContainer.doInit(pmap);
        AS_VFContainer.doSave(pmap,'PickUp');
        AS_VFContainer.doSave(pmap,'Delivery');

        Test.stopTest();
    }

}