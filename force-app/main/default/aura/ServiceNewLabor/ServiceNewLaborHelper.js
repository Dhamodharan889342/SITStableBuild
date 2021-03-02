/**
 * Created by H1812104 on 2019-03-27.
 */
({
    fn_init: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var sectioUnitName = component.get('v.sectioUnitName');

        console.log('ServiceNewLaborHelper.fn_init==> sectioUnitName='+sectioUnitName);
        
        var sObjectTypeList = [];
        sObjectTypeList.push('RepairLabor__c');
        sObjectTypeList.push('RepairQuoteLineItem__c');

        // LMS GD-1014 3/1/2021
        //     we always need to know the current section 
        //     where we want to add a new item


        helper.fn_getSObjectType(component,
            sObjectTypeList, null
        );
    },
    fn_search: function (component, event, helper) {
        component.set('v.IsLoading', true);
        //var repairType = component.find("repairType").get("v.value");
        var repairType = '';
        var opCode = component.find("opCode").get("v.value");
        var opDesc = component.find("opDesc").get("v.value");


        var recordId = component.get('v.recordId');
        console.log('recordId ::', recordId);
        var params = {
            recordId: recordId,
            repairType: repairType,
            opCode: opCode,
            opDesc: opDesc
        };

        var action = component.get("c.doSearchLabor");
        action.setParams({"pmap": params});
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var l = response.getReturnValue();
                component.set("v.laborList", l);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    /**
     * GD-1014
     * 
     * Save the data to the itemList of the repair quote
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    fn_save: function (component, event, helper) {
        // component.set('v.IsLoading', true);
        var selectedLaborList = component.get('v.selectedLaborList');

        if (selectedLaborList.length <= 0) {
//            alert('No selected Labor');
            var message = 'No selected Labor.';
            var toastParams = {
                title: "Error",
                message: message,
                type: "error"
            };
            // Fire error toast
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
            return;
        }
        //  LMS GD-1014
        //
        //     add the selected parts to the itemList
        //
        var itemList=component.get('v.itemList');
        var sectionUnitName=component.get('v.sectionUnitName');
        var sectionType=component.get('v.sectionType');

        console.log('ServiceNewLaborHelper.fn_save itemList::', itemList);
        console.log('ServiceNewLaborHelper.fn_save selectedLaborList::', selectedLaborList);
        
        // search the itemList to find the appropriate 
        // sectionQuoteId
        var RepairQuoteSectionId=null;
        for (var ind=0; ind < itemList.length; ind++){
            if ((itemList[ind].LineItemSectionName==sectionUnitName) 
                && (itemList[ind].LineItemSectionType==sectionType)) {
                RepairQuoteSectionId=itemList[ind].RepairQuoteSectionId;
            }
        }
        for (var ind=0; ind<selectedLaborList.length;ind++){
            var amount=0;
            if ((selectedLaborList[ind].listPrice) && (selectedLaborList[ind].quantity)){
                amount=selectedLaborList[ind].listPrice*selectedLaborList[ind].quantity;
            } else {
                if (selectedLaborList[ind].amount) {
                    amount=selectedLaborList[ind].amount;
                }
            }
            // more defensive code
            var listPrice=0;
            if (selectedLaborList[ind].listPrice) {
                listPrice=selectedLaborList[ind].listPrice;
            } else{
                listPrice=amount;
            }
            var tax=0;
            if (selectedLaborList[ind].tax){
                tax=selectedLaborList[ind].tax;
            }

            var totalAmount=amount*(1+tax/100);

            var recLineItem={
                LaborTypeRateId: null,
                LineItemCode: selectedLaborList[ind].laborCode,
                LineItemName: selectedLaborList[ind].laborName,
                LineItemSectionName: sectionUnitName,
                LineItemSectionType: sectionType,
                LineItemType: "Labor",
                RepairQuoteSectionId: RepairQuoteSectionId,
                hours: selectedLaborList[ind].hours,
                amount: amount,
                discount: 0,   // TODO: check if it is true
                id: "",
                issueType: "Billable",
                listPrice:  listPrice,
                productId: selectedLaborList[ind].productId,
                quantity: selectedLaborList[ind].quantity,
                tax: tax,              
                taxCode: selectedLaborList[ind].taxCode,             
                totalAmount: totalAmount  // To be updated on repair quote
            };
            console.log('ServiceNewLaborHelper.fn_save  new recLineItem::',recLineItem);
            itemList.push(recLineItem);
        }

        console.log('ServiceNewLaborHelper.fn_save itemList after adding items::', itemList);
        component.set('v.itemList', itemList);
        // $A.get('e.force:refreshView').fire();
        component.set('v.isOpen', false);

        
        // LMS 3/1/2021
        // GD 1014
        // 
        // use the event component to pass information
        /*console.log(' ServiceNewLaborHelper.fn_save==> Params to controller::');
        console.log(selectedLaborList);
        var myEvent = component.getEvent("itemList_ComponentEvent");
        myEvent.setParams({"param": selectedLaborList });
        myEvent.fire();
        */
        /*
            LMS GD-1014

            This entire section is not needed since we're
            using component event passing
        */
       /*
       var recordId = component.get('v.recordId');

        var params = {
            recordId: recordId,
            selectedLaborList: JSON.stringify(selectedLaborList)
        };
        component.set('v.saved', true);
        var action = component.get("c.doSave");
        action.setParams({"pmap": params});
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var rmap = response.getReturnValue();
                console.log('rmap ::', rmap);

                // $A.get('e.force:refreshView').fire();

                component.set('v.isOpen', false);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
                component.set('v.saved', false);
                helper.fn_handleErrors(
                    response.getError(),
                    null
                ); // Parent Method Call.
            }
        });

        $A.enqueueAction(action);
        */
        
    },
})