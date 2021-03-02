/*
Created By: Mayank Pant
Created Date: 10th Nov 2020
Description: General utility class to list actions/methods which are used across the CXP platform.
*/
public class Util {
    /*
Purpose: This method will return the department of the user. 
Argument: User Id
Return Type: Deparment/Dealer record of the User.
*/
    public static Department__c getDepartment(string departmentCode){
        system.debug('enters in getDepartment'+departmentCode);
        List<Department__c> lstDepartment = new List<Department__c> ([SELECT ID,
                                                                      Country__c
                                                                      FROM Department__c 
                                                                      WHERE Department_Code__c =: departmentCode]);
        if(lstDepartment!=null && !lstDepartment.isEmpty()){
            return lstDepartment[0];
            
        }
        else{return null;}
        
    }
    
    /*This method will return then pricebook that belong to the department.*/
    public static PriceBook2 getPriceBookIdByDepart(string departmentCode){
        
        List<PriceBook2> lstpriceBook = new List<PriceBook2> ([SELECT ID,
                                                               Last_Sync__c
                                                               FROM PRICEBOOK2                                                                
                                                               WHERE DEPARTMENT__r.Department_Code__c = :departmentCode
                                                               AND Type__c = 'Service']);
        system.debug('lstpriceBook is '+lstpriceBook);
        if(lstpriceBook!=null && !lstpriceBook.isEmpty()){
            return lstpriceBook[0];
        }
        else{return null;}
    }
    
    public static PriceBook2 getPriceBookId(String country){
        
        List<PriceBook2> lstpriceBook = new List<PriceBook2> ([SELECT ID 
                                                               FROM PRICEBOOK2 
                                                               WHERE country__c = :country
                                                               AND Is_Regional_Pricebook__c = TRUE]);
        if(lstpriceBook!=null && !lstpriceBook.isEmpty()){
            return lstpriceBook[0];
        }
        else{return null;}
    }
    
    public static PriceBook2 getRegionalPriceBook(string country){
        try{
            return [SELECT ID,Last_Sync__c FROM PRICEBOOK2 
                    WHERE country__c= :country
                    AND Is_Regional_Pricebook__c = true 
                    LIMIT 1];
        }catch(Exception ex){
            return null;
        } 
    }    
    
    public static PriceBook2 getNSCPriceBook (string country , string type){
        try {
            	 return [SELECT ID FROM PRICEBOOK2 
                    WHERE country__c= :country
                    AND Type__c  = :type 
                    LIMIT 1];
        }catch(Exception ex){
            return null;
        }
    }
    public static PriceBook2 getPriceBookForRepairPackage(Id repairPackageId){ 
        RepairPackage__c rpPckg = new RepairPackage__c();
        system.debug('repairPackageId '+repairPackageId);
        rpPckg = [SELECT ID,Department__c FROM RepairPackage__c where id =:repairPackageId];
        system.debug('rpPckg '+rpPckg);
        If(rpPckg!=null & rpPckg.Department__c!=null){
            system.debug('enters in the loop');
            List<PriceBook2> lstpriceBook = new List<PriceBook2> ([SELECT ID 
                                                                   FROM PRICEBOOK2 
                                                                   WHERE Department__c = :rpPckg.Department__c]);
            if(lstpriceBook!=null && !lstpriceBook.isEmpty()){
                return lstpriceBook[0];
            }
            else{return null;}    
        }
        else{
            return null;
        }
    }
    
    /*
Purpose: This method will check if the user is NSC user or GME User.
This method uses role to identify if the user is NSC User
Argument: User Id
Return Type: Boolean

*/
    public string userType(Id userId){
        // Create Labels and user role to identity the user type
        // If role starts with NSC then user is NSC user
        // If role starts with GME, then user is GME user
        // If role starts with Call Center, then user is Call Center Agent
        // If role starts with Dealer, then user is Dealer user. 
        return 'true';
    }
    
    public static Employee__c getEmployeeInformation(Id userId){
        try{
            
            return [SELECT ID,NAME,Department__c,Department__r.Country__c
                    	FROM EMPLOYEE__c
                   		WHERE user__c = :userId
                   	    LIMIT 1];
            
        }catch(Exception ex){
            return null;
        }
    }
    
    /*This method will query user detail*/
    public static User getUserInfo(Id userId){
        system.debug('enters here'+userId);
        return [SELECT ID,NAME,Department ,country FROM USER WHERE Id = :userId][0];
    }
    /* This method will query user id and pass its department id from employee object */
    public static map<Id,Id> getDepartmentID(Set<string> userId){
        List<Employee__c>  lstDepartment =new List<Employee__c>();
        lstDepartment  = [SELECT id, department__c,User__c FROM Employee__c where User__c IN : userId] ;
        system.debug('...lstDepartment1...'+lstDepartment);
        Map<ID,ID> mapUseridandDepartmentID = new Map<ID,ID>();
        for (Employee__c a : lstDepartment){
            mapUseridandDepartmentID.put(a.User__c,a.department__c);
            
        } 
        return mapUseridandDepartmentID;   
    }
    
    
    /*This method will return the sobject name of the record*/
    public static string getSobjectName(Id recordId){
        return recordId.getSObjectType().getDescribe().getName();
    }
    
