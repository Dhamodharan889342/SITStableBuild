/**
 * Created by H1812104 on 2019-02-13.
 */ 
 
public without sharing class Signature {

    /**
     LMS 14/12/2020
     GD-1838 
     
     Copy from the chinese sandbox util class
     
     * Empty Check
     * @param o     Object
     * @return      o가 null 혹은 '' 이면 true, 아니면 false 를 return.
     * @Author      김성일
     * e.g.) Util.isEmpty(' ') --> true
     **/
    public static Boolean isEmpty(Object o) {
        if (o == null) return true;

        if (o instanceOf String) {
            if (''.equals(o)) return true;
            if (''.equals(String.valueOf(o).trim())) return true; // SPACE도 empty로 본다.
        } // type 별 null 기준 정의 필요. Number일 경우 등.

        return false;
    }
	@AuraEnabled
    public static String getRecordType(Map<String, Object> pmap){
         Id recordId = (String)pmap.get('recordId');
        String recordtypename='';
        String localName = recordId.getSobjectType().getDescribe().localName;
        if ('StatusConfirmation__c'.equals(localName)) {
         Id RecordtypeId = [SELECT Id, RecordtypeId FROM StatusConfirmation__c where Id =:recordId].RecordtypeId;
           recordtypename =[Select Id,Name from RecordType where Id=:RecordtypeId].Name;
    }
        return recordtypename;
    }
    @AuraEnabled
    public static Map<String, Object> doSaveSign(Map<String, Object> pmap, String selected, String recordTypeName) {
        System.debug(selected);
        Map<String, Object> returnMap   = new Map<String, Object>();
        ResponseStatus responseStatus   = new ResponseStatus();

//        try{
            // Param
            Id recordId             = (String) pmap.get('recordId');
            String base64Data       = (String) pmap.get('base64Data');
            // LMS 14/12/2020 Adaptation 
            // to local call
            if( Signature.isEmpty(recordId)){
                responseStatus.fail('Invalid Record ID');
                returnMap.put('responseStatus',responseStatus);
                return returnMap;
            }

            Datetime d          = Datetime.now();
            String s            = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');

            Attachment attach = new Attachment();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = recordTypeName+'_'+selected+'_Sign_' + s + '.png';
            attach.IsPrivate = false;
            attach.ParentId = recordId;
            insert attach;

            String localName = recordId.getSobjectType().getDescribe().localName;   //Object Name
            if(String.isNotBlank(localName)) {
                sObject obj = Schema.getGlobalDescribe().get(localName).newSObject();    //Object Instance
                if(obj != null && selected=='Driver') {
                    obj.put('Id', recordId);
                    if(recordTypeName=='Pickup')
                        obj.put('SignatureId__c', attach.Id);
                    else
                        obj.put('Delivery_DriverSignatureId__c', attach.Id);
                    update obj;
                }
                 if(obj != null && selected=='Customer') {
                    obj.put('Id', recordId);
                     if(recordTypeName=='Pickup'){
                        obj.put('CustomerSignatureId__c', attach.Id);
                         //If customer signature completed on pickup, change record type to Delivery
                          
                     }
                    else
                        obj.put('Delivery_CustomerSignatureId__c', attach.Id);
                    update obj;
                }
               if ('StatusConfirmation__c'.equals(localName)) { 
                StatusConfirmation__c parent = [SELECT Id, RecordtypeId, SignatureId__c,CustomerSignatureId__c,Delivery_CustomerSignatureId__c,Delivery_DriverSignature__c FROM StatusConfirmation__c WHERE Id = :recordId];
                if(parent.SignatureId__c!=null && parent.CustomerSignatureId__c!=null){
                  Id rtid=[Select Id,Name from RecordType where Name='Delivery'].Id;
				parent.RecordtypeId=rtid;
                update parent;
                }
                if(parent.Delivery_CustomerSignatureId__c!=null && parent.Delivery_DriverSignature__c!=null){
                Id rtid=[Select Id,Name from RecordType where Name='ReadOnly'].Id;
				parent.RecordtypeId=rtid;
                update parent;
                }
            } 
                
            } else {
                responseStatus.fail('Invalid Record ID');
                returnMap.put('responseStatus',responseStatus);
                return returnMap;
            }
            responseStatus.success();
            returnMap.put('responseStatus',responseStatus);
            returnMap.put('attachId', attach.Id);

//        }catch(Exception e){
//            responseStatus.fail(e.getMessage());
//            returnMap.put('responseStatus',responseStatus);
//
//            system.debug('[Signature.cls] EXCEPTION =====================================');
//            system.debug('[Signature.cls] Type : ' + e.getTypeName());
//            system.debug('[Signature.cls] Message : ' + e.getMessage());
//            system.debug('[Signature.cls] Stack Trace : ' + e.getStackTraceString());
//        }


        return returnMap;
    }

    public class ResponseStatus {
        @AuraEnabled public String result   {get;set;}
        @AuraEnabled public String message  {get;set;}

        public void success(){
            this.result = 'SUCCESS';
        }
        public void fail(String message){
            this.result     = 'fail';
            this.message    = message;
        }
    }
}