/**
 * @author Daniel Varhidi
 * @createdDate 08/01/2021 
 * @description 
*/
@RestResource(urlMapping = '/CXP_AMOS_PartsMaster_Btch/*')
global with sharing class CXP_AMOS_Parts_MastAPI {

    @HttpPut
    global static void upsertPartsProduct() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Product2> recordsToUpsert = new List<Product2> ();
        Schema.SObjectField externalId = Product2.Fields.AMOS_Part_Mast_ExternalKey__c;
        Id laborRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Part').getRecordTypeId();

        String jsonString = null;
        if (req.requestBody != null) {
            jsonString = req.requestBody.toString();
        }
        //System.debug('jsonString ============================> ' + jsonString);                                                                                 

        CXP_AMOS_Parts_MastAPIWrapper wrapperList = (CXP_AMOS_Parts_MastAPIWrapper) System.JSON.deserialize(jsonString, CXP_AMOS_Parts_MastAPIWrapper.class);
        //System.debug('CXP_LTS_Labor_MastAPI > upsertLaborProduct > wrapperList.request.payload.T_DATA: ' + wrapperList.request.payload.T_DATA);        
        CXP_AMOS_Parts_MastAPIWrapper.response responseInstance = new CXP_AMOS_Parts_MastAPIWrapper.response(wrapperList.request.header.ifTrackingId);


        Set<String> ExternalKeySet = new Set<String> ();
        if (!wrapperList.request.payload.T_DATA.isEmpty()) {
            for (CXP_AMOS_Parts_MastAPIWrapper.T_DATA wrapper : wrapperList.request.payload.T_DATA) {

                String ExternalKey;
                if (String.isNotBlank(wrapper.AMOSCompanyKindCode) || String.isNotBlank(wrapper.AMOSProductCode)) {
                    ExternalKey = wrapper.AMOSCompanyKindCode + wrapper.AMOSProductCode;
                }
                //System.debug('External Id to check for Upsert ==============>' + ExternalKey);                

                if (ExternalKey == null) {
                    responseInstance.response.payload.ResultCode = 'Z';
                    responseInstance.response.payload.ErrorMsg = ' ';
                    responseInstance.response.payload.ErrorCode = ' ';
                    String responseJSON = System.JSON.serialize(responseInstance, false);
                    res.responsebody = blob.valueof(responseJSON);
                } else {
                    Product2 prod = new Product2();
                    prod.RecordTypeId = laborRecordTypeId;
                    prod.AMOS_Part_Mast_ExternalKey__c = ExternalKey;
                    ExternalKeySet.add(ExternalKey);
                    if (String.isNotBlank(wrapper.AMOSCompanyKindCode)) prod.AMOSCompanyKindCode__c = wrapper.AMOSCompanyKindCode;
                    if (String.isNotBlank(wrapper.AMOSProductCode)) prod.AMOSProductCode__c = wrapper.AMOSProductCode;
                    if (String.isNotBlank(wrapper.AMOSPartNameNative)) prod.AMOSPartNameNative__c = wrapper.AMOSPartNameNative;
                    if (String.isNotBlank(wrapper.AMOSPartName)) prod.AMOSPartName__c = wrapper.AMOSPartName;
                    if (String.isNotBlank(wrapper.AMOSProductCodeNEW)) prod.AMOSProductCodeNew__c = wrapper.AMOSProductCodeNEW;
                    if (String.isNotBlank(wrapper.AMOSProductCodeOLD)) prod.AMOSProductCodeOld__c = wrapper.AMOSProductCodeOLD;
                    if (String.isNotBlank(wrapper.ProductType)) prod.AMOSProductType_c__c = wrapper.ProductType;
                    if (String.isNotBlank(wrapper.AMOSDisposableClass)) prod.AMOSDisposableClass__c = wrapper.AMOSDisposableClass;
                    if (String.isNotBlank(wrapper.AMOSQuantity)) prod.AMOSQuantity__c = Double.valueOf(wrapper.AMOSQuantity);
                    if (String.isNotBlank(wrapper.AMOSDimensionalMeasurement)) prod.AMOSDimensionalMeasurement__c = wrapper.AMOSDimensionalMeasurement;
                    if (String.isNotBlank(wrapper.AMOSWeightMeasurement)) prod.AMOSWeightMeasurement__c = wrapper.AMOSWeightMeasurement;
                    if (String.isNotBlank(wrapper.Width)) prod.AMOSWidth__c = wrapper.Width;
                    if (String.isNotBlank(wrapper.Length)) prod.AMOSLength__c = wrapper.Length;
                    if (String.isNotBlank(wrapper.Height)) prod.AMOSHeight__c = wrapper.Height;
                    if (String.isNotBlank(wrapper.Weight)) prod.AMOSWeight__c = wrapper.Weight;
                    if (String.isNotBlank(wrapper.CurrencyIsoCode)) prod.CurrencyIsoCode = wrapper.CurrencyIsoCode;
                    if (String.isNotBlank(wrapper.ProductPriceRetail)) prod.AMOSPriceRetail__c = Double.valueOf(wrapper.ProductPriceRetail);
                    if (String.isNotBlank(wrapper.ProductPriceBasic)) prod.AMOSPriceBasic__c = Double.valueOf(wrapper.ProductPriceBasic);
                    if (String.isNotBlank(wrapper.ProductPriceMSRP)) prod.AMOSPriceMSRP__c = Double.valueOf(wrapper.ProductPriceMSRP);
                    if (String.isNotBlank(wrapper.ProductDealerPriceVOR)) prod.AMOSDealerPriceVOR__c = Double.valueOf(wrapper.ProductDealerPriceVOR);
                    if (String.isNotBlank(wrapper.ProductDealerPriceDLY)) prod.AMOSDealerPriceDLY__c = Double.valueOf(wrapper.ProductDealerPriceDLY);
                    if (String.isNotBlank(wrapper.ProductDealerPriceStk)) prod.AMOSDealerPriceStk__c = Double.valueOf(wrapper.ProductDealerPriceStk);
                    if (String.isNotBlank(wrapper.AMOSDiscountGroup)) prod.AMOSDiscountGroup__c = wrapper.AMOSDiscountGroup;
                    if (String.isNotBlank(wrapper.ProductDiscountRateVOR)) prod.AMOSDiscountRateVOR__c = Double.valueOf(wrapper.ProductDiscountRateVOR);
                    if (String.isNotBlank(wrapper.ProductDiscountRateDLY)) prod.AMOSDiscountRateDLY__c = Double.valueOf(wrapper.ProductDiscountRateDLY);
                    if (String.isNotBlank(wrapper.ProductDiscountRateSTK)) prod.AMOSDiscountRateSTK__c = Double.valueOf(wrapper.ProductDiscountRateSTK);
                    recordsToUpsert.add(prod);
                }
            }
            //System.debug('Number of records in the list ' + recordsToUpsert.size());                        

            if (!recordsToUpsert.isEmpty()) {

                //Check the existing records
                List<Product2> existingProductList = [SELECT Id, Name, AMOS_Part_Mast_ExternalKey__c FROM Product2 WHERE AMOS_Part_Mast_ExternalKey__c IN :ExternalKeySet];
                //Create a Map from the List
                Map<String, Product2> existingProductMapByExternalKey = new Map<String, Product2> ();
                for (Product2 pItem : existingProductList) {
                    existingProductMapByExternalKey.put(pItem.AMOS_Part_Mast_ExternalKey__c, pItem);
                }
                //Configure the new Product record
                for (Product2 pItem : recordsToUpsert) {
                    if (!existingProductMapByExternalKey.containsKey(pItem.AMOS_Part_Mast_ExternalKey__c)) {
                        pItem.Name = pItem.AMOSPartName__c;
                    } 
                }

                try {
                    //upsert recordsToUpsert AMOS_Part_Mast_ExternalKey__c;
                    Database.upsert(recordsToUpsert, externalId, true);
                    res.statusCode = 200;
                    responseInstance.response.payload.ResultCode = 'Z';
                    responseInstance.response.payload.ErrorMsg = ' ';
                    responseInstance.response.payload.ErrorCode = ' ';
                    String responseJSON = System.JSON.serialize(responseInstance, false);
                    res.responsebody = blob.valueof(responseJSON);
                }
                catch(Exception e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    res.statusCode = 400;
                    responseInstance.response.payload.ResultCode = 'E';
                    responseInstance.response.payload.ErrorMsg = e.getMessage();
                    responseInstance.response.payload.ErrorCode = ' ';
                    //responseInstance.payload.ErrorMsg = 'The payload contains duplicate values with the same external Id';
                    String responseJSON = System.JSON.serialize(responseInstance, false);
                    res.responsebody = blob.valueof(responseJSON);
                }
            }
        } else {
            responseInstance.response.payload.ResultCode = 'Z';
            responseInstance.response.payload.ErrorMsg = ' ';
            responseInstance.response.payload.ErrorCode = ' ';
            String responseJSON = System.JSON.serialize(responseInstance, false);
            res.responsebody = blob.valueof(responseJSON);
        }
    }
}