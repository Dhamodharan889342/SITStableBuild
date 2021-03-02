/*
 Author: Neha Aggrawal
Created Date: 18-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1026
*/
public class AS_StatusConfirmationExtension {
    public list<VehicleWrapper> recordlist { get; set;}
    public boolean showDeliverySection{get; set;}
    private final StatusConfirmation__c statusconfirmation;
    public AS_StatusConfirmationExtension(ApexPages.StandardController stdController){
        this.statusconfirmation=(StatusConfirmation__c)stdController.getRecord();
        if(apexpages.currentpage().getparameters().get('recordtypename')=='Pickup')
            showDeliverySection=false;
    }
    //wrapper class to get vehicle and vehicle model information
    public list<VehicleWrapper> getvehicleinfo(){
        recordlist = new List<VehicleWrapper>();
        Id	 astId =[Select Repair__r.Vehicle__c from StatusConfirmation__c where Id =:statusconfirmation.Id].Repair__r.Vehicle__c;
        for(Asset ast: [Select Id,Account.Name, Account.PersonMobilePhone, Account.PersonHomePhone, Account.PersonEmail, Vehicle_Model_LTM__r.Model__c,Vehicle_Model_LTM__r.Engine_Capacity__c,Model_Year__c,
                        Vehicle_Model_LTM__r.Fuel_Type__c,Color__c,
                         Latest_Mileage__c, Licence_plate_after_registration__c, VIN__c from Asset where Id =:astId] )
        {
            recordlist.add(new VehicleWrapper(ast));
        }
        System.debug(recordlist);
        return recordlist;
        
    }


public class VehicleWrapper {
public Asset record  { get; set;}
        public VehicleWrapper(Asset record){
            this.record = record;
           
        }
}
}