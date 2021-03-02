/******************************************************************************************
  * File Name   : AS_SchedRepair_AppointmentCreationTest
  * Created Date: 21th December 2020
  * Description : Apex test class for AS_SchedRepair_AppointmentCreationCtrl. It's used for implementation of GD-547 ( Workshop scheduling for new repair reservation (GPA/SA) ). It's used for overwriting standard Service Booking (API Name: Repair__c) new record creation page.
  * Author      : Konrad Maluszkiewicz
  * Modification Log
  * =======================================================================
  * Ver     Date             Author                      Modification
  * =======================================================================
  * 1.0     21.12.2020       Konrad Maluszkiewicz        Creation
  ****************************************************************************************/

@isTest
private class AS_SchedRepair_AppointmentCreationTest {
/*
@AuraEnabled
public static String getRelatedDepartmentId() {
    Id currentUserId = UserInfo.getUserId();
    Id relatedDepartmentId;

    List<Employee__c> employeesList;
    try {
        employeesList = [
            SELECT Department__c
            FROM Employee__c
            WHERE User__c =:currentUserId
        ];
        System.debug('employeesList = ' + employeesList);

        if (employeesList?.size() == 1) {
            return employeesList[0].Department__c;
        }
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return '';
}
*/
    @testSetup
    static void setupTestData() {
        Asset assetRecord = new Asset(Name = 'Asset Name');
        insert assetRecord;

        // Department__c departmentRecord = new Department__c(Department_Code__c = 'test deparment code', Name = 'test department', State__c = 'Hessen');
        // insert departmentRecord;

        // Account accountRecord = new Account(Name = 'test Account', Major_Language__c = 'en_US', Preferred_ZipCode__c = 'test zip', Contact_Details__c = 'Email');
        // insert accountRecord;
        // Contact contactRecord = new Contact(AccountId = accountRecord.Id, LastName = 'Doe');
        // insert contactRecord;

        // //required fields missing: [EmploymentEndDate__c, EmploymentStartDate__c, Role__c, Salutation__c, Sex__c]
        // Employee__c employee = new Employee__c(User__c = UserInfo.getUserId(), Department__c = departmentRecord.Id, Contact__c = contactRecord.Id, Contact_details__c = 'Email', Country__c = 'United Kingdom', EmploymentEndDate__c = Date.today().addMonths(3), EmploymentStartDate__c = Date.today().addMonths(-3), Role__c = 'Technician', Salutation__c = 'Mr.', Sex__c = 'Male');
        // insert employee;


// OperatingHours operatingHoursRecord = new OperatingHours(
//     Name = '9 To 5',
//     TimeZone = 'Europe/Berlin'
// );
// insert operatingHoursRecord;

// ServiceTerritory serviceTerritoryRecord = new ServiceTerritory();
// serviceTerritoryRecord.Name = 'Test Territory';
// serviceTerritoryRecord.OperatingHoursId = operatingHoursRecord.Id;
// serviceTerritoryRecord.IsActive = TRUE;
// serviceTerritoryRecord.Department__c = departmentRecord.Id;
// insert serviceTerritoryRecord;

//         ServiceResource servResourceRecord = new ServiceResource(
//             AccountId = accountRecord.Id,
//             Department__c = departmentRecord.Id,
//             Employee__c = employee.Id,
//             Name = 'test service resource',
//             ResourceType = 'T',
//             RelatedRecordId = UserInfo.getUserId(),
//             IsActive = true
//         );
//         insert servResourceRecord;
// System.debug('inserted servResourceRecord = ' + servResourceRecord);

// ServiceTerritoryMember serviceTerritoryMemberRecord = new ServiceTerritoryMember();
// serviceTerritoryMemberRecord.TerritoryType = 'P';
// serviceTerritoryMemberRecord.ServiceTerritoryId = serviceTerritoryRecord.Id;
// serviceTerritoryMemberRecord.ServiceResourceId = servResourceRecord.Id;
// serviceTerritoryMemberRecord.EffectiveStartDate = Date.today().addYears(-1);
// serviceTerritoryMemberRecord.EffectiveEndDate = Date.today().addYears(2);
// insert serviceTerritoryMemberRecord;

//         Schema.Location locationRecord = new Schema.Location(
//             Name = 'test location',
//             LocationType = 'Warehouse'
//         );
//         insert locationRecord;

//         Schema.Address addressRecord = new Schema.Address(
//             ParentId = locationRecord.Id,
//             LocationType = 'Warehouse'
//         );
//         insert addressRecord;

// Case caseRecord = new Case(
//     AccountId = accountRecord.Id,
//     Status = 'New',
//     Origin = 'Homepage'
// );
// insert caseRecord;

// WorkOrder workOrderRecord = new WorkOrder(
//     AccountId = accountRecord.Id,
//     CaseId = caseRecord.Id
// );
// insert workOrderRecord;

//         ServiceAppointment servAppointmentRecord = new ServiceAppointment(
//             ParentRecordId = workOrderRecord.Id,
//             DueDate = System.now().addMonths(3),
//             Duration = 5,
//             SchedStartTime = System.now().addMonths(1),
//             SchedEndTime = System.now().addMonths(2),
//             EarliestStartTime = System.now().addDays(1)
//         );
//         insert servAppointmentRecord;

//         AssignedResource assignedResourceRecord = new AssignedResource(
//             ServiceAppointmentId = servAppointmentRecord.Id,
//             ServiceResourceId = servResourceRecord.Id
//         );
//         insert assignedResourceRecord;

// not to include START
        // SELECT Id, Employee__c
        // FROM ServiceResource
        // WHERE Employee__r.Department__c = :getRelatedDepartmentId()

        // Repair__c repairRecord = new Repair__c();
        // insert repairRecord;

        // ServiceAppointment sa = new ServiceAppointment();
        // sa.SchedStartTime = Date.today();
        // sa.SchedEndTime = Date.today();
        // insert sa;
// not to include END
    }

