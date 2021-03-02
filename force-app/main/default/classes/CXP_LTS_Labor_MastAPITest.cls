@isTest 
private class CXP_LTS_Labor_MastAPITest {
	
	static void createTestRecords(){
		List<Product2> listToInsert = new List<Product2>();
        Product2 rec1 = new Product2();
        rec1.LTSCompanyKindCode__c = 'A';
		rec1.LTSCarModelCode__c = 'A1';
		rec1.LTSMainGroup__c = 'Main';
		rec1.LTSSubGroup__c = 'SubGr';
		rec1.LTSWorkCode__c = 'A1';
		rec1.LTSIntegration__c = '1';
		rec1.LTSLaborNativeWorkName__c = 'KorName';
		rec1.LTSEnglishWorkName__c = 'EngName';
		rec1.LTSSPNCCode__c = 'AB123';
		rec1.LTSRepairCategoryCode__c = 'A';
		rec1.LTSTaskCodeEndTwoDigits__c = '12';
		rec1.LTSMessageID__c = '123456';
		rec1.LTSRelatedWorkDetails__c = 'details';
		rec1.LTSWhetherToDelete__c = '0';
		rec1.LTSFinalModifier__c = 'Thomas W';
		rec1.LTSLastModifiedDate__c = '20200708';
		rec1.LTSFirstRegistrant__c = 'John B';
		rec1.LTSFirstRegistrationDate__c = '20200608';

		rec1.LTS_Labor_Mast_ExternalKey__c = rec1.LTSWorkCode__c + rec1.LTSEnglishWorkName__c;
		rec1.Name = 'Prod1';
		rec1.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Labor').getRecordTypeId();
        listToInsert.add(rec1);

		 Product2 rec2 = new Product2();
        rec2.LTSCompanyKindCode__c = 'B';
		rec2.LTSCarModelCode__c = 'A1';
		rec2.LTSMainGroup__c = 'Main';
		rec2.LTSSubGroup__c = 'SubGr';
		rec2.LTSWorkCode__c = 'A2';
		rec2.LTSIntegration__c = '1';
		rec2.LTSLaborNativeWorkName__c = 'KorName';
		rec2.LTSEnglishWorkName__c = 'EngName';
		rec2.LTSSPNCCode__c = 'AB123';
		rec2.LTSRepairCategoryCode__c = 'A';
		rec2.LTSTaskCodeEndTwoDigits__c = '12';
		rec2.LTSMessageID__c = '123456';
		rec2.LTSRelatedWorkDetails__c = 'details';
		rec2.LTSWhetherToDelete__c = '0';
		rec2.LTSFinalModifier__c = 'Thomas W';
		rec2.LTSLastModifiedDate__c = '20200708';
		rec2.LTSFirstRegistrant__c= 'John B';
		rec2.LTSFirstRegistrationDate__c = '20200608';

		rec2.LTS_Labor_Mast_ExternalKey__c = rec2.LTSWorkCode__c + rec2.LTSEnglishWorkName__c;
		rec2.Name = 'Prod1';
		rec2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Labor').getRecordTypeId();
        listToInsert.add(rec2);

        insert listToInsert; 
	}

