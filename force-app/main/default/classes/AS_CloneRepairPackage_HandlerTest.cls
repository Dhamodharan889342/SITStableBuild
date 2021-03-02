/**
 * @author Daniel Varhidi
 * @description 
 * @created 21/01/2021
 * @JIRA GD-2168
*/
@isTest
private class AS_CloneRepairPackage_HandlerTest {

	@isTest
	private static void testName() {
		//User
		User testUser = TestDataSetFactory.createSampleUser();
		testUser.Country__c = 'Germany';
		update testUser;
		//Department
		Department__c dep = TestDataSetFactory.createDepartment('111', 'depName'); //String code, String name
		//Account
		Account acc = TestDataSetFactory.createSampleAccount(dep.Id); //Id prefferedFacilityId
		//Contact
		Contact con = TestDataSetFactory.createSampleContact2(acc.Id);//Id accountId
		//Employee
		Employee__c emp = TestDataSetFactory.createEmployee(dep.Id,con.Id, UserInfo.getUserId());//Id prefferedFacilityId, Id contactId, Id userId
		//Product
		Product2 p = TestDataSetFactory.createProduct('valami', true, 'Germany'); //String name, Boolean isActiveBoolean, String country
		// NSC PriceBook for Germany
		Pricebook2 pb = TestDataSetFactory.createNSCPriceBook('ValamiPb', 'Service', 'Germany'); //String name, String type, String country
		//Standard PBEntry
		Id stdPbeId = Test.getStandardPricebookId();
		PricebookEntry standardpbe1 = TestDataSetFactory.createPriceBookEntry(10, stdPbeId, p.Id);
		//PriceBookEntry
		PricebookEntry pbe = TestDataSetFactory.createPriceBookEntry(10, pb.Id, p.Id); //Integer unitprice, Id pricebookId, Id ProductId
		List<PricebookEntry> pbeList = new List<PricebookEntry> ();
		pbeList.add(pbe);
		//Repair Package
		RepairPackage__c rp = TestDataSetFactory.createRepairPackage();
		RepairPackage__c rp2 = TestDataSetFactory.createRepairPackage();
		//Repair Package Item
		RepairPackageItem__c rpi = new RepairPackageItem__c(
		                                                    Name = 'rpi Name',
		                                                    RecordTypeId = RepairPackageItem__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId(),
		                                                    RepairPackage__c = rp.Id,
		                                                    Product__c = p.Id,
		                                                    Quantity__c = 2
		);
		List<RepairPackageItem__c> rpiList = new List<RepairPackageItem__c>();
		rpiList.add(rpi);

		System.runAs(testUser){
		List<AS_CloneRepairPackage_Handler.FlowInputs> flowInputList = new List<AS_CloneRepairPackage_Handler.FlowInputs> ();
		AS_CloneRepairPackage_Handler.FlowInputs flinput = new AS_CloneRepairPackage_Handler.FlowInputs();
		flinput.newrepairPackageId = rp2.Id;
		//flinput.priceBookEntryList = pbeList;
		flinput.repairPackageItemList = rpiList;
		flowInputList.add(flinput);

		AS_CloneRepairPackage_Handler.cloneRepairPackageApexHandler(flowInputList);

		List<RepairPackageItem__c> newrpiList = [SELECT Id FROM RepairPackageItem__c WHERE RepairPackage__c = :rp2.Id];
		System.assertEquals(rpiList.size(), newrpiList.size(), 'Number of new Repair Package Items');
		}
	}
}