@isTest
public class AS_TestTriggerHandler_RecordSharing {
static testMethod void testUpdateFunc(){
    Profile Pr=[Select Id from Profile where Name='Dealer'];
    Profile Pr1=[Select Id from Profile where Name='System Administrator'];
	Department__c dt;
    Schema.Location loc;
    
User u=TestDataSetFactory.createUserwithDeptandProfile('test@mytestdomain.developer','test','DT0001',Pr.Id);
User u1=TestDataSetFactory.createUserwithDeptandProfile('testonemore@mytestdomain.developer','test1','DT0001',Pr1.Id);
System.debug(u.Id);
Group grp = new Group(Name = 'After_Sales_TestDT_PG');
insert grp;
   System.runAs(u1)  
  	{
GroupMember gm=TestDataSetFactory.createGroupMember(u.Id,grp.Id);
    }
   
       dt=TestDataSetFactory.createDepartment('DT0001','TestDT');
       loc=TestDataSetFactory.createLocation('Warehouse','loc',dt.Id,true);
 	 


  
    

List<Asset> astList = new List<Asset>();
    astList.add(TestDataSetFactory.createAsset('CAS305',dt.Id));

  
    Test.starttest();
    AfterSales_TriggerHandler_RecordSharing.receiveRecords(astList);
    Test.stoptest();
}
}