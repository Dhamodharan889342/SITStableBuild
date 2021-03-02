/*
Ridhdi to add details about this class
*/
public class AfterSales_Customer_CustIdentification {
    
    
    @AuraEnabled
    public static List<Account> getPersonAccount1(string strfirstName, string strlastName, string strVIN , string strpassword)
    {
        system.debug('welcome to my method');
        system.debug('welcome to my method-strfirstName'+strfirstName);
         system.debug('welcome to my method-strlastName'+strlastName);
         system.debug('welcome to my method-strVIN'+strVIN);
         system.debug('welcome to my method-strpassword'+strpassword);
         
        
        List<Account>  lstPersonAccount=new List<Account>();  
        Map<Id,Id> recordIdAndDepartmentID=new Map<Id,Id>();
        
        lstPersonAccount=[Select    Id, Name, FirstName, LastName, PersonEmail, Phone, GAId__c,(Select ID, 	VIN__c, Licence_plate_after_registration__c 
                                                                                                from  Assets)
                                                                                                //where VIN__c =: strVIN 
                                                                                                //AND Licence_plate_after_registration__c=:strpassword)                          
                          From     Account                           
                          Where   
                          (Name =: strfirstName +' '+strlastName OR (FirstName =: strfirstName AND LastName =: strlastName)) 
                          
                          AND 
                          
                          (Phone=:strpassword or PersonEmail=:strpassword or GAId__c=:strpassword )
                          
                         ];
        system.debug('...lstPersonAccount1...'+lstPersonAccount);
        
         if(lstPersonAccount.isEmpty()){
             
         //set<ID> vehicleAccountID = new set<ID>();
          ID  vehicleAccountID = [Select AccountId from  Asset where VIN__c =: strVIN  AND Licence_plate_after_registration__c=:strpassword].AccountId ;
             lstPersonAccount = [select id,(select id from assets where AccountId =:vehicleAccountID ) from Account where id =: vehicleAccountID];
             system.debug('...lstPersonAccount-vehicle account...'+lstPersonAccount);
         }
        
        Map<ID,ID> mapUserIdDepartmentID = new  Map<ID,ID>();
        set<string> loginUserID = new set<string>();
        loginUserID.add(userinfo.getuserid());
        id userId = userinfo.getuserid();
        mapUserIdDepartmentID = Util.getDepartmentID(loginUserID);
        Set<ID> setDepartmentId = new  Set<ID>();
        ID setDepartmentId1 = mapUserIdDepartmentID.get(userId);
        setDepartmentId.add(setDepartmentId1);
        
        // for(Account a:lstPersonAccount)
        List<Asset> lstasset = lstPersonAccount[0].Assets;
        
        system.debug('...lstasset...'+lstasset);
        recordIdAndDepartmentID.put(lstPersonAccount[0].id,setDepartmentId1);
        system.debug('...lstasset-recordIdAndDepartmentID1...'+recordIdAndDepartmentID);
        for( Asset avehicle :lstasset )
        { 
            recordIdAndDepartmentID.put(avehicle.Id,setDepartmentId1);
            system.debug('...lstasset-recordIdAndDepartmentID2...'+recordIdAndDepartmentID);
        }
        system.debug('...lstasset-recordIdAndDepartmentID3...'+recordIdAndDepartmentID);
        
        
        Set<String> setObjectName = new Set<String>();
        if( !lstPersonAccount.isEmpty())
        {
            setObjectName.add('Account');
            setObjectName.add('Asset');
        }
        
        
        //AfterSales_RecordSharing obj1 = new AfterSales_RecordSharing();
        // employee department name is not null
        // AfterSales_RecordSharing RecSha=new AfterSales_RecordSharing();
        // RecSha.getPublicGroupMapPerDepartmentPerObject(setObjectName,departmentname,AccIdandAssetId);
        AfterSales_TriggerHandler_RecordSharing.performProgrammaticRecordSharing(recordIdAndDepartmentID,setDepartmentId,setObjectName);
        system.debug('...lstPersonAccount2...'+lstPersonAccount);
        return lstPersonAccount;
        
        
    }
    
}