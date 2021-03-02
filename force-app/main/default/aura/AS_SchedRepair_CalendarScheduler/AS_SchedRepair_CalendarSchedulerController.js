({
    doInit : function(component, event, helper) {
        let timeInMs = Date.now();
        console.log('# flag_0 # timeInMs = ' + timeInMs);
        let todayDate = new Date();
        console.log('# flag_1 # todayDate = ' + todayDate);
        let todayFullYear = todayDate.getFullYear();
        console.log('# flag_2 # todayFullYear = ' + todayFullYear);
        console.log('# flag_3 # todayDate.getMonth() = ' + todayDate.getMonth());
        console.log('# flag_4 # todayDate.getDay() = ' + todayDate.getDay());
        let firstDayOfMonthDate = new Date(todayDate.getFullYear(), todayDate.getMonth());
        console.log('# flag_5 # firstDayOfMonthDate = ' + firstDayOfMonthDate);
        console.log('# flag_6 # firstDayOfMonthDate.getDay() = ' + firstDayOfMonthDate.getDay());

        component.set("v.firstDayOfMonthDate", firstDayOfMonthDate);
        // helper.getMonthName(component, event, helper);

        console.log('component.get("v.firstDayOfMonthDate") = ' + component.get("v.firstDayOfMonthDate"));
// alert('component.get("v.serviceResourcesList") = ' + component.get("v.serviceResourcesList"));

        let dayToSkipNo = helper.getCellsToSkipNo(component);
        let daysList = [];
        for(let i=0;i<dayToSkipNo;i++) {
            daysList.push('');
        }

        let getNoOfDaysInMonth = helper.getNoOfDaysInMonth(firstDayOfMonthDate.getMonth(),firstDayOfMonthDate.getFullYear());
        for(let i=1;i<=getNoOfDaysInMonth;i++) {
            daysList.push(i);
        }

        // alert('getNoOfDaysInMonth = ' + getNoOfDaysInMonth);

        console.log('helper.getNoOfDaysInMonth(0,2012) = ' + helper.getNoOfDaysInMonth(0,2012));
        console.log('helper.getNoOfDaysInMonth(1,2012) = ' + helper.getNoOfDaysInMonth(1,2012));
        console.log('helper.getNoOfDaysInMonth(8,2012) = ' + helper.getNoOfDaysInMonth(8,2012));
        console.log('helper.getNoOfDaysInMonth(11,2012) = ' + helper.getNoOfDaysInMonth(11,2012));

        // console.log('daysList = ' + JSON.stringify(helper.transformListOfDaysToListOfLists(component, daysList)));
        // alert('daysList = ' + JSON.stringify(helper.transformListOfDaysToListOfLists(daysList)));

        // component.set("v.days2DList", helper.transformListOfDaysToListOfLists(component, daysList));
// console.log('component.get("v.days2DList") = ' + component.get("v.days2DList"));
        // alert(component.get("v.firstDayOfMonthDate"));

        // console.log('# flag_6 # firstDayOfMonthDate.getDay() = ' + firstDayOfMonthDate.getDay());

        // let firstDayOfTheMonth = todayDate.getMonth();
        //  = new Date(todayDate.getFullYear(), todayDate.getMonth(), 1)
        // console.log('# flag_2 # firstDayOfTheMonth = ' + firstDayOfTheMonth);
    },

    getDay : function(component, event, helper) {
        let selectedDay = event.currentTarget.dataset.day;
        if (selectedDay > 0 && selectedDay < 32) {
            console.log("selected day: " + selectedDay);
            // alert("selected day: " + selectedDay);

            let firstDayOfMonthDate = component.get("v.firstDayOfMonthDate");

            let selectedDate = new Date(Date.UTC(firstDayOfMonthDate.getFullYear(), firstDayOfMonthDate.getMonth(), selectedDay));
console.log('CalendarSchedulerController[getDay] = ' + selectedDate);
            let dateSelectedAppEvent = $A.get("e.c:AS_DateSelectedAppEvent");
            dateSelectedAppEvent.setParams({
                "selectedDate" : selectedDate
            });
            dateSelectedAppEvent.fire();

            /*
let vehicleAppEvent = $A.get("e.c:AS_SelectedSObjectAppRecordEvent");
vehicleAppEvent.setParams({
    "recordLabel" : "Vehicle Name",
    "recordByEvent" : assetRecord
});
vehicleAppEvent.fire();
            */
        }
    },

    // handleMonthSelectedAppEvent : function(component, event, helper) {
        // let selectedDate = event.getParam("selectedDate");
        // let firstDayOfMonthDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth());
        // component.set("v.firstDayOfMonthDate", firstDayOfMonthDate);

        // let dayToSkipNo = helper.getCellsToSkipNo(component);
        // let daysList = [];
        // for(let i=0;i<dayToSkipNo;i++) {
        //     daysList.push('');
        // }

        // let getNoOfDaysInMonth = helper.getNoOfDaysInMonth(firstDayOfMonthDate.getMonth(),firstDayOfMonthDate.getFullYear());
        // for(let i=1;i<=getNoOfDaysInMonth;i++) {
        //     daysList.push(i);
        // }

        // component.set("v.days2DList", helper.transformListOfDaysToListOfLists(component, daysList));
    // },

    handleDateSelectedAppEvent : function(component, event, helper) {
// alert('inside handleDateSelectedAppEvent, AS_DateSelectedAppEvent catched...');
        console.log('inside handleDateSelectedAppEvent method');
        let selectedDate = event.getParam("selectedDate");
        component.set("v.selectedDate", selectedDate);

        helper.getServiceAppointmentsForSelectedDate(component);

        // component.set("v.repairSchedulesForSelectedDate", response);
    }

    // testList : function(component, event, helper) {
    //     let serviceResourcesList = component.get("v.serviceResourcesList");
    //     let name = serviceResourcesList[0].Name;
    //     alert('name = ' + name);
    // }
})