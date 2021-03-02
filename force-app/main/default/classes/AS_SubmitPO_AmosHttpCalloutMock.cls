/******************************************************************************************
  * File Name   : AS_SubmitPO_AmosHttpCalloutMock
  * Created Date: 16th December 2020
  * Description : HttpCalloutMock class for AfterSales_ProductRequest_RestAPITest.cls. AS_SubmitPO_AmosHttpCalloutMock is required for GD-1391 ( Integration: submit purchase order ). It allows to mock receiving endpoint for testing REST send calls to AMOS.
  * Author      : Konrad Maluszkiewicz
  * Modification Log
  * =======================================================================
  * Ver     Date             Author                      Modification
  * =======================================================================
  * 1.0     16.12.2020       Konrad Maluszkiewicz        Creation
  ****************************************************************************************/

@isTest
global class AS_SubmitPO_AmosHttpCalloutMock implements HttpCalloutMock {
    private static final String RESPONSE_BODY = '{"status":"OK"}';
    private static final String RESPONSE_HEADER_PARAM_NAME  = 'Content-Type';
    public static final String RESPONSE_HEADER_CONTENT_TYPE = 'application/json';

    global HTTPResponse respond(HttpRequest req) {
        HttpResponse httpResp = new HttpResponse();
        httpResp.setHeader(RESPONSE_HEADER_PARAM_NAME, RESPONSE_HEADER_CONTENT_TYPE);
        httpResp.setBody(RESPONSE_BODY);
        httpResp.setStatusCode(200);
        return httpResp;
    }
}