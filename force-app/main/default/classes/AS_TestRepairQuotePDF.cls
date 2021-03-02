/*
 
Author: Neha Aggrawal
Created Date: 03-02-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1015
 */

@IsTest
public with sharing class AS_TestRepairQuotePDF {

    @TestSetup
    static void setData() {
        Department__c dt= TestDataSetFactory.createDepartment('DT001','TestDepartment');
        Asset ast = TestDataSetFactory.createAsset('TestAsset',dt.Id);
        Repair__c rpr = TestDataSetFactory.createRepair(ast.Id);
         RepairQuote__c rq = TestDataSetFactory.createRepairQuote(rpr.Id,ast.Id);
       Repair_Quote_Section__c rqs= TestDataSetFactory.createRepairQuoteSection(rq.Id,'Test Name');
        Repair_Quote_Section__c rqs1= TestDataSetFactory.createRepairQuoteSection(rq.Id,'Test Name1');
      Repair_Quote_Line_Item__c rqli=TestDataSetFactory.createRepairQuoteLineItem(rqs.Id,'Test Line Item');
        Repair_Quote_Line_Item__c rqli1=TestDataSetFactory.createRepairQuoteLineItem(rqs1.Id,'Test Line Item1');
        Repair_Quote_Line_Item__c rqli2=TestDataSetFactory.createRepairQuoteLineItem(rqs1.Id,'Test Line Item2');
    }

    static testMethod void testCase01() {
        Test.startTest();
		RepairQuote__c rq=[Select Id from RepairQuote__c limit 1];

        Map<String, Object> pmap = new Map<String, Object>();
        pmap.put('recordId', rq.Id);
		AS_RepairQuotePDF.doInit(pmap);
        ApexPages.StandardController stdcont = new ApexPages.StandardController(rq);
        AS_RepairQuotePDFExtension testrq = new AS_RepairQuotePDFExtension(stdcont);
        testrq.getvehicleinfo();
        testrq.getRepairQuoteSectioninfo();
        testrq.getrenderrepairQuoteLinemap();
        testrq.getrendersubtotoalmap();
         testrq.getGrandTotal();
        System.assertnotEquals(testrq.repairQuoteLineItemMap,null);
        System.assertnotEquals(testrq.SubtotalMap,null);
       
        
        PageReference pageRef = Page.AS_RepairQuotePDF;
        pageRef.getParameters().put('id', String.valueOf(rq.Id));
        Test.setCurrentPage(pageRef);
        AS_RepairQuotePDF.doSavePDF(pmap);
        
  		

        Test.stopTest();
    }

}