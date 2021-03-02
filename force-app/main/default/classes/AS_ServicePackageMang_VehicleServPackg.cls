/*Created By Mayank Pant
Purpose: This class will create the vehicle service package and vehicle service package item record*/
public with Sharing class AS_ServicePackageMang_VehicleServPackg {
    
    private static final string IsForAllModel = 'IsForAllModel';

    /*Purpose: This method will create the vehicle service package for vehicles which are added in the system*/
    public static List<VehicleServicePackage__c> createVehicleServicePackage(List<Asset> lstAssetRecords){
        
        Map<String,List<Service_Package__c>> mapServicePackagePerModel = new Map<String,List<Service_Package__c>>();
        Set<Id> setVehicleModelId = new Set<ID>();
        Set<String> setCountry = new Set<String>();
        List<VehicleServicePackage__c> lstVehicleSerPakcage = new List<VehicleServicePackage__c>();
        
        for(Asset asst : lstAssetRecords){
            if(string.valueOf(asst.Vehicle_Model_LTM__c)!= ''){
                setVehicleModelId.add(asst.Vehicle_Model_LTM__c);
                setCountry.add(asst.Country__c);
            } 
        }

        mapServicePackagePerModel = getServicePackagePerModel(setVehicleModelId,setCountry);
        system.debug('mapServicePackagePerModel '+mapServicePackagePerModel);
        lstVehicleSerPakcage = generateVehicleServicePackage(lstAssetRecords,mapServicePackagePerModel);
        insertVehicleServicePackage(lstVehicleSerPakcage);
        return lstVehicleSerPakcage;
    }
    
    public static Map<String,List<Service_Package__c>> getServicePackagePerModel(set<Id> setVehicleModelId, 
                                                                             Set<String> setCountry){
        
        Map<String,List<Service_Package__c>> mapServicePackagePerModel = new Map<String,List<Service_Package__c>>();
        List<Service_Package__c> setServicePackage;
        for(Service_Package__c sp : [SELECT ID, 
                                     		Vehicle_Model__c,
                                     		SpValidity_From__c,
                                     		SpValidity_Until__c,
                                     		IsActive__c
                                     	FROM Service_Package__c
                                    	WHERE (Vehicle_Model__c in :setVehicleModelId 
                                     	OR IsForAllModel__c = TRUE)
                                    	AND Country__c in :setCountry
                                    	AND Auto_Link__c = TRUE
                                        AND IsActive__c = TRUE]){
             if(string.isNotEmpty(sp.Vehicle_Model__c)
                    &&
                mapServicePackagePerModel.containsKey(sp.Vehicle_Model__c)){
    
                    setServicePackage = new List<Service_Package__c>();
                    setServicePackage = mapServicePackagePerModel.get(sp.Vehicle_Model__c);
                    setServicePackage.add(sp);
                    mapServicePackagePerModel.put(sp.Vehicle_Model__c, setServicePackage);
                }
             if(string.isNotEmpty(sp.Vehicle_Model__c)
                                 &&
                !mapServicePackagePerModel.containsKey(sp.Vehicle_Model__c)){
                    setServicePackage = new List<Service_Package__c>();
                    setServicePackage.add(sp);
                    mapServicePackagePerModel.put(sp.Vehicle_Model__c, setServicePackage);    
                }
            
            if(string.isEmpty(sp.Vehicle_Model__c)){
                if(mapServicePackagePerModel.containsKey(IsForAllModel)){
                    setServicePackage = new List<Service_Package__c>();
                    setServicePackage = mapServicePackagePerModel.get(IsForAllModel);
                    setServicePackage.add(sp);
                    mapServicePackagePerModel.put(IsForAllModel, setServicePackage);	    
                } 
                else{
                    setServicePackage = new List<Service_Package__c>();
                    setServicePackage.add(sp);
                    mapServicePackagePerModel.put(IsForAllModel, setServicePackage);
                } 
            }
                                     
		}        
        return mapServicePackagePerModel;        
    }
    
    public static List<VehicleServicePackage__c> insertVehicleServicePackage(
        																	List<VehicleServicePackage__c> lstVehicleSerPakcage
    ){
        try{
            database.insert(lstVehicleSerPakcage, false);
            return lstVehicleSerPakcage;
        }catch(Exception ex){
            // Mayank to write a logic to inform if there is error in inserting the vehicle service package record
            system.debug('enters int he error'+ex.getMessage());
            return null;
        }
    }
    
    public static List<VehicleServicePackage__c> generateVehicleServicePackage(
        											List<Asset> lstAssetRecords,
    												Map<String,List<Service_Package__c>> mapServicePackagePerModel){
     	List<VehicleServicePackage__c> lstVehicleSerPakcage = new List<VehicleServicePackage__c>();
		for(Asset asst : lstAssetRecords){
            if(mapServicePackagePerModel.containsKey(asst.Vehicle_Model_LTM__c)){
                system.debug('enter in lstAssetRecords');
                for(Service_Package__c srvPcgk : mapServicePackagePerModel.get(asst.Vehicle_Model_LTM__c)){
                    system.debug('enter in Vehicle_Model_LTM__c');
                	VehicleServicePackage__c vehSrvpckg = new VehicleServicePackage__c();
                    vehSrvpckg.Service_Package__c = srvPcgk.Id;
                    vehSrvpckg.Vehicle__c = asst.Id;
                    if(string.valueOf(srvPcgk.SpValidity_From__c)!=null){
                        vehSrvpckg.Validity_From__c = srvPcgk.SpValidity_From__c;
                    }
                    if(string.valueOf(srvPcgk.SpValidity_Until__c)!=null){
                    	vehSrvpckg.Validity_Until__c =	srvPcgk.SpValidity_Until__c;  
                    }
                     vehSrvpckg.Is_Valid__c = srvPcgk.IsActive__c;
                     lstVehicleSerPakcage.add(vehSrvpckg);
                    
                }
            }	
            if(mapServicePackagePerModel.containsKey(IsForAllModel)){
            	for(Service_Package__c srvPcgk : mapServicePackagePerModel.get(IsForAllModel)){
                	system.debug('enter in isforallmodel');
                	VehicleServicePackage__c vehSrvpckg = new VehicleServicePackage__c();
                    vehSrvpckg.Service_Package__c = srvPcgk.Id;
                    vehSrvpckg.Vehicle__c = asst.Id;
                    if(string.valueOf(srvPcgk.SpValidity_From__c)!=null){
                        vehSrvpckg.Validity_From__c = srvPcgk.SpValidity_From__c;
                    }
                    if(string.valueOf(srvPcgk.SpValidity_Until__c)!=null){
                    	vehSrvpckg.Validity_Until__c =	srvPcgk.SpValidity_Until__c;  
                    }
                     vehSrvpckg.Is_Valid__c = srvPcgk.IsActive__c;
                     lstVehicleSerPakcage.add(vehSrvpckg);    
                }
   
            }
		}
                                                        
 	return lstVehicleSerPakcage;
    }
}