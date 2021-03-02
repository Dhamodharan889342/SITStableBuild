@isTest 
private class CXP_LTS_Labor_MastAPIWrapperTest {

	static testMethod void testParse() {
        
        CXP_LTS_Labor_MastAPIWrapper.Header head = new CXP_LTS_Labor_MastAPIWrapper.Header();           
        
        List<CXP_LTS_Labor_MastAPIWrapper.T_DATA> tdataList = new List<CXP_LTS_Labor_MastAPIWrapper.T_DATA>();
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
        tdata.LTSCompanyKindCode = 'K';
		tdata.LTSCarModelCode = 'A1';
		tdata.LTSMainGroup = 'Main';
		tdata.LTSSubGroup = 'SubGr';
		tdata.LTSWorkCode = 'ABCD1234';
		tdata.LTSIntegration = '1';
		tdata.LTSKoreanWorkName = 'KorName';
		tdata.LTSEnglishWorkName = 'EngName';
		tdata.LTSSPNCCode = 'AB123';
		tdata.LTSRepairCategoryCode = 'A';
		tdata.LTSTaskCodeEndTwoDigits = '12';
		tdata.LTSMessageID = '123456';
		tdata.LTSRelatedWorkDetails = 'details';
		tdata.LTSWhetherToDelete = '0';
		tdata.LTSFinalModifier = 'Thomas W';
		tdata.LTSLastModifiedDate = '20200708';
		tdata.LTSFirstRegistrant = 'John B';
		tdata.LTSFirstRegistrationDate = '20200608';
        tdataList.add(tdata);                   
        
        CXP_LTS_Labor_MastAPIWrapper.Payload payload = new CXP_LTS_Labor_MastAPIWrapper.Payload();
        payload.T_DATA = tdataList;
        
        CXP_LTS_Labor_MastAPIWrapper.Request request = new CXP_LTS_Labor_MastAPIWrapper.Request();
        request.header = head;
        request.payload = payload; 
        
        CXP_LTS_Labor_MastAPIWrapper wrap = new CXP_LTS_Labor_MastAPIWrapper(); 
        wrap.request = request;        
        
        String json = JSON.serialize(wrap);        
        
        CXP_LTS_Labor_MastAPIWrapper obj = CXP_LTS_Labor_MastAPIWrapper.parse(json);
        System.assert(obj != null);
    }
}