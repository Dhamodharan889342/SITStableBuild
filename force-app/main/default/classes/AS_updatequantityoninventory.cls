/******************************************************************************************
  * File Name   : AS_updatequantityoninventory
  * Created Date: 28th December 2020
  * Description : Called by trigger AS_updatequantityoninventory on after delete on Product Required record to update Quantity Reserved on connected Inventory record.
  * Story       : https://jira.hyundai-autoever.eu/browse/GD-1606
  * Author      : Neha Aggrawal
*/
  

public class AS_updatequantityoninventory {
public void func(){
ProductRequired[] newBatch=Trigger.old;
System.debug(newBatch.size());

Map<Id,Decimal> updateMap=new Map<Id,Decimal>();
Map<Id,Decimal> updateMap1=new Map<Id,Decimal>();
Map<Id,ProductItem > updateMap2=new Map<Id,ProductItem >();


Set<Id> prSet=new Set<Id>();
//Get all inventory records for the deleted Product required records
 for(ProductRequired pr:newBatch){ 
     System.debug(pr.QuantityRequired);
            if(pr.Product_Item_Inventory__c!=null) 
                prSet.add(pr.Product_Item_Inventory__c);
                }
if(prSet.size()!=0)
{
//get sum of quantity required for all product required records including the deleted ones for the Inventory set above 
List<AggregateResult> AggregateResultList=[Select Product_Item_Inventory__c ,sum(QuantityRequired) qr from ProductRequired where Product_Item_Inventory__c in: prSet and Status__c=:'New' group by Product_Item_Inventory__c  ALL ROWS];
if(AggregateResultList != null && AggregateResultList.size() > 0){ 
        for(AggregateResult aggr:AggregateResultList){  
        updateMap.put((id)aggr.get('Product_Item_Inventory__c'), (decimal)aggr.get('qr'));
        }
        }   
//get sum of quantity required for only deleted product required records for the Inventory set above 
List<AggregateResult> AggregateResultList1=[Select Product_Item_Inventory__c ,sum(QuantityRequired) qr from ProductRequired where Product_Item_Inventory__c in: prSet and Status__c=:'New' and isDeleted=True group by Product_Item_Inventory__c ALL ROWS];
if(AggregateResultList1 != null && AggregateResultList1.size() > 0){ 
        for(AggregateResult aggr:AggregateResultList1){ 
        updateMap1.put((id)aggr.get('Product_Item_Inventory__c'), (decimal)aggr.get('qr'));
        }
        }  
        
 for(Id i:prSet)
 {
//To update the Reserved quantity on Inventory, minus the quantity required for deleted product required records from the total quantity required
 ProductItem pI=new ProductItem(); 
 pI.Id=i;
 pI.Quantity_Reserved__c=updateMap.get(i)-updateMap1.get(i);
 updateMap2.put(pI.Id,pI);
 }
     update updateMap2.values();  
   System.debug(updateMap2);

}  
}
}