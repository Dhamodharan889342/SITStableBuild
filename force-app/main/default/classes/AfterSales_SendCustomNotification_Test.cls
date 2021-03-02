@isTest 
private class AfterSales_SendCustomNotification_Test {

	@isTest(seealldata = true)
	private static void testSendSampleNotificationFromProcessBuilder() {
		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);
		//User
		User testUserGTA1 = TestDataSetFactory.createSampleUserUniqueUserName('un1@mytestdomain.developer', 'nck1');
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
		Employee__c gtaEmployee1 = TestDataSetFactory.createEmployee(retailstoreDepartment.Id, testContactGTA1.Id, testUserGTA1.Id);

		//Input
		List<AfterSales_SendCustomNotification.FlowInputsSampleNotification> inputList = new List<AfterSales_SendCustomNotification.FlowInputsSampleNotification> ();
		AfterSales_SendCustomNotification.FlowInputsSampleNotification input = new AfterSales_SendCustomNotification.FlowInputsSampleNotification();
		input.titleEnglish = 'Title';
		input.bodyEnglis = 'Body';
		input.titleGerman = 'Title German';
		input.bodyGerman = 'Body German';
		input.targetIdString = String.valueOf(testAccount.Id);
		input.employeeIdString = String.valueOf(gtaEmployee1.Id);
		input.notificationTypeDeveloperName = 'sendAccountNotification';

		inputList.add(input);
		try {
			AfterSales_SendCustomNotification.sendSampleNotificationFromProcessBuilder(inputList);
		} catch(Exception ex) {
			System.assert(false);
		}
	}

	@isTest(seealldata = true)
	private static void testSendCustNotiHandlerGTAofDep() {
		//Department
		Department__c retailstoreDepartment = TestDataSetFactory.createDepartment('DEP123', 'retailstoreDepartment');
		//Account
		Account testAccount = TestDataSetFactory.createSampleAccount(retailstoreDepartment.id);
		//User
		User testUserGTA1 = TestDataSetFactory.createSampleUserUniqueUserName('un1@mytestdomain.developer', 'nck1');
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
		Employee__c gtaEmployee1 = TestDataSetFactory.createEmployeeWithSpecificRole(retailstoreDepartment.Id, testContactGTA1.Id, testUserGTA1.Id, 'GTA', gtaEmployeeRecordTypeId);
		GTA__c gta1 = new GTA__c(
		                         Department__c = retailstoreDepartment.Id,
		                         Employee__c = gtaEmployee1.Id
		);
		insert gta1;

		//Pricebook
		Pricebook2 pb = TestDataSetFactory.createPriceBook('pb1','Service');

		//JobOrder
		WorkOrder wo = TestDataSetFactory.createJobOrderWithServiceCenter(testAccount.Id, pb.Id, retailstoreDepartment.Id);

		//JobOrder Extension
		Job_Order_Extension__c joe = TestDataSetFactory.createJobOrderExtension(wo.Id, 'joeName');

		//Input
		List<AfterSales_SendCustNotiHandler_GTAofDep.FlowInputs> inputList = new List<AfterSales_SendCustNotiHandler_GTAofDep.FlowInputs> ();
		AfterSales_SendCustNotiHandler_GTAofDep.FlowInputs input = new AfterSales_SendCustNotiHandler_GTAofDep.FlowInputs();
		input.titleEnglish = 'Title';
		input.bodyEnglis = 'Body';
		input.titleGerman = 'Title German';
		input.bodyGerman = 'Body German';
		input.targetIdString = String.valueOf(joe.Id);
		input.servicecenterIdString = String.valueOf(retailstoreDepartment.Id);
		input.notificationTypeDeveloperName = 'sendAccountNotification';

		inputList.add(input);
		try {
			AfterSales_SendCustNotiHandler_GTAofDep.sendNotificationFromProcessBuilderToGTAofDepartment(inputList);
		} catch(Exception ex) {
			System.assert(false);
		}
	}
}