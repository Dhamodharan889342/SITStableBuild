/**
Author: Shashikant Bagale
Company: CTS
Date:  31/12/2020 
Description: Get Product request Line Item.
*/
public without sharing class AfterSales_ProductNewRequestLineItem {
    
    
    @AuraEnabled
    /*  public static List <PriceBookEntry> getRequestProductNewItem(String searchKeyWord){ 
List <PriceBookEntry> returnListProductLineItem = new List <PriceBookEntry> (); 
String searchString = '%' + searchKeyWord + '%';        
List <PriceBookEntry> lstOfProductLineItem =[
SELECT Product2.Id,Product2.recordtype.name ,Product2.Name, Product2.ProductCode,Product2.Description, Product2.ProductNameNative__c,Product2.Family,Product2.StartDate__c,Product2.Quantity__c,Product2.DAOSMinimumOrderQuantity__c,Product2.EndDate__c,Product2.Model__c,PricebookEntry.UnitPrice,Product2.AfterSales_Recommendation__c,Product2.AfterSales_Supersession__c from PriceBookEntry where ((Product2.productcode like :searchString) or (Product2.name like :searchString)) and Product2.recordtype.name='Part' ];
return lstOfProductLineItem;
}
select id,QuantityOnHand,Product2.productcode,Product2.Id,Product2.recordtype.name ,Product2.Name,
Product2.Description,Product2.ProductNameNative__c,Product2.Family,Product2.Price_Per_Unit__c,
Product2.StartDate__c,Product2.Quantity__c,Product2.DAOSMinimumOrderQuantity__c,Product2.EndDate__c,
Product2.Model__c,Product2.AfterSales_Recommendation__c,Product2.AfterSales_Supersession__c 
from ProductItem */
    
    public static List <Product2> getRequestProductNewItem(String searchKeyWord){         
        List <Product2> returnListProductLineItem = new List <Product2> (); 
        List<Employee__c>  lstDepartment =new List<Employee__c>();
        lstDepartment  = [SELECT id, department__c,User__c FROM Employee__c where User__c=: userInfo.getUserId()] ;   
        String searchString = '%' + searchKeyWord + '%';   
        List <Product2> lstOfProductLineItem =[  
            SELECT Id,productcode,recordtype.name,Name,Description,ProductNameNative__c,Family,Price_Per_Unit__c,StartDate__c,Quantity__c,
            DAOSMinimumOrderQuantity__c,EndDate__c,Model__c,AfterSales_Recommendation__c,AfterSales_Supersession__c,
            (SELECT Id,QuantityOnHand FROM ProductItems  ORDER BY LastModifiedDate DESC LIMIT 1  ) 
            FROM Product2 
            WHERE ((productcode like :searchString) or (name like :searchString))            
            AND recordtype.name='Part' ];
        return lstOfProductLineItem;
        //where Department__c=:lstDepartment[0].Department__c
    }
    
    @AuraEnabled
    public static String getRequestProductNumber(String recordId){  	
        List<ProductRequest> lstProductRequest =[SELECT ProductRequestNumber FROM ProductRequest where Id=:recordId]; 
        return lstProductRequest[0].ProductRequestNumber;
    }  
    
    @AuraEnabled
    public static ProductRequestLineItem saveProductRequestLineItem(ProductRequestLineItem objProductRequestLineItem) {
        upsert objProductRequestLineItem;
        return objProductRequestLineItem;
    }
    
    @AuraEnabled
    public static string getSupersessionProductNewItem(String searchSupersessionKeyWord){ 
        
        String searchSupersessionString = '%' + searchSupersessionKeyWord + '%';        
        List <Product2> lstSupersessionProductLineItem =[ SELECT Id, Name from Product2  where  Name like :searchSupersessionString];        
        return lstSupersessionProductLineItem[0].Id;
    } 
    
}