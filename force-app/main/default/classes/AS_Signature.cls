/*
Author: Neha Aggrawal
Created Date: 15-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026 
*Update Daniel Varhidi - add Courtesy_Car_Contract__c
*/

public without sharing class AS_Signature {
    
    public static Boolean isEmpty(Object o) {
        if (o == null) return true;
        
        if (o instanceOf String) {
            if (''.equals(o)) return true;
            if (''.equals(String.valueOf(o).trim())) return true; // SPACE도 empty로 본다.
        }
        
        return false;
    }
    @AuraEnabled
    public static String getRecordType(Map<String, Object> pmap) {
        Id recordId = (String) pmap.get('recordId');
        String recordtypename = '';
        String localName = recordId.getSobjectType().getDescribe().localName;
        System.debug('AS_Signature > getRecordType()');
        if ('StatusConfirmation__c'.equals(localName)) {
            Id RecordtypeId = [SELECT Id, RecordtypeId FROM StatusConfirmation__c where Id = :recordId].RecordtypeId;
            recordtypename = [Select Id, Name from RecordType where Id = :RecordtypeId and SobjectType = 'StatusConfirmation__c'].Name;
        }else if ('Courtesy_Car_Contract__c'.equals(localName)) {
            Id RecordtypeId = [SELECT Id, RecordtypeId FROM Courtesy_Car_Contract__c where Id = :recordId].RecordtypeId;
            recordtypename = [Select Id, Name from RecordType where Id = :RecordtypeId and SobjectType = 'Courtesy_Car_Contract__c'].Name;
        }
        return recordtypename;
    }
    @AuraEnabled
    public static Map<String, Object> doSaveSign(Map<String, Object> pmap, String selected, String recordTypeName, String signername) {
        System.debug(selected);
        Map<String, Object> returnMap = new Map<String, Object> ();
        ResponseStatus responseStatus = new ResponseStatus();
        
        //        try{
        // Param
        Id recordId = (String) pmap.get('recordId');
        String base64Data = (String) pmap.get('base64Data');
        
        if (AS_Signature.isEmpty(recordId)) {
            responseStatus.fail('Invalid Record ID');
            returnMap.put('responseStatus', responseStatus);
            return returnMap;
        }
        
        Datetime d = Datetime.now();
        String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');
        //Save signature as attachment
        Attachment attach = new Attachment();
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = recordTypeName + '_' + selected + '_Sign_' + s + '.png';
        attach.IsPrivate = false;
        attach.ParentId = recordId;
        insert attach;
        //Update signature Id field as per record type and selected option by user
        String localName = recordId.getSobjectType().getDescribe().localName; //Object Name
        if (String.isNotBlank(localName)) {
            sObject obj = Schema.getGlobalDescribe().get(localName).newSObject(); //Object Instance
            if (obj != null && selected == 'Driver') {
                obj.put('Id', recordId);
                if (recordTypeName == 'Pickup')
                    obj.put('SignatureId__c', attach.Id);
                else
                    if (recordTypeName == 'Delivery')
                    obj.put('Delivery_DriverSignatureId__c', attach.Id);
                update obj;
            }
            else if (obj != null && selected == 'Customer') {
                obj.put('Id', recordId);
                if (recordTypeName == 'Pickup')
                    obj.put('CustomerSignatureId__c', attach.Id);
                else if (recordTypeName == 'Delivery')
                    obj.put('Delivery_CustomerSignatureId__c', attach.Id);
                update obj;
            }
            else if (obj != null && selected == 'Signer_On_Behalf') {
                obj.put('Id', recordId);
                if (recordTypeName == 'Pickup') {
                    obj.put('Pickup_Signer_onbehalf__c', signername);
                    obj.put('Pickup_On_Behalf_SignatureId__c', attach.Id);
                }
                if (recordTypeName == 'Delivery') {
                    obj.put('Delivery_Signer_Name_on_behalf__c', signername);
                    obj.put('Delivery_on_Behalf_SignatureId__c', attach.Id);
                }
                update obj;
            }
            //If pickup customer signature or signer signature and driver signature both not null, change record type to delivery   
            
            if ('StatusConfirmation__c'.equals(localName)) {
                StatusConfirmation__c parent = [SELECT Id, Repair__c, RecordtypeId, SignatureId__c, Delivery_on_Behalf_SignatureId__c, Pickup_On_Behalf_SignatureId__c, CustomerSignatureId__c, Delivery_CustomerSignatureId__c, Delivery_DriverSignatureId__c FROM StatusConfirmation__c WHERE Id = :recordId];
                /*
if (recordtypename == 'Pickup' && (parent.SignatureId__c != null && (parent.CustomerSignatureId__c != null || parent.Pickup_On_Behalf_SignatureId__c != null))) {
Id rtid = [Select Id, Name from RecordType where Name = 'Delivery' and SobjectType = 'StatusConfirmation__c'].Id;
parent.RecordtypeId = rtid;
update parent;
}
*/
                //If delivery customer signature or signer signature and driver signature both not null, change record type to readonly  
                if (recordtypename == 'Delivery' && (parent.Delivery_DriverSignatureId__c != null && (parent.Delivery_CustomerSignatureId__c != null || parent.Delivery_on_Behalf_SignatureId__c != null))) {
                    Id rtid = [Select Id, Name from RecordType where Name = 'ReadOnly' and SobjectType = 'StatusConfirmation__c'].Id;
                    parent.RecordtypeId = rtid;
                    update parent;
                    //Send Notification to Repair user
                    
                }
            }
            //If pickup customer signature or signer signature and driver signature both not null, change record type to pickup   
            if ('Courtesy_Car_Contract__c'.equals(localName)) {
                Courtesy_Car_Contract__c parent = [SELECT Id, Repair__c, RecordtypeId, SignatureId__c, Delivery_on_Behalf_SignatureId__c, Pickup_On_Behalf_SignatureId__c, CustomerSignatureId__c, Delivery_CustomerSignatureId__c, Delivery_DriverSignatureId__c FROM Courtesy_Car_Contract__c WHERE Id = :recordId];
                /*
//if (recordtypename == 'Delivery' && (parent.SignatureId__c != null && (parent.CustomerSignatureId__c != null || parent.Pickup_On_Behalf_SignatureId__c != null))) {
if (recordtypename == 'Delivery' &&  (parent.Delivery_DriverSignatureId__c != null && (parent.Delivery_CustomerSignatureId__c != null || parent.Delivery_on_Behalf_SignatureId__c != null))) {
Id rtid = [Select Id, Name from RecordType where Name = 'Pickup' and SobjectType = 'Courtesy_Car_Contract__c'].Id;
parent.RecordtypeId = rtid;
parent.Date_Time_PICK_UP__c = System.now();
update parent;
}
*/
                //If delivery customer signature or signer signature and driver signature both not null, change record type to readonly  
                if (recordtypename == 'Pickup' && (parent.SignatureId__c != null && (parent.CustomerSignatureId__c != null || parent.Pickup_On_Behalf_SignatureId__c != null))) {
                    Id rtid = [Select Id, Name from RecordType where Name = 'ReadOnly' and SobjectType = 'Courtesy_Car_Contract__c'].Id;
                    parent.RecordtypeId = rtid;
                    update parent;
                    //Send Notification to Repair user
                    
                }
            }
            
        } else {
            responseStatus.fail('Invalid Record ID');
            returnMap.put('responseStatus', responseStatus);
            return returnMap;
        }
        responseStatus.success();
        returnMap.put('responseStatus', responseStatus);
        returnMap.put('attachId', attach.Id);
        
        
        
        
        return returnMap;
    }
    
    public class ResponseStatus {
        @AuraEnabled public String result { get; set; }
        @AuraEnabled public String message { get; set; }
        
        public void success() {
            this.result = 'SUCCESS';
        }
        public void fail(String message) {
            this.result = 'fail';
            this.message = message;
        }
    }
}