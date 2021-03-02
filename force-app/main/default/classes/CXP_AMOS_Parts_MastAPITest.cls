@isTest
private class CXP_AMOS_Parts_MastAPITest {

	static void createTestRecords() {
		List<Product2> listToInsert = new List<Product2> ();
		Product2 rec1 = new Product2();
		rec1.AMOSCompanyKindCode__c = 'A1';
		rec1.AMOSProductCode__c = 'P1';
		rec1.AMOSPartNameNative__c = 'NativePartName';
		rec1.AMOSPartName__c = 'PartName';
		rec1.AMOSProductCodeNEW__c = 'PC12NEW';
		rec1.AMOSProductCodeOLD__c = 'PC12OLD';
		rec1.AMOSProductType_c__c = 'T';
		rec1.AMOSDisposableClass__c = 'T';
		rec1.AMOSQuantity__c = 14.2;
		rec1.AMOSDimensionalMeasurement__c = 'DMes';
		rec1.AMOSWeightMeasurement__c = 'WMes';
		rec1.AMOSWidth__c = 'A12';
		rec1.AMOSLength__c = 'A24';
		rec1.AMOSHeight__c = 'A6';
		rec1.AMOSWeight__c = 'A25';
		rec1.AMOSPriceRetail__c = 125.78;
		rec1.AMOSPriceBasic__c = 130.85;
		rec1.AMOSPriceMSRP__c = 147;
		rec1.AMOSDealerPriceVOR__c = 180.25;
		rec1.AMOSDealerPriceDLY__c = 190.65;
		rec1.AMOSDealerPriceStk__c = 143.53;
		rec1.AMOSDiscountGroup__c = 'GH';
		rec1.AMOSDiscountRateVOR__c = 10.2;
		rec1.AMOSDiscountRateDLY__c = 8.6;
		rec1.AMOSDiscountRateSTK__c = 4.9;

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
		rec2.AMOSDisposableClass__c = 'T';
		rec2.AMOSQuantity__c = 14.2;
		rec2.AMOSDimensionalMeasurement__c = 'DMes';
		rec2.AMOSWeightMeasurement__c = 'WMes';
		rec2.AMOSWidth__c = 'A12';
		rec2.AMOSLength__c = 'A24';
		rec2.AMOSHeight__c = 'A6';
		rec2.AMOSWeight__c = 'A25';
		rec2.AMOSPriceRetail__c = 125.78;
		rec2.AMOSPriceBasic__c = 130.85;
		rec2.AMOSPriceMSRP__c = 147.87;
		rec2.AMOSDealerPriceVOR__c = 180.25;
		rec2.AMOSDealerPriceDLY__c = 190.65;
		rec2.AMOSDealerPriceStk__c = 143.53;
		rec2.AMOSDiscountGroup__c = 'GH';
		rec2.AMOSDiscountRateVOR__c = 10.2;
		rec2.AMOSDiscountRateDLY__c = 8.6;
		rec2.AMOSDiscountRateSTK__c = 4.9;

		rec2.AMOS_Part_Mast_ExternalKey__c = rec2.AMOSCompanyKindCode__c + rec2.AMOSProductCode__c;
		rec2.Name = 'Prod1';
		rec2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Part').getRecordTypeId();
		listToInsert.add(rec2);

		insert listToInsert;
	}

