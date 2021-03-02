@RestResource(urlMapping = '/CXP_AMOS_PartsInventory/*')
global with sharing class CXP_Amos_Parts_InventoryAPI {
    @HttpPut
    global static void upsertPartsProduct() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Boolean isError = false;
        String errorMsg = '';
        List<Product2> recordsToUpsert = new List<Product2> ();
       Schema.SObjectField externalId = Product2.Fields.AMOS_Part_Mast_ExternalKey__c;
        Id laborRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Part').getRecordTypeId();

        String jsonString = null;
        if (req.requestBody != null) {
            jsonString = req.requestBody.toString();
        }
        System.debug('jsonString ============================> ' + jsonString);         
        
      
        CXP_Amos_Parts_InventoryAPIWrapper wrapperList = (CXP_Amos_Parts_InventoryAPIWrapper) System.JSON.deserialize(jsonString, CXP_Amos_Parts_InventoryAPIWrapper.class);
        CXP_Amos_Parts_InventoryAPIWrapper.response responseInstance = new CXP_Amos_Parts_InventoryAPIWrapper.response(wrapperList.request.header.ifTrackingId);
        
        Set<String> ExternalKeySet = new Set<String> ();
        if (!wrapperList.request.payload.T_DATA.isEmpty()) {
            for (CXP_Amos_Parts_InventoryAPIWrapper.T_DATA wrapper : wrapperList.request.payload.T_DATA) {
                String ExternalKey;
                if (String.isNotBlank(wrapper.AMOSCompanyKindCode) || String.isNotBlank(wrapper.AMOSProductCode)) {
                    ExternalKey = wrapper.AMOSCompanyKindCode + wrapper.AMOSProductCode;
                }
 
                if (ExternalKey == null) {
                    responseInstance.response.payload.ResultCode = 'Z';
                    responseInstance.response.payload.ErrorMsg = '';
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
                    if (String.isNotBlank(wrapper.AMOSPartName)) prod.AMOSPartName__c = wrapper.AMOSPartName;
                    if (String.isNotBlank(wrapper.AMOSNewPartNo)) prod.AMOSProductCodeNew__c = wrapper.AMOSNewPartNo;
                    if (String.isNotBlank(wrapper.AMOSOldPartNo)) prod.AMOSProductCodeOld__c = wrapper.AMOSOldPartNo;
                    if (String.isNotBlank(wrapper.AMOSProductType)) prod.AMOSProductType_c__c = wrapper.AMOSProductType;
                    //if (String.isNotBlank(wrapper.AMOSPDC)) prod.AMOSPDC__c = wrapper.AMOSPDC;
                    //if (String.isNotBlank(wrapper.AMOSZone)) prod.AMOSZone__c = wrapper.AMOSZone;
                    //if (String.isNotBlank(wrapper.AMOSAVL_QT)) prod.AMOSAVL_QT__c = wrapper.AMOSQuantity;
                    recordsToUpsert.add(prod);
                }
            }
 
            if (!recordsToUpsert.isEmpty()) {

                List<Product2> existingProductList = [SELECT Id, Name, AMOS_Part_Mast_ExternalKey__c FROM Product2 WHERE AMOS_Part_Mast_ExternalKey__c IN :ExternalKeySet];
                Map<String, Product2> existingProductMapByExternalKey = new Map<String, Product2> ();
                for (Product2 pItem : existingProductList) {
                    existingProductMapByExternalKey.put(pItem.AMOS_Part_Mast_ExternalKey__c, pItem);
                }
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
                    responseInstance.response.payload.ErrorMsg = '';
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
            responseInstance.response.payload.ErrorMsg = 'record not Inserted';
            responseInstance.response.payload.ErrorCode = ' ';
            String responseJSON = System.JSON.serialize(responseInstance, false);
            res.responsebody = blob.valueof(responseJSON);
        }
        
        
            
        
    }

}