    /*This method will return the sobject name Map*/
    public static Map<String,String> getSobjectName(Set<Id> setRecordId){
        Map<String,String> mapRecIdAndSobjectName = new Map<String,String>();
        for(Id recId : setRecordId){
            if(mapRecIdAndSobjectName.isEmpty()){
                mapRecIdAndSobjectName.put(string.valueOf(recId).left(3),
                                           recId.getSObjectType().getDescribe().getName());   
            }else if(!mapRecIdAndSobjectName.containskey(string.valueOf(recId).left(3))){
                mapRecIdAndSobjectName.put(string.valueOf(recId).left(3),
                                           recId.getSObjectType().getDescribe().getName());         
            }
        }
        return mapRecIdAndSobjectName;
    }  
    /*This method will return the whether sObject is custom or stanard*/
    public static Boolean checkObjectType(String objectname) {
        SObjectType objToken = Schema.getGlobalDescribe().get(objectname);
        if(objToken  != null && objToken.getDescribe().isCustom())
            return true;
        return false;
    }
    
    /*This method will return the map of department name and its department id*/
    public static Map<Id,String> getDepartmentNameIDMap(set<Id> setDepartmentId){
        map<Id,String> mapDepartmentNameID = new Map<Id,String>();
        
        for(Department__c recDep : [SELECT ID,NAME 
                                    FROM Department__c
                                    WHERE ID IN :setDepartmentId])
        {
            mapDepartmentNameID.put(recDep.Id,recDep.Name);                                         
        }
        return mapDepartmentNameID;
    }
    
    /*This method will return the department Name*/
    public static set<String> getDepartmentName(set<Id> setDepartmentId){
        Set<String> setDepartmentName= new Set<String>();
        
        for(Department__c recDep : [SELECT ID,NAME 
                                    FROM Department__c
                                    WHERE ID IN :setDepartmentId])
        {
            setDepartmentName.add(recDep.Name);                                         
        }
        return setDepartmentName;
    }
    /*Method to insert the object sharing record in the system*/
    public static Map<String,Id> getPublicgroupIds(set<String> setPublicGroupDeveloperName)
    {
        Map<String,Id> mapublicGroupIds = new Map<String, Id>();
        for(Group grpRec : [SELECT Id, DeveloperName 
                            FROM Group 
                            WHERE DeveloperName IN :setPublicGroupDeveloperName]){
                                mapublicGroupIds.put(grpRec.DeveloperName, grpRec.Id);
                            }           
        return mapublicGroupIds;
    }
    
    /*This method will retun true of user has the custom permission otherwise return false.*/
    public static Boolean userHasTheCustomPermission(String customPermissionName, Id userId){
        for(User usr : getUsersWithCustomPermission(customPermissionName)){
            if(usr.Id == userId){
                return true;
            }
        }
        return false;
    }
    
    
    
    
    /*This method will return list of users who have the custom permission received in the argument*/
    public static List<User> getUsersWithCustomPermission(String customPermissionName)
    {
        Set<Id> permissionSetIds = new Set<Id>();
        for (SetupEntityAccess access : [
            SELECT ParentId 
            FROM SetupEntityAccess 
            WHERE SetupEntityId IN (
                SELECT Id 
                FROM CustomPermission 
                WHERE DeveloperName = :customPermissionName
            )
        ]) {
            permissionSetIds.add(access.ParentId);
        }
        return permissionSetIds.isEmpty() ? new List<User>() : [
            SELECT Username FROM User WHERE Id IN (
                SELECT AssigneeId FROM PermissionSetAssignment
                WHERE PermissionSetId IN :permissionSetIds
            )
        ];
            }
    
     /*This method will return list of LaborType and Rates 
      
     */
    public static List<LaborTypeRate__c> getAllLaborRates (string country,Date referenceDate){     
        List<LaborTypeRate__c> lstLaborTypeRate = new List<LaborTypeRate__c> ([SELECT ID,
                                                                       LaborType__c,Rate__c
                                                                      FROM LaborTypeRate__c 
                                                                      WHERE country__c = :country 
                                                                      AND
                                                                    (StartDate__c<=:referenceDate and (EndDate__c>=:referenceDate or EndDate__c=null))                                      ]);
        if(lstLaborTypeRate!=null && !lstLaborTypeRate.isEmpty()){
            return lstLaborTypeRate;            
        }
        else{return null;}
        
    }
    
     /*This method will return Rates  from Labor Type Rate*/
    
     public static List<LaborTypeRate__c> getLaborRate(string country,string LaborType, Date referenceDate){     
        List<LaborTypeRate__c> lstLaborRate = new List<LaborTypeRate__c> ([SELECT ID,
                                                                      Rate__c
                                                                      FROM LaborTypeRate__c 
                                                                      WHERE country__c = :country
                                                                      AND
                                                                           LaborType__c=:LaborType
                                                                      AND 
                                                                          (StartDate__c<=:referenceDate and (EndDate__c>=:referenceDate or EndDate__c=null))]);
        if(lstLaborRate!=null && !lstLaborRate.isEmpty()){
            return lstLaborRate;            
        }
        else{return null;}
        
    }
   
}