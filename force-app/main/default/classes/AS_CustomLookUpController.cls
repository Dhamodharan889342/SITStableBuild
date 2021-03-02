/******************************************************************************************
  * File Name   : AS_CustomLookUpController
  * Created Date: 21th December 2020
  * Description : Apex controller for reusable custom lookup Lightning Aura component AS_CustomLookUpController. Wrote for implementation of GD-547 ( Workshop scheduling for new repair reservation (GPA/SA) ). It's used to enable user to select record for any lookup field only by knowing the name of the record.
  * Author      : Konrad Maluszkiewicz
  * Modification Log
  * =======================================================================
  * Ver     Date             Author                      Modification
  * =======================================================================
  * 1.0     21.12.2020       Konrad Maluszkiewicz        Creation
  ****************************************************************************************/

public with sharing class AS_CustomLookUpController {
    @AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyWord, String ObjectName) {
        System.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';

        List<sObject> returnList = new List<sObject>();
        String soqlQuery =  'SELECT Id, Name FROM ' + ObjectName + ' WHERE Name LIKE :searchKey ORDER BY CreatedDate DESC LIMIT 5';
System.debug('soqlQuery = ' + soqlQuery);
        List<sObject> lstOfRecords = Database.query(soqlQuery);

System.debug('lstOfRecords = ' + lstOfRecords);

        for(sObject obj : lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}