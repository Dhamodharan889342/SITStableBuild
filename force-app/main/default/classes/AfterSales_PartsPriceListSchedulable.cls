/**
* @author Daniel Varhidi
* @createdDate 05/01/2021
* @description Run class AfterSales_PartsPriceListBatchable every day
*/ 
global class AfterSales_PartsPriceListSchedulable implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		Id batchJobId  = Database.executeBatch(new AfterSales_PartsPriceListBatchable(), 200);
	}
}