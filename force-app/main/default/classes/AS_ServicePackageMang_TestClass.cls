/*
	Created By: Mayank Pant
    Purpose: This class is a test class for apex class 
    AS_ServicePackageMang_RelatedRepPackItm
    User Story: https://jira.hyundai-autoever.eu/browse/GD-2132
    */
    @isTest
    public with sharing class AS_ServicePackageMang_TestClass {
        @IsTest
        static void relatedRepairPackageTest(){
             
            
        VehicleModel__c vM = new VehicleModel__c();
        vM = TestDataSetFactory.createVehicleModel();
        
        Product2 prd = new Product2();
        prd = TestDataSetFactory.createProduct('Oil Filter', true, 'Germany');
        
        Service_Package__c servPckg = new Service_Package__c();
        servPckg = TestDataSetFactory.createServicepackage('SP1', 
                                                    'Germany', 
                                                    system.today(),
                                                    system.today().addDays(3),
                                                    true,
                                                    '1 Year',
                                                    vM.Id );
         
         List<Service_Package_Item__c>  servPckgItmList = new List<Service_Package_Item__c> ();
         servPckgItmList = TestDataSetFactory.createServicePackagePartItems(servPckg.id, prd.Id, 3 , true);
    
         RepairPackage__c rprPckg = new RepairPackage__c();
         rprPckg = TestDataSetFactory.createRepairPackage();
    
         List<RepairPackageItem__c> repPckgItmList = new List<RepairPackageItem__c>();
         repPckgItmList = TestDataSetFactory.createRepairPackagePartItems(rprPckg.id, prd.Id, 3 , true);
    
         Test.startTest();
            TestDataSetFactory.createRelatedRepairPackage(servPckg.id,rprPckg.id);
            system.assertEquals(6, [SELECT ID 
                                        FROM Service_Package_Item__c 
                                        WHERE Service_Package__c = :servPckg.id].size());
         Test.stopTest();
            
        }
    }