	@isTest
    static void insertRecords() {                                              

        CXP_LTS_Labor_MastAPIWrapper.Header head = new CXP_LTS_Labor_MastAPIWrapper.Header();           
        
        List<CXP_LTS_Labor_MastAPIWrapper.T_DATA> tdataList = new List<CXP_LTS_Labor_MastAPIWrapper.T_DATA>();
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
        tdata.LTSCompanyKindCode = 'K';
		tdata.LTSCarModelCode = 'A1';
		tdata.LTSMainGroup = 'Main';
		tdata.LTSSubGroup = 'SubGr';
		tdata.LTSWorkCode = 'A234';
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
        
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata1 = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
        tdata1.LTSCompanyKindCode = 'L';
		tdata1.LTSCarModelCode = 'A1';
		tdata1.LTSMainGroup = 'Main';
		tdata1.LTSSubGroup = 'SubGr';
		tdata1.LTSWorkCode = 'A6';
		tdata1.LTSIntegration = '1';
		tdata1.LTSKoreanWorkName = 'KorName';
		tdata1.LTSEnglishWorkName = 'EngName';
		tdata1.LTSSPNCCode = 'AB123';
		tdata1.LTSRepairCategoryCode = 'A';
		tdata1.LTSTaskCodeEndTwoDigits = '12';
		tdata1.LTSMessageID = '123456';
		tdata1.LTSRelatedWorkDetails = 'details';
		tdata1.LTSWhetherToDelete = '0';
		tdata1.LTSFinalModifier = 'Thomas W';
		tdata1.LTSLastModifiedDate = '20200708';
		tdata1.LTSFirstRegistrant = 'John B';
		tdata1.LTSFirstRegistrationDate = '20200608';
        tdataList.add(tdata1);        
        
        CXP_LTS_Labor_MastAPIWrapper.Payload payload = new CXP_LTS_Labor_MastAPIWrapper.Payload();
        payload.T_DATA = tdataList;
        
		CXP_LTS_Labor_MastAPIWrapper.Request request = new CXP_LTS_Labor_MastAPIWrapper.Request();
		request.header = head;
        request.payload = payload;
        
        CXP_LTS_Labor_MastAPIWrapper wrap = new CXP_LTS_Labor_MastAPIWrapper(); 
        wrap.request = request;        
        
        String json = JSON.serialize(wrap);                
        
        Test.startTest();                                 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/CXP_LTS_Labor_Mast';
        req.httpMethod = 'PUT';        
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;
        CXP_LTS_Labor_MastAPI.upsertLaborProduct();         
        Test.stopTest();                 
        
        List<Product2> recordsList = [Select Id From Product2];
        System.assertEquals(2, recordsList.size());  
        System.assertEquals(200, res.statusCode); 
    }

    @isTest
	static void updateRecords() {                                              
		createTestRecords();
		CXP_LTS_Labor_MastAPIWrapper.Header head = new CXP_LTS_Labor_MastAPIWrapper.Header();           
        
        List<CXP_LTS_Labor_MastAPIWrapper.T_DATA> tdataList = new List<CXP_LTS_Labor_MastAPIWrapper.T_DATA>();
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
		tdata.LTSCompanyKindCode = 'A';
		tdata.LTSCarModelCode = 'A1';
		tdata.LTSMainGroup = 'Main';
		tdata.LTSSubGroup = 'SubGr';
		tdata.LTSWorkCode = 'A1';
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
        
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata1 = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
        tdata1.LTSCompanyKindCode = 'B';
		tdata1.LTSCarModelCode = 'A1';
		tdata1.LTSMainGroup = 'Main';
		tdata1.LTSSubGroup = 'SubGr';
		tdata1.LTSWorkCode = 'A2';
		tdata1.LTSIntegration = '1';
		tdata1.LTSKoreanWorkName = 'KorName';
		tdata1.LTSEnglishWorkName = 'EngName';
		tdata1.LTSSPNCCode = 'AB123';
		tdata1.LTSRepairCategoryCode = 'A';
		tdata1.LTSTaskCodeEndTwoDigits = '12';
		tdata1.LTSMessageID = '123456';
		tdata1.LTSRelatedWorkDetails = 'details';
		tdata1.LTSWhetherToDelete = '0';
		tdata1.LTSFinalModifier = 'Thomas W';
		tdata1.LTSLastModifiedDate = '20200708';
		tdata1.LTSFirstRegistrant = 'John B';
		tdata1.LTSFirstRegistrationDate = '20200608';
        tdataList.add(tdata1);        
        
        CXP_LTS_Labor_MastAPIWrapper.Payload payload = new CXP_LTS_Labor_MastAPIWrapper.Payload();
        payload.T_DATA = tdataList;
        
		CXP_LTS_Labor_MastAPIWrapper.Request request = new CXP_LTS_Labor_MastAPIWrapper.Request();
		request.header = head;
        request.payload = payload;
        
        CXP_LTS_Labor_MastAPIWrapper wrap = new CXP_LTS_Labor_MastAPIWrapper(); 
        wrap.request = request;        
        
        String json = JSON.serialize(wrap);            
        
        Test.startTest();                                 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/CXP_LTS_Labor_Mast';
        req.httpMethod = 'PUT';        
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;
        CXP_LTS_Labor_MastAPI.upsertLaborProduct();         
        Test.stopTest();                 
        
        List<Product2> recordsList = [Select Id From Product2];
        System.assertEquals(2, recordsList.size());  
        System.assertEquals(200, res.statusCode); 
    }  
    
