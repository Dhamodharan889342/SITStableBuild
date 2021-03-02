/******************************************************************************************
  * File Name   : AS_SubmitPO_AmosRestAPITest
  * Created Date: 16th December 2020
  * Description : Test class for AS_SubmitPO_AmosRestAPI.cls. API is required for GD-1391 ( Integration: submit purchase order ) and GD-1393 ( Integration: shipping information for purchase order ). It allows to send and recieive REST calls to/from AMOS system.
  * Author      : Konrad Maluszkiewicz
  * Modification Log
  * =======================================================================
  * Ver     Date             Author                      Modification
  * =======================================================================
  * 1.0     16.12.2020       Konrad Maluszkiewicz        Creation
  ****************************************************************************************/

@isTest
private class AS_SubmitPO_AmosRestAPITest {
    @testSetup
    static void setupTestData() {
        Product2 prod2 = new Product2();
        prod2.Name = 'Local test product2';
        prod2.CurrencyIsoCode = 'EUR';
        prod2.IsActive = true;
        insert prod2;

        Department__c department = new Department__c();
        department.Department_Code__c = 'test_department_code';
        department.SalesCompanyCode__c = 'test';
        department.Part_Item__c = prod2.Id;
        insert department;

        ProductRequest prodReq = new ProductRequest();
        prodReq.OrderNoCXP__c = 'CXPOrderNo';
        prodReq.OrderType__c = 'S';
        prodReq.ShipMode__c = 'E';
        prodReq.Description = 'test description';
        prodReq.Department__c = department.Id;
        prodReq.ExternalIdCXP__c = 'EXT_ID_1_TEST';
        prodReq.Status = 'Draft';
        prodReq.ShipmentType = 'Rush';
        insert prodReq;

        // List<ProductRequestLineItem> productRequestLineItemsList = new List<ProductRequestLineItem>();
        // ProductRequestLineItem prodReqLineItem;

        // for(Integer i=0;i<3;i++) {
        //     prodReqLineItem = new ProductRequestLineItem();
        //     prodReqLineItem.ParentId = prodReq.Id;
        //     prodReqLineItem.OrderLineNoCXP__c = 'oln' + i;
        //     prodReqLineItem.OrderedPartNo__c = 'opn' + i;
        //     prodReqLineItem.QuantityUnitOfMeasure = 'Each';
        //     prodReqLineItem.Product2Id = prod2.Id;

        //     productRequestLineItemsList.add(prodReqLineItem);
        // }

        // insert productRequestLineItemsList;
    }

    // @isTest static void testMethod1() {
    //     List<ProductRequest> prodRequestsList = [SELECT Id FROM ProductRequest];
    //     System.assertEquals(1, prodRequestsList.size());

    //     List<Department__c> departmentsList = [SELECT Id FROM Department__c];
    //     System.assertEquals(1, departmentsList.size());

    //     List<Product2> products2List = [SELECT Id FROM Product2];
    //     System.assertEquals(1, products2List.size());

    //     List<ProductRequestLineItem> productRequestLineItemsList = [SELECT Id FROM ProductRequestLineItem];
    //     System.assertEquals(3, productRequestLineItemsList.size());
    // }

    @isTest
    static void testSendProdReqToAMOS() {
        AS_SubmitPO_AmosHttpCalloutMock amosProdReqHttpCalloutMock = new AS_SubmitPO_AmosHttpCalloutMock();
        Test.setMock(HttpCalloutMock.class, amosProdReqHttpCalloutMock);

        Test.startTest();
        Id prodReqId = [SELECT Id FROM ProductRequest WHERE ExternalIdCXP__c = 'EXT_ID_1_TEST'].Id;
        System.debug('prodReqId = ' + prodReqId);
        HttpResponse httpResp = AS_SubmitPO_AmosRestAPI.sendProdReqToAMOS(prodReqId);
        System.assertEquals(200, httpResp.getStatusCode(), 'Error: status code of response for sendProdReqToAMOS callout should be equal to: 200');
        Test.stopTest();
    }

    @isTest
    static void testUpsertProductRequest() {
        ProductRequest prodReq = [SELECT ShipMode__c FROM ProductRequest WHERE ExternalIdCXP__c = 'EXT_ID_1_TEST'];
        System.assertEquals('E',prodReq.ShipMode__c,'Error: ProductRequest.ShipMode__c field before inbound REST call should have value of: \'E\'');
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/ProductRequestAPI';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf('{"ExternalIdCXP__c" : "EXT_ID_1_TEST","ShipMode__c" : "G","Status" : "Received","ShipmentType" : "Pick Up"}');
        RestContext.request = request;
        AS_SubmitPO_AmosRestAPI.upsertProductRequest();

        prodReq = [SELECT ShipMode__c FROM ProductRequest WHERE ExternalIdCXP__c = 'EXT_ID_1_TEST'];
        System.debug('after inbound REST call # prodReq = ' + prodReq);
        System.assertEquals('G',prodReq.ShipMode__c,'Error: ProductRequest.ShipMode__c field after inbound REST call should have value of: \'G\'');
    }

// @isTest static  void testGetCallout() {
//     // Create the mock response based on a static resource
//     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
//     mock.setStaticResource('GetAnimalResource');
//     mock.setStatusCode(200);
//     mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
//     // Associate the callout with a mock response
//     Test.setMock(HttpCalloutMock.class, mock);
//     // Call method to test
//     HttpResponse result = AnimalsCallouts.makeGetCallout();
//     // Verify mock response is not null
//     System.assertNotEquals(null,result,
//         'The callout returned a null response.');
//     // Verify status code
//     System.assertEquals(200,result.getStatusCode(),
//         'The status code is not 200.');
//     // Verify content type   
//     System.assertEquals('application/json;charset=UTF-8',
//         result.getHeader('Content-Type'),
//         'The content type value is not expected.');  
//     // Verify the array contains 3 items     
//     Map<String, Object> results = (Map<String, Object>) 
//         JSON.deserializeUntyped(result.getBody());
//     List<Object> animals = (List<Object>) results.get('animals');
//     System.assertEquals(3, animals.size(),
//         'The array should only contain 3 items.');          
// }
}