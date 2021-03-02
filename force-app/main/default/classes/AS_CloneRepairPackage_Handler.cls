/**
 * @author Daniel Varhidi
 * @Date 09/Febr/2021
 * @JIRA GD-2168
 * @description called from flow 'CloneRepairPackage 2' 
*/
public class AS_CloneRepairPackage_Handler {

	@InvocableMethod(label = 'cloneRepairPackageApexHandler' description = '' category = '')
	public static void cloneRepairPackageApexHandler(List<FlowInputs> request) {
		User currentUser = [
		                    SELECT Id, Country__c
		                    FROM User
		                    WHERE ID = :UserInfo.getUserId()
		                   ];
		List<RepairPackageItem__c> returnValueList = new List<RepairPackageItem__c> ();
		for (FlowInputs i : request) {
			List<RepairPackageItem__c> repairPackageItemList = i.repairPackageItemList;
			if (!repairPackageItemList.isEmpty()) {
				//Collect the Products
				Set<Id> productIdSet = new Set<Id> ();
				for (RepairPackageItem__c item : repairPackageItemList) {
					productIdSet.add(item.Product__c);
				}
				if (!productIdSet.isEmpty()) {
					List<Product2> prodList = [
					                           SELECT Id, ProductCode, Country__c
					                           FROM Product2
					                           WHERE Id IN :productIdSet AND Country__c = :currentUser.Country__c
					                          ];
					System.debug('AS_CloneRepairPackage_Handler > cloneRepairPackageApexHandler > prodList: ' + prodList);

					//create Map ProductCode-Product2
					Map<String, Product2> prodMapbyProductCode = new Map<String, Product2> ();
					for (Product2 pItem : prodList) {
						prodMapbyProductCode.put(pItem.ProductCode, pItem);
					}
					//clone the RepairPackage Items and modify the Unitprice
					for (RepairPackageItem__c item : repairPackageItemList) {
						//Check whether the necessary product is exist
						System.debug('AS_CloneRepairPackage_Handler > cloneRepairPackageApexHandler > item.fm_ProductCode__c: ' + item.fm_ProductCode__c);

						if (prodMapbyProductCode.containsKey(item.fm_ProductCode__c)) {
							RepairPackageItem__c newItem = new RepairPackageItem__c();
							newItem.Name = item.Name;
							newItem.Quantity__c = item.Quantity__c;
							newItem.RecordTypeId = item.RecordTypeId;
							newItem.RepairPackage__c = i.newrepairPackageId;
							newItem.Product__c = prodMapbyProductCode.get(item.fm_ProductCode__c).Id;

							returnValueList.add(newItem);
						}
					}
				}
			}
		}
		System.debug('AS_CloneRepairPackage_Handler > cloneRepairPackageApexHandler > returnValueList: ' + returnValueList);

		if (!returnValueList.isEmpty()) {
			insert returnValueList;
		}

	}

	/**
	 * @description input details that comes to apex from flow
	 */
	public class FlowInputs {

		@InvocableVariable
		public List<RepairPackageItem__c> repairPackageItemList;

		@InvocableVariable
		public String newrepairPackageId;

	}

}