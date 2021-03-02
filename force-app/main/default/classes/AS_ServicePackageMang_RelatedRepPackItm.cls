/*
    Created By Mayank Pant
    Purpose: This class will create the  service package item records when related repair package 
             is created for a service package
    User Story: https://jira.hyundai-autoever.eu/browse/GD-2132
*/
public class AS_ServicePackageMang_RelatedRepPackItm { 
	
    /*This method will be called from Related Repair Package Trigger. 
      This method will receive list of related repair package and will create service package item records
	*/
    public static List<Service_Package_Item__c> createServicePackageItemRecords(List<Related_Repair_Package__c> lstRelatedRepPckg){
    
        set<Id> setReparPackgId = new Set<Id>();
        Map<Id,List<RepairPackageItem__c>> mapRepPckRepPckgItms = new Map<Id,List<RepairPackageItem__c>>();
        List<Service_Package_Item__c> lstServicePackgItem = new List<Service_Package_Item__c>();
        
        for(Related_Repair_Package__c rpPckg : lstRelatedRepPckg){
            setReparPackgId.add(rpPckg.Repair_Package__c);
        }
        mapRepPckRepPckgItms = getReparPackageItemDetails(setReparPackgId);  
        lstServicePackgItem = prepareServicePckgItemRecords(lstRelatedRepPckg, mapRepPckRepPckgItms);
        return insertSrvPckgItemRecords(lstServicePackgItem);
    }
    
    /*This method will return repair package items related to repair package ids received in the argument*/
    public static Map<Id,List<RepairPackageItem__c>> getReparPackageItemDetails(set<Id> setReparPackgId){
    	Map<Id,List<RepairPackageItem__c>> mapRepPckRepPckgItms = new Map<Id,List<RepairPackageItem__c>>();
        for(RepairPackageItem__c repPckgItem : [SELECT ID,
                                                	   Name,
                                                       RepairPackage__c,
                                                       UnitPrice__c,
                                                       Hours__c,
                                                       Tax__c,
                                                       LineItemType__c,
                                                       RecordType.Name,
                                                       Product__c,
                                                       Quantity__c
                                                FROM RepairPackageItem__c
                                                WHERE RepairPackage__c IN :setReparPackgId])
        {
            if(mapRepPckRepPckgItms.containsKey(repPckgItem.RepairPackage__c)){
            	List<RepairPackageItem__c> lstRepairPackgItem = new List<RepairPackageItem__c>();
                lstRepairPackgItem = mapRepPckRepPckgItms.get(repPckgItem.RepairPackage__c);
                lstRepairPackgItem.add(repPckgItem);
                mapRepPckRepPckgItms.put(repPckgItem.RepairPackage__c,lstRepairPackgItem);
                
            }else{
                mapRepPckRepPckgItms.put(repPckgItem.RepairPackage__c,new List<RepairPackageItem__c>{repPckgItem});    
            }
            
        }
        return mapRepPckRepPckgItms;
                                                    
    }
    
    /*This method will prepare Service Package Item records for received repair package item records*/
    public static List<Service_Package_Item__c> prepareServicePckgItemRecords(List<Related_Repair_Package__c> lstRelatedRepPckg,
                                                    Map<Id,List<RepairPackageItem__c>> mapRepPckRepPckgItms){
        
        Map<String,Id> mapRecordType = new Map<String,Id>();
        mapRecordType = getServicePackageRecordType();                                               
        List<Service_Package_Item__c> lstServicePackgItem = new List<Service_Package_Item__c>();
                                                        
        for(Related_Repair_Package__c rltRepPckg : lstRelatedRepPckg){
        	Integer numberOfTimes = 1;
            if(rltRepPckg.Number_of_Times__c!=null & rltRepPckg.Number_of_Times__c!=0){
            	numberOfTimes =  Integer.valueOf(rltRepPckg.Number_of_Times__c);
            }
            if(mapRepPckRepPckgItms.containsKey(rltRepPckg.Repair_Package__c)){
               
                for(RepairPackageItem__c repPckgItm : mapRepPckRepPckgItms.get(rltRepPckg.Repair_Package__c)){
					Service_Package_Item__c spPckgItm = new Service_Package_Item__c();
                	//spPckgItm.Name = repPckgItm.Name; // Commented for Field is not writable @ 09 Feb 2021
                    spPckgItm.Service_Package__c = rltRepPckg.Service_Package__c;
                    spPckgItm.SpiUnitPrice__c = repPckgItm.UnitPrice__c;
                    if(repPckgItm.Hours__c!=null){
                    	spPckgItm.Hours__c = repPckgItm.Hours__c * numberOfTimes;    
                    }
                    spPckgItm.Repair_Package_Item__c = repPckgItm.Id;
                    spPckgItm.Tax__c = repPckgItm.Tax__c;
                    spPckgItm.LineItemType__c = repPckgItm.LineItemType__c;
                     if(mapRecordType.containsKey(repPckgItm.LineItemType__c)){
                        spPckgItm.RecordTypeId = mapRecordType.get(repPckgItm.LineItemType__c);
                    }
                    spPckgItm.Product__c= repPckgItm.Product__c;
                    if(repPckgItm.Quantity__c!=null){
                    	spPckgItm.Quantity__c = repPckgItm.Quantity__c * numberOfTimes;    
                    }
                    lstServicePackgItem.add(spPckgItm);
                }
            }
        }
		return lstServicePackgItem;
    }
    /*This method will perform the dml operation and will create the service package item records*/
    public static List<Service_Package_Item__c> insertSrvPckgItemRecords(List<Service_Package_Item__c> lstServicePackgItem){
        try{
            system.debug('');
         	Database.insert(lstServicePackgItem, false);        
        } catch(Exception ex){
            // Mayank to Write code for exception
            return null;
        }
        return lstServicePackgItem;
    }
    
    public static Map<String,Id> getServicePackageRecordType(){
        Map<String,Id> mapRecordType = new Map<String,Id>();
        
        for(RecordType recTyp : [SELECT ID,DEVELOPERNAME FROM RECORDTYPE WHERE SOBJECTTYPE = 'Service_Package_Item__c']){
        	mapRecordType.put(recTyp.DEVELOPERNAME,recTyp.Id);
        }
        return mapRecordType;
    }
}