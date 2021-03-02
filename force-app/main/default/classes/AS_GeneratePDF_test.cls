/*
 
  Author: Neha Aggrawal
  Created Date: 18-01-2020
  Story:https://jira.hyundai-autoever.eu/browse/GD-1026
 */

@IsTest
public with sharing class AS_GeneratePDF_test {

	@TestSetup
	static void setData() {
		Department__c dt = TestDataSetFactory.createDepartment('DT001', 'TestDepartment');
		Asset ast = TestDataSetFactory.createAsset('TestAsset', dt.Id);
		Repair__c rpr = TestDataSetFactory.createRepair(ast.Id);
		StatusConfirmation__c sc = TestDataSetFactory.createStatusConfirmation(rpr.Id);
		Courtesy_Car_Contract__c ccc = TestDataSetFactory.createCourtesyCarContract(rpr.Id);
	}

	static testMethod void testCase01() {
		Test.startTest();

		StatusConfirmation__c sc = [SELECT Id FROM StatusConfirmation__c];

		Map<String, Object> pmap = new Map<String, Object> ();
		pmap.put('recordId', sc.Id);
		//AS_GeneratePDF.doInit(pmap);
		ApexPages.StandardController stdcont = new ApexPages.StandardController(sc);
		AS_StatusConfirmationExtension testsc = new AS_StatusConfirmationExtension(stdcont);
		testsc.getvehicleinfo();
		testsc.SaveAttachment();
		PageReference pageRef = Page.AS_StatusConfirmationPDF;
		pageRef.getParameters().put('id', String.valueOf(sc.Id));
		Test.setCurrentPage(pageRef);
		// AS_GeneratePDF.doSavePDF(pmap);



		Test.stopTest();
	}

	static testMethod void testCourtesyCarContractExtension() {
		Test.startTest();

		Courtesy_Car_Contract__c ccc = [SELECT Id FROM Courtesy_Car_Contract__c];

		Map<String, Object> pmap = new Map<String, Object> ();
		pmap.put('recordId', ccc.Id);
		AS_GeneratePDF.doInit(pmap);
		ApexPages.StandardController stdcont = new ApexPages.StandardController(ccc);
		AS_CourtesyCarContractExtension testsc = new AS_CourtesyCarContractExtension(stdcont);

		PageReference pageRef = Page.AS_CourtesyCarContractPDF;
		pageRef.getParameters().put('id', String.valueOf(ccc.Id));
		Test.setCurrentPage(pageRef);
		//AS_GeneratePDF.doSavePDF(pmap);

		//('/lightning/r/Courtesy_Car_Contract__c/' + courtesyCarContract.Id + '/view')
		PageReference pageRef2 = testsc.SaveAttachment();
		System.debug('AS_GeneratePDF_test > testCourtesyCarContractExtension > pageRef2: ' + pageRef2);
		System.assertEquals('System.PageReference[/lightning/r/Courtesy_Car_Contract__c/' + ccc.Id + '/view]', String.valueOf(pageRef2), 'pageRef2');
		Test.stopTest();
	}

}