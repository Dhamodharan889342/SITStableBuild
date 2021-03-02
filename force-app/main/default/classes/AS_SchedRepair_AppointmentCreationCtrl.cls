/******************************************************************************************
  * File Name   : AS_SchedRepair_AppointmentCreationCtrl
  * Created Date: 18th December 2020
  * Description : Apex controller for Lightning Aura component AS_SchedRepair_AppointmentCreation. It's used for implementation of GD-547 ( Workshop scheduling for new repair reservation (GPA/SA) ). It's used for overwriting standard Service Booking (API Name: Repair__c) new record creation page.
  * Author      : Konrad Maluszkiewicz
  * Modification Log
  * =======================================================================
  * Ver     Date             Author                      Modification
  * =======================================================================
  * 1.0     18.12.2020       Konrad Maluszkiewicz        Creation
  ****************************************************************************************/

  public with sharing class AS_SchedRepair_AppointmentCreationCtrl {
    private static final String HERE_LATITUDE = 'lat';
    private static final String HERE_LONGITUDE = 'lng';
    private static final String HERE_DURATION = 'duration';
    private static final String HERE_LENGTH = 'length';

    @AuraEnabled
    public static String getServiceBookingObjectLabel() {
        return SObjectType.Repair__c.getLabel();
    }

    @AuraEnabled
    public static String insertRepair(String jSONRepair) {
        System.debug('jSONRepair = ' + jSONRepair);

        AppointmentCreationWrapper appointmentCreationWrapper = (AppointmentCreationWrapper) System.JSON.deserialize(jSONRepair, AppointmentCreationWrapper.class);

System.debug('1# assetRecordId = ' + appointmentCreationWrapper.assetRecordId);
System.debug('2# customerId = ' + appointmentCreationWrapper.customerId);
System.debug('3# serviceResourceId = ' + appointmentCreationWrapper.serviceResourceId);
System.debug('4# receivingDatetimeMS = ' + appointmentCreationWrapper.receivingDatetimeMS);
System.debug('5# repairCompleteDatetimeMS = ' + appointmentCreationWrapper.repairCompleteDatetimeMS);
System.debug('6# pickupPersonId = ' + appointmentCreationWrapper.pickupPersonId);
System.debug('7# pickupAddressString = ' + appointmentCreationWrapper.pickupAddressString);
// System.debug('8# dropOffAddress = ' + appointmentCreationWrapper.dropOffAddress);
System.debug('9# repairPackagesList = ' + appointmentCreationWrapper.repairPackagesList);
System.debug('10# individualRepairItemsList = ' + appointmentCreationWrapper.individualRepairItemsList);

        Repair__c newRepairRecord = new Repair__c();
        newRepairRecord.DepartmentVehicle__c = appointmentCreationWrapper.assetRecordId;
        newRepairRecord.PickupPerson__c = appointmentCreationWrapper.pickupPersonId;
        newRepairRecord.Vehicle__c = appointmentCreationWrapper.assetRecordId;
        newRepairRecord = setGeolocationsForAddresses(newRepairRecord,appointmentCreationWrapper.pickupAddressString,'');

ServiceAppointment serviceAppointmentRecord = new ServiceAppointment();
serviceAppointmentRecord.SchedStartTime = Datetime.newinstance(appointmentCreationWrapper.receivingDatetimeMS);

System.debug('serviceAppointmentRecord.SchedStartTime = ' + serviceAppointmentRecord.SchedStartTime);

List<AS_CalendarSetting__c> calendarSettingsList = AS_CalendarSetting__c.getall().values();
Integer pickupDurationInMinutes;

for (AS_CalendarSetting__c calSetting : calendarSettingsList) {
    if (calSetting.Name == 'Pickup Time') {
        pickupDurationInMinutes = Integer.valueOf(calSetting.RequiredTime__c);
        break;
    }
}


AS_CalendarSetting__c calendarSetting = AS_CalendarSetting__c.getInstance();
System.debug('[flag_0] # pickupDurationInMinutes = ' + pickupDurationInMinutes);
System.debug('appointmentCreationWrapper.repairCompleteDatetimeMS = ' + appointmentCreationWrapper.repairCompleteDatetimeMS);
serviceAppointmentRecord.SchedEndTime = Datetime.newinstance(appointmentCreationWrapper.repairCompleteDatetimeMS + pickupDurationInMinutes * 60000);

System.debug('[flag_1] # serviceAppointmentRecord.SchedStartTime = ' + serviceAppointmentRecord.SchedStartTime);
System.debug('[flag_2] # serviceAppointmentRecord.SchedEndTime = ' + serviceAppointmentRecord.SchedEndTime);

serviceAppointmentRecord.ServiceTerritoryId = '0Hh7a0000004epH'; // to make it dynamic
System.debug('serviceAppointmentRecord.SchedEndTime = ' + serviceAppointmentRecord.SchedEndTime);

serviceAppointmentRecord.ParentRecordId = appointmentCreationWrapper.assetRecordId;

/*
select id,employee__c
from service_resorce
where employee__r.user__c -= :userinfo.id
*/

// Employee__c tmpEmployee;
        Id relatedDepartmentId = getRelatedDepartmentId();

        ServiceResource serviceResource;
        try {
            serviceResource = [
                SELECT Id, Employee__c
                FROM ServiceResource
                // WHERE Employee__r.Department__c = :relatedDepartmentId AND Employee__r.User__c = :UserInfo.getUserId()
                WHERE Employee__r.Department__c = :relatedDepartmentId AND ResourceType = 'T'
                LIMIT 1
            ];

            newRepairRecord.Service_Resource__c = serviceResource.Employee__c;
            newRepairRecord.Department__c = relatedDepartmentId;

            Id serviceAdviserId = [
                SELECT Employee__c
                FROM GTA__c
                WHERE Department__c = :relatedDepartmentId
                LIMIT 1
            ]?.Employee__c;

            newRepairRecord.ServiceAdviser__c = serviceAdviserId;
// System.debug('newRepairRecord.ServiceAdviser__c = ' + newRepairRecord.ServiceAdviser__c);
            newRepairRecord.Created_By__c = 'Service Center';
            // tmpEmployee = [
            //     SELECT Id
            //     FROM Employee__c
            //     // WHERE User__c = :UserInfo.getUserId()
            //     WHERE Service_Resource__c = 
            // ];
            // newRepairRecord.Service_Resource__c = .Id;
        } catch(Exception ex) {
            // throw ui error: "no service resource found"
            // to create an object for logging exceptions (in case there is no employee__c)
            System.debug(ex.getMessage());
            return 'Error: ' + ex.getMessage();
        }

// repairRecord.DepartmentVehicle__c = assetRecord.Id;
// REQUIRED_FIELD_MISSING, Required fields are missing: [Service_Resource__c]: [DepartmentVehicle__c, Service_Resource__c]
// insert repairRecord;

        AssignedResource assignedResourceRecord = new AssignedResource();

        try {
            insert newRepairRecord;
System.debug('#__flag_0__# newRepairRecord = ' + newRepairRecord);
System.debug('#__flag_1__# serviceAppointmentRecord = ' + serviceAppointmentRecord);
            insert serviceAppointmentRecord;
System.debug('[142]__flag_123 serviceResource.Id = ' + serviceResource.Id);
// insertAssignedResource(serviceAppointmentRecord.Id, serviceResource.Id);
// System.debug('[567]__flag_123 servResourceId = ' + servResourceId);
            assignedResourceRecord.ServiceAppointmentId = serviceAppointmentRecord.Id;
            assignedResourceRecord.ServiceResourceId = serviceResource.Id; // '0Hn7a000000GpGE';
// rec.ServiceResourceId = servResourceId;
// rec.ServiceAppointmentId = servAppointmentId;


            // assignedResourceRecord.ServiceAppointmentId = serviceAppointmentRecord.Id;
            // assignedResourceRecord.ServiceResourceId = serviceResource.Id;
            // assignedResourceRecord. // assign department here
// System.debug('#__flag_2__# assignedResourceRecord = ' + assignedResourceRecord);
            insert assignedResourceRecord;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
            return 'Error: ' + ex.getMessage();
        }

        // here logic that will insert all repair package related data should be triggered

        List<Individual_Repair_Item__c> individualRepairItemsList = appointmentCreationWrapper?.individualRepairItemsList;
        
        for (Individual_Repair_Item__c irItem : individualRepairItemsList) {
            irItem.Service_Booking__c = newRepairRecord.Id;
        }

        List<Service_Booking_Repair_Package__c> serviceBookingRepairPackagesList = new List<Service_Booking_Repair_Package__c>();
        Service_Booking_Repair_Package__c tmpServiceBookingRepairPackageRecord;

        try {
            for(Id repairPackageId : appointmentCreationWrapper.repairPackagesList) {
                tmpServiceBookingRepairPackageRecord = new Service_Booking_Repair_Package__c(
                    Repair_Package__c = repairPackageId,
                    Service_Booking_Repair__c = newRepairRecord.Id
                );

                serviceBookingRepairPackagesList.add(tmpServiceBookingRepairPackageRecord);
            }

            insert serviceBookingRepairPackagesList;
            insert individualRepairItemsList;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
            return 'Error: ' + ex.getMessage();
        }

        return String.valueOf(newRepairRecord?.Id);
    }
/*
// parentRecordId is an Id of an Asset record
if(parentRecordId != null && parentRecordId != null) {
    // get and auto populate relevant fields
    - Customer (API Name: parentRecord.AccountId.Name)
    - Vehicle Model (API Name: parentRecord.Vehicle_Type__r.Name)
    - Mileage (API Name: parentRecord.Latest_Mileage__c)
    - Color (API Name: parentRecord.Color__c)
}*/
    @AuraEnabled
    public static Asset getVehicle(String assetIdString) {
        System.debug('...inside getVehicle method...');
        System.debug('assetIdString = ' + assetIdString);
        if (assetIdString == null) {
            return null;
        }
        Asset assetRecord = [
            SELECT Id, Name, AccountId, Account.Name, Vehicle_Type__r.Name, Latest_Mileage__c, VIN__c, Recall_Date__c, GCS_DTCs__c, Color__c, availability_of_service_packages__c
            FROM Asset
            WHERE Id = :Id.valueOf(assetIdString)
        ];
        System.debug('assetRecord = ' + assetRecord);
        System.debug('[217] assetRecord.AccountId = ' + assetRecord.AccountId);
        System.debug('assetRecord.VIN__c = ' + assetRecord.VIN__c);
        return assetRecord;
    }

    public class AppointmentCreationWrapper {
        public Id assetRecordId;
        public Id customerId;
        public Id serviceResourceId;
        public Id pickupPersonId;
        public Long receivingDatetimeMS;
        public Long repairCompleteDatetimeMS;
        public String pickupAddressString;
public Id serviceTerritoryId;
// public String test123;
        // public String dropOffAddress;
//...........................................................
// basing on below items I need to create a list of Service_Booking_Repair_Package__c records...
        // public String repairPackagesList;
        // public String individualRepairItemsList;
        // RepairPackage__c
        public List<Id> repairPackagesList;
        public List<Individual_Repair_Item__c> individualRepairItemsList;
    }

    // serviceResource = [
    //             SELECT Id, Employee__c
    //             FROM ServiceResource
    //             WHERE Employee__r.Department__c = :getRelatedDepartmentId()
    //             // LIMIT 1
    //         ];

    @AuraEnabled
    public static List<ServiceResource> getServiceResourcesList() {
        try {
System.debug('...inside AS_SchedRepair_AppointmentCreationCtrl.getServiceResourcesList() method...');
System.debug('getRelatedDepartmentId() = ' + getRelatedDepartmentId());
            return [
                SELECT Id, Name
                FROM ServiceResource
                WHERE Department__c = :getRelatedDepartmentId() AND IsActive = true
            ];
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static String getVehicleAndDepartmentWrapperJSON(String assetIdString) {
System.debug('inside getVehicleAndDepartmentWrapperJSON with assetIdString = ' + assetIdString);
        VehicleWithDepartmentWrapper vehicleWithDepartmentWrp = new VehicleWithDepartmentWrapper();
        try {
            Department__c department = getRelatedDepartment();

            HereAddressWrapper deptAddressWrapper = new HereAddressWrapper();
            deptAddressWrapper.street = department.Street__c;
            deptAddressWrapper.zipcode = department.Zipcode__c;
            deptAddressWrapper.city = department.City__c;
            deptAddressWrapper.country = department.Country__c;
            deptAddressWrapper.latitude = department.Geolocation__Latitude__s;
            deptAddressWrapper.longitude = department.Geolocation__Longitude__s;

            vehicleWithDepartmentWrp.vehicle = getVehicle(assetIdString);
            vehicleWithDepartmentWrp.departmentName = department.Name;
            vehicleWithDepartmentWrp.vehicle = getVehicle(assetIdString);
            //vehicleWithDepartmentWrp.colorsMap = AS_SchedRepair_CalendarDayViewerCtrl.getColorsForMonths(Date.today());
            vehicleWithDepartmentWrp.departmentAddressWrapper = deptAddressWrapper;
            vehicleWithDepartmentWrp.repairPackagesList = getRepairPackagesForCurrentUser();
vehicleWithDepartmentWrp.serviceResourcesList = getServiceResourcesList();
System.debug('getServiceResourcesList = ' + vehicleWithDepartmentWrp.serviceResourcesList);
System.debug('departmentName = ' + vehicleWithDepartmentWrp.departmentName);

System.debug('return value = ' + JSON.serialize(vehicleWithDepartmentWrp));
            return JSON.serialize(vehicleWithDepartmentWrp);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            return '{}';
        }
    }

    public class VehicleWithDepartmentWrapper {
        public Asset vehicle;
        // public Id departmentId;
        public String departmentName;
        public String colorsMap;
        public HereAddressWrapper departmentAddressWrapper;
        public List<RepairPackage__c> repairPackagesList;
        public List<ServiceResource> serviceResourcesList;
    }

    @AuraEnabled
    public static Id getRelatedDepartmentId() {
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
        return null;
    }

    public static Repair__c setGeolocationsForAddresses(Repair__c repairObj, String pickupAddress, String dropOffAddress) {
        repairObj.Pickup_Location_Geo__Latitude__s = 45;
        repairObj.Pickup_Location_Geo__Longitude__s = 90;
        repairObj.Drop_Off_Location_Geo__Latitude__s = 50;
        repairObj.Drop_Off_Location_Geo__Longitude__s = 95;
        return repairObj;
    }

    @AuraEnabled
    public static Department__c getRelatedDepartment() {
        Id currentUserId = UserInfo.getUserId();

        List<Employee__c> employeesList;
        try {
            employeesList = [
                SELECT Id, Department__r.Name, Department__r.Street__c, Department__r.Zipcode__c, Department__r.City__c, Department__r.Country__c, Department__r.Geolocation__Longitude__s, Department__r.Geolocation__Latitude__s
                FROM Employee__c
                WHERE User__c = :currentUserId
            ];
            System.debug('employeesList = ' + employeesList);

            if (employeesList?.size() == 1) {
                // return employeesList[0].Department__r.Name;
                return new Department__c(
                    Name = employeesList[0].Department__r.Name,
                    Street__c = employeesList[0].Department__r.Street__c,
                    Zipcode__c = employeesList[0].Department__r.Zipcode__c,
                    City__c = employeesList[0].Department__r.City__c,
                    Country__c = employeesList[0].Department__r.Country__c,
                    Geolocation__Latitude__s = employeesList[0].Department__r.Geolocation__Latitude__s,
                    Geolocation__Longitude__s = employeesList[0].Department__r.Geolocation__Longitude__s
                );
                // return employeesList[0].Department__r.clone(false, true, false, false);
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static String getRelatedDepartmentName() {
        Id currentUserId = UserInfo.getUserId();

        List<Employee__c> employeesList;
        try {
            employeesList = [
                SELECT Department__r.Name
                FROM Employee__c
                WHERE User__c =:currentUserId
            ];
            System.debug('employeesList = ' + employeesList);

            if (employeesList?.size() == 1) {
                return employeesList[0].Department__r.Name;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return '';
    }

    @AuraEnabled
    public static List<RepairPackage__c> getRepairPackagesForCurrentUser() {
        User currentUser = [ SELECT Id, Country FROM User WHERE Id = :UserInfo.getUserId() ];
        Employee__c currentUsersEmployee = [ SELECT Id, Department__c FROM Employee__c WHERE User__c = :currentUser.Id LIMIT 1];
System.debug('currentUser = ' + currentUser);
System.debug('currentUsersEmployee = ' + currentUsersEmployee);

        System.debug('inside getRepairPackages method');
        List<RepairPackage__c> repairPackagesList = [
            SELECT Id, Name FROM RepairPackage__c WHERE (Country__c = :currentUser.Country OR IsForAllModel__c = true) AND IsActive__c = true
        ];
        System.debug('repairPackagesList = ' + repairPackagesList);
// AND IsActive__c = true
// to ask Mayank if to check for Active

// Vehicle__c.VehicleModel__c - to get it from Vehicle__c, it's also a field on a RepairPackage__c: VehicleModel__c

// |Field name on repair package is:Vehicle_Model__c and field name on Vehicle(asset) object is Vehicle_Model_LTM__c| (from Mayank)


        return repairPackagesList;
    }

    public class HereDeliveryWrapper {
        public String pickupStreet;
        public String pickupZipcode;
        public String pickupCity;
        public String pickupCountry;
        public String dropoffStreet;
        public String dropoffZipcode;
        public String dropoffCity;
        public String dropoffCountry;
        public Decimal departmentLatitude;
        public Decimal departmentlongitude;
        public String trailerOrJockey;
        public Boolean hasCourtesyCar;
    }

    public class HereAddressWrapper {
        public String street;
        public String zipcode;
        public String city;
        public String country;
        public Decimal latitude;
        public Decimal longitude;
    }

    public class HereGeocodeWrapper {
        public Decimal lat;
        public Decimal lng;
    }

    public class HereDeliveryResultWrapper {
        public Decimal pickupDistance;
        public Integer pickupDuration;
        public Decimal dropoffDistance;
        public Integer dropoffDuration;
        public Id closestDepartmentId;
        public String closestDepartmentName;
        public String closestDepartmentStreet;
        public String closestDepartmentCity;
        public String closestDepartmentCountry;
    }

public class HereDistanceResultWrapper {
public Decimal distance;
public Integer duration;
}

    // public class HereDistancesResultWrapper {
    //     public Integer pickupDistance;
    //     public Integer pickupDuration;
    //     public Integer dropoffDistance;
    //     public Integer dropoffDuration;
    // }

    @AuraEnabled
    public static String getDistanceAndDuration(String hereDeliveryJSON) {
System.debug('inside getDistanceAndDuration method');
System.debug('hereAddressJSON = ' + hereDeliveryJSON);

        HereDeliveryWrapper hereAddressWrp = (HereDeliveryWrapper) JSON.deserialize(hereDeliveryJSON, HereDeliveryWrapper.class);

System.debug('hereAddressWrp = ' + hereAddressWrp);

        HereGeocodeWrapper departmentGeocodeWrp = new HereGeocodeWrapper();

        departmentGeocodeWrp.lat = hereAddressWrp.departmentLatitude;
        departmentGeocodeWrp.lng = hereAddressWrp.departmentLongitude;
System.debug('departmentGeocodeWrp = ' + departmentGeocodeWrp);

        try {
            // calculation of pickup
            HereGeocodeWrapper hereGeocodePickupWrp = getAddressWrapper(hereAddressWrp.pickupStreet, hereAddressWrp.pickupZipcode, hereAddressWrp.pickupCity, hereAddressWrp.pickupCountry);
System.debug('hereGeocodePickupWrp = ' + hereGeocodePickupWrp);
            HereGeocodeWrapper hereGeocodeDropoffWrp = getAddressWrapper(hereAddressWrp.dropoffStreet, hereAddressWrp.dropoffZipcode, hereAddressWrp.dropoffCity, hereAddressWrp.dropoffCountry);
System.debug('hereGeocodeDropoffWrp = ' + hereGeocodeDropoffWrp);

//---------------------------------------------------------------------------------------------
// here modifications for GD-2377 should be implemented
Department__c closestDepartment = getClosestDepartment(hereGeocodePickupWrp, hereAddressWrp.trailerOrJockey, hereAddressWrp.hasCourtesyCar);
//---------------------------------------------------------------------------------------------

            HereDeliveryResultWrapper hereDeliveryResultWrp = new HereDeliveryResultWrapper();
hereDeliveryResultWrp.closestDepartmentId = closestDepartment.Id;
hereDeliveryResultWrp.closestDepartmentName = closestDepartment.Name;
hereDeliveryResultWrp.closestDepartmentStreet = closestDepartment.Street__c;
hereDeliveryResultWrp.closestDepartmentCity = closestDepartment.City__c;
hereDeliveryResultWrp.closestDepartmentCountry = closestDepartment.Country__c;

            HereDistanceResultWrapper hereDistanceResultWrp = getDistance(departmentGeocodeWrp, hereGeocodePickupWrp);
            hereDeliveryResultWrp.pickupDistance = hereDistanceResultWrp.distance;
            hereDeliveryResultWrp.pickupDuration = hereDistanceResultWrp.duration;

            hereDistanceResultWrp = getDistance(hereGeocodeDropoffWrp, departmentGeocodeWrp);
            hereDeliveryResultWrp.dropoffDistance = hereDistanceResultWrp.distance;
            hereDeliveryResultWrp.dropoffDuration = hereDistanceResultWrp.duration;

System.debug('hereDeliveryResultWrp = ' + hereDeliveryResultWrp);
            return JSON.serialize(hereDeliveryResultWrp);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
System.debug('__flag22_null__');
            return null;
        }
    }

    @AuraEnabled
    public static HereGeocodeWrapper getAddressWrapper(String street, String zipcode, String city, String country) {
        String addressToEncode = street + ', ' + zipcode + ', ' + city + ', ' + country;
        addressToEncode = EncodingUtil.urlEncode(addressToEncode, 'UTF-8');

System.debug('addressToEncode = ' + addressToEncode);
        Map<String,Object> getGeoLocationResult = HereIntegration.getGeoLocation(EncodingUtil.urlEncode(addressToEncode, 'UTF-8'));
System.debug('getGeoLocationResult = ' + getGeoLocationResult);

        if (getGeoLocationResult != null) {
            HereGeocodeWrapper hereGeocodeWrp = new HereGeocodeWrapper();
            hereGeocodeWrp.lat = (Decimal) getGeoLocationResult.get(HERE_LATITUDE);
            hereGeocodeWrp.lng = (Decimal) getGeoLocationResult.get(HERE_LONGITUDE);
System.debug('__flag_return__ # hereGeocodeWrp = ' + hereGeocodeWrp);
            return hereGeocodeWrp;
        } else {
System.debug('__flag_null__');
            return null;
        }
    }

    @AuraEnabled
    public static HereDistanceResultWrapper getDistance(HereGeocodeWrapper startGeocodeWrp, HereGeocodeWrapper endGeocodeWrp) {
        Map<String,Object> hereDistanceResult = HereIntegration.getDistance(startGeocodeWrp.lat, startGeocodeWrp.lng, endGeocodeWrp.lat, endGeocodeWrp.lng);
        System.debug('hereDistanceResult = ' + hereDistanceResult);

        if (hereDistanceResult != null) {
            HereDistanceResultWrapper hereDistanceResultWrp = new HereDistanceResultWrapper();

            hereDistanceResultWrp.distance = (Decimal) hereDistanceResult.get(HERE_LENGTH);
            hereDistanceResultWrp.duration = (Integer) hereDistanceResult.get(HERE_DURATION);

            return hereDistanceResultWrp;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static Department__c getClosestDepartment(HereGeocodeWrapper currentHereGeocodeWrp, String trailerOrJockey, Boolean hasCourtesyCar) {
        if (trailerOrJockey != 'Trailer' && trailerOrJockey != 'Jockey') {
            return null;
        }

        System.debug('trailerOrJockey = ' + trailerOrJockey);
        System.debug('hasCourtesyCar = ' + hasCourtesyCar);
        List<Department__c> departmentsList = [
            SELECT Id, Name, Street__c, City__c, Country__c, Geolocation__Latitude__s, Geolocation__Longitude__s, (SELECT Id, Resource_Category__c FROM Service_Resources__r)
            FROM Department__c
            WHERE Geolocation__Latitude__s != null AND Geolocation__Longitude__s != null
            ORDER BY DISTANCE(Geolocation__c, GEOLOCATION(:currentHereGeocodeWrp.lat,:currentHereGeocodeWrp.lng), 'km')
        ];

        Boolean correctCourtesyCarCategory, correctTrailerJockeyCategory;
        if (departmentsList.isEmpty() == false) {
            for (Department__c department : departmentsList) {
                correctCourtesyCarCategory = false;
                correctTrailerJockeyCategory = false;
                for (ServiceResource sr : department.Service_Resources__r) {
                    if (hasCourtesyCar == false) {
                        correctCourtesyCarCategory = true;
                    }

                    if (hasCourtesyCar && sr.Resource_Category__c == 'Courtesy Car') {
                        correctCourtesyCarCategory = true;
                    } else if (sr.Resource_Category__c == trailerOrJockey) {
                        correctTrailerJockeyCategory = true;
                    }

                    if (correctCourtesyCarCategory == true && correctTrailerJockeyCategory == true) {
                        return department;
                    }
                }
            }
        }

        return null;
    }
}