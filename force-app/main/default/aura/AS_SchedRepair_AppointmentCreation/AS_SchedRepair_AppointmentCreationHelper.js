({
    setServiceBookingObjectLabel : function(component) {
        let action = component.get("c.getServiceBookingObjectLabel");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.newServiceBookingLabel", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    insertRepair : function(component, helper) {
        component.set("v.showSpinner", true);

        let assetRecord = component.get("v.selectedLookUpAssetRecord");
        let accountRecord = component.get("v.selectedLookUpAccountRecord");
        let serviceResourceRecord = component.get("v.selectedLookUpServiceResourceRecord");
        let pickupPersonRecord = component.get("v.selectedLookUpPickupPersonRecord");
        let repairPackagesList = component.get("v.selectedRepairPackagesList");
        let individualRepairItemsList = component.get("v.individualRepairItemsList");

        serviceResourceRecord['Id'] === null
        if ($A.util.isUndefinedOrNull(assetRecord['Id'])) {
            assetRecord['Id'] = '';
        }

        if ($A.util.isUndefinedOrNull(accountRecord['Id'])) {
            accountRecord['Id'] = '';
        }

        if ($A.util.isUndefinedOrNull(serviceResourceRecord['Id'])) {
            serviceResourceRecord['Id'] = '';
        }

        if ($A.util.isUndefinedOrNull(pickupPersonRecord['Id'])) {
            pickupPersonRecord['Id'] = '';
        }

        let receivingDate = component.get("v.receivingDate");
// console.log('receivingDate = ' + receivingDate);
        let receivingTime = component.get("v.receivingTime");
// console.log('receivingTime = ' + receivingTime);

        let receivingDatetime = new Date(receivingDate);
console.log('[flag_1] # receivingDatetime = ' + receivingDatetime);
        let receivingDatetimeSeconds = (parseInt(receivingTime.substring(0,2),10) * 60 + parseInt(receivingTime.substring(3,5),10) + receivingDatetime.getTimezoneOffset()) * 60;

        receivingDatetime = new Date(receivingDatetime.getTime() + receivingDatetimeSeconds * 1000);
console.log('[flag_2] # receivingDatetime = ' + receivingDatetime);

        let repairCompleteDate = component.get("v.repairCompleteDate");
// console.log('repairCompleteDate = ' + repairCompleteDate);
        let repairCompleteTime = component.get("v.repairCompleteTime");
// console.log('repairCompleteTime = ' + repairCompleteTime);
        let repairCompleteDatetime = new Date(repairCompleteDate);
console.log('[flag_3] # repairCompleteDatetime = ' + repairCompleteDatetime);

        let closeDatetimeSeconds = (parseInt(repairCompleteTime.substring(0,2),10) * 60 + parseInt(repairCompleteTime.substring(3,5),10) + repairCompleteDatetime.getTimezoneOffset()) * 60;

        repairCompleteDatetime = new Date(repairCompleteDatetime.getTime() + closeDatetimeSeconds * 1000);
console.log('[flag_4] # repairCompleteDatetime = ' + repairCompleteDatetime);

// let closeDatetimeSeconds = parseInt(repairCompleteTime.substring(0,2), 10) * 60 + parseInt(repairCompleteTime.substring(3,5), 10) * 60;
        // let repairCompleteDatetime = new Date(closeDatetimeSeconds * 1000);

// console.log('hours to seconds = ' + repairCompleteTime.substring(0,2) * 60 * 60);
// console.log('mins to seconds = ' + repairCompleteTime.substring(3,5) * 60);
// console.log('hours and mins to seconds = ' + (
// 	parseInt(repairCompleteTime.substring(0,2), 10) * 60
//  + parseInt(repairCompleteTime.substring(3,5), 10)) * 60);
// console.log('offSet to seconds = ' + repairCompleteDatetime.getTimezoneOffset() * 60);

// console.log('hours to MS = ' + repairCompleteTime.substring(0,2) * 60 * 60 * 1000);
// console.log('mins to MS = ' + repairCompleteTime.substring(3,5) * 60 * 1000);
// console.log('hours and mins to MS = ' + ((repairCompleteTime.substring(0,2) * 60 ) + repairCompleteTime.substring(3,5)) * 60 * 1000 );
// console.log('offSet to MS = ' + repairCompleteDatetime.getTimezoneOffset() * 60000);

// console.log('receivingDatetime.getTimezoneOffset() = ' + receivingDatetime.getTimezoneOffset());
// console.log('receivingDatetime.getTimezoneOffset() * 60000 = ' + receivingDatetime.getTimezoneOffset() * 60000);

// console.log('repairCompleteDatetime.getTime() = ' + repairCompleteDatetime.getTime());
// console.log('repairCompleteTime.substring(0,2) = ' + repairCompleteTime.substring(0,2));
// console.log('repairCompleteTime.substring(3,5) = ' + repairCompleteTime.substring(3,5));
// console.log('repairCompleteDatetime.getTimezoneOffset() = ' + repairCompleteDatetime.getTimezoneOffset());
// console.log('repairCompleteDatetime = ' + repairCompleteDatetime);
// console.log('repairCompleteDatetime.getTime() = ' + repairCompleteDatetime.getTime());
// console.log('repairCompleteDatetime.getTime() + (repairCompleteTime.substring(0,2) * 60 + repairCompleteTime.substring(3,5))*600 + repairCompleteDatetime.getTimezoneOffset() * 60000 = ' + repairCompleteDatetime.getTime() + (repairCompleteTime.substring(0,2) * 60 + repairCompleteTime.substring(3,5)) * 600 + repairCompleteDatetime.getTimezoneOffset() * 60000);

//         let closeDatetimeMS = repairCompleteDatetime.getTime() + (repairCompleteTime.substring(0,2) * 60 + repairCompleteTime.substring(3,5) * 600 + repairCompleteDatetime.getTimezoneOffset() * 60000);
// console.log('closeDatetimeMS = ' + closeDatetimeMS);
//         repairCompleteDatetime = new Date(closeDatetimeMS)

        let jSONRepairStr = '{"assetRecordId":"' + assetRecord['Id']
        + '","customerId":"' + accountRecord['Id']
        + '","receivingDatetimeMS":' + receivingDatetime.getTime()
        + ',"repairCompleteDatetimeMS":' + repairCompleteDatetime.getTime()
        + ',"serviceResourceId":"' + serviceResourceRecord['Id']
        + '","pickupPersonId":"' + pickupPersonRecord['Id']
        + '","pickupAddressString":"' + ''
        // + '","pickupAddressString":"' + component.find("pickupAddress").get("v.value")
        // + '","dropOffAddress":"' + component.find("dropOffAddress").get("v.value")
        + '","repairPackagesList":' + JSON.stringify(repairPackagesList)
        + ',"individualRepairItemsList":' + JSON.stringify(individualRepairItemsList)
        + '}';

        let insertRepairAction = component.get("c.insertRepair");
        insertRepairAction.setParam("jSONRepair", jSONRepairStr);

        insertRepairAction.setCallback(this, function(response, errorMessage) {
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");

            if (state === "SUCCESS" && !response.getReturnValue().startsWith('Error:')) {
                console.log('response.getReturnValue() = ' + response.getReturnValue());

                toastEvent.setParams({
                    title : 'Success!',
                    message : 'The record has been inserted successfully with Id: ' + response.getReturnValue(),
                    duration : '5000',
                    key : 'info_alt',
                    type : 'success',
                    mode : 'dismissible'
                });
            } else {
                toastEvent.setParams({
                    title : 'Error',
                    message : 'Response message: ' + response.getReturnValue(),
                    duration : '10000',
                    key : 'info_alt',
                    type : 'error',
                    mode : 'dismissible'
                });
            }
            component.set("v.showSpinner", false);
            toastEvent.fire();
        });
        $A.enqueueAction(insertRepairAction);
    },

    getRelatedDepartmentId : function(component) {
        let getRelatedDepartmentIdAction = component.get("c.getRelatedDepartmentId");

        getRelatedDepartmentIdAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.find("serviceCenter").set("v.value", response.getReturnValue());
            }
        });
        $A.enqueueAction(getRelatedDepartmentIdAction);
    },

    getRelatedDepartmentName : function(component) {
        let getRelatedDepartmentNameAction = component.get("c.getRelatedDepartmentName");

        getRelatedDepartmentNameAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.find("serviceCenter").set("v.value", response.getReturnValue());
            }
        });
        $A.enqueueAction(getRelatedDepartmentNameAction);
    },

    getParameterByName : function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

    getRelatedParentVehicle : function(component) {
        let getRelatedParentVehicleAction = component.get("c.getVehicle");
        getRelatedParentVehicleAction.setParam('assetIdString', component.get("v.parentRecordId"));

        getRelatedParentVehicleAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let returnedValue = response.getReturnValue();
                component.set("v.selectedLookUpAssetRecord", returnedValue);

console.log('Asset.Name = ' + returnedValue.Name);
console.log('Asset.Id = ' + returnedValue.Id);
                let assetRecord = {'SObjectType' : 'Asset', 'Name' : returnedValue.Name, 'Id' : returnedValue.Id};
                component.set("v.selectedLookUpAssetRecord", assetRecord);
                component.set("v.vinNumber", returnedValue.VIN__c);
                if (returnedValue.Vehicle_Type__r !== undefined) {
                    component.set("v.vehicleType", returnedValue.Vehicle_Type__r.Name);
                }

component.set("v.mileageAmount", returnedValue.Latest_Mileage__c);
component.set("v.recallsInfo", returnedValue.Recall_Date__c);
component.set("v.gcsDTC", returnedValue.GCS_DTCs__c);
component.set("v.vehicleColor", returnedValue.Color__c);
component.set("v.servicePackageAvailability", returnedValue.availability_of_service_packages__c);

                let vehicleAppEvent = $A.get("e.c:AS_SelectedSObjectAppRecordEvent");
                vehicleAppEvent.setParams({
                    "recordLabel" : "Vehicle Name",
                    "recordByEvent" : returnedValue
                });
                vehicleAppEvent.fire();

                if (!$A.util.isUndefinedOrNull(returnedValue.Account)) {
                    let customerAppEvent = $A.get("e.c:AS_SelectedSObjectAppRecordEvent");
                    let customerValue = JSON.parse('{"Id":"' + returnedValue.AccountId + '","Name":"' + returnedValue.Account.Name + '"}');
                    customerAppEvent.setParams({
                        "recordLabel" : "Customer Name",
                        "recordByEvent" : customerValue
                    });
                    customerAppEvent.fire();
                }
            }
        });
        $A.enqueueAction(getRelatedParentVehicleAction);
    },

    getRepairPackagesPicklistValues : function(component) {
        let getRepairPackagesAction = component.get("c.getRepairPackagesForCurrentUser");

        getRepairPackagesAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let responseValue = response.getReturnValue();
                let picklistValues = [];
console.log('responseValue = ' + responseValue);
console.log('typeof responseValue = ' + typeof responseValue);
console.log('typeof responseValue !== \'undefined\' = ' + typeof responseValue !== 'undefined');

                if (typeof responseValue !== 'undefined') {
                    for (let i=0; i<responseValue.length; i++) {
                        picklistValues.push({
                            label: responseValue[i].Name,
                            value: responseValue[i].Id
                        });
                    }

                    component.set("v.availableRepairPackagesList",picklistValues);
                }
            }
        });
        $A.enqueueAction(getRepairPackagesAction);
    },

    clearVehicleDetailsSection : function(component) {
        component.find("vinNumber").set("v.value",'');
        component.find("vehicleType").set("v.value",'');
        component.find("mileageAmount").set("v.value",'');
        component.find("recallsInfo").set("v.value",'');
        component.find("gcsDTC").set("v.value",'');
        component.find("vehicleColor").set("v.value",'');
        component.find("servicePackageAvailability").set("v.value",'');
    },

    getParentVehicleWithDepartment : function(component) {
        let getParentVehicleWithDepartmentAction = component.get("c.getVehicleAndDepartmentWrapperJSON");
        getParentVehicleWithDepartmentAction.setParam('assetIdString', component.get("v.parentRecordId"));
console.log('component.get("v.parentRecordId") = ' + component.get("v.parentRecordId"));

        getParentVehicleWithDepartmentAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {

                let returnedValue = response.getReturnValue();
                let returnWrapper = JSON.parse(returnedValue);
                let assetRecord = returnWrapper.vehicle;
// alert('[270]assetRecord = ' + assetRecord);
// alert('JSON.stringify(assetRecord) = ' + JSON.stringify(assetRecord));
                let departmentName = returnWrapper.departmentName;
                component.find("serviceCenter").set("v.value", departmentName);

                let dateNow = new Date();
                let selectedDate = new Date(Date.UTC(dateNow.getFullYear(), dateNow.getMonth(), 1));
                let repairPackagesList = returnWrapper.repairPackagesList;
                let serviceResourcesList = returnWrapper.serviceResourcesList;
                component.set("v.serviceResourcesList", serviceResourcesList);

                component.set("v.departmentAddress", returnWrapper.departmentAddressWrapper);

                if (!$A.util.isUndefinedOrNull(assetRecord)) {
                    component.set("v.vinNumber", assetRecord.VIN__c);
                    component.set("v.mileageAmount", assetRecord.Latest_Mileage__c);
                    component.set("v.recallsInfo", assetRecord.Recall_Date__c);
                    component.set("v.gcsDTC", assetRecord.GCS_DTCs__c);
                    component.set("v.vehicleColor", assetRecord.Color__c);
                    component.set("v.servicePackageAvailability", assetRecord.availability_of_service_packages__c);

                    if (!$A.util.isUndefinedOrNull(assetRecord.Vehicle_Type__r)) {
                        component.set("v.vehicleType", assetRecord.Vehicle_Type__r.Name);
                    }
                }

                let picklistValues = [];
console.log('typeof repairPackagesList = ' + typeof repairPackagesList);
                if (typeof repairPackagesList !== 'undefined') {

                    for (let i=0; i<repairPackagesList.length; i++) {
                        picklistValues.push({
                            label: repairPackagesList[i].Name,
                            value: repairPackagesList[i].Id
                        });
                    }

                    component.set("v.availableRepairPackagesList",picklistValues);
                }
console.log('JSON.stringify(assetRecord) = ' + JSON.stringify(assetRecord));

                if (assetRecord !== null) {
                    let vehicleAppEvent = $A.get("e.c:AS_SelectedSObjectAppRecordEvent");
                    vehicleAppEvent.setParams({
                        "recordLabel" : "Search for Customer's Vehicle",
                        "recordByEvent" : assetRecord
                    });
                    vehicleAppEvent.fire();
                }
                
                let customerAppEvent = $A.get("e.c:AS_SelectedSObjectAppRecordEvent");
// alert('[321] assetRecord.Account = ' + JSON.stringify(assetRecord.Account));
                if (!$A.util.isUndefinedOrNull(assetRecord) && !$A.util.isUndefinedOrNull(assetRecord.Account)) {
// alert('in line [323]: assetRecord not null and not undefined and Accoubnt not null and not undefined');
                    let customerValue = JSON.parse('{"Id":"' + assetRecord.AccountId + '","Name":"' + assetRecord.Account.Name + '"}');
                    customerAppEvent.setParams({
                        "recordLabel" : "Search for Customer",
                        "recordByEvent" : customerValue
                    });
                    customerAppEvent.fire();
                }
            }
        });
        $A.enqueueAction(getParentVehicleWithDepartmentAction);
    },

    getDistance : function(component) {
        let departmentAddress = component.get("v.departmentAddress");

        let hasCourtesyCar = component.get("v.hasCourtesyCar");

        if ($A.util.isUndefinedOrNull(hasCourtesyCar)) {
            hasCourtesyCar = false;
        }

        let hereDeliveryJSON = '{'
            + '"pickupStreet":"' + component.find("pickupStreet").get("v.value")
            + '","pickupZipcode":"' + component.find("pickupZipcode").get("v.value")
            + '","pickupCity":"' + component.find("pickupCity").get("v.value")
            + '","pickupCountry":"' + component.find("pickupCountry").get("v.value")

            + '","dropoffStreet":"' + component.find("dropoffStreet").get("v.value")
            + '","dropoffZipcode":"' + component.find("dropoffZipcode").get("v.value")
            + '","dropoffCity":"' + component.find("dropoffCity").get("v.value")
            + '","dropoffCountry":"' + component.find("dropoffCountry").get("v.value")

            + '","departmentLatitude":' + departmentAddress.latitude
            + ',"departmentLongitude":' + departmentAddress.longitude
            + ',"trailerOrJockey":"' + component.get("v.trailerOrJockey")
            + '","hasCourtesyCar":' + hasCourtesyCar
        + '}';

        let getDistanceAndDurationAction = component.get("c.getDistanceAndDuration");
        getDistanceAndDurationAction.setParam('hereDeliveryJSON', hereDeliveryJSON);

        getDistanceAndDurationAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let responseValue = JSON.parse(response.getReturnValue());

                component.set("v.pickupDistance", responseValue.pickupDistance);
                component.set("v.pickupDuration", responseValue.pickupDuration);
                component.set("v.dropoffDistance", responseValue.dropoffDistance);
                component.set("v.dropoffDuration", responseValue.dropoffDuration);
                component.set("v.closestDepartmentId", responseValue.closestDepartmentId);
                component.set("v.closestDeprtmentName", responseValue.closestDepartmentName);
                component.set("v.closestDepartmentStreet", responseValue.closestDepartmentStreet);
                component.set("v.closestDepartmentCity", responseValue.closestDepartmentCity);
                component.set("v.closestDepartmentCountry", responseValue.closestDepartmentCountry);

                component.set('v.mapMarkers', [
                    {
                        location: {
                            Street: component.find("pickupStreet").get("v.value"),
                            City: component.find("pickupCity").get("v.value"),
                            Country: component.find("pickupCountry").get("v.value")
                        },

                        icon: 'custom:custom26',
                        value: 'PickupLocation',
                        title: 'Spot / Pickup Location',
                        description: 'Pickup Location'
                    },
                    
                    {
                        location: {
                            Street: component.find("dropoffStreet").get("v.value"),
                            City: component.find("dropoffCity").get("v.value"),
                            Country: component.find("dropoffCountry").get("v.value")
                        },
        
                        icon: 'custom:custom31',
                        value: 'DropoffLocation',
                        title: 'Drop Off Location',
                        description: 'Dropoff Location'
                    },
        
                    {
                        location: {
                            Street: component.get("v.closestDepartmentStreet"),
                            City: component.get("v.closestDepartmentCity"),
                            Country: component.get("v.closestDepartmentCountry")
                        },
        
                        icon: 'custom:custom19',
                        value: 'ClosestDepartment',
                        title: component.get("v.closestDeprtmentName"),
                        description: 'Closest Department'
                    }
                ]);

                // alert('v.closestDepartmentId = ' + component.get("v.closestDepartmentId"));
            }
        });
        $A.enqueueAction(getDistanceAndDurationAction);
    }
})