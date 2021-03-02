trigger VehicleTrigger on Asset (after insert, before insert, after update, before update, after delete, before delete) {
    //GME_TriggerDispatcher.Run(new VehicleTriggerHandler());
    
   //added by Pankaj mishra to calculate rollup summary for lookup
   if (Trigger.isInsert) {
       //rollupAvailableVehicle.calculateRollup(trigger.new);
       // added by Mayank Pant https://jira.hyundai-autoever.eu/browse/GD-1335
       AS_ServicePackageMang_VehicleServPackg.createVehicleServicePackage(Trigger.new);
        
       
       
         
   }
   // if (Trigger.isUpdate || Trigger.isDelete ) {
     //  rollupAvailableVehicle.calculateRollup(trigger.old);
           
  // }
   
    
}