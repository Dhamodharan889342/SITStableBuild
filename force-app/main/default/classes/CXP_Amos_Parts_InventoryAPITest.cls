@isTest
private class CXP_Amos_Parts_InventoryAPITest {

	static void createTestRecords() {
		List<Product2> listToInsert = new List<Product2> ();
		Product2 rec1 = new Product2();
		rec1.AMOSCompanyKindCode__c = 'A1';
		rec1.AMOSProductCode__c = 'P1';
		rec1.AMOSPartName__c = 'PartName';
		rec1.AMOSProductCodeNEW__c = 'PC12NEW';
		rec1.AMOSProductCodeOLD__c = 'PC12OLD';
		rec1.AMOSProductType_c__c = 'T';
		
		rec1.AMOS_Part_Mast_ExternalKey__c = rec1.AMOSCompanyKindCode__c + rec1.AMOSProductCode__c;
		rec1.Name = 'Prod1';
		rec1.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Part').getRecordTypeId();
		listToInsert.add(rec1);

		Product2 rec2 = new Product2();
		rec2.AMOSCompanyKindCode__c = 'A2';
		rec2.AMOSProductCode__c = 'P2';
		rec2.AMOSPartNameNative__c = 'NativePartName';
		rec2.AMOSPartName__c = 'PartName';
		rec2.AMOSProductCodeNEW__c = 'PC12NEW';
		rec2.AMOSProductCodeOLD__c = 'PC12OLD';
		rec2.AMOSProductType_c__c = 'T';
		
		rec2.AMOS_Part_Mast_ExternalKey__c = rec2.AMOSCompanyKindCode__c + rec2.AMOSProductCode__c;
		rec2.Name = 'Prod1';
		rec2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Part').getRecordTypeId();
		listToInsert.add(rec2);

		insert listToInsert;
	}

	@isTest
	static void insertRecords() {

		CXP_Amos_Parts_InventoryAPIWrapper.Header head = new CXP_Amos_Parts_InventoryAPIWrapper.Header();

		List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> tdataList = new List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> ();
		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();
		tdata.AMOSCompanyKindCode = 'ABC123';
		tdata.AMOSProductCode = 'PC12';
		tdata.AMOSPartName = 'PartName';
		tdata.AMOSNewPartNo = 'PC12NEW';
		tdata.AMOSOldPartNo = 'PC12OLD';
		tdata.AMOSProductType = 'T';
		tdataList.add(tdata);
		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata1 = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();
		tdata1.AMOSCompanyKindCode = 'ABC123';
		tdata1.AMOSProductCode = 'AC12';
		tdata1.AMOSPartName = 'PartName';
		tdata1.AMOSNewPartNo = 'PC12NEW';
		tdata1.AMOSOldPartNo = 'PC12OLD';
		tdata1.AMOSProductType = 'T';
		
		tdataList.add(tdata1);

		CXP_Amos_Parts_InventoryAPIWrapper.Payload payload = new CXP_Amos_Parts_InventoryAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_Amos_Parts_InventoryAPIWrapper.Request request = new CXP_Amos_Parts_InventoryAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_Amos_Parts_InventoryAPIWrapper wrap = new CXP_Amos_Parts_InventoryAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsInventory';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_Amos_Parts_InventoryAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(2, recordsList.size());
		System.assertEquals(200, res.statusCode);
	}

	@isTest
	static void updateRecords() {
		createTestRecords();
		CXP_Amos_Parts_InventoryAPIWrapper.Header head = new CXP_Amos_Parts_InventoryAPIWrapper.Header();

		List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> tdataList = new List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> ();
		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();
		tdata.AMOSCompanyKindCode = 'A1';
		tdata.AMOSProductCode = 'P1';
		tdata.AMOSPartName = 'PartName';
		tdata.AMOSNewPartNo = 'PC12NEW';
		tdata.AMOSOldPartNo = 'PC12OLD';
		tdata.AMOSProductType = 'T';
			tdataList.add(tdata);

		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata1 = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();
		tdata1.AMOSCompanyKindCode = 'A2';
		tdata1.AMOSProductCode = 'P2';
		tdata1.AMOSPartName = 'PartName';
		tdata1.AMOSNewPartNo = 'PC12NEW';
		tdata1.AMOSOldPartNo = 'PC12OLD';
		tdata1.AMOSProductType = 'T';
		tdataList.add(tdata1);

		CXP_Amos_Parts_InventoryAPIWrapper.Payload payload = new CXP_Amos_Parts_InventoryAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_Amos_Parts_InventoryAPIWrapper.Request request = new CXP_Amos_Parts_InventoryAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_Amos_Parts_InventoryAPIWrapper wrap = new CXP_Amos_Parts_InventoryAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsInventory';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_Amos_Parts_InventoryAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(2, recordsList.size());
		System.assertEquals(200, res.statusCode);
	}

