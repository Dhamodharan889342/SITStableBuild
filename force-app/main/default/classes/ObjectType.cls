/**
 * Created by H1812104 on 2019-04-16.
 */

public without sharing class ObjectType {
    @AuraEnabled
    public static String doGetSObjectType(Map<String, Object> pmap) {
        String temp = (String) pmap.get('sObjectTypeList'); // required.
//        System.debug('temp :: ' + temp);
        List<String> sObjectTypeList = (List<String>) JSON.deserialize(temp, List<String>.Class);
//        System.debug('sObjectTypeList :: ' + JSON.serialize(sObjectTypeList));
        return getDescribedObjects(sObjectTypeList);
    }

//    public static String getDescribedObjects(List<String> sObjectTypeList) {
//        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
//        // Create a JSON string with object field labels and picklist values
//        String allObjJSON = '{';
//        // Iterate over the list of objects and describe each object
//        for (String sObjectType : sObjectTypeList) {
//            if (allObjJSON != '{') allObjJSON += ', ';
//
//            allObjJSON += '"' + sObjectType + '": ';
//            DescribeSObjectResult describeResult = globalDescribe.get(sObjectType).getDescribe();
//            Map<String, Schema.SObjectField> describedFields = describeResult.fields.getMap();
//            String objJSON = '{';
//
//            for (String fieldName : describedFields.keySet()) {
//
//                // Descirbe the field
//                Schema.SObjectField field = describedFields.get(fieldName);
//                Schema.DescribeFieldResult f = field.getDescribe();
//                if (objJSON != '{') objJSON += ', ';
//
//                // Get the field label and append in the JSON string
//                objJSON += '"' + f.getName() + '": ' + '{ "label" : "' + f.getLabel() + '"';
//
//                // if it's a picklist field then also add the picklist options
//                if (field.getDescribe().getType() == Schema.DisplayType.PICKLIST) {
//
//                    List <Schema.PicklistEntry> picklistValues = field.getDescribe().getPickListValues();
//                    List<String> pickListOptions = new List<String>();
//                    pickListOptions.add('{ "label": "--None--", "value": null }');
//
//                    for (Schema.PicklistEntry pe : picklistValues) {
//
//                        pickListOptions.add('{ "label": "' + pe.getLabel() + '", "value": "' + pe.getValue() + '" }');
//
//                    }
//
//                    System.debug('>>>> ' + fieldName + '>>>> ' + String.join(pickListOptions, ', '));
//                    objJSON += ', "picklistOptions": [' + String.join(pickListOptions, ', ') + ']';
//                }
//                objJSON += '}';
//            }
//            objJSON += '}';
//
//            allObjJSON += objJSON;
//        }
//
//        // Close the object in the JSON String
//        allObjJSON += '}';
//
//        System.debug(' JSON STRING : ' + allObjJSON);
//
//        return allObjJSON;
//    }

    public static String getDescribedObjects(List<String> sObjectTypeList) {
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Map<String, Object> allObject = new Map<String, Object>();

        System.debug('ObjectType.getDescribedObjects List of objects to find label :: ' + JSON.serialize(sObjectTypeList));

        for (String sObjectType : sObjectTypeList) {
            System.debug('ObjectType.getDescribedObjects==> sObjectType :: ' + sObjectType);
            Map<String, Object> fieldMap = new Map<String, Object>();

            DescribeSObjectResult describeResult = globalDescribe.get(sObjectType).getDescribe();
            Map<String, Schema.SObjectField> describedFields = describeResult.fields.getMap();
            fieldMap.put('label',describeResult.getLabel());

            for (String fieldName : describedFields.keySet()) {
                Map<String, Object> fieldItem = new Map<String, Object>();

                Schema.SObjectField field = describedFields.get(fieldName);
                Schema.DescribeFieldResult f = field.getDescribe();

                System.debug('ObjectType.getDescribedObjects Object Schema :: ' + JSON.serialize(f));
                fieldItem.put('label', f.getLabel());

                if (field.getDescribe().getType() == Schema.DisplayType.PICKLIST) {
                    List <Schema.PicklistEntry> picklistValues = field.getDescribe().getPickListValues();
                    List<Map<String, Object>> pickListOptions = new List<Map<String, Object>>();

                    Map<String, Object> emptyItem = new Map<String, Object>();

                    emptyItem.put('label', '--'+Label.None+'--');
                    emptyItem.put('value', null);

                    pickListOptions.add(emptyItem);

                    for (Schema.PicklistEntry pe : picklistValues) {
                        Map<String, Object> pickItem = new Map<String, Object>();

                        pickItem.put('label', pe.getLabel());
                        pickItem.put('value', pe.getValue());

                        pickListOptions.add(pickItem);
                    }

                    fieldItem.put('picklistOptions', pickListOptions);
                }

                fieldMap.put(f.getName(), fieldItem); // Be Careful with Case Sensitive with Key of Map
            }

            allObject.put(sObjectType, fieldMap);
        }

        // Close the object in the JSON String
        String s = JSON.serialize(allObject);
        System.debug(' s : ' + s);
        return s;
    }
}