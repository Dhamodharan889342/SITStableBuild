/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-17-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class AS_AssetTriggerTest {    
    @isTest 
    static void insertServicePackage() {
        // Riddhi is creating Service package record for US-1335
        Test.startTest();        
        Department__c dep = AfterSales_TestFactory.getDepartmentStore('Store','StoreCode', false);  
        GMECountry__c country = AfterSales_TestFactory.getCountry('Germany', 'DE', true);
        VehicleModel__c vM = new VehicleModel__c(
            Name = 'G70-Product Name',
            Model__c = 'G70'            
        );
        insert vM;
      
        Service_Package__c rec = new Service_Package__c();
        rec = TestDataSetFactory.createServicepackage('SP1', 
                                                      'Germany', 
                                                      system.today(),
                                                      system.today().addDays(3),
                                                      true,
                                                      '1 Year',
                                                      vM.Id );
        system.debug('rec is '+rec);
        Database.upsert  (rec,false);
        system.debug('SP1 record'+Database.upsert (rec,false));
        Service_Package__c SP2 = new Service_Package__c(
            Name = 'SP2',
            SpValidity_From__c = system.today(),
            SpValidity_Until__c = system.today().addDays(3),
            Country__c = 'Germany',
            Auto_Link__c = TRUE,
            IsActive__c = TRUE,
            SpLAST_MODIFIED_DATE__c = system.today(),
            Validity__c = '1 Year',
            Vehicle_Model__c = vM.Id
        );
        Database.upsert  (SP2,false);
        system.debug('SP2 record'+Database.upsert (SP2,false));
        
        Service_Package__c SP3 = new Service_Package__c(
            Name = 'SP3',
            SpValidity_From__c = system.today(),
            SpValidity_Until__c = system.today().addDays(3),
            Country__c = 'Germany',
            Auto_Link__c = TRUE,
            IsActive__c = TRUE,
            SpLAST_MODIFIED_DATE__c = system.today(),
            Validity__c = '1 Year',
            IsForAllModel__c = TRUE
        );
        Database.upsert  (SP3,false);
        Asset vehicle = TestDataSetFactory.createAssetWithVehicleModel('Test Vehicle', dep.Id , vM.Id);
        
        //Service_Package_Item__c record creation
        Service_Package_Item__c sPI = new Service_Package_Item__c(
        //Name = 'sPT1',
        Service_Package__c= SP3.id
        );
         Database.upsert  (sPI,false);
        
        //VehicleServicePackage__c recod creation
        VehicleServicePackage__c vSP = new VehicleServicePackage__c(
            Service_Package__c = SP3.id,
            Vehicle__c = vehicle.id
        );
        Database.upsert  (vSP,false);
        
        Vehicle_Service_Package_Item__c vSPI = new Vehicle_Service_Package_Item__c(
        Name = 'vSPI1',
            Vehicle__c = vehicle.id,
            Vehicle_Service_Package__c = vSP.id,
            tax__c= 16
            
        );
         Database.upsert  (vSPI,false);
        Vehicle_Service_Package_Item__c vSPI2 = new Vehicle_Service_Package_Item__c(
        Name = 'vSPI2',
            Vehicle__c = vehicle.id,
            Vehicle_Service_Package__c = vSP.id,
            tax__c= 16
            
        );
         Database.upsert  (vSPI2,false);
        Test.stopTest();
        
        
        string spcountry = 'Germany' ;
    string vehicleModelName  = 'xyzVM' ;
    Date DOR = system.today();
    boolean autolink = true;
    Date vFrom = system.today().addDays(-30);
    Date vuntile = system.today().addDays(30);
    string CheckValidity = '1 Year';
    Datetime checkdate = system.today();
    string spName  = 'xyz' ;
    string vName  = 'Trigger testclass' ;
    
VehicleModel__c vm1 = new VehicleModel__c(Name = vehicleModelName );
    insert vm1;
Service_Package__c sp  = new Service_Package__c(Name =spName, country__C=spcountry, Vehicle_Model__c =vm1.id,SpValidity_From__c= vFrom, SpValidity_Until__c = vuntile,Auto_Link__c = autolink, SpLAST_MODIFIED_DATE__c= checkdate ,Validity__c = CheckValidity  ); 
insert sp;
  Asset ass = new Asset (Name =vName,country__C=spcountry, Vehicle_Model_LTM__c =vm1.id,Date_of_Registration__c=DOR );
insert ass;
        
        
    }
    
}