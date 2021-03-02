({
    getMonthName : function(component, event, helper) {
        const monthsNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ];
        let date = component.get("v.firstDayOfMonthDate");
        component.set("v.monthName", monthsNames[date.getMonth()] + ' ' + date.getFullYear());
    },

    getCellsToSkipNo : function(component) {
        let firstDayOfMonthDate = component.get("v.firstDayOfMonthDate");
        console.log('firstDayOfMonthDate.getDay() = ' + firstDayOfMonthDate.getDay());

        return (firstDayOfMonthDate.getDay() - 1) % 7;
    },

    getNoOfDaysInMonth : function(month,year) {
            // Here January is 1 based
            // Day 0 is the last day in the previous month
            // return new Date(year, month, 0).getDate();
            // Here January is 0 based
        return new Date(year, month + 1, 0).getDate();
    },

    transformListOfDaysToListOfLists : function(component, daysList) {
        let colorsMap = component.get("v.colorsMap");
console.log('JSON.stringify(daysList) = ' + JSON.stringify(daysList));
        let listOfLists = [];
        let tmpList = [];
        let tmpRecord;

        for (let i=0;i<daysList.length;i++) {
            if (tmpList.length === 7) {
                listOfLists.push(tmpList);
                tmpList = [];
            }
            tmpRecord = {};
            tmpRecord['value'] = daysList[i];
            if (tmpList.length !== 6) {
                tmpRecord['class'] = colorsMap[daysList[i]];
            } else {
                tmpRecord['class'] = '';
            }

            tmpList.push(tmpRecord);
        }

        if (tmpList.length > 0) {
            let remainingDays = 7 - tmpList.length;

            for (let i=0;i<remainingDays;i++) {
                tmpRecord = {};
                tmpRecord['value'] = '';
                tmpRecord['class'] = '';
                tmpList.push(tmpRecord);
            }
            listOfLists.push(tmpList);
        }

        return listOfLists;
    },

    getServiceAppointmentsForSelectedDate : function(component) {
        let selectedDate = component.get("v.selectedDate");
console.log('selectedDate = ' + selectedDate);
console.log('#__flag_123__#');
        let getServiceAppointmentsForDayAction = component.get("c.getServiceAppointmentsForDay");
        getServiceAppointmentsForDayAction.setParam('dayDate', selectedDate);
console.log('date sent to Apex controller: ' + selectedDate);
console.log('#__flag_321__#');

        getServiceAppointmentsForDayAction.setCallback(this, function(response) {
            let responseState = response.getState();

            if (responseState === "SUCCESS") {
                console.log('responseState === "SUCCESS"');
                // let returnedValue = response.getReturnValue();
console.log('response.getReturnValue() = ' + response.getReturnValue());
                let repairSchedulesForSelectedDate = JSON.parse(response.getReturnValue());

                component.set("v.repairSchedulesForSelectedDate", repairSchedulesForSelectedDate);

// alert('component.get("v.repairSchedulesForSelectedDate") = ' + component.get("v.repairSchedulesForSelectedDate"));
// console.log('component.get("v.repairSchedulesForSelectedDate") = ' + component.get("v.repairSchedulesForSelectedDate"));

// public class RepairScheduleWrapper {
//     public String repairSubject;
//     public Datetime startTime;
//     public Datetime endTime;
//     public Id serviceResourceId;
// }

// let repairSchedulesForSelectedDate = component.get("v.repairSchedulesForSelectedDate");

let serviceResIdWithHourObjSet = new Set();
let tmpRepairSched, repairDurationInHours, startDatetime, endDatetime;
for (let i in repairSchedulesForSelectedDate) {
    // serviceResIdHourObj2ClassMap.set(repairSchedulesForSelectedDate[i].serviceResourceId + '#' + repairSchedulesForSelectedDate[i].startTime, 'red');
    // console.log('repairSchedulesForSelectedDate[' + i + '].schedStartTime = ' + repairSchedulesForSelectedDate[i].schedStartTime);
    // console.log('repairSchedulesForSelectedDate[' + i + '] = ' + repairSchedulesForSelectedDate[i]);
    // console.log('repairSchedulesForSelectedDate[' + i + '].schedEndTime = ' + repairSchedulesForSelectedDate[i].schedEndTime);
    tmpRepairSched = repairSchedulesForSelectedDate[i];
    console.log('tmpRepairSched = ' + tmpRepairSched);
    console.log('tmpRepairSched.schedStartTime = ' + tmpRepairSched.schedStartTime);
    console.log('tmpRepairSched.schedEndTime = ' + tmpRepairSched.schedEndTime);
    // console.log('tmpRepairSched[' + i + '].schedEndTime = ' + repairDuration.schedEndTime);
    // console.log('tmpRepairSched[' + i + '].schedStartTime = ' + repairDuration.schedStartTime);

// console.log('typeof suspected datetime: ' + typeof Date.parse(tmpRepairSched.schedStartTime));
startDatetime = new Date(Date.parse(tmpRepairSched.schedStartTime));
console.log('just after setting # startDatetime = ' + startDatetime);
endDatetime = new Date(Date.parse(tmpRepairSched.schedEndTime));
console.log('just after setting # endDatetime = ' + endDatetime);
repairDurationInHours = Math.ceil((endDatetime - startDatetime) / 3.6e6);
    console.log('repairDurationInHours[' + i + '] = ' + repairDurationInHours);

console.log('xyz = ' + typeof startDatetime);
    for (let j=0;j<repairDurationInHours;j++) {
console.log('zyx # startDatetime.getHours() = ' + startDatetime.getHours());
        serviceResIdWithHourObjSet.add(tmpRepairSched.serviceResourceId + '#' + (startDatetime.getHours() + j));
    }

    // repairDuration = (tmpRepairSched.schedEndTime.getTime() - tmpRepairSched.schedStartTime.getTime()) / 3.6e6;
    // console.log('repairDuration[' + i + '] = ' + repairDuration);
}

console.log('serviceResIdWithHourObjSet.size = ' + serviceResIdWithHourObjSet.size);
console.log('serviceResIdWithHourObjSet = ' + serviceResIdWithHourObjSet);

let calendarWrappersList = [];
let calWrpItem;

let serviceResourcesList = component.get("v.serviceResourcesList");


// alert('serviceResourcesList = ' + JSON.stringify(serviceResourcesList));
let workingHoursList = component.get("v.workingHoursList");


for (let i in serviceResourcesList) {
    console.log('serviceResource.Id = ' + serviceResourcesList[i].Id);
    console.log('serviceResource.Name = ' + serviceResourcesList[i].Name);
    calWrpItem = {};
    // console.log('serviceResource.Name = ' + serviceResource.Name);
    calWrpItem.Name = serviceResourcesList[i].Name;
    calWrpItem.hoursList = [];

    for (let j in workingHoursList) {
        if (serviceResIdWithHourObjSet.has(serviceResourcesList[i].Id + '#' + workingHoursList[j])) {
            calWrpItem.hoursList.push({
                class: 'red',
                hour: workingHoursList[j]
            });
        } else {
            calWrpItem.hoursList.push({
                class: 'green',
                hour: workingHoursList[j]
            });
        }
    }

    calendarWrappersList.push(calWrpItem);
}

// here I need to set all red calendarWrappers that are already booked
// for () {

// }


component.set("v.calendarWrappersList", calendarWrappersList);

console.log('component.get("v.calendarWrappersList") = ' + JSON.stringify(component.get("v.calendarWrappersList")));

// let workingHoursList = component.get("v.workingHoursList");

// let newHoursList = workingHoursList.slice();
// let hoursWrappersList = [];
// let newHourWrapper;
// for (let workingHour in workingHoursList) {
//     newHourWrapper = {};
//     newHourWrapper.hour = workingHour;
//     newHourWrapper.class = 'green';
//     hoursWrappersList.push(newHourWrapper);
    //newHourWrapper
    // serviceResourceWrappersList.pu
// }

// let serviceResources2serviceAppointmentsMap = new Map();

// for(let serviceResource in serviceResourcesList) {
//     serviceResources2serviceAppointmentsMap.set(serviceResource.Id, hoursWrappersList);
// }
// console.log('serviceResources2serviceAppointmentsMap = ' + serviceResources2serviceAppointmentsMap);
// alert('serviceResources2serviceAppointmentsMap = ' + serviceResources2serviceAppointmentsMap);

// component.set("v.serviceResources2serviceAppointmentsMap", serviceResources2serviceAppointmentsMap);

// console.log('component.get("v.repairSchedulesForSelectedDate") = ' + component.get("v.repairSchedulesForSelectedDate"));
                // let repairSchedulesForDate = [];

                // for (let repairSchedule in returnedValue) {
                //     repairSchedulesForDate.push();
                // }

                // console.log('returnedValue = ' + returnedValue);
            } else {
                console.log('responseState !== "SUCCESS"');
            }
        });

        $A.enqueueAction(getServiceAppointmentsForDayAction);
    }

//     transformListOfDaysToListOfLists : function(daysList) {
// console.log('JSON.stringify(daysList) = ' + JSON.stringify(daysList));
//         let listOfLists = [];
//         let tmpList = [];

//         for (let i=0;i<daysList.length;i++) {
//             if (tmpList.length === 7) {
//                 listOfLists.push(tmpList);
//                 tmpList = [];
//             }

//             tmpList.push(daysList[i]);
//         }

//         if (tmpList.length > 0) {
//             let remainingDays = 7 - tmpList.length;

//             for (let i=0;i<remainingDays;i++) {
//                 tmpList.push('');
//             }
//             listOfLists.push(tmpList);
//         }

//         return listOfLists;
//     }
})