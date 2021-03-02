/*Created By: Mayank Pant*/
public class AfterSales_RecordSharing {
    /*Method to fetch reord sharing details from the meta data. 
     * This method takes list of objects and list of departments
	and return map of department name and public group id*/
    
    public static Map<String, String> getPublicGroupMapPerDepartmentPerObject(set<String> setObjectName, 
																			  set<String> setDepartmentName){                
		
		Map<String, String> mapDepartmentAndItsPublicGroupDevName = new Map<String, String>();
		Map<String, Id> mapDepartmentAndItsPubligGroupId = new Map<String, Id>();
        Map<String,Id> mapublicGroupIds = new Map<String,Id>();
		
		Set<String> setPublicGroupDeverloperName = new Set<String>();
		for (Record_Sharing__mdt rec : [SELECT  After_Sales_Public_Group__c,Label 
										FROM Record_Sharing__mdt
										WHERE Object_Name__c IN :setObjectName 
										AND Label IN : setDepartmentName]){
										
			mapDepartmentAndItsPublicGroupDevName.put(rec.Label,rec.After_Sales_Public_Group__c);
			setPublicGroupDeverloperName.add(rec.After_Sales_Public_Group__c);
		}

		mapublicGroupIds = Util.getPublicgroupIds(setPublicGroupDeverloperName);
		for(String departmentName : mapDepartmentAndItsPublicGroupDevName.keySet()){
			if(mapublicGroupIds.containsKey(mapDepartmentAndItsPublicGroupDevName.get(departmentName))){
					mapDepartmentAndItsPubligGroupId.put(departmentName,mapublicGroupIds.get(mapDepartmentAndItsPublicGroupDevName.get(departmentName)));
			}
		}		

		return  mapDepartmentAndItsPubligGroupId; 

	}
    
    /*Method to generate logic to prepare file according to the record sharing meta data*/
    public static List<Sobject> generateShareRecords(Map<Id,Id> mapRecordIdAndPublicGroupId){
        
        List<Sobject> lstshareSobjectRecords = new List<Sobject>(); // This list will hold the share object records
          
        Map<String,Boolean> mapSObjectIsCustom = new  map<String,Boolean>();
        Map<String,String> mapRecIdAndSobjectName = new Map<String,String>();
        Map<String, String> mapSobjectAndShareObjectName = new Map<String, String>();
        
        for(Id recordID : mapRecordIdAndPublicGroupId.keySet())
        {
            String sobjectName = Util.getSobjectName(recordID);
            
            
            Boolean isSObjectCustom = Util.checkObjectType(sobjectName);
            string SobjectShareName =  isSObjectCustom ?  sobjectName.replace('__c', '__Share') : sobjectName+'Share';
            
            mapRecIdAndSobjectName.put(recordId,String.valueof(sobjectName)); // This map will hold information for record id and its object name
            mapSObjectIsCustom.put( String.valueof(sobjectName),isSObjectCustom); // This map will hold information whether object is custom or standard
            mapSobjectAndShareObjectName.put(String.valueof(sobjectName),String.valueof(SobjectShareName)); // This map hold information about record id and its share sobjectname
        
        }
               
		/*This loop will create share records for records and public group ids received in the argument*/
        for(Id recordID : mapRecordIdAndPublicGroupId.keySet()){
            Schema.SObjectType shareObjectType = Schema.getGlobalDescribe().get(mapSobjectAndShareObjectName.get(mapRecIdAndSobjectName.get(recordID)));              
            Sobject shareRecord =  shareObjectType.newSobject();
            system.debug('....mapRecordIdAndPublicGroupId.get(recordId)....'+mapRecordIdAndPublicGroupId.get(recordId));
            if(string.valueOf(mapRecIdAndSobjectName.get(recordID)) == 'Account' || string.valueOf(mapRecIdAndSobjectName.get(recordID)) == 'Asset'){ // If Account or Asset object then below code will run
                shareRecord.put(string.valueOf(mapRecIdAndSobjectName.get(recordID))+'Id', recordId); 
                shareRecord.put(string.valueOf(mapRecIdAndSobjectName.get(recordID))+'AccessLevel','Edit');
                shareRecord.put('UserOrGroupId' ,mapRecordIdAndPublicGroupId.get(recordId));
                if(string.valueOf(mapRecIdAndSobjectName.get(recordID)) == 'Account')
                {
                	shareRecord.put('OpportunityAccessLevel','Edit');
                }
			}
            else{ 
				shareRecord.put('parentid',recordId);
                shareRecord.put('AccessLevel', 'Edit');
                shareRecord.put('UserOrGroupId' ,mapRecordIdAndPublicGroupId.get(recordId));               
                
            }
            lstshareSobjectRecords.add(shareRecord);
        }
        return lstshareSobjectRecords;
    }
    /*Method to insert the object sharing record in the system*/
    public static List<Sobject> insertShareRecords(List<sobject> lstObjectShareRecord){
        Database.insert(lstObjectShareRecord,false);
        return lstObjectShareRecord;
    }
}