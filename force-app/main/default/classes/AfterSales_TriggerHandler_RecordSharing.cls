/*Created By: Mayank Pant
Created Date: 30th Dec 2020
Purpose: This class will be called from triggers to perform Programmatic record sharing*/
public class AfterSales_TriggerHandler_RecordSharing {
	
    /*This method will receive the records which will be shared with their department public group*/
     @InvocableMethod  
    public static void receiveRecords(List<Sobject> lstSobject){
        // Create a map of record id and its department id
		// Create a set of department id
		// create a set of object name and for this user sobject.getglobal descibe
		// Call below method performProgrammaticRecordSharing
		Map<Id,Id> maprecIdAndDepartmentId= new Map<Id,Id>();
        Set<Id> setDepartmentId = new Set<Id>();
        Set<String> setObjectName = new Set<String>();
        Set<Id> recId=new Set<Id>();
        String sobjectname='';
        for(sobject s:lstSobject)
        {
            recId.add(s.Id);
            setObjectName.add(util.getSobjectName(s.Id));
            sobjectname=util.getSobjectName(s.Id);
        }
        System.debug(sobjectname);
		String queryStr= 'Select Id, Department__c from '+sobjectname+ ' where Id in: recId';
        System.debug(queryStr);
        List<Sobject> results=Database.query(queryStr);
		for(Sobject res:results)
        {
            maprecIdAndDepartmentId.put(res.Id,(Id)res.get('Department__c'));
            setDepartmentId.add((Id)res.get('Department__c'));  
        }
        System.debug(maprecIdAndDepartmentId);
        performProgrammaticRecordSharing(maprecIdAndDepartmentId,setDepartmentId,setObjectName);
        
	}
    /*This method will receive the list of records*/
    public Static void performProgrammaticRecordSharing(Map<Id,Id> maprecIdAndDepartmentId, 
                                                        Set<Id> setDepartmentId, 
                                                        Set<String> setObjectName){
        /*Method to find the object name and departmentName for the received parameters*/
     	Map<String, String> mapDepartmentAndItsPublicGroupDevName = new Map<String, String>();
		Map<Id,Id> mapRecordIdAndPublicGroupId = new Map<Id,Id>();
		
		Map<Id,String> mapDepartmentNameID = new Map<Id,String>();
		Set<String> setDepartmentName = new Set<String>();
		
        map<String, String> mapRecIdPrefixAndSobjectName = new Map<String, String>();
		setDepartmentName = Util.getDepartmentName(setDepartmentId);
                                                            
        mapDepartmentNameID = Util.getDepartmentNameIDMap(setDepartmentId);
        mapRecIdPrefixAndSobjectName = Util.getSobjectName(maprecIdAndDepartmentId.keySet()); 
		
		/*Get Public group map per department for the object*/
        mapDepartmentAndItsPublicGroupDevName = AfterSales_RecordSharing.getPublicGroupMapPerDepartmentPerObject(setObjectName, setDepartmentName);
		
		/*Prepare Record id and its corresponding public group id */
		for(Id recId : maprecIdAndDepartmentId.keySet()){
				mapRecordIdAndPublicGroupId.put(recId,mapDepartmentAndItsPublicGroupDevName.get(mapDepartmentNameID.get(maprecIdAndDepartmentId.get(recId))));
		}
			
		List<Sobject> lstshareSobjectRecords = new List<Sobject>(); 
		lstshareSobjectRecords = AfterSales_RecordSharing.generateShareRecords(mapRecordIdAndPublicGroupId);
		lstshareSobjectRecords = AfterSales_RecordSharing.insertShareRecords(lstshareSobjectRecords);
        
    }
}