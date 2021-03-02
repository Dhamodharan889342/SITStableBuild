/*
Author: Neha Aggrawal
Created Date: 28-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1257
*/
public class AS_VehicleInspectionExtension {
 public list<VehicleInsWrapper> recordlist { get; set;}
    private final Vehicle_Inspection_Report__c vehicleInspection;
    public AS_VehicleInspectionExtension(ApexPages.StandardController stdController){
        this.vehicleInspection=(Vehicle_Inspection_Report__c)stdController.getRecord();
    }
    //wrapper class to get vehicle and vehicle model information
    public list<VehicleInsWrapper> getvehicleInsinfo(){
        recordlist = new List<VehicleInsWrapper>();
        Id  astId =[Select Service_Booking__r.Vehicle__c from Vehicle_Inspection_Report__c where Id =:vehicleInspection.Id].Service_Booking__r.Vehicle__c;
        for(Asset ast: [Select Id,Account.Name, Account.PersonMobilePhone, Account.PersonHomePhone, Account.PersonEmail, Vehicle_Model_LTM__r.Model__c,Vehicle_Model_LTM__r.Engine_Capacity__c,Model_Year__c,
                        Vehicle_Model_LTM__r.Fuel_Type__c,Color__c,
                         Latest_Mileage__c, Licence_plate_after_registration__c, VIN__c from Asset where Id =:astId] )
        {
            recordlist.add(new VehicleInsWrapper(ast));
        }
        System.debug(recordlist);
        return recordlist;
        
    }


public class VehicleInsWrapper {
public Asset record  { get; set;}
        public VehicleInsWrapper(Asset record){
            this.record = record;
           
        }
}
}