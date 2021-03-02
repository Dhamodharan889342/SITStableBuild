/******************************************************************************************
  * File Name   : AS_SubmitPO_AmosRestAPI
  * Created Date: 14th December 2020
  * Description : API required for GD-1391 ( Integration: submit purchase order ) and GD-1393 ( Integration: shipping information for purchase order ). It allows to send and recieive REST calls to/from AMOS system.
  * Author      : Konrad Maluszkiewicz
  * Modification Log
  * =======================================================================
  * Ver     Date             Author                      Modification
  * =======================================================================
  * 1.0     14.12.2020       Konrad Maluszkiewicz        Creation
  ****************************************************************************************/

@RestResource(urlMapping='/ProductRequestAPI/*')
global with sharing class AS_SubmitPO_AmosRestAPI {

    @HttpPut
    global static void upsertProductRequest() {
        String productRequestJSON = RestContext.request.requestBody.toString();
        System.debug('RestContext.request.requestBody = ' + productRequestJSON);

        ProductRequest prodRequest = jSON2ProductRequestWrapper(productRequestJSON);

        System.debug('prodRequest.ExternalIdCXP__c = ' + prodRequest.ExternalIdCXP__c);
        System.debug('prodRequest.ShipMode__c = ' + prodRequest.ShipMode__c);
        System.debug('prodRequest.Status = ' + prodRequest.Status);
        System.debug('prodRequest.ShipmentType = ' + prodRequest.ShipmentType);

        upsert prodRequest ExternalIdCXP__c;

// ProductRequest.ShipToAddress # ShipToAddress
// ProductRequest.ShipmentType # ShipmentType

        // tmp fields to include in wrapper (all fields of ProductRequest related to shipping):
        // ProductRequest.ExternalIdCXP__c # Text(255) (External ID) (Unique Case Insensitive) # __OK__
        // ProductRequest.ExternalIdDAOS__c # Text(255) (External ID) (Unique Case Insensitive)
        // ProductRequest.OrderNoCXP__c # Text(10)
        // ProductRequest.OrderType__c # Picklist
        // ProductRequest.ProductRequestNumber # Auto Number
        // ProductRequest.ru_DAOSShippedQty__c # Roll-Up Summary (SUM Product Request Line Item)
        // ProductRequest.Status # Picklist
        // ProductRequest.DAOSSubmittedDate__c # Date/Time
        // ProductRequest.TransmissionDate__c # Date/Time

        // List<Contact> contactsToUpdate = (List<Contact>) JSON.deserialize(RestContext.request.requestBody.toString(), List<Contact>.class);
        // System.debug('contactsToUpdate = ' + contactsToUpdate);
        // upsert contactsToUpdate DA_EGCID__c;
    }

    public static ProductRequest jSON2ProductRequestWrapper(String productRequestJSON) {
        return (ProductRequest)JSON.deserialize(productRequestJSON, ProductRequest.class);
    }

    public static ProductRequest getProductRequestForAMOSCallout(Id productRequestId) {
        ProductRequest prodRequest = [
            SELECT Id, CreatedDate, OrderNoCXP__c, OrderType__c, ShipMode__c, Description, Department__r.SalesCompanyCode__c, Department__r.Department_Code__c, (SELECT OrderLineNoCXP__c, OrderedPartNo__c, QuantityUnitOfMeasure FROM ProductRequestLineItems)
            FROM ProductRequest
            WHERE Id = :productRequestId
        ];

        // System.debug('prodRequest = ' + prodRequest);
        return prodRequest;
    }

    // @future(callout=true)
    public static HttpResponse sendProdReqToAMOS(Id productRequestId) {
        String authKey = 'Bearer Z2VuZXNpc2RpaDppbXNpITEyMzQ=';
        String reqBody = generateAmosProdReqCalloutBody(productRequestId);
        // String endpoint = 'http://exampleendpoint:7071/services/receive';
        String endpoint = 'http://10.115.192.157:7071/services/receive';

        Http mainHttp = new Http();
        HttpRequest httpReq = new HttpRequest();

        httpReq.setHeader('Authorization', authKey);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('ifId','IF_GME_CXP_DAOS_0001');
        httpReq.setHeader('ifSenderGp','EU');
        httpReq.setHeader('ifSender','CXP');
        httpReq.setHeader('ifReceiverGp','GME');
        httpReq.setHeader('ifReceiver','AMOS');
        httpReq.setHeader('ifTrackingId',String.valueOf(productRequestId));
        httpReq.setHeader('ifDateTime',System.now().format('yyyyMMddkkmmss'));
        httpReq.setBody(reqBody);
        httpReq.setMethod('PUT');
        httpReq.setEndpoint(endpoint);

        System.debug('httpReq = ' + httpReq);

        HttpResponse httpResp = mainHttp.send(httpReq);
        System.debug('httpReq.getHeader(\'ifId\') = ' + httpReq.getHeader('ifId'));
        System.debug('httpReq.getHeader(\'ifSenderGp\') = ' + httpReq.getHeader('ifSenderGp'));
        System.debug('httpReq.getHeader(\'ifSender\') = ' + httpReq.getHeader('ifSender'));
        System.debug('httpReq.getHeader(\'ifReceiverGp\') = ' + httpReq.getHeader('ifReceiverGp'));
        System.debug('httpReq.getHeader(\'ifReceiver\') = ' + httpReq.getHeader('ifReceiver'));
        System.debug('httpReq.getHeader(\'ifTrackingId\') = ' + httpReq.getHeader('ifTrackingId'));
        System.debug('httpReq.getHeader(\'ifDateTime\') = ' + httpReq.getHeader('ifDateTime'));
        return httpResp;
    }

    public static String generateAmosProdReqCalloutBody(Id productRequestId) {
        ProductRequest prodRequest = getProductRequestForAMOSCallout(productRequestId);
        JSONGenerator jSONMainGenerator = JSON.createGenerator(true);

        jSONMainGenerator.writeStartObject();

        if (prodRequest.Department__r == null) {
            jSONMainGenerator.writeStringField('SalesCompanyCode', '');
            jSONMainGenerator.writeStringField('DepartmentCode', '');
        } else {
            jSONMainGenerator.writeStringField('SalesCompanyCode', prodRequest.Department__r.SalesCompanyCode__c != null ? prodRequest.Department__r.SalesCompanyCode__c : '');
            jSONMainGenerator.writeStringField('DepartmentCode', prodRequest.Department__r.Department_Code__c != null ? prodRequest.Department__r.Department_Code__c : '');
        }

        jSONMainGenerator.writeStringField('OrderNoCXP', prodRequest.OrderNoCXP__c != null ? prodRequest.OrderNoCXP__c : '');
        jSONMainGenerator.writeStringField('OrderType', prodRequest.OrderType__c != null ? prodRequest.OrderType__c : '');
        jSONMainGenerator.writeStringField('OrderDate', prodRequest.CreatedDate.format('yyyyMMdd'));
        jSONMainGenerator.writeStringField('ShipMode', prodRequest.ShipMode__c != null ? prodRequest.ShipMode__c : '');
        jSONMainGenerator.writeStringField('Description', prodRequest.Description != null ? prodRequest.Description : '');
        jSONMainGenerator.writeStringField('CreationDate', prodRequest.CreatedDate.format('yyyyMMdd'));
        jSONMainGenerator.writeStringField('CreationTime', prodRequest.CreatedDate.format('kkmmss'));
        jSONMainGenerator.writeStringField('SendDate', System.now().format('yyyyMMdd'));
        jSONMainGenerator.writeStringField('SendTime', System.now().format('kkmmss'));

        jSONMainGenerator.writeFieldName('ProductRequestLineItems');
        jSONMainGenerator.writeStartArray();

        for (ProductRequestLineItem prodReqLineItem : prodRequest.ProductRequestLineItems) {
            jSONMainGenerator.writeStartObject();

            jSONMainGenerator.writeStringField('OrderLineNoCXP', prodReqLineItem.OrderLineNoCXP__c != null ? prodReqLineItem.OrderLineNoCXP__c : '');
            jSONMainGenerator.writeStringField('OrderedPartNo', (prodReqLineItem.OrderedPartNo__c != null ? prodReqLineItem.OrderedPartNo__c : ''));
            jSONMainGenerator.writeStringField('QuantityUnitOfMeasure', (prodReqLineItem.QuantityUnitOfMeasure != null ? prodReqLineItem.QuantityUnitOfMeasure : ''));

            jSONMainGenerator.writeEndObject();
        }

        jSONMainGenerator.writeEndArray();
        jSONMainGenerator.writeEndObject();

        System.debug('jSONMainGenerator.getAsString() = ' + jSONMainGenerator.getAsString());
        return jSONMainGenerator.getAsString();
    }
}