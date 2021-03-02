/******************************************************************************************
  * File Name   : AS_SchedRepair_CalendarSchedulerCtrl
  * Created Date: 6th January 2021
  * Description : Apex controller for Lightning Aura component AS_SchedRepair_CalendarScheduler . It's used for implementation of GD-679 ( Courtesy car scheduling for new repair reservation (GPA/SA) ). It's used for showing User calendar with information about how many curtesy car bookings are already created for each day of the specific month.
  * Author      : Konrad Maluszkiewicz
  * Modification Log
  * =======================================================================
  * Ver     Date             Author                      Modification
  * =======================================================================
  * 1.0     06.01.2021       Konrad Maluszkiewicz        Creation
  ****************************************************************************************/

public with sharing class AS_SchedRepair_CalendarSchedulerCtrl {
    public class RepairScheduleWrapper {
        public String repairSubject;
        public Datetime startTime;
        public Datetime endTime;
        public Id serviceResourceId;
        public Id serviceAppointmentId;
        public Datetime schedStartTime;
        public Datetime schedEndTime;
    }

    @AuraEnabled
    public static String getServiceAppointmentsForDay(Date dayDate) {
        Datetime dayStartDatetime = Datetime.newInstance(dayDate.year(), dayDate.month(), dayDate.day(),0,0,0);
System.debug('dayStartDatetime = ' + dayStartDatetime);
        Datetime dayEndDatetime = dayStartDatetime.addDays(1);
System.debug('nextMonthStartDate = ' + dayEndDatetime);

System.debug('JSON.serialize(getServiceAppointmentsBetweenDatetimes(dayStartDatetime, dayEndDatetime)) = ' + JSON.serialize(getServiceAppointmentsBetweenDatetimes(dayStartDatetime, dayEndDatetime)));
        return JSON.serialize(getServiceAppointmentsBetweenDatetimes(dayStartDatetime, dayEndDatetime));
    }

    @AuraEnabled
    public static List<RepairScheduleWrapper> getServiceAppointmentsBetweenDatetimes(Datetime startDatetime, Datetime endDatetime) {
        Id currentUserId = UserInfo.getUserId();
        System.debug('currentUserId = ' + currentUserId);

        try {

            // I need to get all service resources related to current department
            List<ServiceResource> usersServiceResources = [
                SELECT Id, Department__c
                FROM ServiceResource
                WHERE RelatedRecordId = :currentUserId
            ];

            List<Id> departmentIdsList = new List<Id>();

            for (ServiceResource sr : usersServiceResources) {
                departmentIdsList.add(sr.Department__c);
            }

            List<ServiceResource> allServiceResourcesForDepartments = [
                SELECT Id
                FROM ServiceResource
                WHERE Department__c IN :departmentIdsList
            ];

            List<Id> allServiceResourcesForDepartmentsIds = new List<Id>();
            
            for (ServiceResource sr : allServiceResourcesForDepartments) {
                allServiceResourcesForDepartmentsIds.add(sr.Id);
            }

            List<AssignedResource> allAssignedResourcesForTimePeriod = [
                SELECT ServiceAppointment.Subject, ServiceAppointment.SchedStartTime, ServiceAppointment.SchedEndTime, ServiceAppointment.Street, ServiceAppointment.PostalCode, ServiceAppointment.City, ServiceAppointment.Country, ServiceResourceId, ServiceResource.Name, ServiceAppointment.Id
                FROM AssignedResource
                WHERE ServiceAppointment.SchedStartTime >= :startDatetime AND ServiceAppointment.SchedStartTime < :endDatetime AND ServiceResourceId = :allServiceResourcesForDepartmentsIds
                ORDER BY ServiceAppointment.SchedStartTime ASC
            ];
System.debug('allAssignedResourcesForTimePeriod = ' + allAssignedResourcesForTimePeriod);

            List<RepairScheduleWrapper> repairScheduleWrappersList = new List<RepairScheduleWrapper>();
            RepairScheduleWrapper tmpRepairScheduleWrapper;
            for (AssignedResource ar : allAssignedResourcesForTimePeriod) {
                tmpRepairScheduleWrapper = new RepairScheduleWrapper();
                tmpRepairScheduleWrapper.repairSubject = ar.ServiceAppointment.Subject;
                tmpRepairScheduleWrapper.startTime = ar.ServiceAppointment.SchedStartTime;
                tmpRepairScheduleWrapper.endTime = ar.ServiceAppointment.SchedEndTime;
                tmpRepairScheduleWrapper.serviceResourceId = ar.ServiceResourceId;
                tmpRepairScheduleWrapper.serviceAppointmentId = ar.ServiceAppointment.Id;
                tmpRepairScheduleWrapper.schedStartTime = ar.ServiceAppointment.SchedStartTime;
                tmpRepairScheduleWrapper.schedEndTime = ar.ServiceAppointment.SchedEndTime;

                repairScheduleWrappersList.add(tmpRepairScheduleWrapper);
            }

            return repairScheduleWrappersList;
        } catch (Exception ex) {
            // throw new AuraHandledException(ex.getMessage());
            System.debug(ex.getMessage());
            return null;
        }
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
}