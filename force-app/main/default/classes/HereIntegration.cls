/***********************************************************************************************************************
* Name:    HereIntegration
* Author:  Konrad Russa - konrad.russa@cognizant.com
* Purpose: Class used for integration with HERE maps services to obrain geolocation and distance/duration for Test Drive
*======================================================================================================================*
* History                                                                                                              *
* -------                                                                                                              *
* VERSION  AUTHOR           DATE              DETAIL                                               RELEASE/CSR         *
*   1.0 -  Konrad Russa     11.12.2020        INITIAL DEVELOPMENT                                         *
*   1.0 -  Konrad Russa     15.01.2021        ADDED ERROR HANDLING                                         *
************************************************************************************************************************/

/*
    Prerequisites (created by System Administrator): 
        - Here.com account and project created, credentials obtained (Freemium and later Business account for Production)
        - Remote Site settings created for https://account.api.here.com, https://router.hereapi.com, https://geocode.search.hereapi.com
        - Custom setting HereSettings__c organization default created and updated in HereTokenScheduler, HereTokenIntegration
*/

public with sharing class HereIntegration {

    private static final String HERE_GEOCODE_API_URL = 'https://geocode.search.hereapi.com/v1/geocode';
    private static final String GEOLOCATION_QUERY = '?q={0}';

    private static final String HERE_ROUTE_API_URL = 'https://router.hereapi.com/v8/routes';
    private static final String ROUTE_QUERY = '?transportMode=car&origin={0},{1}&destination={2},{3}&return=summary';
    //latitude,longitude

    private static final String HERE_GEO_ITEMS = 'items';
    private static final String HERE_GEO_ITEMS_ACCESS = 'access';
    
    private static final String HERE_LATITUDE = 'lat';
    private static final String HERE_LONGITUDE = 'lng';

    private static final String HERE_ROUTE_ROUTES = 'routes';
    private static final String HERE_ROUTE_ROUTES_SECTIONS = 'sections';
    private static final String HERE_ROUTE_ROUTES_SECTIONS_SUMMARY = 'summary';

    private static final String HERE_DURATION = 'duration';
    private static final String HERE_LENGTH = 'length';

    private static final Integer HTTP_CODE_OK = 200;

    private static Http httpClient;

    public static Http getHttpClient() {
        if(httpClient == null) {
            httpClient = new Http();
        }
        return httpClient;
    }

    @AuraEnabled
    public static HereSettings__c getHereSetting(){
        HereSettings__c setting = HereSettings__c.getOrgDefaults();
        if(setting != null && !String.isBlank(setting.JSApiKey__c) && setting.DistanceLimit__c != null) {
            return setting;
        }
        return null;
    }

    //Lead
    //Street, PostalCode, City, Country; Latitude, Longitude
    public static Boolean runOnceLeadUpdate = false;
    public static void saveLeadsGeolocations(final Map<Id, SObject> newItems, final Map<Id, SObject> oldItems) {

        if(!runOnceLeadUpdate && !System.isQueueable()) {
            runOnceLeadUpdate = true;
        } else {
            return;
        }

        try {
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> leadsToUpdateInvalid = new List<Lead>();
            for(SObject o : newItems.values()) {
                Lead rec = (Lead) o;
                Lead oldRec = (oldItems != null && !oldItems.isEmpty()) ? (Lead)oldItems.get(o.Id) : null;
                
                String street = rec.Street;
                String zipcode = rec.PostalCode;
                String city = rec.City;
                String country = rec.Country;

                String streetOld = (oldRec != null) ? oldRec.Street : null;
                String zipcodeOld = (oldRec != null) ? oldRec.PostalCode : null;
                String cityOld = (oldRec != null) ? oldRec.City : null;
                String countryOld = (oldRec != null) ? oldRec.Country : null;

                AddressValidator validator = new AddressValidator(street, zipcode, city, country,
                                                        oldRec != null, streetOld, zipcodeOld, cityOld, countryOld);
                    
                if(validator.addressValid()) {
                    leadsToUpdate.add(rec);
                } else if(!validator.addressUnchangedForAsync()) {
                    if(rec.Latitude != null && rec.Longitude != null) {
                        Lead ld = new Lead(Id = rec.Id);
                        ld.Latitude = null;
                        ld.Longitude = null;
                        leadsToUpdateInvalid.add(ld);
                    }
                }
            }

            if(!leadsToUpdateInvalid.isEmpty()) {
                update leadsToUpdateInvalid;
            }

            if(!leadsToUpdate.isEmpty()) {
                System.enqueueJob(new QueueableLeadsGeolocation(leadsToUpdate));
            }
        } catch(Exception e) {
            ErrorLogUtilities.logTriggerException(e);
        }
    }

    public class QueueableLeadsGeolocation implements Queueable, Database.AllowsCallouts {
        public List<Lead> leads;
        public QueueableLeadsGeolocation(List<Lead> leads){
            this.leads = leads;
        }

        public void execute(QueueableContext context) {
            try {
                if(leads != null && !leads.isEmpty()) {
                    List<Lead> leadsToUpdate = new List<Lead>();
                    for(Lead rec : leads) {
                        String street = rec.Street;
                        String zipcode = rec.PostalCode;
                        String city = rec.City;
                        String country = rec.Country;
                        Map<String, Object> latlng = getGeoLocation(buildEncodedAddress(street, zipcode, city, country));
                        Lead ld = new Lead(Id = rec.Id);
                        if(latlng != null) {
                            ld.Latitude = (Decimal) latlng.get(HERE_LATITUDE);
                            ld.Longitude = (Decimal) latlng.get(HERE_LONGITUDE);
                        } else {
                            ld.Latitude = null;
                            ld.Longitude = null;
                        }
                        leadsToUpdate.add(ld);
                    }
                    update leadsToUpdate;
                }
            }catch(Exception e) {
                ErrorLogUtilities.logException(e);
            }
        }
    }

    //Person Account 
    //PersonMailingStreet, PersonMailingPostalCode, PersonMailingCity, PersonMailingCountry; PersonMailingLatitude, PersonMailingLongitude
    public static Boolean runOncePersonAccountUpdate = false;
    public static void savePersonAccountsGeolocations(final Map<Id, SObject> newItems, final Map<Id, SObject> oldItems) {

        if(newItems == null || newItems.isEmpty()) {
            return;
        }
        
        if(!runOncePersonAccountUpdate && !System.isQueueable()) {
            runOncePersonAccountUpdate = true;
        } else {
            return;
        }

        try {
            List<Account> accountsToUpdate = new List<Account>();
            List<Account> accountsToUpdateInvalid = new List<Account>();
            for(SObject o : newItems.values()) {
                Account rec = (Account) o;
                Account oldRec = (oldItems != null && !oldItems.isEmpty()) ? (Account)oldItems.get(o.Id) : null;
                
                String street = rec.PersonMailingStreet;
                String zipcode = rec.PersonMailingPostalCode;
                String city = rec.PersonMailingCity;
                String country = rec.PersonMailingCountry;

                String streetOld = (oldRec != null) ? oldRec.PersonMailingStreet : null;
                String zipcodeOld = (oldRec != null) ? oldRec.PersonMailingPostalCode : null;
                String cityOld = (oldRec != null) ? oldRec.PersonMailingCity : null;
                String countryOld = (oldRec != null) ? oldRec.PersonMailingCountry : null;

                AddressValidator validator = new AddressValidator(street, zipcode, city, country,
                                                        oldRec != null, streetOld, zipcodeOld, cityOld, countryOld);
                    
                if(validator.addressValid()) {
                    accountsToUpdate.add(rec);
                } else if(!validator.addressUnchangedForAsync()) {
                    if(rec.PersonMailingLatitude != null && rec.PersonMailingLongitude != null) {
                        Account acc = new Account(Id = rec.Id);
                        acc.PersonMailingLatitude = null;
                        acc.PersonMailingLongitude = null;
                        accountsToUpdateInvalid.add(acc);
                    }
                }
            }

            if(!accountsToUpdate.isEmpty()) {
                System.enqueueJob(new QueueablePersonAccountsGeolocation(accountsToUpdate));
            }

            if(!accountsToUpdateInvalid.isEmpty()) {
                update accountsToUpdateInvalid;
            }
        } catch(Exception e) {
            ErrorLogUtilities.logTriggerException(e);
        }
    }

    public class QueueablePersonAccountsGeolocation implements Queueable, Database.AllowsCallouts {
        public List<Account> accounts;
        public QueueablePersonAccountsGeolocation(List<Account> accounts){
            this.accounts = accounts;
        }

        public void execute(QueueableContext context) {
            try {
                if(accounts != null && !accounts.isEmpty()) {
                    List<Account> accountsToUpdate = new List<Account>();
                    for(Account rec : accounts) {
                        String street = rec.PersonMailingStreet;
                        String zipcode = rec.PersonMailingPostalCode;
                        String city = rec.PersonMailingCity;
                        String country = rec.PersonMailingCountry;
                        Map<String, Object> latlng = getGeoLocation(buildEncodedAddress(street, zipcode, city, country));
                        Account acc = new Account(Id = rec.Id);
                        if(latlng != null) {
                            acc.PersonMailingLatitude = (Decimal) latlng.get(HERE_LATITUDE);
                            acc.PersonMailingLongitude = (Decimal) latlng.get(HERE_LONGITUDE);
                        } else {
                            acc.PersonMailingLatitude = null;
                            acc.PersonMailingLongitude = null;
                        }
                        accountsToUpdate.add(acc);
                    }
                    update accountsToUpdate;
                }
            }catch(Exception e) {
                ErrorLogUtilities.logException(e);
            }
        }
    }

    //Account 
    //BillingStreet, BillingPostalCode, BillingCity, BillingCountry; BillingLatitude, BillingLongitude
    public static Boolean runOnceBusinessAccountUpdate = false;
    public static void saveBusinessAccountsGeolocations(final Map<Id, SObject> newItems, final Map<Id, SObject> oldItems) {

        if(newItems == null || newItems.isEmpty()) {
            return;
        }
        
        if(!runOnceBusinessAccountUpdate && !System.isQueueable()) {
            runOnceBusinessAccountUpdate = true;
        } else {
            return;
        }

        try {
            List<Account> accountsToUpdate = new List<Account>();
            List<Account> accountsToUpdateInvalid = new List<Account>();
            for(SObject o : newItems.values()) {
                Account rec = (Account) o;
                Account oldRec = (oldItems != null && !oldItems.isEmpty()) ? (Account)oldItems.get(o.Id) : null;
                
                String street = rec.BillingStreet;
                String zipcode = rec.BillingPostalCode;
                String city = rec.BillingCity;
                String country = rec.BillingCountry;

                String streetOld = (oldRec != null) ? oldRec.BillingStreet : null;
                String zipcodeOld = (oldRec != null) ? oldRec.BillingPostalCode : null;
                String cityOld = (oldRec != null) ? oldRec.BillingCity : null;
                String countryOld = (oldRec != null) ? oldRec.BillingCountry : null;

                AddressValidator validator = new AddressValidator(street, zipcode, city, country,
                                                        oldRec != null, streetOld, zipcodeOld, cityOld, countryOld);
                    
                if(validator.addressValid()) {
                    accountsToUpdate.add(rec);
                } else if(!validator.addressUnchangedForAsync()) {
                    if(rec.BillingLatitude != null && rec.BillingLongitude != null) {
                        Account acc = new Account(Id = rec.Id);
                        acc.BillingLatitude = null;
                        acc.BillingLongitude = null;
                        accountsToUpdateInvalid.add(acc);
                    }
                }
            }

            if(!accountsToUpdate.isEmpty()) {
                System.enqueueJob(new QueueableBusinessAccountsGeolocation(accountsToUpdate));
            }

            if(!accountsToUpdateInvalid.isEmpty()) {
                update accountsToUpdateInvalid;
            }
        } catch(Exception e) {
            ErrorLogUtilities.logTriggerException(e);
        }
    }

    public class QueueableBusinessAccountsGeolocation implements Queueable, Database.AllowsCallouts {
        public List<Account> accounts;
        public QueueableBusinessAccountsGeolocation(List<Account> accounts){
            this.accounts = accounts;
        }

        public void execute(QueueableContext context) {
            try {
                if(accounts != null && !accounts.isEmpty()) {
                    List<Account> accountsToUpdate = new List<Account>();
                    for(Account rec : accounts) {
                        String street = rec.BillingStreet;
                        String zipcode = rec.BillingPostalCode;
                        String city = rec.BillingCity;
                        String country = rec.BillingCountry;
                        Map<String, Object> latlng = getGeoLocation(buildEncodedAddress(street, zipcode, city, country));
                        Account acc = new Account(Id = rec.Id);
                        if(latlng != null) {
                            acc.BillingLatitude = (Decimal) latlng.get(HERE_LATITUDE);
                            acc.BillingLongitude = (Decimal) latlng.get(HERE_LONGITUDE);
                        } else {
                            acc.BillingLatitude = null;
                            acc.BillingLongitude = null;
                        }
                        accountsToUpdate.add(acc);
                    }
                    update accountsToUpdate;
                }
            }catch(Exception e) {
                ErrorLogUtilities.logException(e);
            }
        }
    }

    //Contact:
    //MailingStreet, MailingPostalCode, MailingCity, MailingCountry; MailingLatitude, MailingLongitude
    public static Boolean runOnceContactUpdate = false;
    public static void saveContactsGeolocations(final Map<Id, SObject> newItems, final Map<Id, SObject> oldItems) {
        
        if(!runOnceContactUpdate && !System.isQueueable()) {
            runOnceContactUpdate = true;
        } else {
            return;
        }

        try {
            List<Contact> contactsToUpdate = new List<Contact>();
            List<Contact> contactsToUpdateInvalid = new List<Contact>();
            for(SObject o : newItems.values()) {
                Contact rec = (Contact) o;
                Contact oldRec = (oldItems != null && !oldItems.isEmpty()) ? (Contact)oldItems.get(o.Id) : null;
                
                String street = rec.MailingStreet;
                String zipcode = rec.MailingPostalCode;
                String city = rec.MailingCity;
                String country = rec.MailingCountry;

                String streetOld = (oldRec != null) ? oldRec.MailingStreet : null;
                String zipcodeOld = (oldRec != null) ? oldRec.MailingPostalCode : null;
                String cityOld = (oldRec != null) ? oldRec.MailingCity : null;
                String countryOld = (oldRec != null) ? oldRec.MailingCountry : null;

                AddressValidator validator = new AddressValidator(street, zipcode, city, country,
                                                        oldRec != null, streetOld, zipcodeOld, cityOld, countryOld);
                    
                if(validator.addressValid()) {
                    contactsToUpdate.add(rec);
                } else if(!validator.addressUnchangedForAsync()) {
                    if(rec.MailingLatitude != null && rec.MailingLongitude != null) {
                        Contact cnt = new Contact(Id = rec.Id);
                        cnt.MailingLatitude = null;
                        cnt.MailingLongitude = null;
                        contactsToUpdateInvalid.add(cnt);
                    }
                }
            }

            if(!contactsToUpdate.isEmpty()) {
                System.enqueueJob(new QueueableContactsGeolocation(contactsToUpdate));
            }

            if(!contactsToUpdateInvalid.isEmpty()) {
                update contactsToUpdateInvalid;
            }
        } catch(Exception e) {
            ErrorLogUtilities.logTriggerException(e);
        }
    }

    public class QueueableContactsGeolocation implements Queueable, Database.AllowsCallouts {
        public List<Contact> contacts;
        public QueueableContactsGeolocation(List<Contact> contacts){
            this.contacts = contacts;
        }

        public void execute(QueueableContext context) {
            try {
                if(contacts != null && !contacts.isEmpty()) {
                    List<Contact> contactsToUpdate = new List<Contact>();
                    for(Contact rec : contacts) {
                        String street = rec.MailingStreet;
                        String zipcode = rec.MailingPostalCode;
                        String city = rec.MailingCity;
                        String country = rec.MailingCountry;
                        Map<String, Object> latlng = getGeoLocation(buildEncodedAddress(street, zipcode, city, country));
                        Contact cnt = new Contact(Id = rec.Id);
                        if(latlng != null) {
                            cnt.MailingLatitude = (Decimal) latlng.get(HERE_LATITUDE);
                            cnt.MailingLongitude = (Decimal) latlng.get(HERE_LONGITUDE);
                        } else {
                            cnt.MailingLatitude = null;
                            cnt.MailingLongitude = null;
                        }
                        contactsToUpdate.add(cnt);
                    }
                    update contactsToUpdate;
                }
            }catch(Exception e) {
                ErrorLogUtilities.logException(e);
            }
        }
    }

    //Appointment for record type test drive valet: 
    //PickUpStreet__c, PickUpPostalCode__c, PickUpCity__c, PickUpCountry__c; PickupGeolocation__c (PickupGeolocation__Latitude__s, PickupGeolocation__Longitude__s)
    //get Distance with getDistance() service, prerequisite Retail Store is set 
    //and its Department geolocation exists, get Department__r (Geolocation__c (Geolocation__Latitude__s, Geolocation__Longitude__s))
    public static Boolean runOnceAppointmentUpdate = false;
    public static void saveAppointmentsTestDriveValetGeolocations(final Map<Id, SObject> newItems, final Map<Id, SObject> oldItems) {
        
        if(!runOnceAppointmentUpdate && !System.isQueueable()) {
            runOnceAppointmentUpdate = true;
        } else {
            return;
        }
        
        try {
            List<Appointment__c> appointmentsToUpdate = new List<Appointment__c>();
            List<Appointment__c> appointmentsToUpdateInvalid = new List<Appointment__c>();

            Id testDriveValetRecordTypeId = Appointment__c.sObjectType.getDescribe()
                                                .getRecordTypeInfosByDeveloperName().get('TestDriveValet')
                                                .getRecordTypeId();

            for(SObject o : newItems.values()) {
                Appointment__c rec = (Appointment__c) o;

                Boolean isTestDriveValet = rec.RecordTypeId == testDriveValetRecordTypeId;

                if(isTestDriveValet) {
                    Appointment__c oldRec = (oldItems != null && !oldItems.isEmpty()) ? (Appointment__c)oldItems.get(o.Id) : null;
                    
                    String street = rec.PickUpStreet__c;
                    String zipcode = rec.PickUpPostalCode__c;
                    String city = rec.PickUpCity__c;
                    String country = rec.PickUpCountry__c;

                    String streetOld = (oldRec != null) ? oldRec.PickUpStreet__c : null;
                    String zipcodeOld = (oldRec != null) ? oldRec.PickUpPostalCode__c : null;
                    String cityOld = (oldRec != null) ? oldRec.PickUpCity__c : null;
                    String countryOld = (oldRec != null) ? oldRec.PickUpCountry__c : null;

                    AddressValidator validator = new AddressValidator(street, zipcode, city, country,
                                                        oldRec != null, streetOld, zipcodeOld, cityOld, countryOld);
                    
                    if(validator.addressValid()) {
                        appointmentsToUpdate.add(rec);
                    } else if(!validator.addressUnchangedForAsync()) {
                        if(rec.PickupGeolocation__Latitude__s != null && rec.PickupGeolocation__Longitude__s != null) {
                            Appointment__c app = new Appointment__c(Id = rec.Id);
                            app.PickupGeolocation__Latitude__s = null;
                            app.PickupGeolocation__Longitude__s = null;
                            app.DistanceTime__c = null;
                            app.DistanceLongitude__c = null;
                            appointmentsToUpdateInvalid.add(app);
                        }
                    }
                }
            }

            if(!appointmentsToUpdate.isEmpty()) {
                System.enqueueJob(new QueueableAppointmentsGeolocationDistance(appointmentsToUpdate));
            }

            if(!appointmentsToUpdateInvalid.isEmpty()) {
                update appointmentsToUpdateInvalid;
            }
        } catch(Exception e) {
            ErrorLogUtilities.logTriggerException(e);
        }
    }

    public class QueueableAppointmentsGeolocationDistance implements Queueable, Database.AllowsCallouts {
        public List<Appointment__c> appointments;
        public QueueableAppointmentsGeolocationDistance(List<Appointment__c> appointments){
            this.appointments = appointments;
        }

        public void execute(QueueableContext context) {
            try {
                if(appointments != null && !appointments.isEmpty()) {
                    List<Appointment__c> appointmentsToUpdate = new List<Appointment__c>();
                    Set<Id> appointmentIds = new Set<Id>();
                    for(Appointment__c rec : appointments) {
                        String street = rec.PickUpStreet__c;
                        String zipcode = rec.PickUpPostalCode__c;
                        String city = rec.PickUpCity__c;
                        String country = rec.PickUpCountry__c;
                        Map<String, Object> latlng = getGeoLocation(buildEncodedAddress(street, zipcode, city, country));
                        appointmentIds.add(rec.Id);
                        Appointment__c app = new Appointment__c(Id = rec.Id);
                        if(latlng != null) {
                            app.PickupGeolocation__Latitude__s = (Decimal) latlng.get(HERE_LATITUDE);
                            app.PickupGeolocation__Longitude__s = (Decimal) latlng.get(HERE_LONGITUDE);
                        } else {
                            app.PickupGeolocation__Latitude__s = null;
                            app.PickupGeolocation__Longitude__s = null;
                            app.DistanceTime__c = null;
                            app.DistanceLongitude__c = null;
                        }
                        appointmentsToUpdate.add(app);
                    }
                    
                    Map<Id, Appointment__c> appointmentsWithDepartmentLocation = new Map<Id, Appointment__c>(
                            [SELECT Id, ReservationRequestStart__c, 
                                        ReservationRequestEnd__c,
                                        RetailStore__r.Geolocation__Latitude__s, 
                                        RetailStore__r.Geolocation__Longitude__s,
                                        RetailStore__r.AdditionalVehicleOccupationHoursStar__c, 
                                        RetailStore__r.AdditionalVehicleOccupationHoursEnd__c
                                FROM Appointment__c WHERE Id in :appointmentIds]);

                    for(Appointment__c recUp : appointmentsToUpdate) {
                        Decimal appLatitude = recUp.PickupGeolocation__Latitude__s;
                        Decimal appLongitude = recUp.PickupGeolocation__Longitude__s;
                        if(appLatitude != null && appLongitude != null) {
                            Decimal depLatitude = appointmentsWithDepartmentLocation.get(recUp.Id).RetailStore__r.Geolocation__Latitude__s;
                            Decimal depLongitude = appointmentsWithDepartmentLocation.get(recUp.Id).RetailStore__r.Geolocation__Longitude__s;
                            
                            String hoursBeforeStr = appointmentsWithDepartmentLocation.get(recUp.Id).RetailStore__r.AdditionalVehicleOccupationHoursStar__c;
                            String hoursAfterStr = appointmentsWithDepartmentLocation.get(recUp.Id).RetailStore__r.AdditionalVehicleOccupationHoursEnd__c;
                            
                            Integer hoursBefore = String.isNotEmpty(hoursBeforeStr) ? Integer.valueOf(hoursBeforeStr) : 0;
                            Integer hoursAfter = String.isNotEmpty(hoursAfterStr) ? Integer.valueOf(hoursAfterStr) : 0;

                            DateTime reservationRequestStart = appointmentsWithDepartmentLocation.get(recUp.Id).ReservationRequestStart__c;
                            DateTime reservationRequestEnd = appointmentsWithDepartmentLocation.get(recUp.Id).ReservationRequestEnd__c;
                            
                            if(depLatitude != null && depLongitude != null) {
                                Map<String, Object> summary = getDistance(appLatitude, appLongitude, depLatitude, depLongitude);
                                if(summary != null) {
                                    Integer distanceMeters = (Integer)summary.get(HERE_LENGTH); // from HERE is in meters
                                    recUp.DistanceLongitude__c = (Decimal) distanceMeters / 1000; // in kilometers
                                    
                                    Integer secondsOneWay = (Integer)summary.get(HERE_DURATION); // from HERE is in seconds
                                    //recUp.DistanceTime__c = ((hoursBefore + hoursAfter) * 60) + ( 2 * (Decimal) secondsOneWay / 60 ); //in minutes
                                    recUp.DistanceTime__c =  (Decimal) secondsOneWay / 60; //in minutes

                                    if(reservationRequestStart != null) {
                                        recUp.VehicleOccupationStart__c = reservationRequestStart.addHours(-hoursBefore).addSeconds(-secondsOneWay);
                                    }
                                    if(reservationRequestEnd != null) {
                                        recUp.VehicleOccupationEnd__c = reservationRequestEnd.addSeconds(secondsOneWay).addHours(hoursAfter);
                                    }
                                } 
                            }
                        } else {
                            recUp.DistanceLongitude__c = null;
                            recUp.DistanceTime__c = null;
                            recUp.VehicleOccupationStart__c = null;
                            recUp.VehicleOccupationEnd__c = null;
                        }
                    }             
                    update appointmentsToUpdate;
                }
            }catch(Exception e) {
                ErrorLogUtilities.logException(e);
            }
        }
    }

    //Department:
    //Street__c, Zipcode__c, City__c, Country__c; Geolocation__c (Geolocation__Latitude__s, Geolocation__Longitude__s)
    public static Boolean runOnceDepartmentUpdate = false;
    public static void saveDepartmentsGeolocations(final Map<Id, SObject> newItems, final Map<Id, SObject> oldItems) {
        
        if(!runOnceDepartmentUpdate && !System.isQueueable()) {
            runOnceDepartmentUpdate = true;
        } else {
            return;
        }

        try {
            List<Department__c> departmentsToUpdate = new List<Department__c>();
            List<Department__c> departmentsToUpdateInvalid = new List<Department__c>();
            for(SObject o : newItems.values()) {
                Department__c rec = (Department__c) o;
                Department__c oldRec = (oldItems != null && !oldItems.isEmpty()) ? (Department__c)oldItems.get(o.Id) : null;
                
                String street = rec.Street__c;
                String zipcode = rec.Zipcode__c;
                String city = rec.City__c;
                String country = rec.Country__c;

                String streetOld = (oldRec != null) ? oldRec.Street__c : null;
                String zipcodeOld = (oldRec != null) ? oldRec.Zipcode__c : null;
                String cityOld = (oldRec != null) ? oldRec.City__c : null;
                String countryOld = (oldRec != null) ? oldRec.Country__c : null;

                AddressValidator validator = new AddressValidator(street, zipcode, city, country,
                                                        oldRec != null, streetOld, zipcodeOld, cityOld, countryOld);
                    
                if(validator.addressValid()) {
                    departmentsToUpdate.add(rec);
                } else if(!validator.addressUnchangedForAsync()) {
                    Department__c dp = new Department__c(Id = rec.Id);
                    dp.Geolocation__Latitude__s = null;
                    dp.Geolocation__Longitude__s = null;
                    departmentsToUpdateInvalid.add(dp);
                }
            }

            if(!departmentsToUpdate.isEmpty()) {
                System.enqueueJob(new QueueableDepartmentsGeolocation(departmentsToUpdate));
            }

            if(!departmentsToUpdateInvalid.isEmpty()) {
                update departmentsToUpdateInvalid;
            }
        } catch(Exception e) {
            ErrorLogUtilities.logTriggerException(e);
        }
    }

    public class QueueableDepartmentsGeolocation implements Queueable, Database.AllowsCallouts {
        public List<Department__c> departments;
        public QueueableDepartmentsGeolocation(List<Department__c> departments){
            this.departments = departments;
        }

        public void execute(QueueableContext context) {
            try {
                if(departments != null && !departments.isEmpty()) {
                    List<Department__c> departmentsToUpdate = new List<Department__c>();
                    for(Department__c rec : departments) {
                        String street = rec.Street__c;
                        String zipcode = rec.Zipcode__c;
                        String city = rec.City__c;
                        String country = rec.Country__c;
                        Map<String, Object> latlng = getGeoLocation(buildEncodedAddress(street, zipcode, city, country));
                        Department__c dp = new Department__c(Id = rec.Id);
                        if(latlng != null) {
                            dp.Geolocation__Latitude__s = (Decimal) latlng.get(HERE_LATITUDE);
                            dp.Geolocation__Longitude__s = (Decimal) latlng.get(HERE_LONGITUDE);
                        } else {
                            dp.Geolocation__Latitude__s = null;
                            dp.Geolocation__Longitude__s = null;
                        }
                        departmentsToUpdate.add(dp);
                    }
                    update departmentsToUpdate;
                }
            }catch(Exception e) {
                ErrorLogUtilities.logException(e);
            }
        }
    }

    // class used to validate if address was submitted or changed and geolocation should be checked and updated
    class AddressValidator {
        String street;
        String zipcode;
        String city;
        String country;

        Boolean oldExists;
        String streetOld;
        String zipcodeOld;
        String cityOld;
        String countryOld;

        public AddressValidator(String street, String zipcode, String city, String country, 
                                Boolean oldExists, String streetOld, String zipcodeOld, String cityOld, String countryOld) {
            this.street = street;
            this.zipcode = zipcode;
            this.city = city;
            this.country = country;
    
            this.oldExists = oldExists;
            this.streetOld = streetOld;
            this.zipcodeOld = zipcodeOld;
            this.cityOld = cityOld;
            this.countryOld = countryOld;
        }

        public Boolean addressValid() {
            Boolean hasAllFields = !String.isBlank(street) && !String.isBlank(zipcode)
                                    && !String.isBlank(city) && !String.isBlank(country);

            Boolean isNewWithFields = !oldExists && hasAllFields;

            Boolean hasChangedFields = oldExists && hasAllFields
                                        && (street != streetOld || zipcode != zipcodeOld 
                                            || city != cityOld || country != countryOld);

            return isNewWithFields || hasChangedFields;
        }

        public Boolean addressUnchangedForAsync() {
            return street == streetOld && zipcode == zipcodeOld && city == cityOld && country == countryOld;
        }
    }

    private static String buildEncodedAddress(String street, String zipcode, String city, String country) {
        String addressToEncode = street + ', ' + zipcode + ', ' + city + ', ' + country;
        return EncodingUtil.urlEncode(addressToEncode, 'UTF-8');
    }

    //fetched in HereTokenScheduler and HereTokenIntegration
    private static String getHereToken() {
        HereSettings__c setting = HereSettings__c.getOrgDefaults();
        if(setting != null && setting.TokenExpires__c > System.now()) {
            return setting.TokenPart1__c + setting.TokenPart2__c + setting.TokenPart3__c + setting.TokenPart4__c;
        } else {
            return null;
        }
    }

    public static Map<String, Object> getGeoLocation(final String queryEncoded) {

        String token = getHereToken();

        if(token == null){
            return null;
        } 

        HttpRequest req = new HttpRequest();

        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Accept', 'application/json');

        String queryURI = String.format(GEOLOCATION_QUERY, new List<Object>{queryEncoded});

        req.setEndpoint(HERE_GEOCODE_API_URL + queryURI);
        req.setMethod('GET');

        // Send the request, and return a response
        HttpResponse res = getHttpClient().send(req);
        String responseBody = res.getBody();

        Map<String, Object> latlng;

        if(res.getStatusCode() == HTTP_CODE_OK && !String.isBlank(responseBody)
            && responseBody.contains(HERE_GEO_ITEMS)               
            && responseBody.contains(HERE_GEO_ITEMS_ACCESS)
            && responseBody.contains(HERE_LATITUDE) 
            && responseBody.contains(HERE_LONGITUDE)) {

            Map<String, Object> jsonBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

            if(jsonBodyMap.containsKey(HERE_GEO_ITEMS)) {

                List<Object> items = (List<Object>) jsonBodyMap.get(HERE_GEO_ITEMS);
                List<Object> access = (List<Object>) ((Map<String, Object>) items[0]).get(HERE_GEO_ITEMS_ACCESS);
                latlng = (Map<String, Object>) access[0];

                //System.debug(LoggingLevel.DEBUG, 'Lat : ' + latlng.get(HERE_LATITUDE));
                //System.debug(LoggingLevel.DEBUG, 'Lng : ' + latlng.get(HERE_LONGITUDE));
            }
        }
        return latlng;
    }

    //Latitude, Longitude
    public static Map<String, Object> getDistance(Decimal appLat, Decimal appLon, Decimal depLat, Decimal depLon)  {

        String token = getHereToken();

        if(token == null) {
            return null;
        } 

        HttpRequest req = new HttpRequest();

        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Accept', 'application/json');

        String queryURI = String.format(ROUTE_QUERY, new List<Object>{appLat,appLon,depLat,depLon});
        //'?transportMode=car&origin=52.5308,13.3847&destination=52.5323,13.3789&return=summary';

        req.setEndpoint(HERE_ROUTE_API_URL + queryURI);
        req.setMethod('GET');

        // Send the request, and return a response
        HttpResponse res = getHttpClient().send(req);
        String responseBody = res.getBody();

        Map<String, Object> summary;

        if(res.getStatusCode() == HTTP_CODE_OK && !String.isBlank(responseBody)
            && responseBody.contains(HERE_ROUTE_ROUTES) 
            && responseBody.contains(HERE_ROUTE_ROUTES_SECTIONS) 
            && responseBody.contains(HERE_ROUTE_ROUTES_SECTIONS_SUMMARY)
            && responseBody.contains(HERE_DURATION) 
            && responseBody.contains(HERE_LENGTH)) {
            //System.debug('Route : ' + JSON.serializePretty(responseBody, true));

            Map<String, Object> jsonBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

            if(jsonBodyMap.containsKey(HERE_ROUTE_ROUTES)) {

                List<Object> routes = (List<Object>) jsonBodyMap.get(HERE_ROUTE_ROUTES);
                List<Object> sections = (List<Object>) ((Map<String, Object>) routes[0]).get(HERE_ROUTE_ROUTES_SECTIONS);
                summary = (Map<String, Object>) ((Map<String, Object>) sections[0]).get(HERE_ROUTE_ROUTES_SECTIONS_SUMMARY);
    
                //System.debug(LoggingLevel.DEBUG, 'Destination : ' + summary);
                //System.debug(LoggingLevel.DEBUG, 'Duration : ' + summary.get(HERE_DURATION)); //in seconds
                //System.debug(LoggingLevel.DEBUG, 'Distance : ' + summary.get(HERE_LENGTH));   //in meters
            }
        }
        return summary;
    }
}