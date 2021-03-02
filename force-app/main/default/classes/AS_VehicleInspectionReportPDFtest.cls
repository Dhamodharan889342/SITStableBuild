/*
Author: Neha Aggrawal
Created Date: 28-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1257
*/
@IsTest
public with sharing class AS_VehicleInspectionReportPDFtest {

    @TestSetup
    static void setData() {
        Department__c dt= TestDataSetFactory.createDepartment('DT001','TestDepartment');
        Asset ast = TestDataSetFactory.createAsset('TestAsset',dt.Id);
        Repair__c rpr = TestDataSetFactory.createRepair(ast.Id);
        StatusConfirmation__c sc = TestDataSetFactory.createStatusConfirmation(rpr.Id);
       Vehicle_Inspection_Report__c vir = TestDataSetFactory.createVehicleInspectionReport(rpr.Id,sc.Id);
    }

    static testMethod void testCase01() {
        Test.startTest();
		Repair__c rpr = [SELECT Id FROM Repair__c];
        Vehicle_Inspection_Report__c vir=[Select Id from Vehicle_Inspection_Report__c];
        Map<String, Object> pmap = new Map<String, Object>();
        pmap.put('recordId', vir.Id);
        AS_VehicleInspectionReportPDF.doInit(pmap);
        AS_VehicleInspectionReportPDF.doSavePDF(pmap);
        
        ApexPages.StandardController stdcont = new ApexPages.StandardController(vir);
        AS_VehicleInspectionExtension testvir = new AS_VehicleInspectionExtension(stdcont);
        testvir.getvehicleInsinfo();
		PageReference pageRef = Page.AS_PDFVehicleInspectionReport;
        pageRef.getParameters().put('id', String.valueOf(vir.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }

}