/*
Created By: Mayank Pant
Created Date: 10th Nov 2020
Description: Purpose of this class is to calculate the price of the items for the partcular pricebook
*/	
public class AfterSales_Service_Package_ItemPrice {

    /*This method will recieve the product id and pricebook id
		Argument: set<Id> and pricebook Id
		Return type: Return the list of pricebook entry for the products recieved as argument in the pricebook
	*/
    public static Map<Id,PricebookEntry> getPriceBookItem(set<ID> product2ID, Id priceBookId){

        Map<Id,PricebookEntry> mapPriceBookEntry = new Map<Id,PriceBookEntry>();
        
        for(PricebookEntry prBkEntry : [SELECT ID,
                                               Unit_Price_DAOS__c,
                                               Unit_Price_Dist__c,
                                        	   UnitPrice,
                                        	   UnitDiscount__c,
	                                           Product2Id
                                         FROM PRICEBOOKENTRY
                                         WHERE Pricebook2Id = :priceBookId
                                        AND Product2Id in :product2ID])
        {
                                            
        	mapPriceBookEntry.put(prBkEntry.Product2Id,prBkEntry);                                 
        }
        return mapPriceBookEntry;
    }
    
}