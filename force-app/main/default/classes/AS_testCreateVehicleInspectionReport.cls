/*
 
Author: Neha Aggrawal
Created Date: 28-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1257
 */

@IsTest
public with sharing class AS_testCreateVehicleInspectionReport {

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
		Map<String,Object> compdata =new Map<String,Object>();
           List<object> rec= new List<object>();
            List<object> icare= new List<object>();
        compdata.put('ServicebookingId',rpr.Id);
        compdata.put('w_base64Data','Attachment Body');
        compdata.put('uneven','Yes');
      	compdata.put('recommend', rec);
        compdata.put('icare', icare);
        compdata.put('brakepads',0.5);
        compdata.put('brakeshoes',0.9);
            
		AS_CreateVehicleInspectionReport.getcount(rpr.Id);
        AS_CreateVehicleInspectionReport.getdata(rpr.Id);
        AS_CreateVehicleInspectionReport.savedata(compdata);
            
       
        

        Test.stopTest();
    }
    }