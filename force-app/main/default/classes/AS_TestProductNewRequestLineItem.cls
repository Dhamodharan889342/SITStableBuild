/**
Author: Shashikant Bagale
Company: CTS
Date:  31/12/2020 
Description: Test class for batch class to update/Create Pricbookentry
*/

@isTest
public class AS_TestProductNewRequestLineItem {
    // This is used for the new request product new Item.   
    static testMethod void testgetRequestProductNewItem() {   
        product2 ProductLineItem = new product2(name='Product1', productcode='PR-001',ProductNameNative__c='Native',Family='',Description='Demo Car');
        insert ProductLineItem;
        List <product2> returnListProductLineItem = new List <product2> ();       
        Test.startTest();
        returnListProductLineItem= AfterSales_ProductNewRequestLineItem.getRequestProductNewItem('strValue');        
        Test.stopTest();
    } 
    
    // This test method used for fetch Product Numbers
    static testMethod void testgetRequestProductNumber() { 
        Department__c dep = AfterSales_TestFactory.getDepartmentStore('Store','StoreCode', false);  
        insert dep;   
        ProductRequest objProductRequest = new ProductRequest(OrderType__c='S',ShipMode__c='G',Department__c=dep.id); 
        insert objProductRequest;    
        Test.startTest();
        string strProductRequestNumber= AfterSales_ProductNewRequestLineItem.getRequestProductNumber(objProductRequest.id);        
        Test.stopTest();
    }  
    
    // Product Request Line Item used for the Save the line Item.  
   static testMethod void test_saveProductRequestLineItem() { 
        Department__c dep = AfterSales_TestFactory.getDepartmentStore('Store','StoreCode', false);  
        insert dep;   
        Schema.Location loc=TestDataSetFactory.createLocation('Warehouse','loc',dep.Id,true);       
        product2 ProductLineItem = new product2(name='Product1', productcode='PR-001',ProductNameNative__c='Native',Family='',Description='Demo Car');
        insert ProductLineItem;        
        ProductRequest objProductRequest = new ProductRequest(OrderType__c='S',ShipMode__c='G',Department__c=dep.Id);
        insert objProductRequest;          
        ProductRequestLineItem objProductRequestLineItem = new ProductRequestLineItem(ParentId=objProductRequest.id,Product2Id=ProductLineItem.id,Description='Test Description',QuantityRequested=5);        
        insert objProductRequestLineItem;        
        Test.startTest();
        ProductRequestLineItem objProductRequestLineItemReturn= AfterSales_ProductNewRequestLineItem.saveProductRequestLineItem(objProductRequestLineItem);        
        Test.stopTest();
    }    
    static testMethod void testgetSupersessionProductNewItem() {            
        product2 ProductLineItem = new product2(name='Product1', productcode='PR-001',ProductNameNative__c='Native',Family='',Description='Demo Car');
        insert ProductLineItem;    
        Test.startTest();
        string strProductRequestNumber= AfterSales_ProductNewRequestLineItem.getSupersessionProductNewItem(ProductLineItem.Name);        
        Test.stopTest();
    }   
}