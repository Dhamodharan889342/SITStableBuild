/*Created By: Mayank Pant
Create Date: 28th Dec 2020
Purpose: This class will generate test data for AfterSales related objects*/
@isTest 
public class AfterSales_TestFactory { 
    public static Account getAccount(String name, Boolean doInsert){
        Account a = new Account(
            name = name,
            Major_Language__c = 'en_US',
            Contact_Details__c = 'Email',
            Preferred_ZipCode__c = '1234567890'
        );
        if(doInsert){
        insert a;
        }
        return a;
    }

    public static GMECountry__c getCountry(String name, String code, Boolean doInsert){
        GMECountry__c c = new GMECountry__c(
            name = name,
            Country_Code__c = code,
            VAT__c = 0.20
        );
        if(doInsert){
            insert c;
        }
        return c;
    }

    public static Business_Hours__c getBusinessHours(String day, String departmentId, Time startT, Time endT, Boolean doInsert){
        Business_Hours__c bh = new Business_Hours__c(
            Day__c = day,
            Department__c = departmentId,
            Start__c = startT,
            End__c = endT
        );
        if(doInsert){
            insert bh;
        }
        return bh;
    }

    public static Zip_Code__c getZipCode(String code, Id departmentId, Id countryId,  Boolean doInsert){
        Zip_Code__c z = new Zip_Code__c(
            Name = code,  
            ZipCode__c = code,
            Department__c = departmentId,
            GMECountry__c = countryId
        );

        if(doInsert){
            insert z;
        }
        return z;
    }

    public static Contact getContact(Id accountId, String fname, String lname, Boolean doInsert){
        Contact c = new Contact(
            firstName = fname, 
            lastName = lname, 
            accountId = accountId
        );
        if(doInsert){
          insert c;
        }
        return c;
    }
    public static void generateAccountWithContacts(Integer numContacts){
        Account a = getAccount('default account ltd', true);
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numContacts; i++){
          String contactName = 'contact' + i;
          contacts.add(getContact(a.id, contactName, contactName, false));
        }
        insert contacts;
    }

    public static Opportunity[] generateOppsForAccount(id accountId, Decimal amount, Integer numOpps){
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < numOpps; i++){
            Opportunity o = new Opportunity();
            o.name = 'Account ' + i;
            o.accountId = accountid;
            o.amount = amount;
            o.closeDate = Date.today().addDays(5);
            o.stageName = 'Prospecting';
            opps.add(o);
        }
        return opps;
    }

    public static User generateUser(String profileName){
        UserRole userRole = new UserRole(DeveloperName = 'TestingTeam', Name = 'Testing Team');
        insert userRole;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
            LastName = 'last',
            Email = 'Cpt.Awesome@awesomesauce.com',
            Username = 'Cpt.Awesome@awesomesauce.com',
            CompanyName = 'Testing Co',
            Title = 'Captian',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRole.Id
        );
        insert u;
        return u;
    }

    public static Opportunity getOpportunity(id accountId, Decimal amount, Boolean doInsert){
        Opportunity o = new Opportunity(
            name = 'Account Opp 1',
            accountId = accountid,
            amount = amount,
            closeDate = Date.today().addDays(5),
            stageName = 'New',
            estimatedPurchaseTime__c = '1',
            Scoring__c = 'Hot',
            modelOfInterest__c = 'G90'
        );

        if(doInsert){
            insert o;
        }
        return o;
    }

    public static Lead getLead(String lastName, Boolean doInsert){
        Lead l = new Lead(
            LastName = lastName,
            Status = 'New'
        );

        if(doInsert){
            insert l;
        }
        return l;
    }

    public static Department__c getDepartmentStore(string name, string code, Boolean doInsert){

        Department__c dep = new Department__c(
            Name = name, 
            Department_Code__c = code,
            RecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId(),
            Official_dealer_Name__c = 'test dealer name', 
            Status__c = 'Active', 
            Department_Type__c = 'Sales', 
            Bank_Address__c = 'test address', 
            IBAN__c = 'test iban', 
            BIC__c = 'test bic', 
            ROM__c = 'test rom', 
            Contact_person_NSC_Creator__c = 'test nsc', 
            CPO__c = 'test cpo',
            State__c = 'test state', 
            Address__c = 'test address', 
            Email__c = 'test@email.dep.com'
        );
        
        if(doInsert){
            insert dep;
        }
        return dep;
    }

    public static Asset getDepartmentVehicle(string name, string departmentId, string regNumber, Boolean doInsert){
        Asset ve = new Asset(
            Name = name, 
            Department__c= departmentId,  
            Registration_Number__c = regNumber
        );
        if(doInsert){
            insert ve;
        }
        return ve;
    }

    public static Appointment__c getAppointment(string departmentId, string vehicleId, string oppotunityId, Datetime startDate, Datetime endDate, Boolean doInsert){
        Appointment__c ap = new Appointment__c(
            RetailStore__c = departmentId,
            DepartmentVehicle__c = vehicleId, 
            Opportunity__c = oppotunityId,
            ReservationRequestStart__c = startDate,
            ReservationRequestEnd__c = endDate,
            Stage__c = 'Request'
        );
        if(doInsert){
            insert ap;
        }
        return ap;
    }

    public static ServiceTerritory getServiceTerritory(Id departmentId){
        return null;
    }
    public static Employee__c getEmployee(string name, Id departmentId, string userId, string contactId, Boolean doInsert){

        Employee__c emp = new Employee__c(
            Name = name, 
            Department__c = departmentId, 
            User__c = userId, 
            Contact__c = contactId,
            EmploymentStatus__c = 'Active', 
            Salutation__c = 'Mr.', 
            Sex__c = 'Male', 
            Role__c = 'Technician',
            Contact_Details__c = 'Email',
            Country__c = 'Germany',
            EmploymentStartDate__c = date.today(),
            EmploymentEndDate__c = date.today().addDays(1000)
        );
        if(doInsert){
            insert emp;
          }
        return emp;
    }
    public static ServiceResource getServiceResource(string employee, string serviceTerritory){
        return null;
    }
}