	@isTest
	static void upsertRecords() {
		createTestRecords();
		CXP_Amos_Parts_InventoryAPIWrapper.Header head = new CXP_Amos_Parts_InventoryAPIWrapper.Header();

		List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> tdataList = new List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> ();
		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();
		tdata.AMOSCompanyKindCode = 'A1';
		tdata.AMOSProductCode = 'P1';
		tdata.AMOSPartName = 'PartName';
		tdata.AMOSNewPartNo = 'PC12NEW';
		tdata.AMOSOldPartNo = 'PC12OLD';
		tdata.AMOSProductType = 'T';
		tdataList.add(tdata);

		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata1 = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();
		tdata1.AMOSCompanyKindCode = 'ABC123';
		tdata1.AMOSProductCode = 'AC12';
		tdata1.AMOSPartName = 'PartName';
		tdata1.AMOSNewPartNo = 'PC12NEW';
		tdata1.AMOSOldPartNo = 'PC12OLD';
		tdata1.AMOSProductType = 'T';
		tdataList.add(tdata1);

		CXP_Amos_Parts_InventoryAPIWrapper.Payload payload = new CXP_Amos_Parts_InventoryAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_Amos_Parts_InventoryAPIWrapper.Request request = new CXP_Amos_Parts_InventoryAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_Amos_Parts_InventoryAPIWrapper wrap = new CXP_Amos_Parts_InventoryAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsInventory';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_Amos_Parts_InventoryAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(3, recordsList.size());
		System.assertEquals(200, res.statusCode);
	}

	@isTest
	static void upsertEmptyData() {

		CXP_Amos_Parts_InventoryAPIWrapper.Header head = new CXP_Amos_Parts_InventoryAPIWrapper.Header();

		List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> tdataList = new List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> ();
		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();
		tdataList.add(tdata);

		CXP_Amos_Parts_InventoryAPIWrapper.Payload payload = new CXP_Amos_Parts_InventoryAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_Amos_Parts_InventoryAPIWrapper.Request request = new CXP_Amos_Parts_InventoryAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_Amos_Parts_InventoryAPIWrapper wrap = new CXP_Amos_Parts_InventoryAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsInventory';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_Amos_Parts_InventoryAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(0, recordsList.size());
	}

	@isTest
	static void upsertNullData() {

		CXP_Amos_Parts_InventoryAPIWrapper.Header head = new CXP_Amos_Parts_InventoryAPIWrapper.Header();

		List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> tdataList = new List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> ();
		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();

		CXP_Amos_Parts_InventoryAPIWrapper.Payload payload = new CXP_Amos_Parts_InventoryAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_Amos_Parts_InventoryAPIWrapper.Request request = new CXP_Amos_Parts_InventoryAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_Amos_Parts_InventoryAPIWrapper wrap = new CXP_Amos_Parts_InventoryAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsInventory';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_Amos_Parts_InventoryAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(0, recordsList.size());
	}

	@isTest
	static void upsertException() {

		CXP_Amos_Parts_InventoryAPIWrapper.Header head = new CXP_Amos_Parts_InventoryAPIWrapper.Header();

		List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> tdataList = new List<CXP_Amos_Parts_InventoryAPIWrapper.T_DATA> ();
		CXP_Amos_Parts_InventoryAPIWrapper.T_DATA tdata = new CXP_Amos_Parts_InventoryAPIWrapper.T_DATA();
		tdata.AMOSCompanyKindCode = 'ABC123';
		tdata.AMOSProductCode = 'PC12';
		tdata.AMOSPartName = 'PartName';
		tdata.AMOSNewPartNo = 'PC12NEW';
		tdata.AMOSOldPartNo = 'PC12OLD';
		tdata.AMOSProductType = 'T1';// Wrong field
		tdataList.add(tdata);

		CXP_Amos_Parts_InventoryAPIWrapper.Payload payload = new CXP_Amos_Parts_InventoryAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_Amos_Parts_InventoryAPIWrapper.Request request = new CXP_Amos_Parts_InventoryAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_Amos_Parts_InventoryAPIWrapper wrap = new CXP_Amos_Parts_InventoryAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsInventory';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_Amos_Parts_InventoryAPI.upsertPartsProduct();
		Test.stopTest();

		System.assertEquals(400, res.statusCode);
	
}

}