    // <c:AS_CustomLookup objectAPIName="Asset" IconName="standard:asset_object" selectedRecord="{!v.selectedLookUpAssetRecord}" label="Vehicle Name" id="assetCustomLookup"/>
/*

REQUIRED_FIELD_MISSING, Required fields are missing: [DepartmentVehicle__c, Service_Resource__c]: [DepartmentVehicle__c, Service_Resource__c]

*/
    @isTest
    static void testGetServiceBookingObjectLabel() {
        System.assertEquals(SObjectType.Repair__c.getLabel(), AS_SchedRepair_AppointmentCreationCtrl.getServiceBookingObjectLabel(), 'Service Booking (API Name: Repair__c) label isn\'t properly assigned...');
    }

    @isTest
    static void testCustomLookupControllerFetchingLookUpValues() {
        List<sObject> fetchedLookUpValues = AS_CustomLookUpController.fetchLookUpValues('Asset Name', 'Asset');
        System.assertEquals(1, fetchedLookUpValues.size());
    }

    @isTest
    static void testSetGeolocationsForAddresses() {
        Repair__c repair = new Repair__c();
        repair = AS_SchedRepair_AppointmentCreationCtrl.setGeolocationsForAddresses(repair,'','');
        System.assertEquals(45, repair.Pickup_Location_Geo__Latitude__s);
        System.assertEquals(90, repair.Pickup_Location_Geo__Longitude__s);
        System.assertEquals(50, repair.Drop_Off_Location_Geo__Latitude__s);
        System.assertEquals(95, repair.Drop_Off_Location_Geo__Longitude__s);
    }

    @isTest
    static void testGetRelatedDepartmentId() {
        Id departmentId = [
            SELECT Department__c
            FROM Employee__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ][0].Department__c;

        System.assertEquals(departmentId, AS_SchedRepair_AppointmentCreationCtrl.getRelatedDepartmentId());
    }

