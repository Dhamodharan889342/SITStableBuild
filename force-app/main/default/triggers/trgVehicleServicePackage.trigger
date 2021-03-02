trigger trgVehicleServicePackage on VehicleServicePackage__c(after insert) {
    /*This method will create the vehicle service package item records for added vehicle service package records*/
    AS_ServicePackageMang_VhclServPackgItem.createVehicleServicePackageItem(Trigger.New);  
 }