@isTest
private class CXP_AMOS_Parts_MastAPIWrapperTest {

	static testMethod void testParse() {

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

		CXP_AMOS_Parts_MastAPIWrapper.Payload payload = new CXP_AMOS_Parts_MastAPIWrapper.Payload();
		payload.T_DATA = tdataList;

		CXP_AMOS_Parts_MastAPIWrapper.Request request = new CXP_AMOS_Parts_MastAPIWrapper.Request();
		request.header = head;
		request.payload = payload;

		CXP_AMOS_Parts_MastAPIWrapper wrap = new CXP_AMOS_Parts_MastAPIWrapper();
		wrap.request = request;

		String json = JSON.serialize(wrap);

		CXP_AMOS_Parts_MastAPIWrapper obj = CXP_AMOS_Parts_MastAPIWrapper.parse(json);
		System.assert(obj != null);
	}

}