	@isTest
	static void insertRecords() {

		CXP_AMOS_Parts_MastAPIWrapper.Header head = new CXP_AMOS_Parts_MastAPIWrapper.Header();

		List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> tdataList = new List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> ();
		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();
		tdata.AMOSCompanyKindCode = 'ABC123';
		tdata.AMOSProductCode = 'PC12';
		tdata.AMOSPartNameNative = 'NativePartName';
		tdata.AMOSPartName = 'PartName';
		tdata.AMOSProductCodeNEW = 'PC12NEW';
		tdata.AMOSProductCodeOLD = 'PC12OLD';
		tdata.ProductType = 'T';
		tdata.AMOSDisposableClass = 'T';
		tdata.AMOSQuantity = '14.2';
		tdata.AMOSDimensionalMeasurement = 'DMes';
		tdata.AMOSWeightMeasurement = 'WMes';
		tdata.Width = 'A12';
		tdata.Length = 'A24';
		tdata.Height = 'A6';
		tdata.Weight = 'A25';
		tdata.CurrencyIsoCode = 'CHF';
		tdata.ProductPriceRetail = '125.78';
		tdata.ProductPriceBasic = '130.85';
		tdata.ProductPriceMSRP = '147.87';
		tdata.ProductDealerPriceVOR = '180.25';
		tdata.ProductDealerPriceDLY = '190.65';
		tdata.ProductDealerPriceStk = '143.53';
		tdata.AMOSDiscountGroup = 'GH';
		tdata.ProductDiscountRateVOR = '10.2';
		tdata.ProductDiscountRateDLY = '8.6';
		tdata.ProductDiscountRateSTK = '4.9';
		tdataList.add(tdata);

		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata1 = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();
		tdata1.AMOSCompanyKindCode = 'ABC123';
		tdata1.AMOSProductCode = 'AC12';
		tdata1.AMOSPartNameNative = 'NativePartName';
		tdata1.AMOSPartName = 'PartName';
		tdata1.AMOSProductCodeNEW = 'PC12NEW';
		tdata1.AMOSProductCodeOLD = 'PC12OLD';
		tdata1.ProductType = 'T';
		tdata1.AMOSDisposableClass = 'T';
		tdata1.AMOSQuantity = '14.2';
		tdata1.AMOSDimensionalMeasurement = 'DMes';
		tdata1.AMOSWeightMeasurement = 'WMes';
		tdata1.Width = 'A12';
		tdata1.Length = 'A24';
		tdata1.Height = 'A6';
		tdata1.Weight = 'A25';
		tdata1.CurrencyIsoCode = 'CHF';
		tdata1.ProductPriceRetail = '125.78';
		tdata1.ProductPriceBasic = '130.85';
		tdata1.ProductPriceMSRP = '147.87';
		tdata1.ProductDealerPriceVOR = '180.25';
		tdata1.ProductDealerPriceDLY = '190.65';
		tdata1.ProductDealerPriceStk = '143.53';
		tdata1.AMOSDiscountGroup = 'GH';
		tdata1.ProductDiscountRateVOR = '10.2';
		tdata1.ProductDiscountRateDLY = '8.6';
		tdata1.ProductDiscountRateSTK = '4.9';
		tdataList.add(tdata1);

		CXP_AMOS_Parts_MastAPIWrapper.Payload payload = new CXP_AMOS_Parts_MastAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_AMOS_Parts_MastAPIWrapper.Request request = new CXP_AMOS_Parts_MastAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_AMOS_Parts_MastAPIWrapper wrap = new CXP_AMOS_Parts_MastAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsMaster_Btch';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_AMOS_Parts_MastAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(2, recordsList.size());
		System.assertEquals(200, res.statusCode);
	}

	@isTest
	static void updateRecords() {
		createTestRecords();
		CXP_AMOS_Parts_MastAPIWrapper.Header head = new CXP_AMOS_Parts_MastAPIWrapper.Header();

		List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> tdataList = new List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> ();
		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();
		tdata.AMOSCompanyKindCode = 'A1';
		tdata.AMOSProductCode = 'P1';
		tdata.AMOSPartNameNative = 'NewNativePartName';
		tdata.AMOSPartName = 'PartName';
		tdata.AMOSProductCodeNEW = 'PC12NEW';
		tdata.AMOSProductCodeOLD = 'PC12OLD';
		tdata.ProductType = 'T';
		tdata.AMOSDisposableClass = 'T';
		tdata.AMOSQuantity = '14.2';
		tdata.AMOSDimensionalMeasurement = 'DMes';
		tdata.AMOSWeightMeasurement = 'WMes';
		tdata.Width = 'A12';
		tdata.Length = 'A24';
		tdata.Height = 'A6';
		tdata.Weight = 'A25';
		tdata.CurrencyIsoCode = 'CHF';
		tdata.ProductPriceRetail = '125.78';
		tdata.ProductPriceBasic = '130.85';
		tdata.ProductPriceMSRP = '147.87';
		tdata.ProductDealerPriceVOR = '180.25';
		tdata.ProductDealerPriceDLY = '190.65';
		tdata.ProductDealerPriceStk = '143.53';
		tdata.AMOSDiscountGroup = 'GH';
		tdata.ProductDiscountRateVOR = '10.2';
		tdata.ProductDiscountRateDLY = '8.6';
		tdata.ProductDiscountRateSTK = '4.9';
		tdataList.add(tdata);

		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata1 = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();
		tdata1.AMOSCompanyKindCode = 'A2';
		tdata1.AMOSProductCode = 'P2';
		tdata1.AMOSPartNameNative = 'NewNativePartName';
		tdata1.AMOSPartName = 'PartName';
		tdata1.AMOSProductCodeNEW = 'PC12NEW';
		tdata1.AMOSProductCodeOLD = 'PC12OLD';
		tdata1.ProductType = 'T';
		tdata1.AMOSDisposableClass = 'T';
		tdata1.AMOSQuantity = '14.2';
		tdata1.AMOSDimensionalMeasurement = 'DMes';
		tdata1.AMOSWeightMeasurement = 'WMes';
		tdata1.Width = 'A12';
		tdata1.Length = 'A24';
		tdata1.Height = 'A6';
		tdata1.Weight = 'A25';
		tdata1.CurrencyIsoCode = 'CHF';
		tdata1.ProductPriceRetail = '125.78';
		tdata1.ProductPriceBasic = '130.85';
		tdata1.ProductPriceMSRP = '147.87';
		tdata1.ProductDealerPriceVOR = '180.25';
		tdata1.ProductDealerPriceDLY = '190.65';
		tdata1.ProductDealerPriceStk = '143.53';
		tdata1.AMOSDiscountGroup = 'GH';
		tdata1.ProductDiscountRateVOR = '10.2';
		tdata1.ProductDiscountRateDLY = '8.6';
		tdata1.ProductDiscountRateSTK = '4.9';
		tdataList.add(tdata1);

		CXP_AMOS_Parts_MastAPIWrapper.Payload payload = new CXP_AMOS_Parts_MastAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_AMOS_Parts_MastAPIWrapper.Request request = new CXP_AMOS_Parts_MastAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_AMOS_Parts_MastAPIWrapper wrap = new CXP_AMOS_Parts_MastAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsMaster_Btch';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_AMOS_Parts_MastAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(2, recordsList.size());
		System.assertEquals(200, res.statusCode);
	}