    @isTest
	static void upsertRecords() {   
        createTestRecords();
        CXP_LTS_Labor_MastAPIWrapper.Header head = new CXP_LTS_Labor_MastAPIWrapper.Header();           
        
        List<CXP_LTS_Labor_MastAPIWrapper.T_DATA> tdataList = new List<CXP_LTS_Labor_MastAPIWrapper.T_DATA>();
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
        tdata.LTSCompanyKindCode = 'A';
		tdata.LTSCarModelCode = 'A1';
		tdata.LTSMainGroup = 'Main';
		tdata.LTSSubGroup = 'SubGr';
		tdata.LTSWorkCode = 'A1';
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
        
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata1 = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
        tdata1.LTSCompanyKindCode = 'C';
		tdata1.LTSCarModelCode = 'A1';
		tdata1.LTSMainGroup = 'Main';
		tdata1.LTSSubGroup = 'SubGr';
		tdata1.LTSWorkCode = 'ABCD1234';
		tdata1.LTSIntegration = '1';
		tdata1.LTSKoreanWorkName = 'KorName';
		tdata1.LTSEnglishWorkName = 'EngName';
		tdata1.LTSSPNCCode = 'AB123';
		tdata1.LTSRepairCategoryCode = 'A';
		tdata1.LTSTaskCodeEndTwoDigits = '12';
		tdata1.LTSMessageID = '123456';
		tdata1.LTSRelatedWorkDetails = 'details';
		tdata1.LTSWhetherToDelete = '0';
		tdata1.LTSFinalModifier = 'Thomas W';
		tdata1.LTSLastModifiedDate = '20200708';
		tdata1.LTSFirstRegistrant = 'John B';
		tdata1.LTSFirstRegistrationDate = '20200608';
        tdataList.add(tdata1);        
        
        CXP_LTS_Labor_MastAPIWrapper.Payload payload = new CXP_LTS_Labor_MastAPIWrapper.Payload();
        payload.T_DATA = tdataList;
        
		CXP_LTS_Labor_MastAPIWrapper.Request request = new CXP_LTS_Labor_MastAPIWrapper.Request();
		request.header = head;
        request.payload = payload;
        
        CXP_LTS_Labor_MastAPIWrapper wrap = new CXP_LTS_Labor_MastAPIWrapper(); 
        wrap.request = request;        
        
        String json = JSON.serialize(wrap);               
        
        Test.startTest();                                 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/CXP_LTS_Labor_Mast';
        req.httpMethod = 'PUT';        
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;
        CXP_LTS_Labor_MastAPI.upsertLaborProduct();         
        Test.stopTest();                 
        
        List<Product2> recordsList = [Select Id From Product2];
        System.assertEquals(3, recordsList.size());  
        System.assertEquals(200, res.statusCode); 
    }  
    
    @isTest
    static void upsertEmptyData() {
                        
        CXP_LTS_Labor_MastAPIWrapper.Header head = new CXP_LTS_Labor_MastAPIWrapper.Header();              
        
        List<CXP_LTS_Labor_MastAPIWrapper.T_DATA> tdataList = new List<CXP_LTS_Labor_MastAPIWrapper.T_DATA>();
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();                         
        tdataList.add(tdata);                
        
        CXP_LTS_Labor_MastAPIWrapper.Payload payload = new CXP_LTS_Labor_MastAPIWrapper.Payload();
        payload.T_DATA = tdataList;               
        
        CXP_LTS_Labor_MastAPIWrapper.Request request = new CXP_LTS_Labor_MastAPIWrapper.Request();
        request.header = head;
        request.payload = payload;
        
        CXP_LTS_Labor_MastAPIWrapper wrap = new CXP_LTS_Labor_MastAPIWrapper(); 
        wrap.request = request;        
        
        String json = JSON.serialize(wrap);               
        
        Test.startTest();                         
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/CXP_LTS_Labor_Mast';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;
        CXP_LTS_Labor_MastAPI.upsertLaborProduct();         
        Test.stopTest();  
        
        List<Product2> recordsList = [Select Id From Product2];
        System.assertEquals(0, recordsList.size());        
    }
    
