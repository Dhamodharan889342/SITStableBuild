/**
 * Created by H1812104 on 2019-08-19.
 */

public without sharing class RelatedRecordController {

    	// LMS 8/12/2020
    	//   Copied from the chinese sandbox: Util class
    	public static Id getValidId(String str) {
            try {
                Id objId = Id.valueOf(str);
                return objId;
            } catch (Exception e) {
                return null;
            }
        }
    
    
    @AuraEnabled
    public static Map<String, Object> doGetRecordId(Map<String, Object> pmap) {
        Map<String, Object> rmap = new Map<String, Object>();
        // Id recordId = Util.getValidId((String) pmap.get('recordId'));  // Method does not exist or incorrect signature: void getValidId(String) from the type Util
        Id recordId = RelatedRecordController.getValidId((String) pmap.get('recordId'));
        String relatedField = (String) pmap.get('relatedField');
        Schema.SObjectType sobjType = recordId.getSobjectType();
        schema.DescribeSObjectResult dsResult = sobjType.getDescribe();
        switch on dsResult.getName() {
            when 'RepairQuote__c' {
                RepairQuote__c rq = [
                        SELECT Id, Vehicle__c, Customer__c, Requester__c
                        FROM RepairQuote__c
                        WHERE Id = :recordId
                ];
                rmap.put('relatedRecordId', rq.get(relatedField));

            }
        }
        // Id relatedRecordId = Util.getValidId((String) rmap.get('relatedRecordId'));  //Method does not exist or incorrect signature: void getValidId(String) from the type Util
        Id relatedRecordId = RelatedRecordController.getValidId((String) rmap.get('relatedRecordId'));
        if (relatedRecordId != null) {
            Schema.SObjectType relatedSObjType = relatedRecordId.getSobjectType();
            schema.DescribeSObjectResult dsResult2 = relatedSObjType.getDescribe();
            List<TabDefinition> tabDef = [
                    SELECT (SELECT Url FROM Icons WHERE Url LIKE '%120%')
                    FROM TabDefinition
                    WHERE SobjectName = :dsResult2.getName()
            ];
            for (TabDefinition tabDefinition : tabDef) {
                for (IconDefinition iconDef : tabDefinition.Icons) {
                    String url = iconDef.Url;
                    //url => https://genesis--ps.my.salesforce.com/img/icon/t4v35/custom/custom31_120.png
  
                    String iconType = url.substring(0, url.lastIndexOf('/'));
                    iconType = iconType.substring(iconType.lastIndexOf('/') + 1);

                    String iconName = url.substring(url.lastIndexOf('/') + 1);
                    iconName = iconName.substring(0, iconName.lastIndexOf('_'));
                    //custom:custom23
                    rmap.put('iconName', iconType + ':' + iconName);
                }
            }
        } else {
            rmap.put('iconName', 'standard:product');
        }


        return rmap;
    }
}