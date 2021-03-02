/****************************************************************************************
 * @author          Lee Donghu
 * @date            2019-07-30
 *
 * @group           Service
 * @group-content   Service
 *
 * @description     ServicePackageHelper.js
 ****************************************************************************************/
({
    fn_init: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId ::', recordId);
        var sObjectTypeList = [];

        sObjectTypeList.push('RepairPackage__c');
        sObjectTypeList.push('RepairQuoteLineItem__c');
        sObjectTypeList.push('Product2');

        helper.fn_getSObjectType(component,
            sObjectTypeList
        );
    },
    /**
     *  Search 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    fn_search: function (component, event, helper) {
        component.set('v.IsLoading', true);
        //var packageNo = component.find("packageNo").get("v.value");
        var packageName = component.find("packageName").get("v.value");
        var laborCode = component.find("laborCode").get("v.value");
        var laborName = component.find("laborName").get("v.value");
        var partNo = component.find("partNo").get("v.value");
        var partName = component.find("partName").get("v.value");

        console.log('servicePackageHelper.fn_search  recordId search ::#####');
        var recordId = component.get('v.recordId');
        // console.log('servicePackageHelper.fn_search  recordId ::', recordId);
        var params = {
            recordId: recordId,
            // packageNo: packageNo,  // LMS not used un Genesis Europe
            packageName: packageName,
            laborCode: laborCode,
            laborName: laborName,
            partNo: partNo,
            partName: partName,
        };
        console.log('servicePackageHelper.fn_search  params ::', params);

        var action = component.get("c.doSearchPackage");
        action.setParams({"pmap": params});
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var r = response.getReturnValue();
                console.log('r ::', r);
                component.set("v.packageList", r);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    /**
     *   Select a repair package
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     * @param {*} packageId 
     */
    fn_add: function (component, event, helper, packageId ) {
        component.set('v.IsLoading', true);
        component.set('v.laborList', null);
        component.set('v.partList', null);

        var recordId = component.get('v.recordId');
        console.log('recordId ::', recordId);

        var params = {
            recordId: recordId,
            packageId: packageId,
        };
        var action = component.get("c.doAddPackage");
        action.setParams({"pmap": params});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state ::', state);
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var r = response.getReturnValue();
                console.log('r ::', r);
                var laborList = [];
                var partList = [];
                for (var i = 0; i < r.length; i++) {
                    if (r[i].lineItemType == 'Labor') {
                        laborList = laborList.concat(r[i]);
                    } else if ((r[i].lineItemType == 'Part') ||
                            (r[i].lineItemType == 'Additional Services' )) {
                        partList = partList.concat(r[i]);
                    }
                }
                component.set("v.laborList", laborList);
                component.set("v.partList", partList);

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
                helper.fn_handleErrors(
                    response.getError(),
                    null
                ); // Parent Method Call.
            }
        });

        $A.enqueueAction(action);
    },
    /**
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    fn_save: function (component, event, helper) {
        // component.set('v.IsLoading', true);
        var laborList = component.get('v.laborList');
        var partList = component.get('v.partList');
        // GD-1014 parent itemList
        var  itemList= component.get('v.itemList');                

        if (laborList.length == 0 || partList.length == 0) {
            var message = $A.get('$Label.c.COM_MSG_NoItemsSelected');
            var toastParams = {
                title: "Error",
                message: message,
                type: "error"
            };
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
            component.set('v.IsLoading', false);
            return;
        }

        var recordId = component.get('v.recordId');

        // console.log('servicePackageHelper.fn_save  laborList ::',laborList);
        // console.log('servicePackageHelper.fn_save  laborList.length ::',laborList.length);
        // console.log('servicePackageHelper.fn_save  partList ::',partList);
        
        // TODO: get package name
        var sectionUnitName=component.get('v.sectionName');
        console.log('servicePackageHelper.fn_save before  labor itemList ::',itemList);

        for (var ind=0;ind<laborList.length;ind++){
            var amount=laborList[ind].quantity * laborList[ind].hours * laborList[ind].listPrice;
            var totalAmount=amount*(1+(laborList[ind].tax/100));

            console.log('servicePackageHelper.fn_save  laborList[ind]::',laborList[ind]);
            console.log('servicePackageHelper.fn_save  amount='+amount +' Total='+totalAmount);
            // some bad data from testing
            var laborCode;
            if (laborList[ind].code) {
                laborCode=laborList[ind].code;
            } else {
                laborCode="";
            }
            var recLineItem={
                LaborTypeRateId:null,   // standard type applied later
                LineItemCode: laborCode,
                LineItemName: laborList[ind].name,
                LineItemSectionName: sectionUnitName,
                LineItemSectionType: 'Pack',
                LineItemType: 'Labor',
                RepairQuoteSectionId: null,
                amount: amount,
                discount: 0,   // TODO: check if it is true
                id: "",
                issueType: "Billable",
                claimType: "",
                listPrice:  laborList[ind].listPrice,
                hours:  laborList[ind].hours,
                productId: laborList[ind].laborId,
                quantity: laborList[ind].quantity,
                tax: laborList[ind].tax,              
                taxCode: '-',             
                totalAmount: totalAmount  // To be updated on repair quote
            };
            console.log('servicePackageHelper.fn_save  new recLineItem::',recLineItem);
            itemList.push(recLineItem);
        }
        console.log('servicePackageHelper.fn_save after labor itemList ::',itemList);

        for (var ind=0;ind<partList.length;ind++){

            console.log('servicePackageHelper.fn_save  partList[ind]::',partList[ind]);
            var amount=partList[ind].quantity * partList[ind].listPrice;
            var totalAmount=amount*(1+(laborList[ind].tax/100));

            
            console.log('servicePackageHelper.fn_save  amount='+amount +' Total='+totalAmount);
            // some bad data from testing
            var partCode;
            if (partList[ind].code) {
                partCode=partList[ind].code;
            } else {
                partCode="";
            }
   
            var recLineItem={
                LaborTypeRateId:null,   // standard type applied later
                LineItemCode: partList[ind].code,
                LineItemName: partList[ind].name,
                LineItemSectionName: sectionUnitName,
                LineItemSectionType: 'Pack',
                LineItemType: "Part",
                RepairQuoteSectionId: null,
                amount: amount,
                discount: 0,   // TODO: check if it is true
                id: "",
                issueType: "Billable",
                claimType: "",
                listPrice:  partList[ind].listPrice,
                productId: partList[ind].partId,
                quantity: partList[ind].quantity,
                tax: partList[ind].tax,              
                taxCode: '-',             
                totalAmount: totalAmount  // To be updated on repair quote
            };
            console.log('servicePackageHelper.fn_save  new recLineItem (part)::',recLineItem);
            itemList.push(recLineItem);
        }
        // console.log('servicePackageHelper.fn_save after ===========> part itemList 6 amount ::',itemList[6].amount);
        console.log('servicePackageHelper.fn_save after ===========> part itemList ::',itemList);
        /*
        var itemList3=JSON.parse(JSON.stringify(itemList));
        itemList3[0].amount=123456;

        
        for (var ind=0;ind < itemList.length; ind++) {
            const cloneObject=JSON.parse(JSON.stringify(itemList[ind]));


        }*/

        // add a new section list
        var sectionList=component.get('v.sectionList');
        sectionList.push({'name':sectionUnitName , type:'Pack'})
        component.set('v.sectionList',sectionList);

        component.set('v.itemList', itemList);
        // console.log('servicePackageHelper.fn_save after ===========> part itemList3 ::',itemList3);

        // $A.get('e.force:refreshView').fire();
        component.set('v.isOpen', false);

        /*  GD-1014 The saving is not done to the database
        var params = {
            recordId: recordId,
            laborList: JSON.stringify(laborList),
            partList: JSON.stringify(partList)
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