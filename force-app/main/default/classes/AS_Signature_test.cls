/*
 
Author: Neha Aggrawal
Created Date: 18-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026
*Update	Daniel Varhidi - add Courtesy_Car_Contract__c
 */

@IsTest
public with sharing class AS_Signature_test {

    @TestSetup
    static void setData() {
        Department__c dt= TestDataSetFactory.createDepartment('DT001','TestDepartment');
        Asset ast = TestDataSetFactory.createAsset('TestAsset',dt.Id);
        Repair__c rpr = TestDataSetFactory.createRepair(ast.Id);
        StatusConfirmation__c sc = TestDataSetFactory.createStatusConfirmation(rpr.Id);
		Courtesy_Car_Contract__c ccc = TestDataSetFactory.createCourtesyCarContract(rpr.Id);
    }

    static testMethod void testCase01() {
        Test.startTest();

        StatusConfirmation__c sc = [SELECT Id FROM StatusConfirmation__c];

        Map<String, Object> pmap = new Map<String, Object>();
        pmap.put('recordId', sc.Id);
        pmap.put('base64Data', 'aaa');
		
		AS_Signature.getRecordType(pmap);
        AS_Signature.doSaveSign(pmap,'Driver','Pickup','');
        AS_Signature.doSaveSign(pmap,'Customer','Pickup','');
        AS_Signature.doSaveSign(pmap,'Signer_On_Behalf','Pickup','Test Signer');
        AS_Signature.doSaveSign(pmap,'Driver','Delivery','');
        AS_Signature.doSaveSign(pmap,'Customer','Delivery','');
        AS_Signature.doSaveSign(pmap,'Signer_On_Behalf','Delivery','Test Signer');
        pmap.clear();
        pmap.put('recordId', null);
        pmap.put('base64Data', 'aaa');
        AS_Signature.doSaveSign(pmap,'Driver','Pickup','');
        
        Test.stopTest();
    }

	static testMethod void testCaseCourtesyCarContract() {
        Test.startTest();

        Courtesy_Car_Contract__c ccc = [SELECT Id FROM Courtesy_Car_Contract__c];

        Map<String, Object> pmap = new Map<String, Object>();
        pmap.put('recordId', ccc.Id);
        pmap.put('base64Data', 'aaa');
		
		AS_Signature.getRecordType(pmap);
        AS_Signature.doSaveSign(pmap,'Driver','Pickup','');
        AS_Signature.doSaveSign(pmap,'Customer','Pickup','');
        AS_Signature.doSaveSign(pmap,'Signer_On_Behalf','Pickup','Test Signer');
        AS_Signature.doSaveSign(pmap,'Driver','Delivery','');
        AS_Signature.doSaveSign(pmap,'Customer','Delivery','');
        AS_Signature.doSaveSign(pmap,'Signer_On_Behalf','Delivery','Test Signer');
        pmap.clear();
        pmap.put('recordId', null);
        pmap.put('base64Data', 'aaa');
        AS_Signature.doSaveSign(pmap,'Driver','Pickup','');
        
        Test.stopTest();
    }

}