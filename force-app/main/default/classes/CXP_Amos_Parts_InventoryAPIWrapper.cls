public class CXP_Amos_Parts_InventoryAPIWrapper {
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
        public String AMOSCompanyKindCode;
        public String AMOSProductCode;
        public String AMOSPartName;
        public String AMOSNewPartNo;
        public String AMOSOldPartNo;
        public String AMOSProductType;
        //public String AMOSPDC;
        //public String AMOSZone;
        //public String AMOSAVL_QT;
        
    }

    public class Request {
        public Header header;
        public Payload payload;
    }

    public class Payload {
        public List<T_DATA> T_DATA;
    }

    public static CXP_Amos_Parts_InventoryAPIWrapper  parse(String json) {
        return(CXP_Amos_Parts_InventoryAPIWrapper ) System.JSON.deserialize(json, CXP_Amos_Parts_InventoryAPIWrapper.class);
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
            header = new responseheaderWrapper('IF_EU_AMOS_CXP_0003', 'EU', 'LTS', 'EU', 'CXP', ifTrackingId);
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