	@isTest
	static void upsertRecords() {
		createTestRecords();
		CXP_AMOS_Parts_MastAPIWrapper.Header head = new CXP_AMOS_Parts_MastAPIWrapper.Header();

		List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> tdataList = new List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> ();
		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();
		tdata.AMOSCompanyKindCode = 'A1';
		tdata.AMOSProductCode = 'P1';
		tdata.AMOSPartNameNative = 'NewNativePartName';
		tdata.AMOSPartName = 'PartName';
		tdata.AMOSProductCodeNEW = 'PC12NEW';
		tdata.AMOSProductCodeOLD = 'PC12OLD';
		tdata.ProductType = 'T';
		tdata.AMOSDisposableClass = 'T';
		tdata.AMOSQuantity = '14.2';
		tdata.AMOSDimensionalMeasurement = 'DMes';
		tdata.AMOSWeightMeasurement = 'WMes';
		tdata.Width = 'A12';
		tdata.Length = 'A24';
		tdata.Height = 'A6';
		tdata.Weight = 'A25';
		tdata.CurrencyIsoCode = 'CHF';
		tdata.ProductPriceRetail = '125.78';
		tdata.ProductPriceBasic = '130.85';
		tdata.ProductPriceMSRP = '147.87';
		tdata.ProductDealerPriceVOR = '180.25';
		tdata.ProductDealerPriceDLY = '190.65';
		tdata.ProductDealerPriceStk = '143.53';
		tdata.AMOSDiscountGroup = 'GH';
		tdata.ProductDiscountRateVOR = '10.2';
		tdata.ProductDiscountRateDLY = '8.6';
		tdata.ProductDiscountRateSTK = '4.9';
		tdataList.add(tdata);

		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata1 = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();
		tdata1.AMOSCompanyKindCode = 'ABC123';
		tdata1.AMOSProductCode = 'AC12';
		tdata1.AMOSPartNameNative = 'NativePartName';
		tdata1.AMOSPartName = 'PartName';
		tdata1.AMOSProductCodeNEW = 'PC12NEW';
		tdata1.AMOSProductCodeOLD = 'PC12OLD';
		tdata1.ProductType = 'T';
		tdata1.AMOSDisposableClass = 'T';
		tdata1.AMOSQuantity = '14.2';
		tdata1.AMOSDimensionalMeasurement = 'DMes';
		tdata1.AMOSWeightMeasurement = 'WMes';
		tdata1.Width = 'A12';
		tdata1.Length = 'A24';
		tdata1.Height = 'A6';
		tdata1.Weight = 'A25';
		tdata1.CurrencyIsoCode = 'CHF';
		tdata1.ProductPriceRetail = '125.78';
		tdata1.ProductPriceBasic = '130.85';
		tdata1.ProductPriceMSRP = '147.87';
		tdata1.ProductDealerPriceVOR = '180.25';
		tdata1.ProductDealerPriceDLY = '190.65';
		tdata1.ProductDealerPriceStk = '143.53';
		tdata1.AMOSDiscountGroup = 'GH';
		tdata1.ProductDiscountRateVOR = '10.2';
		tdata1.ProductDiscountRateDLY = '8.6';
		tdata1.ProductDiscountRateSTK = '4.9';
		tdataList.add(tdata1);

		CXP_AMOS_Parts_MastAPIWrapper.Payload payload = new CXP_AMOS_Parts_MastAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_AMOS_Parts_MastAPIWrapper.Request request = new CXP_AMOS_Parts_MastAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_AMOS_Parts_MastAPIWrapper wrap = new CXP_AMOS_Parts_MastAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsMaster_Btch';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_AMOS_Parts_MastAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(3, recordsList.size());
		System.assertEquals(200, res.statusCode);
	}

