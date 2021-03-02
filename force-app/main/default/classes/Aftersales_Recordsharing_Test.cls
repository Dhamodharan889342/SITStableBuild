@isTest
Private class Aftersales_Recordsharing_Test {
 

@isTest 
    static void testingAfterSales_Customer_CustIdentification2(){
Account testAccount = new Account();
testAccount.FirstName='Nisha';
testAccount.LastName='Kumar';
testAccount.GAId__c='9900';
testAccount.Job_Title__pc='Employee';
testAccount.Customer_type__pc='Owner';
testAccount.Preferred_ZipCode__c='8978';
testAccount.Contact_Details__c='SMS';
testAccount.Major_Language__c= 'en_US';
insert testAccount;
system.debug('.... id of the account...'+testAccount.id);
    
// For Negative Test case
Account testAccount1 = new Account();
testAccount1.FirstName='Nisha Kumar';
testAccount1.LastName='Nisha Kumar';
testAccount1.GAId__c='Nisha Kumar';
testAccount1.Job_Title__pc='Employee';
testAccount1.Customer_type__pc='Owner';
testAccount1.Preferred_ZipCode__c='8978';
testAccount1.Contact_Details__c='SMS';
testAccount1.Major_Language__c= 'en_US';
insert testAccount1;
system.debug('.... id of the account...'+testAccount1.id);
    
// Insert Asset record for VIN and Licence plate and return its corresponding account
    Asset testAsset = new Asset();
    testAsset.name = 'Nisha_s Car';
    testAsset.VIN__c = '9999';
    testAsset.Licence_plate_after_registration__c = '9876';
    testAsset.AccountId = testAccount1.id;
    insert testAsset;
system.debug('.... id of the account...'+testAsset.id);

    
    //AfterSales_Customer_CustIdentification customercust = new AfterSales_Customer_CustIdentification();
    //there is no need to create object for call because method is static and we can directly call it with its class name.
    list<Account> lstAcc =AfterSales_Customer_CustIdentification.getPersonAccount1('Nisha','Kumar','A!','9900');
System.assertEquals(testAccount.id, lstAcc[0].id);
    // for Negative test case
    System.assertEquals(testAccount1.id, lstAcc[0].id);
    
    
    
    
    list<Account> lstAcc2 =AfterSales_Customer_CustIdentification.getPersonAccount1('Nisha1','Kumar1','9999','9876');
   System.assertEquals(testAccount1.id, lstAcc2[0].id);
    // for Negative test case
   System.assertEquals(testAccount.id, lstAcc2[0].id);
    
    }
/*@isTest
Static Void testingRecordSharing()
    {
       map<string,string> mapRecordSharing = AfterSales_RecordSharing.getPublicGroupMapPerDepartmentPerObject(); 
    }*/
    
    
   

}