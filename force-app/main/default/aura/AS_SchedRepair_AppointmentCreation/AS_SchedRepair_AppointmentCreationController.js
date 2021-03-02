({
    doInit : function(component, event, helper) {
        let parentIdParameter = helper.getParameterByName(component, event, 'inContextOfRef');
        let context = JSON.parse(window.atob(parentIdParameter));
        component.set("v.parentRecordId", context.attributes.recordId);
// alert("v.parentRecordId = " + component.get("v.parentRecordId"));
        helper.getParentVehicleWithDepartment(component);
// alert('JSON.stringify(component.get("v.selectedLookUpAssetRecord")) = ' + JSON.stringify(component.get("v.selectedLookUpAssetRecord")));
// alert('JSON.stringify(component.get("v.selectedLookUpAccountRecord")) = ' + JSON.stringify(component.get("v.selectedLookUpAccountRecord")));
    },

    testGetDistance : function(component, event, helper) {
        helper.getDistance(component);
    },

testJockeyAndCourtesyCar : function(component, event, helper) {
    alert('component.get("v.trailerOrJockey") = ' + component.get("v.trailerOrJockey"));
    alert('component.get("v.hasCourtesyCar") = ' + component.get("v.hasCourtesyCar"));
},

    handleMarkerSelect: function (cmp, event, helper) {
        let marker = event.getParam("selectedMarkerValue");
    },

    receivingDateChanged : function(component, event, helper) {
        let dateSelectedAppEvent = $A.get("e.c:AS_DateSelectedAppEvent");
        dateSelectedAppEvent.setParams({
            "selectedDate" : component.get("v.receivingDate")
        });
        dateSelectedAppEvent.fire();
    },

    handleComponentEvent : function(component, event, helper) {
        let selectedRecordGotFromEvent = event.getParam("recordByEvent");
        if ('02i' === selectedRecordGotFromEvent.Id.substring(0,3)) {
            component.set("v.parentRecordId",selectedRecordGotFromEvent.Id)
            helper.getRelatedParentVehicle(component);
            helper.getRepairPackagesPicklistValues(component);
        }
    },

    handleAddRow : function(component, event, helper) {
        let individualRepairItemsList = component.get("v.individualRepairItemsList");
        let newIndividualRepairItem = {
            SObjectType : 'Individual_Repair_Item__c',
            Description__c : '',
            Hour__c : '',
            Minute__c : '',
            Skill__c : ''
        };
        individualRepairItemsList.push(newIndividualRepairItem);
        component.set("v.individualRepairItemsList", individualRepairItemsList);
    },

    handleRemoveRow : function(component, event, helper) {
        let individualRepairItemsList = component.get("v.individualRepairItemsList");
        individualRepairItemsList.pop();
        component.set("v.individualRepairItemsList", individualRepairItemsList);
    },

    handleClearEvent : function(component, event, helper) {
        helper.clearVehicleDetailsSection(component);
    },

    handleServiceBookingRepairChange : function(component, event, helper) {
        let selectedValues = event.getParam("value");
        component.set("v.selectedServiceBookingRepairPackagesList", selectedValues);
    },

    saveRecord : function(component, event, helper) {
        helper.insertRepair(component, helper);
    },
    
    cancel : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/Repair__c/home",
            "isredirect":true
        });
        urlEvent.fire();
    }
})