	@isTest
	static void upsertEmptyData() {

		CXP_AMOS_Parts_MastAPIWrapper.Header head = new CXP_AMOS_Parts_MastAPIWrapper.Header();

		List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> tdataList = new List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> ();
		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();
		tdataList.add(tdata);

		CXP_AMOS_Parts_MastAPIWrapper.Payload payload = new CXP_AMOS_Parts_MastAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_AMOS_Parts_MastAPIWrapper.Request request = new CXP_AMOS_Parts_MastAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_AMOS_Parts_MastAPIWrapper wrap = new CXP_AMOS_Parts_MastAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsMaster_Btch';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_AMOS_Parts_MastAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(0, recordsList.size());
	}

	@isTest
	static void upsertNullData() {

		CXP_AMOS_Parts_MastAPIWrapper.Header head = new CXP_AMOS_Parts_MastAPIWrapper.Header();

		List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> tdataList = new List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> ();
		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();

		CXP_AMOS_Parts_MastAPIWrapper.Payload payload = new CXP_AMOS_Parts_MastAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_AMOS_Parts_MastAPIWrapper.Request request = new CXP_AMOS_Parts_MastAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_AMOS_Parts_MastAPIWrapper wrap = new CXP_AMOS_Parts_MastAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsMaster_Btch';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_AMOS_Parts_MastAPI.upsertPartsProduct();
		Test.stopTest();

		List<Product2> recordsList = [Select Id From Product2];
		System.assertEquals(0, recordsList.size());
	}

	@isTest
	static void upsertException() {

		CXP_AMOS_Parts_MastAPIWrapper.Header head = new CXP_AMOS_Parts_MastAPIWrapper.Header();

		List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> tdataList = new List<CXP_AMOS_Parts_MastAPIWrapper.T_DATA> ();
		CXP_AMOS_Parts_MastAPIWrapper.T_DATA tdata = new CXP_AMOS_Parts_MastAPIWrapper.T_DATA();
		tdata.AMOSCompanyKindCode = 'ABC123';
		tdata.AMOSProductCode = 'PC12';
		tdata.AMOSPartNameNative = 'NativePartName';
		tdata.AMOSPartName = 'PartName';
		tdata.AMOSProductCodeNEW = 'PC12NEW';
		tdata.AMOSProductCodeOLD = 'PC12OLD';
		tdata.ProductType = 'T1';// Wrong field
		tdata.AMOSDisposableClass = 'T';
		tdata.AMOSQuantity = '14.2';
		tdata.AMOSDimensionalMeasurement = 'DMes';
		tdata.AMOSWeightMeasurement = 'WMes';
		tdata.Width = 'A12';
		tdata.Length = 'A24';
		tdata.Height = 'A6';
		tdata.Weight = 'A25';
		tdata.CurrencyIsoCode = 'CHF';
		tdata.ProductPriceRetail = '125.78';
		tdata.ProductPriceBasic = '130.85';
		tdata.ProductPriceMSRP = '147.87';
		tdata.ProductDealerPriceVOR = '180.25';
		tdata.ProductDealerPriceDLY = '190.65';
		tdata.ProductDealerPriceStk = '143.53';
		tdata.AMOSDiscountGroup = 'GH';
		tdata.ProductDiscountRateVOR = '10.2';
		tdata.ProductDiscountRateDLY = '8.6';
		tdata.ProductDiscountRateSTK = '4.9';
		tdataList.add(tdata);

		CXP_AMOS_Parts_MastAPIWrapper.Payload payload = new CXP_AMOS_Parts_MastAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_AMOS_Parts_MastAPIWrapper.Request request = new CXP_AMOS_Parts_MastAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_AMOS_Parts_MastAPIWrapper wrap = new CXP_AMOS_Parts_MastAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		Test.startTest();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CXP_AMOS_PartsMaster_Btch';
		req.httpMethod = 'PUT';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		RestContext.response = res;
		CXP_AMOS_Parts_MastAPI.upsertPartsProduct();
		Test.stopTest();

		System.assertEquals(400, res.statusCode);
	}
}