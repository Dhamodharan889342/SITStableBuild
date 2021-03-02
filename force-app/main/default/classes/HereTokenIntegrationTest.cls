@IsTest
private class HereTokenIntegrationTest {
    
    @IsTest
    private static void hereTokenStoreTest() {

        HereSettings__c setting;
        //setting = new HereSettings__c(SetupOwnerId = UserInfo.getOrganizationId()); // [select Id from Organization].Id or UserInfo.getOrganizationId()
        //insert setting;

        Test.setMock(HttpCalloutMock.class, new HereCalloutMocksTest.HereTokenHttpCalloutMock());
        
        Test.startTest();
            HereTokenIntegration.storeHereToken();
        Test.stopTest();

        setting = HereSettings__c.getOrgDefaults();

        System.assert(setting != null, 'Custom setting should be there');
        System.assert(setting.SetupOwnerId == UserInfo.getOrganizationId(), 'Custom setting for Organization should be there');
        System.assert(String.isNotBlank(setting.TokenPart1__c), 'Custom setting TokenPart1__c should be there');
        System.assert(String.isNotBlank(setting.TokenPart2__c), 'Custom setting TokenPart2__c should be there');
        System.assert(String.isNotBlank(setting.TokenPart3__c), 'Custom setting TokenPart3__c should be there');
        System.assert(String.isNotBlank(setting.TokenPart4__c), 'Custom setting TokenPart4__c should be there');
        System.assert(setting.TokenExpires__c != null, 'Custom setting TokenExpires__c should be there');

    }

}