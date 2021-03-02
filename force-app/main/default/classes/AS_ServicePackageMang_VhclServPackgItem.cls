/*Created By Mayank Pant
Purpose: This class will create the vehicle service package item records for the vehicle service
		 vehicle service package*/
public class AS_ServicePackageMang_VhclServPackgItem {

    /*Purpose: This method will create the vehicle service package for vehicles which are added in the system*/
    public static List<Vehicle_Service_Package_Item__c> createVehicleServicePackageItem(
        														List<VehicleServicePackage__c> lstVehicleServPackage){
    	
    	set<Id> setServPackgId = new Set<Id>();
        Map<Id,List<Service_Package_Item__c>> mapSrvPck_ServPckgItms = new Map<Id,List<Service_Package_Item__c>>();
        List<Vehicle_Service_Package_Item__c> lstVehicleServicePackgItem = new List<Vehicle_Service_Package_Item__c>();
        
        for(VehicleServicePackage__c vhcSrvPckg : lstVehicleServPackage){
            setServPackgId.add(vhcSrvPckg.Service_Package__c);
        }
        mapSrvPck_ServPckgItms = getServPackageItemDetails(setServPackgId);  
        lstVehicleServicePackgItem = prepareVehicleServicePckgItemRecords(lstVehicleServPackage, mapSrvPck_ServPckgItms);
        return insertSrvPckgItemRecords(lstVehicleServicePackgItem);
  
    }
    
    /*This method will prepare vehicle Service Package Item records for received vehicle service package item records*/
    public static List<Vehicle_Service_Package_Item__c> prepareVehicleServicePckgItemRecords(
        											List<VehicleServicePackage__c> lstVehicleServPackage,
                                                    Map<Id,List<Service_Package_Item__c>> mapSrvPck_ServPckgItms)
    {
        Map<String,Id> mapRecordType = new Map<String,Id>();
        mapRecordType = getVehicleServicePackageItemRecordType();                                               
        List<Vehicle_Service_Package_Item__c> lstVehicleServicePackgItem = new List<Vehicle_Service_Package_Item__c>();
                                                        
        for(VehicleServicePackage__c vehcSrvPckg : lstVehicleServPackage){
        	Integer numberOfTimes = 1;

            if(mapSrvPck_ServPckgItms.containsKey(vehcSrvPckg.Service_Package__c)){
               
                for(Service_Package_Item__c srvPckgItm : mapSrvPck_ServPckgItms.get(vehcSrvPckg.Service_Package__c)){
					Vehicle_Service_Package_Item__c vehcSrvPckgItm = new Vehicle_Service_Package_Item__c();
                	vehcSrvPckgItm.Vehicle__c = vehcSrvPckg.Vehicle__c;
                    vehcSrvPckgItm.Name = srvPckgItm.Name;
                    vehcSrvPckgItm.Vehicle_Service_Package__c = vehcSrvPckg.ID;
                    vehcSrvPckgItm.SpiUnitPrice__c = srvPckgItm.SpiUnitPrice__c;
                   
                    vehcSrvPckgItm.Service_Package_Item__c = srvPckgItm.Id;
                    vehcSrvPckgItm.Tax__c = srvPckgItm.Tax__c;
                    vehcSrvPckgItm.LineItemType__c = srvPckgItm.LineItemType__c;
                     if(mapRecordType.containsKey(srvPckgItm.LineItemType__c)){
                        vehcSrvPckgItm.RecordTypeId = mapRecordType.get(srvPckgItm.LineItemType__c);
                    }
                     if(srvPckgItm.Hours__c!=null){
                    	vehcSrvPckgItm.Hours__c = srvPckgItm.Hours__c;    
                    }
                    vehcSrvPckgItm.Product__c= srvPckgItm.Product__c;
                    if(srvPckgItm.Quantity__c!=null){
                    	vehcSrvPckgItm.Quantity__c = srvPckgItm.Quantity__c;    
                    }
                    system.debug('vehcSrvPckgItm '+vehcSrvPckgItm);
                    lstVehicleServicePackgItem.add(vehcSrvPckgItm);
                }
            }
        }
		return lstVehicleServicePackgItem;
    }
    
    /*This method will return service package item items related to service package ids received in the argument*/
    public static Map<Id,List<Service_Package_Item__c>> getServPackageItemDetails(set<Id> setServPackgId)
    {
    	Map<Id,List<Service_Package_Item__c>> mapSrvPck_ServPckgItms = new Map<Id,List<Service_Package_Item__c>>();
        for(Service_Package_Item__c srvPckgItem : [SELECT ID,
                                                	   Name,
                                                       Service_Package__c,
                                                       SpiUnitPrice__c,
                                                       Hours__c,
                                                       Tax__c,
                                                       LineItemType__c,
                                                       Product__c,
                                                       Quantity__c
                                                FROM Service_Package_Item__c
                                                WHERE Service_Package__c IN :setServPackgId])
        {
            if(mapSrvPck_ServPckgItms.containsKey(srvPckgItem.Service_Package__c)){
            	List<Service_Package_Item__c> lstSrvPckgItem = new List<Service_Package_Item__c>();
                lstSrvPckgItem = mapSrvPck_ServPckgItms.get(srvPckgItem.Service_Package__c);
                lstSrvPckgItem.add(srvPckgItem);
                mapSrvPck_ServPckgItms.put(srvPckgItem.Service_Package__c,lstSrvPckgItem);
                
            }else{
                mapSrvPck_ServPckgItms.put(srvPckgItem.Service_Package__c,new List<Service_Package_Item__c>{srvPckgItem});    
            }
            
        }
        return mapSrvPck_ServPckgItms;
    }
    
    public static List<Vehicle_Service_Package_Item__c> insertSrvPckgItemRecords(List<Vehicle_Service_Package_Item__c> lstVehicleServicePackgItem){
        try{
            system.debug('lstVehicleServicePackgItem '+lstVehicleServicePackgItem.get(0));
         	Database.insert(lstVehicleServicePackgItem, false);        
        } catch(Exception ex){
            // Mayank to Write code for exception
            return null;
        }
        return lstVehicleServicePackgItem;
    }
	
    public static Map<String,Id> getVehicleServicePackageItemRecordType(){
        Map<String,Id> mapRecordType = new Map<String,Id>();
        
        for(RecordType recTyp : [SELECT ID,DEVELOPERNAME FROM RECORDTYPE WHERE SOBJECTTYPE = 'Vehicle_Service_Package_Item__c']){
        	mapRecordType.put(recTyp.DEVELOPERNAME,recTyp.Id);
        }
        return mapRecordType;
    }
}