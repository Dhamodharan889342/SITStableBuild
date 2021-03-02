/**
 * @author Daniel Varhidi
 * @createdDate 06/01/2021 
 * @JIRA GD-1326
 * @description 
*/
@RestResource(urlMapping = '/CXP_LTS_Labor_Mast/*')
global with sharing class CXP_LTS_Labor_MastAPI {

	@HttpPut
	global static void upsertLaborProduct() {

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		List<Product2> recordsToUpsert = new List<Product2> ();
		Schema.SObjectField externalId = Product2.Fields.LTS_Labor_Mast_ExternalKey__c;
		Id laborRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Labor').getRecordTypeId();

		String jsonString = null;
		if (req.requestBody != null) {
			jsonString = req.requestBody.toString();
		}
		//System.debug('jsonString ============================> ' + jsonString);                            		                                              

		CXP_LTS_Labor_MastAPIWrapper wrapperList = (CXP_LTS_Labor_MastAPIWrapper) System.JSON.deserialize(jsonString, CXP_LTS_Labor_MastAPIWrapper.class);
		//System.debug('CXP_LTS_Labor_MastAPI > upsertLaborProduct > wrapperList.request.payload.T_DATA: ' + wrapperList.request.payload.T_DATA);        
		CXP_LTS_Labor_MastAPIWrapper.response responseInstance = new CXP_LTS_Labor_MastAPIWrapper.response(wrapperList.request.header.ifTrackingId);


		Set<String> ExternalKeySet = new Set<String> ();
		if (!wrapperList.request.payload.T_DATA.isEmpty()) {
			for (CXP_LTS_Labor_MastAPIWrapper.T_DATA wrapper : wrapperList.request.payload.T_DATA) {

				String ExternalKey;
				if (String.isNotBlank(wrapper.LTSWorkCode) || String.isNotBlank(wrapper.LTSEnglishWorkName)) {
					ExternalKey = wrapper.LTSWorkCode + wrapper.LTSEnglishWorkName;
				}
				//System.debug('External Id to check for Upsert ==============>' + ExternalKey);                

				if (ExternalKey == null) {
					responseInstance.response.payload.ResultCode = 'S';
					responseInstance.response.payload.ErrorMsg = ' ';
					responseInstance.response.payload.ErrorCode = ' ';
					String responseJSON = System.JSON.serialize(responseInstance, false);
					res.responsebody = blob.valueof(responseJSON);
				} else {
					Product2 prod = new Product2();
					prod.RecordTypeId = laborRecordTypeId;
					prod.LTS_Labor_Mast_ExternalKey__c = ExternalKey;
					ExternalKeySet.add(ExternalKey);
					if (String.isNotBlank(wrapper.LTSCompanyKindCode)) prod.LTSCompanyKindCode__c = wrapper.LTSCompanyKindCode;
					if (String.isNotBlank(wrapper.LTSCarModelCode)) prod.LTSCarModelCode__c = wrapper.LTSCarModelCode;
					if (String.isNotBlank(wrapper.LTSMainGroup)) prod.LTSMainGroup__c = wrapper.LTSMainGroup;
					if (String.isNotBlank(wrapper.LTSSubGroup)) prod.LTSSubGroup__c = wrapper.LTSSubGroup;
					if (String.isNotBlank(wrapper.LTSWorkCode)) prod.LTSWorkCode__c = wrapper.LTSWorkCode;
					if (String.isNotBlank(wrapper.LTSIntegration)) prod.LTSIntegration__c = wrapper.LTSIntegration;
					if (String.isNotBlank(wrapper.LTSKoreanWorkName)) prod.LTSLaborNativeWorkName__c = wrapper.LTSKoreanWorkName;
					if (String.isNotBlank(wrapper.LTSEnglishWorkName)) prod.LTSEnglishWorkName__c = wrapper.LTSEnglishWorkName;
					if (String.isNotBlank(wrapper.LTSSPNCCode)) prod.LTSSPNCCode__c = wrapper.LTSSPNCCode;
					if (String.isNotBlank(wrapper.LTSRepairCategoryCode)) prod.LTSRepairCategoryCode__c = wrapper.LTSRepairCategoryCode;
					if (String.isNotBlank(wrapper.LTSTaskCodeEndTwoDigits)) prod.LTSTaskCodeEndTwoDigits__c = wrapper.LTSTaskCodeEndTwoDigits;
					if (String.isNotBlank(wrapper.LTSMessageID)) prod.LTSMessageID__c = wrapper.LTSMessageID;
					if (String.isNotBlank(wrapper.LTSRelatedWorkDetails)) prod.LTSRelatedWorkDetails__c = wrapper.LTSRelatedWorkDetails;
					if (String.isNotBlank(wrapper.LTSWhetherToDelete)) prod.LTSWhetherToDelete__c = wrapper.LTSWhetherToDelete;
					if (String.isNotBlank(wrapper.LTSFinalModifier)) prod.LTSFinalModifier__c = wrapper.LTSFinalModifier;
					if (String.isNotBlank(wrapper.LTSLastModifiedDate)) prod.LTSLastModifiedDate__c = wrapper.LTSLastModifiedDate;
					if (String.isNotBlank(wrapper.LTSFirstRegistrant)) prod.LTSFirstRegistrant__c = wrapper.LTSFirstRegistrant;
					if (String.isNotBlank(wrapper.LTSFirstRegistrationDate)) prod.LTSFirstRegistrationDate__c = wrapper.LTSFirstRegistrationDate;
					recordsToUpsert.add(prod);
				}
			}
			//System.debug('Number of records in the list ' + recordsToUpsert.size());                        

			if (!recordsToUpsert.isEmpty()) {

				//Check the existing records
				List<Product2> existingProductList = [SELECT Id, Name, LTS_Labor_Mast_ExternalKey__c FROM Product2 WHERE LTS_Labor_Mast_ExternalKey__c IN :ExternalKeySet];
				//Create a Map from the List
				Map<String, Product2> existingProductMapByExternalKey = new Map<String, Product2> ();
				for (Product2 pItem : existingProductList) {
					existingProductMapByExternalKey.put(pItem.LTS_Labor_Mast_ExternalKey__c, pItem);
				}
				//Configure the new Product record
				for (Product2 pItem : recordsToUpsert) {
					if (!existingProductMapByExternalKey.containsKey(pItem.LTS_Labor_Mast_ExternalKey__c)) {
						pItem.Name = pItem.LTSEnglishWorkName__c;
						//Currency - Default value is EUR
					} 
				}

				try {
					//upsert recordsToUpsert LTS_Labor_Mast_ExternalKey__c;
					Database.upsert(recordsToUpsert, externalId, true);
					res.statusCode = 200;
					responseInstance.response.payload.ResultCode = 'S';
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
			responseInstance.response.payload.ResultCode = 'S';
			responseInstance.response.payload.ErrorMsg = ' ';
			responseInstance.response.payload.ErrorCode = ' ';
			String responseJSON = System.JSON.serialize(responseInstance, false);
			res.responsebody = blob.valueof(responseJSON);
		}
	}
}