    @isTest
    static void upsertNullData() {
        
        CXP_LTS_Labor_MastAPIWrapper.Header head = new CXP_LTS_Labor_MastAPIWrapper.Header();               
        
        List<CXP_LTS_Labor_MastAPIWrapper.T_DATA> tdataList = new List<CXP_LTS_Labor_MastAPIWrapper.T_DATA>();
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();                                      
        
        CXP_LTS_Labor_MastAPIWrapper.Payload payload = new CXP_LTS_Labor_MastAPIWrapper.Payload();
        payload.T_DATA = tdataList;        
        
        CXP_LTS_Labor_MastAPIWrapper.Request request = new CXP_LTS_Labor_MastAPIWrapper.Request();
        request.header = head;
        request.payload = payload;
        
        CXP_LTS_Labor_MastAPIWrapper wrap = new CXP_LTS_Labor_MastAPIWrapper(); 
        wrap.request = request;        
        
        String json = JSON.serialize(wrap);            
        
        Test.startTest();                         
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/CXP_LTS_Labor_Mast';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;
        CXP_LTS_Labor_MastAPI.upsertLaborProduct();         
        Test.stopTest();  
        
        List<Product2> recordsList = [Select Id From Product2];
        System.assertEquals(0, recordsList.size());             		                                                   
    }
    
    @isTest
    static void upsertException() {
                
		CXP_LTS_Labor_MastAPIWrapper.Header head = new CXP_LTS_Labor_MastAPIWrapper.Header();           
        
        List<CXP_LTS_Labor_MastAPIWrapper.T_DATA> tdataList = new List<CXP_LTS_Labor_MastAPIWrapper.T_DATA>();
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
        tdata.LTSCompanyKindCode = 'A';
		tdata.LTSCarModelCode = 'A1';
		tdata.LTSMainGroup = 'Main';
		tdata.LTSSubGroup = 'SubGr';
		tdata.LTSWorkCode = 'ABCD1234';
		tdata.LTSIntegration = 'YES';
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
        
        CXP_LTS_Labor_MastAPIWrapper.T_DATA tdata1 = new CXP_LTS_Labor_MastAPIWrapper.T_DATA();        
        tdata1.LTSCompanyKindCode = 'C';
		tdata1.LTSCarModelCode = 'A1';
		tdata1.LTSMainGroup = 'Main';
		tdata1.LTSSubGroup = 'SubGr';
		tdata1.LTSWorkCode = 'ABCD1234';
		tdata1.LTSIntegration = '1';
		tdata1.LTSKoreanWorkName = 'KorName';
		tdata1.LTSEnglishWorkName = 'EngName';
		tdata1.LTSSPNCCode = 'AB123';
		tdata1.LTSRepairCategoryCode = 'A';
		tdata1.LTSTaskCodeEndTwoDigits = '12';
		tdata1.LTSMessageID = '123456';
		tdata1.LTSRelatedWorkDetails = 'details';
		tdata1.LTSWhetherToDelete = '0';
		tdata1.LTSFinalModifier = 'Thomas W';
		tdata1.LTSLastModifiedDate = '20200708';
		tdata1.LTSFirstRegistrant = 'John B';
		tdata1.LTSFirstRegistrationDate = '20200608';
        tdataList.add(tdata1);    
        tdataList.add(tdata1);        
        
        CXP_LTS_Labor_MastAPIWrapper.Payload payload = new CXP_LTS_Labor_MastAPIWrapper.Payload();
        payload.T_DATA = tdataList;
        
		CXP_LTS_Labor_MastAPIWrapper.Request request = new CXP_LTS_Labor_MastAPIWrapper.Request();
		request.header = head;
        request.payload = payload;
        
        CXP_LTS_Labor_MastAPIWrapper wrap = new CXP_LTS_Labor_MastAPIWrapper(); 
        wrap.request = request;        
        
        String json = JSON.serialize(wrap);             
        
        Test.startTest();                         
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/CXP_ERP_MC_Mast';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;
        CXP_LTS_Labor_MastAPI.upsertLaborProduct();         
        Test.stopTest();
                        
        System.assertEquals(400, res.statusCode); 
    }	
}