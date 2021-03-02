/**
 * @author Daniel Varhidi
 * @createdDate 05/01/2021
 * @description Unit test class for: AfterSales_PartsPriceListBatchable and AfterSales_PartsPriceListSchedulable
*/
@isTest
private class AfterSales_PartsPriceListBatchableTest {


	@isTest
	private static void testName() {

		Datetime batchLastRun = System.now() - 10;
		//Custom Setting
		Product_Custom_Setting__c createCustomSetting = new Product_Custom_Setting__c(
		                                                                              Name = 'AfterSales_PartsPriceListBatchable',
		                                                                              Batch_Last_run__c = batchLastRun
		);
		insert createCustomSetting;

		//Product - not update
		List<Product2> prodList = new List<Product2>();
		Product2 prod1 = TestDataSetFactory.createProduct('Local test product1', true, 'Germany');
		prodList.add(prod1);
		Product2 prod2 = TestDataSetFactory.createProduct('Local test product2', true, 'Germany');
		prodList.add(prod2);
		Product2 prod3 = TestDataSetFactory.createProduct('Local test product3', true, 'Germany');
		prodList.add(prod3);

		//insert prodList;

		prod1.AMOSPriceBasic__c = 100;
		prod2.AMOSPriceBasic__c = 100;
		prod3.AMOSPriceBasic__c = 100;
		update prodList;

		//Standard pricebook and pbEntries
		Id stdPbeId = Test.getStandardPricebookId();
		List<PricebookEntry> standardpbeList = new List<PricebookEntry> ();
		PricebookEntry standardpbe1 = TestDataSetFactory.createPriceBookEntry(100, stdPbeId, prod1.Id);
		standardpbeList.add(standardpbe1);
		PricebookEntry standardpbe2 = TestDataSetFactory.createPriceBookEntry(50, stdPbeId, prod2.Id);
		standardpbeList.add(standardpbe2);
		PricebookEntry standardpbe3 = TestDataSetFactory.createPriceBookEntry(50, stdPbeId, prod3.Id);
		standardpbeList.add(standardpbe3);
		//insert standardpbeList;

		//PriceBook
		List<Pricebook2> pbList = new List<Pricebook2> ();
		Pricebook2 pb1 = TestDataSetFactory.createNSCPriceBook('pb1', 'Service', 'Germany');
		Pricebook2 pb2 = TestDataSetFactory.createPriceBook('pb2', 'Service');
		//insert pbList;

		//PriceBook entry
		List<PricebookEntry> pbeList = new List<PricebookEntry> ();

		PricebookEntry pb1pbe1 = TestDataSetFactory.createPriceBookEntry(1000, pb1.Id, prod1.Id); //Update
		pbeList.add(pb1pbe1);
		PricebookEntry pb1pbe2 = TestDataSetFactory.createPriceBookEntry(1000, pb1.Id, prod2.Id); //Update
		pbeList.add(pb1pbe2);

		PricebookEntry pb2pbe1 = TestDataSetFactory.createPriceBookEntry(1000, pb2.Id, prod1.Id); //Not update
		pbeList.add(pb2pbe1);
		//insert pbeList;

		//Run batch class
		Test.startTest();
		Id batchJobId = Database.executeBatch(new AfterSales_PartsPriceListBatchable(), 200);
		Test.stopTest();

		//Asserts
		//Should Not be updated
		PricebookEntry pb1pbe1New = [SELECT Id, LastModifiedDate, UnitPrice FROM PricebookEntry WHERE Id = :pb1pbe1.Id];
		System.assertEquals(100, pb1pbe1New.UnitPrice);
		PricebookEntry pb1pbe2New = [SELECT Id, LastModifiedDate, UnitPrice FROM PricebookEntry WHERE Id = :pb1pbe2.Id];
		System.assertEquals(100, pb1pbe2New.UnitPrice);
		//Should be Updated
		PricebookEntry pb2pbe1New = [SELECT Id, LastModifiedDate, UnitPrice FROM PricebookEntry WHERE Id = :pb2pbe1.Id];
		System.assertEquals(1000, pb2pbe1New.UnitPrice);

	}
}