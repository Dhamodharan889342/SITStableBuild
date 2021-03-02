@isTest
private class AfterSales_AssignGTAToAccountTest {

	@isTest
	private static void createPersonAccount1GTA() {
		Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock());
		//User
		User testUserGTA1 = TestDataSetFactory.createSampleUser();
		//User testUserGTA2 = TestDataSetFactory.createSampleUser();
		//User testUserNSCAfterSalesManager = TestDataSetFactory.createSampleUser();

		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		Department__c serviceCenterDepartment = TestDataSetFactory.createDepartment('SC123', 'serviceCenterDepartment');
		serviceCenterDepartment.RecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service_Center').getRecordTypeId();
		serviceCenterDepartment.Country__c = 'Germany';
		serviceCenterDepartment.City__c = 'München';
		serviceCenterDepartment.Zipcode__c = '80638 ';
		serviceCenterDepartment.Street__c = 'Wintrichring 1';
		serviceCenterDepartment.Geolocation__Latitude__s = 48.164045;
		serviceCenterDepartment.Geolocation__Longitude__s = 11.507327;
		update serviceCenterDepartment;

		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);


		//Contact
		Contact testContact = new Contact(
		                                  AccountId = testAccount.Id,
		                                  LastName = 'TestContact',
		                                  FirstName = 'firstname',
		                                  MailingCountry = 'Germany',
		                                  MailingStreet = 'Sonnenstraße 71',
		                                  MailingPostalCode = '80331',
		                                  MailingCity = 'Stuttgart',
		                                  Job_Title__c = 'Employee',
		                                  Customer_type__c = 'Contact person only'
		);

		//Employee
		Id gtaEmployeeRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('GTA_Employee').getRecordTypeId();
		Employee__c gtaEmployee1 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContact.Id, testUserGTA1.Id, 'GTA', gtaEmployeeRecordTypeId);

		//GTA__c
		List<GTA__c> gtaLIst = new List<GTA__c> ();
		GTA__c gta1 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee1.Id
		);
		gtaLIst.add(gta1);
		insert gtaLIst;

		//--!! testcase !!--
		Test.startTest();
		Account acc1 = new Account(
		                           BillingCountry = 'Germany',
		                           BillingStreet = 'Niddastraße 49',
		                           BillingPostalCode = '60329',
		                           BillingCity = 'Frankfurt am Main',
		                           PersonMailingCountry = 'Germany',
		                           PersonMailingStreet = 'Niddastraße 49',
		                           PersonMailingPostalCode = '60329',
		                           PersonMailingCity = 'Frankfurt am Main',
		                           PersonMailingLatitude = 50.10989,
		                           PersonMailingLongitude = 8.66481,
		                           FirstName = 'Test',
		                           LastName = 'PersonAccount',
		                           Salutation = 'Ms.',
		                           Major_Language__c = 'en_US',
		                           Preferred_ZipCode__c = '12345',
		                           Contact_Details__c = 'Email',
		                           Customer_type__pc = 'Prospect',
		                           RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
		                           PreferredFacility__pc = retailstoreDepartment.Id,
		                           SMSConsent__pc = true,
		                           TelephoneConsent__pc = true,
		                           EmailConsent__pc = true
		);
		insert acc1;

		acc1.Customer_type__pc = 'Owner';
		update acc1;

		Test.stopTest();

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, PersonMailingLatitude, PersonMailingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(gtaEmployee1.Id, acc1.Assigned_GTA__c, 'Assigned GTA');

	}

	@isTest
	private static void createAccount0GTA() {
		Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock());
		//User
		User testUserNSCAfterSalesManager = TestDataSetFactory.createSampleUserUniqueUserName('un3@mytestdomain.developer', 'nck3');

		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		Department__c serviceCenterDepartment = TestDataSetFactory.createDepartment('SC123', 'serviceCenterDepartment');
		serviceCenterDepartment.RecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service_Center').getRecordTypeId();
		serviceCenterDepartment.Country__c = 'Germany';
		serviceCenterDepartment.City__c = 'München';
		serviceCenterDepartment.Zipcode__c = '80638 ';
		serviceCenterDepartment.Street__c = 'Wintrichring 1';
		serviceCenterDepartment.Geolocation__Latitude__s = 48.164045;
		serviceCenterDepartment.Geolocation__Longitude__s = 11.507327;
		update serviceCenterDepartment;

		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);


		//Contact

		Contact testContactManager1 = new Contact(
		                                          AccountId = testAccount.Id,
		                                          LastName = 'TestContact3',
		                                          FirstName = 'firstname3',
		                                          MailingCountry = 'Germany',
		                                          MailingStreet = 'Sonnenstraße 60',
		                                          MailingPostalCode = '80334',
		                                          MailingCity = 'Stuttgart',
		                                          Job_Title__c = 'Employee',
		                                          Customer_type__c = 'Contact person only'
		);

		//Employee
		Id gtaEmployeeRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('GTA_Employee').getRecordTypeId();

		Employee__c managerEmployee2 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactManager1.Id, testUserNSCAfterSalesManager.Id, 'NSC Aftersales Manager', gtaEmployeeRecordTypeId);

		serviceCenterDepartment.NSC_Aftersales_Manager__c = managerEmployee2.Id;
		update serviceCenterDepartment;

		//--!! testcase !!--
		Test.startTest();
		Account acc1 = new Account(
		                           BillingCountry = 'Germany',
		                           BillingStreet = 'Niddastraße 49',
		                           BillingPostalCode = '60329',
		                           BillingCity = 'Frankfurt am Main',
		                           PersonMailingCountry = 'Germany',
		                           PersonMailingStreet = 'Niddastraße 49',
		                           PersonMailingPostalCode = '60329',
		                           PersonMailingCity = 'Frankfurt am Main',
		                           PersonMailingLatitude = 50.10989,
		                           PersonMailingLongitude = 8.66481,
		                           FirstName = 'Test',
		                           LastName = 'PersonAccount',
		                           Salutation = 'Ms.',
		                           Major_Language__c = 'en_US',
		                           Preferred_ZipCode__c = '12345',
		                           Contact_Details__c = 'Email',
		                           Customer_type__pc = 'Prospect',
		                           RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
		                           PreferredFacility__pc = retailstoreDepartment.Id,
		                           SMSConsent__pc = true,
		                           TelephoneConsent__pc = true,
		                           EmailConsent__pc = true
		);
		insert acc1;

		acc1.Customer_type__pc = 'Owner';
		update acc1;

		Test.stopTest();

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(null, acc1.Assigned_GTA__c, 'Assigned GTA');

	}

	@isTest
	private static void createAccount2GTA() {
		Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock());
		//User
		User testUserGTA1 = TestDataSetFactory.createSampleUserUniqueUserName('un1@mytestdomain.developer', 'nck1');
		User testUserGTA2 = TestDataSetFactory.createSampleUserUniqueUserName('un2@mytestdomain.developer', 'nck2');
		User testUserNSCAfterSalesManager = TestDataSetFactory.createSampleUserUniqueUserName('un3@mytestdomain.developer', 'nck3');

		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		Department__c serviceCenterDepartment = TestDataSetFactory.createDepartment('SC123', 'serviceCenterDepartment');
		serviceCenterDepartment.RecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service_Center').getRecordTypeId();
		serviceCenterDepartment.Country__c = 'Germany';
		serviceCenterDepartment.City__c = 'München';
		serviceCenterDepartment.Zipcode__c = '80638 ';
		serviceCenterDepartment.Street__c = 'Wintrichring 1';
		serviceCenterDepartment.Geolocation__Latitude__s = 48.164045;
		serviceCenterDepartment.Geolocation__Longitude__s = 11.507327;
		update serviceCenterDepartment;

		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);


		//Contact
		Contact testContactGTA1 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact1',
		                                      FirstName = 'firstname1',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 61',
		                                      MailingPostalCode = '80332',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);
		Contact testContactGTA2 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact2',
		                                      FirstName = 'firstname2',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 71',
		                                      MailingPostalCode = '80331',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);
		Contact testContactManager1 = new Contact(
		                                          AccountId = testAccount.Id,
		                                          LastName = 'TestContact3',
		                                          FirstName = 'firstname3',
		                                          MailingCountry = 'Germany',
		                                          MailingStreet = 'Sonnenstraße 60',
		                                          MailingPostalCode = '80334',
		                                          MailingCity = 'Stuttgart',
		                                          Job_Title__c = 'Employee',
		                                          Customer_type__c = 'Contact person only'
		);

		//Employee
		Id gtaEmployeeRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('GTA_Employee').getRecordTypeId();

		Employee__c gtaEmployee1 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA1.Id, testUserGTA1.Id, 'GTA', gtaEmployeeRecordTypeId);
		Employee__c gtaEmployee2 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA2.Id, testUserGTA2.Id, 'GTA', gtaEmployeeRecordTypeId);
		Employee__c managerEmployee2 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactManager1.Id, testUserNSCAfterSalesManager.Id, 'NSC Aftersales Manager', gtaEmployeeRecordTypeId);

		serviceCenterDepartment.NSC_Aftersales_Manager__c = managerEmployee2.Id;
		update serviceCenterDepartment;

		//GTA__c
		List<GTA__c> gtaLIst = new List<GTA__c> ();
		GTA__c gta1 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee1.Id
		);
		gtaLIst.add(gta1);
		GTA__c gta2 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee2.Id
		);
		gtaLIst.add(gta2);
		insert gtaLIst;

		//--!! testcase !!--
		Test.startTest();
		Account acc1 = new Account(
		                           BillingCountry = 'Germany',
		                           BillingStreet = 'Niddastraße 49',
		                           BillingPostalCode = '60329',
		                           BillingCity = 'Frankfurt am Main',
		                           PersonMailingCountry = 'Germany',
		                           PersonMailingStreet = 'Niddastraße 49',
		                           PersonMailingPostalCode = '60329',
		                           PersonMailingCity = 'Frankfurt am Main',
		                           PersonMailingLatitude = 50.10989,
		                           PersonMailingLongitude = 8.66481,
		                           FirstName = 'Test',
		                           LastName = 'PersonAccount',
		                           Salutation = 'Ms.',
		                           Major_Language__c = 'en_US',
		                           Preferred_ZipCode__c = '12345',
		                           Contact_Details__c = 'Email',
		                           Customer_type__pc = 'Prospect',
		                           RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
		                           PreferredFacility__pc = retailstoreDepartment.Id,
		                           SMSConsent__pc = true,
		                           TelephoneConsent__pc = true,
		                           EmailConsent__pc = true
		);
		insert acc1;

		acc1.Customer_type__pc = 'Owner';
		update acc1;

		Test.stopTest();

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(null, acc1.Assigned_GTA__c, 'Assigned GTA');

	}

	@isTest
	private static void createAccount2GTA2Manager() {
		Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock());
		//User
		User testUserGTA1 = TestDataSetFactory.createSampleUserUniqueUserName('un1@mytestdomain.developer', 'nck1');
		User testUserGTA2 = TestDataSetFactory.createSampleUserUniqueUserName('un2@mytestdomain.developer', 'nck2');
		User testUserNSCAfterSalesManager = TestDataSetFactory.createSampleUserUniqueUserName('un3@mytestdomain.developer', 'nck3');
		User testUserNSCAfterSalesManager2 = TestDataSetFactory.createSampleUserUniqueUserName('un4@mytestdomain.developer', 'nck4');

		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		Department__c serviceCenterDepartment = TestDataSetFactory.createDepartment('SC123', 'serviceCenterDepartment');
		serviceCenterDepartment.RecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service_Center').getRecordTypeId();
		serviceCenterDepartment.Country__c = 'Germany';
		serviceCenterDepartment.City__c = 'München';
		serviceCenterDepartment.Zipcode__c = '80638 ';
		serviceCenterDepartment.Street__c = 'Wintrichring 1';
		serviceCenterDepartment.Geolocation__Latitude__s = 48.164045;
		serviceCenterDepartment.Geolocation__Longitude__s = 11.507327;
		update serviceCenterDepartment;

		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);


		//Contact
		Contact testContactGTA1 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact1',
		                                      FirstName = 'firstname1',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 61',
		                                      MailingPostalCode = '80332',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);
		Contact testContactGTA2 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact2',
		                                      FirstName = 'firstname2',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 71',
		                                      MailingPostalCode = '80331',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);
		Contact testContactManager1 = new Contact(
		                                          AccountId = testAccount.Id,
		                                          LastName = 'TestContact3',
		                                          FirstName = 'firstname3',
		                                          MailingCountry = 'Germany',
		                                          MailingStreet = 'Sonnenstraße 60',
		                                          MailingPostalCode = '80334',
		                                          MailingCity = 'Stuttgart',
		                                          Job_Title__c = 'Employee',
		                                          Customer_type__c = 'Contact person only'
		);

		Contact testContactManager2 = new Contact(
		                                          AccountId = testAccount.Id,
		                                          LastName = 'TestContact4',
		                                          FirstName = 'firstname3',
		                                          MailingCountry = 'Germany',
		                                          MailingStreet = 'Sonnenstraße 58',
		                                          MailingPostalCode = '80334',
		                                          MailingCity = 'Stuttgart',
		                                          Job_Title__c = 'Employee',
		                                          Customer_type__c = 'Contact person only'
		);

		//Employee
		Id gtaEmployeeRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('GTA_Employee').getRecordTypeId();

		Employee__c gtaEmployee1 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA1.Id, testUserGTA1.Id, 'GTA', gtaEmployeeRecordTypeId);
		Employee__c gtaEmployee2 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA2.Id, testUserGTA2.Id, 'GTA', gtaEmployeeRecordTypeId);
		Employee__c managerEmployee = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactManager1.Id, testUserNSCAfterSalesManager.Id, 'NSC Aftersales Manager', gtaEmployeeRecordTypeId);
		Employee__c managerEmployee2 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactManager2.Id, testUserNSCAfterSalesManager2.Id, 'NSC Aftersales Manager', gtaEmployeeRecordTypeId);

		serviceCenterDepartment.NSC_Aftersales_Manager__c = managerEmployee.Id;
		update serviceCenterDepartment;

		managerEmployee.EmploymentStatus__c = 'On Leave';
		managerEmployee.Representative__c = managerEmployee2.Id;
		update managerEmployee;



		//GTA__c
		List<GTA__c> gtaLIst = new List<GTA__c> ();
		GTA__c gta1 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee1.Id
		);
		gtaLIst.add(gta1);
		GTA__c gta2 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee2.Id
		);
		gtaLIst.add(gta2);
		insert gtaLIst;

		//--!! testcase !!--
		Test.startTest();
		Account acc1 = new Account(
		                           BillingCountry = 'Germany',
		                           BillingStreet = 'Niddastraße 49',
		                           BillingPostalCode = '60329',
		                           BillingCity = 'Frankfurt am Main',
		                           PersonMailingCountry = 'Germany',
		                           PersonMailingStreet = 'Niddastraße 49',
		                           PersonMailingPostalCode = '60329',
		                           PersonMailingCity = 'Frankfurt am Main',
		                           PersonMailingLatitude = 50.10989,
		                           PersonMailingLongitude = 8.66481,
		                           FirstName = 'Test',
		                           LastName = 'PersonAccount',
		                           Salutation = 'Ms.',
		                           Major_Language__c = 'en_US',
		                           Preferred_ZipCode__c = '12345',
		                           Contact_Details__c = 'Email',
		                           Customer_type__pc = 'Prospect',
		                           RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
		                           PreferredFacility__pc = retailstoreDepartment.Id,
		                           SMSConsent__pc = true,
		                           TelephoneConsent__pc = true,
		                           EmailConsent__pc = true
		);
		insert acc1;

		acc1.Customer_type__pc = 'Owner';
		update acc1;

		Test.stopTest();

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(null, acc1.Assigned_GTA__c, 'Assigned GTA');

	}

	@isTest
	private static void createAccount2GTA1Inactive() {
		Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock());
		//User
		User testUserGTA1 = TestDataSetFactory.createSampleUserUniqueUserName('un1@mytestdomain.developer', 'nck1');
		User testUserGTA2 = TestDataSetFactory.createSampleUserUniqueUserName('un2@mytestdomain.developer', 'nck2');
		//User testUserNSCAfterSalesManager = TestDataSetFactory.createSampleUserUniqueUserName('un3@mytestdomain.developer', 'nck3');

		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		Department__c serviceCenterDepartment = TestDataSetFactory.createDepartment('SC123', 'serviceCenterDepartment');
		serviceCenterDepartment.RecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service_Center').getRecordTypeId();
		serviceCenterDepartment.Country__c = 'Germany';
		serviceCenterDepartment.City__c = 'München';
		serviceCenterDepartment.Zipcode__c = '80638 ';
		serviceCenterDepartment.Street__c = 'Wintrichring 1';
		serviceCenterDepartment.Geolocation__Latitude__s = 48.164045;
		serviceCenterDepartment.Geolocation__Longitude__s = 11.507327;
		update serviceCenterDepartment;

		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);


		//Contact
		Contact testContactGTA1 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact1',
		                                      FirstName = 'firstname1',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 61',
		                                      MailingPostalCode = '80332',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);
		Contact testContactGTA2 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact2',
		                                      FirstName = 'firstname2',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 71',
		                                      MailingPostalCode = '80331',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);
		Contact testContactManager1 = new Contact(
		                                          AccountId = testAccount.Id,
		                                          LastName = 'TestContact3',
		                                          FirstName = 'firstname3',
		                                          MailingCountry = 'Germany',
		                                          MailingStreet = 'Sonnenstraße 60',
		                                          MailingPostalCode = '80334',
		                                          MailingCity = 'Stuttgart',
		                                          Job_Title__c = 'Employee',
		                                          Customer_type__c = 'Contact person only'
		);
		//Employee
		Id gtaEmployeeRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('GTA_Employee').getRecordTypeId();

		Employee__c gtaEmployee1 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA1.Id, testUserGTA1.Id, 'GTA', gtaEmployeeRecordTypeId);
		Employee__c gtaEmployee2 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA2.Id, testUserGTA2.Id, 'GTA', gtaEmployeeRecordTypeId);
		//Employee__c managerEmployee2 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactManager1.Id, testUserNSCAfterSalesManager.Id, 'NSC Aftersales Manager', gtaEmployeeRecordTypeId);

		gtaEmployee2.EmploymentStatus__c = 'Inactive';
		update gtaEmployee2;

		//GTA__c
		List<GTA__c> gtaLIst = new List<GTA__c> ();
		GTA__c gta1 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee1.Id
		);
		gtaLIst.add(gta1);
		GTA__c gta2 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee2.Id
		);
		gtaLIst.add(gta2);
		insert gtaLIst;

		//--!! testcase !!--
		Test.startTest();
		Account acc1 = new Account(
		                           BillingCountry = 'Germany',
		                           BillingStreet = 'Niddastraße 49',
		                           BillingPostalCode = '60329',
		                           BillingCity = 'Frankfurt am Main',
		                           PersonMailingCountry = 'Germany',
		                           PersonMailingStreet = 'Niddastraße 49',
		                           PersonMailingPostalCode = '60329',
		                           PersonMailingCity = 'Frankfurt am Main',
		                           PersonMailingLatitude = 50.10989,
		                           PersonMailingLongitude = 8.66481,
		                           FirstName = 'Test',
		                           LastName = 'PersonAccount',
		                           Salutation = 'Ms.',
		                           Major_Language__c = 'en_US',
		                           Preferred_ZipCode__c = '12345',
		                           Contact_Details__c = 'Email',
		                           Customer_type__pc = 'Prospect',
		                           RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
		                           PreferredFacility__pc = retailstoreDepartment.Id,
		                           SMSConsent__pc = true,
		                           TelephoneConsent__pc = true,
		                           EmailConsent__pc = true
		);
		insert acc1;

		acc1.Customer_type__pc = 'Owner';
		update acc1;

		Test.stopTest();

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(gtaEmployee1.Id, acc1.Assigned_GTA__c, 'Assigned GTA');
	}

	@isTest
	private static void createAccount2GTAInactiveTheAssigned() {
		Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock());
		//User
		User testUserGTA1 = TestDataSetFactory.createSampleUserUniqueUserName('un1@mytestdomain.developer', 'nck1');
		User testUserGTA2 = TestDataSetFactory.createSampleUserUniqueUserName('un2@mytestdomain.developer', 'nck2');

		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		Department__c serviceCenterDepartment = TestDataSetFactory.createDepartment('SC123', 'serviceCenterDepartment');
		serviceCenterDepartment.RecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service_Center').getRecordTypeId();
		serviceCenterDepartment.Country__c = 'Germany';
		serviceCenterDepartment.City__c = 'München';
		serviceCenterDepartment.Zipcode__c = '80638 ';
		serviceCenterDepartment.Street__c = 'Wintrichring 1';
		serviceCenterDepartment.Geolocation__Latitude__s = 48.164045;
		serviceCenterDepartment.Geolocation__Longitude__s = 11.507327;
		update serviceCenterDepartment;

		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);


		//Contact
		Contact testContactGTA1 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact1',
		                                      FirstName = 'firstname1',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 61',
		                                      MailingPostalCode = '80332',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);
		Contact testContactGTA2 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact2',
		                                      FirstName = 'firstname2',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 71',
		                                      MailingPostalCode = '80331',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);

		//Employee
		Id gtaEmployeeRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('GTA_Employee').getRecordTypeId();

		Employee__c gtaEmployee1 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA1.Id, testUserGTA1.Id, 'GTA', gtaEmployeeRecordTypeId);
		Employee__c gtaEmployee2 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA2.Id, testUserGTA2.Id, 'GTA', gtaEmployeeRecordTypeId);

		//GTA__c
		List<GTA__c> gtaLIst = new List<GTA__c> ();
		GTA__c gta1 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee1.Id
		);
		gtaLIst.add(gta1);
		insert gtaLIst;

		//--!! testcase !!--
		Test.startTest();
		Account acc1 = new Account(
		                           BillingCountry = 'Germany',
		                           BillingStreet = 'Niddastraße 49',
		                           BillingPostalCode = '60329',
		                           BillingCity = 'Frankfurt am Main',
		                           PersonMailingCountry = 'Germany',
		                           PersonMailingStreet = 'Niddastraße 49',
		                           PersonMailingPostalCode = '60329',
		                           PersonMailingCity = 'Frankfurt am Main',
		                           PersonMailingLatitude = 50.10989,
		                           PersonMailingLongitude = 8.66481,
		                           FirstName = 'Test',
		                           LastName = 'PersonAccount',
		                           Salutation = 'Ms.',
		                           Major_Language__c = 'en_US',
		                           Preferred_ZipCode__c = '12345',
		                           Contact_Details__c = 'Email',
		                           Customer_type__pc = 'Prospect',
		                           RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
		                           PreferredFacility__pc = retailstoreDepartment.Id,
		                           SMSConsent__pc = true,
		                           TelephoneConsent__pc = true,
		                           EmailConsent__pc = true
		);
		insert acc1;

		acc1.Customer_type__pc = 'Owner';
		update acc1;

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(gtaEmployee1.Id, acc1.Assigned_GTA__c, 'Assigned GTA');

		//Assign a new GTA to department
		GTA__c gta2 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee2.Id
		);
		insert gta2;
		//Inactivate the Assigned GTA
		gtaEmployee1.EmploymentStatus__c = 'Inactive';
		update gtaEmployee1;

		Test.stopTest();

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(gtaEmployee2.Id, acc1.Assigned_GTA__c, 'Assigned GTA');
	}

	@isTest
	private static void createAccount2GTAInactiveTheAssignedNoOtherActive() {
		Test.setMock(HttpCalloutMock.class, new CalloutMocksTest.GlobalHttpCalloutMock());
		//User
		User testUserGTA1 = TestDataSetFactory.createSampleUserUniqueUserName('un1@mytestdomain.developer', 'nck1');

		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		Department__c serviceCenterDepartment = TestDataSetFactory.createDepartment('SC123', 'serviceCenterDepartment');
		serviceCenterDepartment.RecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service_Center').getRecordTypeId();
		serviceCenterDepartment.Country__c = 'Germany';
		serviceCenterDepartment.City__c = 'München';
		serviceCenterDepartment.Zipcode__c = '80638 ';
		serviceCenterDepartment.Street__c = 'Wintrichring 1';
		serviceCenterDepartment.Geolocation__Latitude__s = 48.164045;
		serviceCenterDepartment.Geolocation__Longitude__s = 11.507327;
		update serviceCenterDepartment;

		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);


		//Contact
		Contact testContactGTA1 = new Contact(
		                                      AccountId = testAccount.Id,
		                                      LastName = 'TestContact1',
		                                      FirstName = 'firstname1',
		                                      MailingCountry = 'Germany',
		                                      MailingStreet = 'Sonnenstraße 61',
		                                      MailingPostalCode = '80332',
		                                      MailingCity = 'Stuttgart',
		                                      Job_Title__c = 'Employee',
		                                      Customer_type__c = 'Contact person only'
		);

		//Employee
		Id gtaEmployeeRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('GTA_Employee').getRecordTypeId();

		Employee__c gtaEmployee1 = TestDataSetFactory.createEmployeeWithSpecificRole(serviceCenterDepartment.Id, testContactGTA1.Id, testUserGTA1.Id, 'GTA', gtaEmployeeRecordTypeId);

		//GTA__c
		List<GTA__c> gtaLIst = new List<GTA__c> ();
		GTA__c gta1 = new GTA__c(
		                         Department__c = serviceCenterDepartment.Id,
		                         Employee__c = gtaEmployee1.Id
		);
		gtaLIst.add(gta1);
		insert gtaLIst;

		//--!! testcase !!--
		Test.startTest();
		Account acc1 = new Account(
		                           BillingCountry = 'Germany',
		                           BillingStreet = 'Niddastraße 49',
		                           BillingPostalCode = '60329',
		                           BillingCity = 'Frankfurt am Main',
		                           PersonMailingCountry = 'Germany',
		                           PersonMailingStreet = 'Niddastraße 49',
		                           PersonMailingPostalCode = '60329',
		                           PersonMailingCity = 'Frankfurt am Main',
		                           PersonMailingLatitude = 50.10989,
		                           PersonMailingLongitude = 8.66481,
		                           FirstName = 'Test',
		                           LastName = 'PersonAccount',
		                           Salutation = 'Ms.',
		                           Major_Language__c = 'en_US',
		                           Preferred_ZipCode__c = '12345',
		                           Contact_Details__c = 'Email',
		                           Customer_type__pc = 'Prospect',
		                           RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
		                           PreferredFacility__pc = retailstoreDepartment.Id,
		                           SMSConsent__pc = true,
		                           TelephoneConsent__pc = true,
		                           EmailConsent__pc = true
		);
		insert acc1;

		acc1.Customer_type__pc = 'Owner';
		update acc1;

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(gtaEmployee1.Id, acc1.Assigned_GTA__c, 'Assigned GTA');

		//Inactivate the Assigned GTA
		gtaEmployee1.EmploymentStatus__c = 'Inactive';
		update gtaEmployee1;

		acc1 = [SELECT Id, Department__c, Assigned_GTA__c, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(serviceCenterDepartment.Id, acc1.Department__c, 'Service Center');
		System.assertEquals(gtaEmployee1.Id, acc1.Assigned_GTA__c, 'Assigned GTA');

	}
}