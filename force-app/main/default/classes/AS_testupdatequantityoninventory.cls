/******************************************************************************************
  * File Name   : AS_testupdatequantityoninventory
  * Created Date: 28th December 2020
  * Description : Test class for AS_updatequantityoninventory
  * Story       : https://jira.hyundai-autoever.eu/browse/GD-1606
  * Author      : Neha Aggrawal
*/

@isTest
public class AS_testupdatequantityoninventory {
static testMethod void testUpdateFunc(){
PriceBook2 pb1 = TestDataSetFactory.createPriceBook('test name','Service');


List<ProductRequired > delprList= new List<ProductRequired >();


Department__c dt=TestDataSetFactory.createDepartment('DT0001','TestDT');
Schema.Location loc=TestDataSetFactory.createLocation('Warehouse','loc',dt.Id,true);



WorkOrder wo=TestDataSetFactory.createWorkOrder('Germany',pb1);
WorkOrderLineItem wolt=TestDataSetFactory.createWorkOrderLineItem(wo.Id);




List<Product2> pdtList=TestDataSetFactory.createBulkProducts('pdt',20);

List<ProductItem> piList=TestDataSetFactory.createBulkProductItems(pdtList,0,loc.Id,dt.Id,0,5);

List<ProductRequired > prList=TestDataSetFactory.createBulkProductRequired(wolt.Id,piList,pdtList,Integer.valueof((Math.random() * 20))+1,5);
System.debug(prList.size());
    
Test.starttest();
delprList.add(prList[1]);

delete delprList;
System.debug(piList[0]);
Test.stoptest();
}
}