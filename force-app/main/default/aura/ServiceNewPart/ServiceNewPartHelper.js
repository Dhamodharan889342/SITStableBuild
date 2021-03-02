/**
 * Created by H1903060 on 2019-04-04.
 */
({
    fn_init: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId ::', recordId);

        var sObjectTypeList = [];
        sObjectTypeList.push('RepairPart__c');
        sObjectTypeList.push('RepairQuoteLineItem__c');
//        console.log('sObjectTypeList :: ', sObjectTypeList);
        helper.fn_getSObjectType(component,
            sObjectTypeList,
            this.fn_getModelList(component, event, helper)
        );
    },
    fn_getModelList: function (component, event, helper) {
        // TODO: GD-1014 can't get this to work
        /*
        var action = component.get('c.getModelList');
        var modelOpts = [];

        action.setCallback(this, function (res) {
            var result = res.getReturnValue();
            for(var i=0; i<result.length; i++) {
                var model = result[i];
                modelOpts.push({
                   "class": "optionClass",
                   label: model.Label__c,
                   value: model.Label__c
                });
            }
            component.set('v.modelList', modelOpts);
        });
        $A.enqueueAction(action);
        */
    },
    /** 
     * GD-1014
     *   Search the sublets or parts that meet the criteria
     */
    fn_search: function (component, event, helper) {
        component.set('v.IsLoading', true);
        console.log('ServiceNewParthelper : fn_search');
        var opPartNo = component.find("opPartNo").get("v.value");
        var opDesc = component.find("opDesc").get("v.value");
        var model = component.find('model').get('v.value');
        var modelList = component.get('v.modelList');
        // TODO: LMS GD-1014
        //       disabled code 
        // if(model == '') model = modelList[0].value;

        // LMS: this is the repair quote id
        var recordId = component.get('v.recordId');

        
        console.log('recordId ::', recordId);
        var params = {
            recordId: recordId,   
            opPartNo: opPartNo,
            opDesc: opDesc,
            model: model   // LMS GD-1014: Model not used in Genesis Europe
        };
        console.log('params :: ', params);
        var action = component.get("c.doSearchPart");
        action.setParams({"pmap": params});
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var partList = response.getReturnValue();
                console.log('partList ::', partList);
                component.set("v.partList", partList);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    /**
     *  GD-1014
     *     save the parts to the itemList in the repair quote
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    fn_save: function (component, event, helper) {
        var selectedPartList = component.get('v.selectedPartList');

        if (selectedPartList.length <= 0) {
//            alert('No selected Labor');
            var message = $A.get('$Label.c.RPR_MSG_NoSelectedLabor');
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

        console.log('ServiceNewPartHelper.fn_save itemList::', itemList);
        console.log('ServiceNewPartHelper.fn_save selectedPartList::', selectedPartList);
        
        // search the itemList to find the appropriate 
        // sectionQuoteId
        var RepairQuoteSectionId=null;
        for (var ind=0; ind < itemList.length; ind++){
            if ((itemList[ind].LineItemSectionName==sectionUnitName) 
                && (itemList[ind].LineItemSectionType==sectionType)) {
                RepairQuoteSectionId=itemList[ind].RepairQuoteSectionId;
            }
        }
        for (var ind=0; ind<selectedPartList.length;ind++){
            var amount=0;
            if ((selectedPartList[ind].listPrice) && (selectedPartList[ind].quantity)){
                amount=selectedPartList[ind].listPrice*selectedPartList[ind].quantity;
            } else {
                if (selectedPartList[ind].amount) {
                    amount=selectedPartList[ind].amount;
                }
            }
            var tax=0;
            if (selectedPartList[ind].tax){
                tax=selectedPartList[ind].tax;
            }

            var totalAmount=amount*(1+tax/100);

            var recLineItem={
                LaborTypeRateId:"",
                LineItemCode: selectedPartList[ind].partCode,
                LineItemName: selectedPartList[ind].partName,
                LineItemSectionName: sectionUnitName,
                LineItemSectionType: sectionType,
                LineItemType: selectedPartList[ind].LineItemType,   // Part||Sublet
                RepairQuoteSectionId: RepairQuoteSectionId,
                amount: amount,
                discount: 0,   // TODO: check if it is true
                id: "",
                issueType: "Billable",
                listPrice:  selectedPartList[ind].listPrice,
                productId: selectedPartList[ind].productId,
                quantity: selectedPartList[ind].quantity,
                tax: tax,              
                taxCode: selectedPartList[ind].taxCode,             
                totalAmount: totalAmount  // To be updated on repair quote
            };
            console.log('ServiceNewPartHelper.fn_save  new recLineItem::',recLineItem);
            itemList.push(recLineItem);
        }

        console.log('ServiceNewPartHelper.fn_save itemList after adding items::', itemList);
        component.set('v.itemList', itemList);
        // $A.get('e.force:refreshView').fire();
        component.set('v.isOpen', false);

        /*
        component.set('v.IsLoading', true);

        var recordId = component.get('v.recordId');

        var params = {
            recordId: recordId,
            selectedPartList: JSON.stringify(selectedPartList)
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

                $A.get('e.force:refreshView').fire();

                component.set('v.isOpen', false);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
                component.set('v.saved', false)
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