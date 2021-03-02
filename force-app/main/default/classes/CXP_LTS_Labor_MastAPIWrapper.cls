/**
* @author Daniel Varhidi
* @createdDate 06/01/2021 
* @JIRA GD-1326
* @description 
*/ 
public class CXP_LTS_Labor_MastAPIWrapper {
	public Request request;

	public class Header {
		public String ifId;
		public String ifSenderGp;
		public String ifSender;
		public String ifReceiverGp;
		public String ifReceiver;
		public String ifDateTime;
		public String ifTrackingId;
	}

	public class T_DATA {
		public String LTSCompanyKindCode;
		public String LTSCarModelCode;
		public String LTSMainGroup;
		public String LTSSubGroup;
		public String LTSWorkCode;
		public String LTSIntegration;
		public String LTSKoreanWorkName;
		public String LTSEnglishWorkName;
		public String LTSSPNCCode;
		public String LTSRepairCategoryCode;
		public String LTSTaskCodeEndTwoDigits;
		public String LTSMessageID;
		public String LTSRelatedWorkDetails;
		public String LTSWhetherToDelete;
		public String LTSFinalModifier;
		public String LTSLastModifiedDate;
		public String LTSFirstRegistrant;
		public String LTSFirstRegistrationDate;
	}

	public class Request {
		public Header header;
		public Payload payload;
	}

	public class Payload {
		public List<T_DATA> T_DATA;
	}

	public static CXP_LTS_Labor_MastAPIWrapper parse(String json) {
		return(CXP_LTS_Labor_MastAPIWrapper) System.JSON.deserialize(json, CXP_LTS_Labor_MastAPIWrapper.class);
	}

	public class response{
        public responseWrapper response;        
        public response(String ifTrackingId) {
            response = new responseWrapper(ifTrackingId);
        }
    }

	public class responseWrapper {
		public responseheaderWrapper header;
		public responseBodyWrapper payload;

		public responseWrapper(String ifTrackingId) {
			header = new responseheaderWrapper('IF_CN_CXP_LTS_0001', 'EU', 'LTS', 'EU', 'CXP', ifTrackingId);
			payload = new responseBodyWrapper();
		}
	}

	Public Class responseheaderWrapper {
		Public String ifId;
		Public String ifSenderGp;
		Public String ifSender;
		Public String ifReceiverGp;
		Public String ifReceiver;
		Public String ifTrackingId;
		Public String ifDateTime = System.now().format('yyyyMMddkkmmss');

		public responseheaderWrapper(String ifId, String ifSenderGp, String ifSender, String ifReceiverGp, String ifReceiver, String ifTrackingId) {
			this.ifId = ifId;
			this.ifSenderGp = ifSenderGp;
			this.ifSender = ifSender;
			this.ifReceiverGp = ifReceiverGp;
			this.ifReceiver = ifReceiver;
			this.ifTrackingId = ifTrackingId;
		}
	}

	public class responseBodyWrapper {
		public string ResultCode;
        public string ErrorMsg;
        public string ErrorCode;   
	}

}