@IsTest
private class HereTokenSchedulerTest {

    @IsTest
    private static void schedulerTest() {

        HereSettings__c setting = new HereSettings__c(SetupOwnerId = [select Id from Organization].Id);
        insert setting;

        Test.setMock(HttpCalloutMock.class, new HereCalloutMocksTest.HereTokenHttpCalloutMock());
        
        Test.startTest();
            AsyncApexJob[] succesfullSchedules = [SELECT CreatedDate FROM AsyncApexJob
                WHERE NumberOfErrors = 0 
                AND Status = 'Completed' 
                AND ApexClass.Name = 'HereTokenScheduler'
                ORDER BY CreatedDate DESC LIMIT 1];

            System.assertEquals(0, succesfullSchedules.size(), 'succesfullSchedules.size() should be 0');

            String jobId = System.schedule('Test Here Token Saving Automation','0 0 1 * * ?', new HereTokenScheduler());
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals('0 0 1 * * ?', ct.CronExpression, 'Cron expression should be 0 0 1 * * ?');
            System.assertEquals(0, ct.TimesTriggered, 'Times triggered should be 0');

        Test.stopTest();

    }

}