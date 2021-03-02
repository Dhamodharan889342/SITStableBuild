@IsTest
private class HereIntegrationTest {
    
    @TestSetup static void prepareToken() {
        HereSettings__c setting = new HereSettings__c(SetupOwnerId = UserInfo.getOrganizationId());
        setting.TokenPart1__c = '1234';
        setting.TokenPart2__c = '1234';
        setting.TokenPart3__c = '1234';
        setting.TokenPart4__c = '1234';
        setting.TokenExpires__c = System.now().addDays(1);
        insert setting;
        
    }

    @IsTest
    private static void appointmentGeolocationAndDistanceTest() {

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(true));
        
        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Department__c prefferedFacility;
        Appointment__c app;
        Test.startTest();

        prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');

        Contact cnt = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cnt = TestDataSetFactory.createSampleContact2(acc.Id);
        }

        System.assert(cnt != null, 'Contact shouldn\'t be null');

        Employee__c employee = TestDataSetFactory.createEmployee(prefferedFacility.Id, cnt.Id, UserInfo.getUserId());

        System.assert(employee != null, 'Employee__c shouldn\'t be null');


        Opportunity opp = TestDataSetFactory.creatSampleOpportunity(acc.Id);
            
        app = TestDataSetFactory.creatAppointmentTestDriveValet(prefferedFacility.Id, opp.Id);

        System.assert(app != null, 'Appointment__c shouldn\'t be null');
        Test.stopTest();

        app = [select Id, DistanceLongitude__c, DistanceTime__c, PickupGeolocation__Latitude__s, PickupGeolocation__Longitude__s from Appointment__c where Id = :app.Id];

        System.assert(app.PickupGeolocation__Latitude__s != null, 'PickupGeolocation__Latitude__s shouldn\'t be null');
        System.assert(app.PickupGeolocation__Longitude__s != null, 'PickupGeolocation__Longitude__s shouldn\'t be null');

        System.assert(app.DistanceLongitude__c != null, 'DistanceLongitude__c shouldn\'t be null');
        System.assert(app.DistanceTime__c != null, 'DistanceTime__c shouldn\'t be null');
    }

    @IsTest
    private static void appointmentGeolocationAndDistanceTest_NOK() {

        Boolean showCorrect = false;

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(showCorrect));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Department__c prefferedFacility;
        Appointment__c app;
        Test.startTest();

        prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');

        Contact cnt = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cnt = TestDataSetFactory.createSampleContact2(acc.Id);
        }

        System.assert(cnt != null, 'Contact shouldn\'t be null');

        Employee__c employee = TestDataSetFactory.createEmployee(prefferedFacility.Id, cnt.Id, UserInfo.getUserId());

        System.assert(employee != null, 'Employee__c shouldn\'t be null');


        Opportunity opp = TestDataSetFactory.creatSampleOpportunity(acc.Id);
            
        app = TestDataSetFactory.creatAppointmentTestDriveValetWithoutAddress(prefferedFacility.Id, opp.Id);

        System.assert(app != null, 'Appointment__c shouldn\'t be null');
        Test.stopTest();

        app = [select Id, DistanceLongitude__c, DistanceTime__c, PickupGeolocation__Latitude__s, PickupGeolocation__Longitude__s from Appointment__c where Id = :app.Id];

        System.assert(app.PickupGeolocation__Latitude__s == null, 'PickupGeolocation__Latitude__s should be null');
        System.assert(app.PickupGeolocation__Longitude__s == null, 'PickupGeolocation__Longitude__s should be null');

        System.assert(app.DistanceLongitude__c == null, 'DistanceLongitude__c should be null');
        System.assert(app.DistanceTime__c == null, 'DistanceTime__c should be null');
    }

    @IsTest
    private static void departmentGeolocationTest() {

        Test.setMock(HttpCalloutMock.class, new HereCalloutMocksTest.HereGeolocationOrDistanceHttpCalloutMock());

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Department__c prefferedFacility;
        Test.startTest();
            prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);
        Test.stopTest();

        Department__c dp = [select Id, Geolocation__Latitude__s, Geolocation__Longitude__s from Department__c where Id = :prefferedFacility.Id];

        System.assert(dp.Geolocation__Latitude__s != null, 'Geolocation__Latitude__s shouldn\'t be null');
        System.assert(dp.Geolocation__Longitude__s != null, 'Geolocation__Longitude__s shouldn\'t be null');
    }

    @IsTest
    private static void departmentGeolocationTest_NOK() {

        Boolean showCorrect = false;

        Test.setMock(HttpCalloutMock.class, new HereCalloutMocksTest.HereGeolocationOrDistanceHttpCalloutMock(showCorrect));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Department__c prefferedFacility;
        Test.startTest();
            prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);
        Test.stopTest();

        Department__c dp = [select Id, Geolocation__Latitude__s, Geolocation__Longitude__s from Department__c where Id = :prefferedFacility.Id];

        System.assert(dp.Geolocation__Latitude__s == null, 'Geolocation__Latitude__s should be null');
        System.assert(dp.Geolocation__Longitude__s == null, 'Geolocation__Longitude__s should be null');
    }

    @IsTest
    private static void contactGeolocationTest() {

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(true));
        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Test.startTest();

        Department__c prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');

        Contact cnt = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cnt = TestDataSetFactory.createSampleContact2(acc.Id);
        }

        System.assert(cnt != null, 'Contact shouldn\'t be null');
  
        Test.stopTest();

        cnt = [select Id, MailingLatitude, MailingLongitude from Contact where Id = :cnt.Id];

        System.assert(cnt.MailingLatitude != null, 'MailingLatitude shouldn\'t be null');
        System.assert(cnt.MailingLongitude != null, 'MailingLongitude shouldn\'t be null');
    }

    @IsTest
    private static void contactGeolocationTest_NOK() {

        Boolean showCorrect = false;

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(showCorrect));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Test.startTest();

        Department__c prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');

        Contact cnt = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cnt = TestDataSetFactory.createSampleContactWithoutAddress(acc.Id);
        }

        System.assert(cnt != null, 'Contact shouldn\'t be null');
  
        Test.stopTest();

        cnt = [select Id, MailingLatitude, MailingLongitude from Contact where Id = :cnt.Id];

        System.assert(cnt.MailingLatitude == null, 'MailingLatitude should be null');
        System.assert(cnt.MailingLongitude == null, 'MailingLongitude should be null');
    }

    @IsTest
    private static void leadGeolocationTest() {

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(true));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Test.startTest();

        Department__c prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');

        Contact cnt = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cnt = TestDataSetFactory.createSampleContact2(acc.Id);
        }

        System.assert(cnt != null, 'Contact shouldn\'t be null');

        Employee__c employee = TestDataSetFactory.createEmployee(prefferedFacility.Id, cnt.Id, UserInfo.getUserId());

        System.assert(employee != null, 'Employee__c shouldn\'t be null');

        Lead testLead = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testLead = TestDataSetFactory.creatSampleLead();
        }

        System.assert(testLead != null, 'Lead shouldn\'t be null');
  
        Test.stopTest();

        Lead ld = [select Id, Latitude, Longitude from Lead where Id = :testLead.Id];

        System.assert(ld.Latitude != null, 'Latitude shouldn\'t be null');
        System.assert(ld.Longitude != null, 'Longitude shouldn\'t be null');
    }

    @IsTest
    private static void leadGeolocationTest_NOK() {

        Boolean showCorrect = false;

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(showCorrect));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Test.startTest();

        Department__c prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');

        Contact cnt = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cnt = TestDataSetFactory.createSampleContact2(acc.Id);
        }

        System.assert(cnt != null, 'Contact shouldn\'t be null');

        Employee__c employee = TestDataSetFactory.createEmployee(prefferedFacility.Id, cnt.Id, UserInfo.getUserId());

        System.assert(employee != null, 'Employee__c shouldn\'t be null');

        Lead testLead = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testLead = TestDataSetFactory.creatSampleLeadWithoutAddress();
        }

        System.assert(testLead != null, 'Lead shouldn\'t be null');
  
        Test.stopTest();

        Lead ld = [select Id, Latitude, Longitude from Lead where Id = :testLead.Id];

        System.assert(ld.Latitude == null, 'Latitude should be null');
        System.assert(ld.Longitude == null, 'Longitude should be null');
    }

    @IsTest
    private static void businessAccountGeolocationTest() {

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(true));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Test.startTest();

        Department__c prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');
  
        Test.stopTest();

        acc = [select Id, BillingLatitude, BillingLongitude from Account where Id = :acc.Id];

        System.assert(acc.BillingLatitude != null, 'BillingLatitude shouldn\'t be null');
        System.assert(acc.BillingLongitude != null, 'BillingLongitude shouldn\'t be null');
    }

    @IsTest
    private static void businessAccountGeolocationTest_NOK() {

        Boolean showCorrect = false;

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(showCorrect));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Test.startTest();

        Department__c prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');
  
        Test.stopTest();

        acc = [select Id, BillingLatitude, BillingLongitude from Account where Id = :acc.Id];

        System.assert(acc.BillingLatitude == null, 'BillingLatitude should be null');
        System.assert(acc.BillingLongitude == null, 'BillingLongitude should be null');
    }

    @IsTest
    private static void personAccountGeolocationTest() {

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(true));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Test.startTest();

        Department__c prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');

        Contact cnt = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cnt = TestDataSetFactory.createSampleContact2(acc.Id);
        }

        System.assert(cnt != null, 'Contact shouldn\'t be null');

        Employee__c employee = TestDataSetFactory.createEmployee(prefferedFacility.Id, cnt.Id, UserInfo.getUserId());

        System.assert(employee != null, 'Employee__c shouldn\'t be null');

        Account personAccount = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            personAccount = TestDataSetFactory.createSamplePersonAccount(prefferedFacility.Id);
        }

        System.assert(personAccount != null, 'PersonAccount shouldn\'t be null');
  
        Test.stopTest();

        personAccount = [select Id, PersonMailingLatitude, PersonMailingLongitude from Account where Id = :personAccount.Id];

        System.assert(personAccount.PersonMailingLatitude != null, 'PersonMailingLatitude shouldn\'t be null');
        System.assert(personAccount.PersonMailingLongitude != null, 'PersonMailingLongitude shouldn\'t be null');
    }

    @IsTest
    private static void personAccountGeolocationTest_NOK() {

        Boolean showCorrect = false;

        Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock(showCorrect));

        GMECountry__c gmeCountry = TestDataSetFactory.createSampleGMECountry();

        Test.startTest();

        Department__c prefferedFacility = TestDataSetFactory.createSamplePrefferedLocation(gmeCountry.Id);

        Account acc = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc = TestDataSetFactory.createSampleAccount(prefferedFacility.Id);
        }

        System.assert(acc != null, 'Account shouldn\'t be null');

        Contact cnt = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cnt = TestDataSetFactory.createSampleContact2(acc.Id);
        }

        System.assert(cnt != null, 'Contact shouldn\'t be null');

        Employee__c employee = TestDataSetFactory.createEmployee(prefferedFacility.Id, cnt.Id, UserInfo.getUserId());

        System.assert(employee != null, 'Employee__c shouldn\'t be null');

        Account personAccount = null;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            personAccount = TestDataSetFactory.createSamplePersonAccount(prefferedFacility.Id);
        }

        System.assert(personAccount != null, 'PersonAccount shouldn\'t be null');
  
        Test.stopTest();

        personAccount = [select Id, PersonMailingLatitude, PersonMailingLongitude from Account where Id = :personAccount.Id];

        System.assert(personAccount.PersonMailingLatitude == null, 'PersonMailingLatitude should be null');
        System.assert(personAccount.PersonMailingLongitude == null, 'PersonMailingLongitude should be null');
    }


}