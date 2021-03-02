@isTest
public class GME_EmployeeTriggerHandlerTest {
    
    @isTest
    public static void addToPublicGroupTest(){
        Account acc = AfterSales_TestFactory.getAccount('AtestAcc', true);
        Contact con = AfterSales_TestFactory.getContact(acc.Id, 'fName', 'lName', true);
        Department__c dep = AfterSales_TestFactory.getDepartmentStore('Store','StoreCode', true);

        Group g = new Group(Name = 'Test group');
        insert g;
        dep.Department_Public_Group_Id__c = g.Id;
        update dep;

        Test.startTest();
            Employee__c emp = AfterSales_TestFactory.getEmployee('testEmp', dep.Id, UserInfo.getUserId(), con.Id, true);
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM GroupMember WHERE GroupId =: g.Id].size());
    }
}