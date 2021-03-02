trigger trgRelatedRepairPackage on Related_Repair_Package__c (after insert) {
    /*This method will create the service repair package item records for added related repair package item records*/
    AS_ServicePackageMang_RelatedRepPackItm.createServicePackageItemRecords(Trigger.New);   
}