    @isTest
    static void testGetRelatedDepartmentName() {
        System.assertEquals('test department', AS_SchedRepair_AppointmentCreationCtrl.getRelatedDepartmentName());
    }
/*
        let jSONRepairStr = '{"serviceBookingId":"' + assetRecord['Id']
        + '","customerId":"' + accountRecord['Id']
        + '","receivingDate":"' + component.find("receivingDate").get("v.value")
        + '","repairCompleteDate":"' + component.find("repairCompleteDate").get("v.value")
        + '","serviceResourceId":"' + serviceResourceRecord['Id']
        + '","pickupPersonId":"' + pickupPersonRecord['Id']
        + '","pickupAddressString":"' + component.find("pickupAddress").get("v.value")
        + '","dropOffAddress":"' + component.find("dropOffAddress").get("v.value")
        + '","repairPackagesList":' + JSON.stringify(repairPackagesList)
        + ',"individualRepairItemsList":' + JSON.stringify(individualRepairItemsList)
        + '}';
*/
    @isTest
    static void testInsertRepair() {
        Id assetId = [
            SELECT Id
            FROM Asset
        ].Id;

        Id accountId = [
            SELECT Id
            FROM Account
        ].Id;

        Id pickupPersonId = [
            SELECT Id
            FROM Employee__c
        ].Id;

        Id serviceResourceId = [
            SELECT Id
            FROM ServiceResource
        ].Id;

        String jSONRepair =
        '{"serviceBookingId":"' + assetId + 
        '","receivingDate":"' + String.valueOf(Date.today()) +
        '","repairCompleteDate":"' + String.valueOf(Date.today().addDays(3)) +
        '","serviceResourceId":"' + serviceResourceId +
        '","pickupAddressString":"test address 1' +
        '","dropOffAddress":"test address 2' +
        '","customerId":"' + accountId + 
        '","pickupPersonId":"' + pickupPersonId +
        '","repairPackagesList":[]' + 
        ',"individualRepairItemsList":[]}';

System.debug('flag_0 = ' + jSONRepair);

        AS_SchedRepair_AppointmentCreationCtrl.insertRepair(jSONRepair);

System.debug('flag_2 # repair = ' + [SELECT Name FROM Repair__c]);
        System.assertEquals(1, [SELECT Name FROM Repair__c].size());
    }

    @isTest
    static void testGetVehicleAndDepartmentWrapperJSON() {
        Id assetId = [
            SELECT Id
            FROM Asset
            WHERE Name = 'Asset Name'
        ].Id;
        Id departmentId = [
            SELECT Id
            FROM Department__c
            WHERE Name = 'test department'
        ].Id;
        String resultString = AS_SchedRepair_AppointmentCreationCtrl.getVehicleAndDepartmentWrapperJSON(String.valueOf(assetId));
        String expectedResult = '{"vehicle":{"attributes":{"type":"Asset","url":"/services/data/v50.0/sobjects/Asset/' + String.valueOf(assetId) + '"},"Id":"' + String.valueOf(assetId) + '","Name":"Asset Name"},"repairPackagesList":[],"departmentId":"' + String.valueOf(departmentId) + '"}';
        System.assertEquals(expectedResult, resultString);
    }

    // @isTest
    // static void testInsertRepair() {
        // String jSONRepair = '';
//         Id assetId = [SELECT Id FROM Asset LIMIT 1].Id;
// System.debug('assetId = ' + assetId);
//         Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
// System.debug('accountId = ' + accountId);
//         Id employeeId = [SELECT Id FROM Employee__c LIMIT 1].Id;
// System.debug('employeeId = ' + employeeId);
        // String jSONRepair = '{"serviceBookingId":"' + assetId + '","customerId":"' + accountId + '","receivingDate":"' + Datetime.now().addMonths(-1).format('yyyy-MM-dd')
        // + '","repairCompleteDate":"' + Datetime.now().addMonths(1).format('yyyy-MM-dd') + '","serviceResourceId":"' + employeeId + '","pickupPersonId":"' + employeeId + '","pickupAddressString":"test 1","dropOffAddress":"test 2"}';

        // System.debug('jSONRepair = ' + jSONRepair);
        // String insertResult = AS_SchedRepair_AppointmentCreationCtrl.insertRepair(jSONRepair);
        // System.debug('insertResult = ' + insertResult);
        // System.assertEquals(18,insertResult.length());
    // }

    // @isTest
    // static void testMethod1() {
        // Asset assetRecord = new Asset();
        // assetRecord.Name = 'Test Asset Name';
        // insert assetRecord;

        // Employee__c employeeRecord = new Employee__c();
        // insert employeeRecord;

        // Repair__c repairRecord = new Repair__c();
        // repairRecord.DepartmentVehicle__c = assetRecord.Id;
        // REQUIRED_FIELD_MISSING, Required fields are missing: [Service_Resource__c]: [DepartmentVehicle__c, Service_Resource__c]
        // insert repairRecord;
        // System.assertEquals(1,[SELECT Id FROM ServiceAppointment].size());
    // }
}