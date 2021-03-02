trigger  triggerRepairPackageItem on RepairPackageItem__c (Before Insert) {

/*This call will populate the unit price and discount on repair package item record 
from Pricebook entry for the relevant product*/
AfterSales_Service_RepairPckgItemTrggr repairPackageTrigger = new AfterSales_Service_RepairPckgItemTrggr(Trigger.New);
}