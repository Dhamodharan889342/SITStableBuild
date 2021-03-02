/**
 * @author Daniel Varhidi
 * @createdDate 05/01/2021
 * @JIRA GD-1572
 * @description Update UnitPrice field on PriceBook Entries from AMOSPriceBasic__c on Product. 
 * @scheduledClass AfterSales_PartsPriceListSchedulable.
*/
global class AfterSales_PartsPriceListBatchable implements Database.Batchable<SObject> {

	global AfterSales_PartsPriceListBatchable() { }

	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */
	global Database.QueryLocator start(Database.BatchableContext context) {
		System.debug('AfterSales_PartsPriceListBatchable > start');
		//Get Batch_Last_run__c from Custom Setting
		Product_Custom_Setting__c customS = [
		                                     SELECT Name, Batch_Last_run__c
		                                     FROM Product_Custom_Setting__c
		                                     WHERE Name = 'AfterSales_PartsPriceListBatchable'
		                                    ];

		//Get Products
		Map<Id, Product2> productMapById = new Map<Id, Product2> ([
		                                                          SELECT Id
		                                                          FROM Product2
		                                                          WHERE LastModifiedDate > :customS.Batch_Last_run__c
		                                                          ]);
		//Update customSetting
		customS.Batch_Last_run__c = System.now();
		System.debug('AfterSales_PartsPriceListBatchable > start > System.Datetime.now(): ' + System.Datetime.now());
		update customS;

		Set<Id> productIdSet = productMapById.keySet();

		//Get Pricebook Entries
		return Database.getQueryLocator('SELECT Id, UnitPrice, Pricebook2.Country__c, Product2.AMOSPriceBasic__c, Product2.Country__c FROM PricebookEntry WHERE Pricebook2.Is_Regional_Pricebook__c = true AND Product2Id IN :productIdSet');

	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */
	global void execute(Database.BatchableContext context, List<PricebookEntry> scope) {
		System.debug('AfterSales_PartsPriceListBatchable > execute');
		if (!scope.isEmpty()) {
			//Create map for Pricebook Entry
			Map<Id, PricebookEntry> pricebookEntryMapById = new Map<Id, PricebookEntry> (scope);
			if (!pricebookEntryMapById.isEmpty()) {
				//Update PricebookEntries
				List<PricebookEntry> pbEntryListForUpdate = updatePricebookEntriesForUpdate(pricebookEntryMapById);
				if (!pbEntryListForUpdate.isEmpty()) {
					update pbEntryListForUpdate;
					updateNSCPricebooks(pbEntryListForUpdate);
				}
			} else {
				System.debug('AfterSales_PartsPriceListBatchable > execute > pricebookEntryMapById.size() == 0');
			}
		} else {
			System.debug('AfterSales_PartsPriceListBatchable > execute > scope.size() == 0');
		}
	}

	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */
	global void finish(Database.BatchableContext context) {

	}

	/**
	* @description 
	* @param pbEntryListForUpdate 
	*/ 
	private void updateNSCPricebooks(List<PricebookEntry> pbEntryListForUpdate) {
		Set<Id> pricebookIdSet = new Set<Id>();
		for(PricebookEntry pbeItem : pbEntryListForUpdate){
			pricebookIdSet.add(pbeItem.Pricebook2Id);
		}
		List<Pricebook2> pbList = [SELECT Id, Last_Sync__c FROM Pricebook2 WHERE Id IN : pricebookIdSet];
		for(Pricebook2 pbItem : pbList){
			pbItem.Last_Sync__c = System.now();
		}
		update pbList;
	}

	/**
	 * @description collect the price book entries for update
	 * @param pricebookEntryMapById 
	 * @param productMapById 
	 * @return 
	 */
	private List<PricebookEntry> updatePricebookEntriesForUpdate(Map<Id, PricebookEntry> pricebookEntryMapById) {
		List<PricebookEntry> pbEntryListForUpdate = new List<PricebookEntry> ();
		//iterate on pricebookEntryMapById
		for (Id pbeId : pricebookEntryMapById.keySet()) {
			//Get Records
			PricebookEntry pbentry = pricebookEntryMapById.get(pbeId);
			if (pbentry.Pricebook2.Country__c == pbentry.Product2.Country__c && pbentry.UnitPrice != pbentry.Product2.AMOSPriceBasic__c) {
				pbentry.UnitPrice = pbentry.Product2.AMOSPriceBasic__c;
				pbEntryListForUpdate.add(pbentry);
			}
		}
		return pbEntryListForUpdate;
	}
}