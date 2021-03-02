/**
 * Created by H1812104 on 2019-03-27.
 */

({
    init: function (component, event, helper) {
        helper.fn_init(component, event, helper);
    },
    refresh: function (component, event, helper) {
        console.log('PackageRepairController.refresh :: refresh');
        helper.fn_refresh(component, event, helper);
    },
    save: function (component, event, helper) {
        var dialog = component.find('dialog');

        console.log('Controller: Save function');

        var param = {
            message: $A.get('$Label.c.MSGS_SF_ConfirmPrompt')
        };

        dialog.confirm(param, function (response) {
            if (response.result) {
                helper.fn_save(component, event, helper);
            }
        });
    },
    /**
     *  Make the 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    getClaimOptions: function(component, event, helper) {
        var items=[{'value':'1','label':'Warranty'}, {'value':'2','label':'Item 1 of Package '}];
        
        var selectName=event.getSource().get("v.name");
        var itemList=component.get('v.itemList');

        // convert the name to integer  "SELTYPE:12" --> 12
        var itemListLineIndex=parseInt(selectName.substring(8));

        var ProductID=itemList[itemListLineIndex].productId;

        items.push({'value':3, 'label':ProductID});
        // component.set('v.ClaimOptions',items);
        
        console.log('PAckageRepairController: itemList ::', itemList);
        // console.log('PAckageRepairController: items ::', items);
        console.log('PAckageRepairController: name ::', selectName);
        var repairQuoteId_p = component.get('v.recordId');
        // helper.fn_getListRedeemableItems(component, helper, repairQuoteId_p, ProductID);

    },

    /**
     *   LMS GD-1014 save the "in memory" repair quote
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    handleClickSaveRepairQuote: function(component, event, helper) {
        console.log('PackageRepairController.handleClickSaveRepairQuote called ');
        var buttonState = component.get('v.RepairQuoteState');

        if (buttonState==false) {
            // nothing to do
            return;
        }

        var dialog = component.find('dialog');        

        var param = {
            message: $A.get('$Label.c.MSGS_SF_ConfirmPrompt')
        };

        dialog.confirm(param, function (response) {
            if (response.result) {
                // helper function to actually save
                console.log('PackageRepairController.handleClickSaveRepairQuote ====> Call the helper to save');
                helper.fn_saveRepairQuote(component, event, helper);
                // helper.fn_save(component, event, helper);
                helper.fn_RepairQuoteState_Change(component, event, helper, true);
                
            }
        });
    },
    syncWithWorkOrder: function (component, event, helper) {
        var dialog = component.find('dialog');
        var param = {
            message: $A.get('$Label.c.MSGS_SF_ConfirmPrompt')
        }
        dialog.confirm(param, function (response) {
            if (response.result) {
                helper.fn_syncWithWorkOrder(component, event, helper);
            } else {

            }
        });
    },
    /**
     *   Handle the remove button
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    remove: function (component, event, helper) {
        var dialog = component.find('dialog');

        var param = {
            message: $A.get('$Label.c.MSGS_SF_ConfirmPrompt')
        };

        dialog.confirm(param, function (response) {
            if (response.result) {
                helper.fn_remove(component, event, helper);
                helper.fn_RepairQuoteAltered(component, "PackageRepairController.remove");
            }
        });
    },
    addPart: function (component, event, helper) {
        if (component.get('v.body') != '') return;

        console.log('Controller: addPart');

        var laborCode = event.getSource().get("v.value"); // from lightning
        console.log('laborCode :: ', laborCode);
        var serviceNewPart = component.find('serviceNewPart');
        var param = {
            recordId: component.get('v.recordId'),
            laborCode: laborCode,
            title: 'New Part',
            message: 'New Part'
        };

        serviceNewPart.open(param);
    },
    cancel: function (component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },
    /**
     *  Call Parts and services screens to add 
     * 
     
     */
    showPopup: function (component, event, helper) {
        var type = event.getSource().get("v.value"); // from lightning

        // LMS GD-1014
        //     get the name of the current section so that
        //     we add the item to the proper section as 
        //     as the list of items that is being managed in memory
        var sectionUnitName=event.getSource().get("v.name");
        var strSplit=sectionUnitName.split("_#");
        sectionUnitName=strSplit[0];
        var sectionType=strSplit[1];
        
        var itemList=component.get('v.itemList');
        console.log('Controller: showPopup==> type='+type+' sectionUnitName='+sectionUnitName);

        helper.fn_RepairQuoteAltered(component, "PackageRepairController.remove");

        if (type == 'part') {
            var serviceNewPart = component.find('serviceNewPart');
            var param = {
                title: 'Add new part to section',   // TODO: Other languages
                recordId: component.get('v.recordId'),
                sectionUnitName: sectionUnitName,   // LMS GD-1014
                sectionType: sectionType  // user||pack ERROR
                // itemList: itemList                  // LMS GD-1014
            };
            
            serviceNewPart.open(param);
        }

        if (type == 'labor') {
            var serviceNewLabor = component.find('serviceNewLabor');
            var param = {
                title: 'Add new labor to section',   // TODO: Other languages
                recordId: component.get('v.recordId'),
                sectionUnitName: sectionUnitName,   // LMS GD-1014
                sectionType: sectionType
            };

            serviceNewLabor.open(param);
        } else if (type == 'package') {   // LMS 21/12/2020 Packages should be handled at the bottom button 
            var repairPackage = component.find('servicePackage');
            var param = {
                recordId: component.get('v.recordId'),
            };

            repairPackage.open(param);
        }
    },
    /**
     *  Handle the change of labor rates
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    handleLaborTypeChange: function (component, event, helper) {
        var strSelectValue = event.getSource().get("v.value"); // from lightning
       

        //var itemListLineIndex=event.getSource().get("v.id");
        var selectName=event.getSource().get('v.name');
        // convert the name to integer  "SEL:12" --> 12
        var itemListLineIndex=parseInt(selectName.substring(4));

        //var itemListLineIndex=event.getSource().getLocalId();
        var itemList=component.get('v.itemList');
        var lstLaborRates=component.get('v.LaborRateOptions');
        // search for the index in the list of labor rates
        var indexSelect=0;
        for (var ind=0;ind<lstLaborRates.length;ind++){
            if (lstLaborRates[ind].value==strSelectValue) {
                indexSelect=ind;
            }
        }

        var hourRate=lstLaborRates[indexSelect].hour_rate;

        console.log('Controller: handleLaborTypeChange==> Hour rate value='+hourRate+
                    ' Index='+itemListLineIndex + ' Text=' + lstLaborRates[indexSelect].text);
        console.log(itemList);

        itemList[itemListLineIndex].listPrice=hourRate;
        itemList[itemListLineIndex].LaborTypeRateId=lstLaborRates[indexSelect].value;
        itemList[itemListLineIndex].LaborTypeRateName=lstLaborRates[indexSelect].text;

        helper.fn_updateTotalAmount(itemList);

        component.set('v.itemList',itemList);
/*
LineItemCode: "NA"
LineItemName: "Light 2"
LineItemSectionName: "Munich Afban Oil Change Repair Package"
LineItemSectionType: "Pack"
LineItemType: "Labor"
amount: 85
claimType: "1"  ==> Not properly related in the UI 
discount: 0
hours: 1
id: ""
issueType: ""  ==> Not properly related in the UI
laborCode: "NA"
laborName: "Light 2"
listPrice: "53"
quantity: 5
tax: 19
taxCode: "-"
totalAmount: 315.34999999999997

TODO: Missing fields

id of masterfile (labor|part)
LaborTypeRateId

*/


    },
    /**
     * LMS GD-1014
     * 
     *    Handle quantity changes 
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    handleQuantityChange: function (component, event, helper) {

        helper.fn_RepairQuoteAltered(component, "PackageRepairController.handleQuantityChange");

        var quantityValue = event.getSource().get("v.value"); // from lightning

        var itemListLineIndex=event.getSource().get("v.id");
        var itemList=component.get('v.itemList');

        console.log('Controller: handleQuantityChange==> type='+quantityValue+' Index='+itemListLineIndex);
        console.log(itemList);
        //itemList[itemListLineIndex].tax=parseFloat(quantityValue);

        helper.fn_updateTotalAmount(itemList);

        component.set('v.itemList',itemList);

    },
    /**
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    onIssueTypeChanged: function (component, event, helper) {

        helper.fn_RepairQuoteAltered(component, "PackageRepairController.onIssueTypeChanged");

        var index = event.getSource().get("v.name"); // from lightning
        console.log('onIssueTypeChanged call. index :: ', index);
       
        var itemList=component.get('v.itemList');
        console.log('PackageRepairController.onIssueTypeChanged itemList::',itemList);
        
        

	/*
        var laborList = component.get('v.itemList');
        var labor = laborList[index];
        if (labor.issueType != 'Claimable') {
            labor.claimType = '';
            component.set('v.itemList', laborList);
        }
        */
    },
    /**  GD-1224
     *   Search for adequate items for redemption
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */

    onChangeDynamicSelect: function (component, event, helper){

        helper.fn_RepairQuoteAltered(component, "PackageRepairController.onChangeDynamicSelect");
        //                               012345678901
        // convert the name to integer  "COMDYNTYPE:12" --> 12        
        var selectName=event.getSource().get("v.name");
        console.log('PackageRepairController.onChangeDynamicSelect selectName::', selectName);
        
        var itemListLineIndex=parseInt(selectName.substring(11));
        console.log('PackageRepairController.onChangeDynamicSelect index='+itemListLineIndex);
        // product id important r
        var itemList=component.get('v.itemList');
        console.log('PackageRepairController.onChangeDynamicSelect itemList::',itemList);
        var ProductID=itemList[itemListLineIndex].productId;

        console.log('PackageRepairController: name ::', selectName);
        var repairQuoteId_p = component.get('v.recordId');
        helper.fn_getListRedeemableItems(component, event, helper, repairQuoteId_p, ProductID);

    },
    /**
     *  Handle the warranty or redemption of items in the repair quote
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    onChangeClaimType: function (component, event, helper){
        helper.fn_RepairQuoteAltered(component, "PackageRepairController.onChangeClaimType");
        
        //                               012345678901
        // convert the name to integer  "COMDYNTYPE:12" --> 12        
        var selectName=event.getSource().get("v.name");
        console.log('PackageRepairController.onChangeClaimType selectName::', selectName);
        
        var itemListLineIndex=parseInt(selectName.substring(11));
        console.log('PackageRepairController.onChangeClaimType index='+itemListLineIndex);
        var itemList=component.get('v.itemList');
        console.log('PackageRepairController.onChangeClaimType itemList::',itemList);
        // TODO: adopt other languages
        var strClaimable='Claimable';
        var strLineItemType='Labor';

        if ((itemList[itemListLineIndex].issueType==strClaimable) &&
            (itemList[itemListLineIndex].LineItemType==strLineItemType))
        {
            // check if we're talking about a warranty in order to update
            // the labor rate
            // TODO: adapt to other languages
            var strWarrantyName='Warranty';

            if (itemList[itemListLineIndex].claimType==strWarrantyName) {                
                var recLaborType=helper.fn_searchLaborType(component, helper,strWarrantyName);                
                if (recLaborType!=null){
                    console.log('PackageRepairController.onChangeClaimType ==> FOUND '+strWarrantyName);
                    itemList[itemListLineIndex].LaborTypeRateId=recLaborType.id; 
                    itemList[itemListLineIndex].LaborTypeRateName=recLaborType.text;
                    itemList[itemListLineIndex].listPrice=recLaborType.hour_rate;
                }
            } else {
                // let's use the internal type
                // TODO: adapt to other languages
                var strInternalName='Internal';

                var recLaborType=helper.fn_searchLaborType(component, helper,strInternalName);                
                if (recLaborType!=null){
                    console.log('PackageRepairController.onChangeClaimType ==> FOUND '+strInternalName);
                    itemList[itemListLineIndex].LaborTypeRateId=recLaborType.id; 
                    itemList[itemListLineIndex].LaborTypeRateName=recLaborType.text;
                    itemList[itemListLineIndex].listPrice=recLaborType.hour_rate;
                }

            }
            // update the list of items 
            component.set('v.itemList',itemList);
        } 
    },

    handleApproveClick : function (cmp) {
        cmp.set('v.approved', !cmp.get('v.approved'));
    },
    /**
     * GD-1014 change the name of the user defined section
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    handleChangeSectionName: function (component, event, helper){
        var strValue = event.getSource().get("v.name"); // from lightning
        var sectionName = event.getSource().get("v.value"); // from lightning
        
        helper.fn_RepairQuoteAltered(component, "PackageRepairController.handleChangeSectionName");
        
        var arrayValue=strValue.split("#");


        //var sectionName=arrayValue[0];  
        var sectionType='User';
        var intSectionIndex=parseInt(arrayValue[1]);

        console.log('PackageRepairController.handleChangeSectionName strValue::',strValue);
        console.log('PackageRepairController.handleChangeSectionName sectionName::',sectionName);
        console.log('PackageRepairController.handleChangeSectionName sectionType::',sectionType);
        console.log('PackageRepairController.handleChangeSectionName intSectionIndex::',intSectionIndex);
        

        var sectionList=component.get('v.sectionList');
        var oldName=sectionList[intSectionIndex].name;
        sectionList[intSectionIndex].name=sectionName;
        console.log('PackageRepairController.handleChangeSectionName oldName::',oldName);

        var itemList=component.get('v.itemList');

        for (var ind=0;ind<itemList.length;ind++){
            if ((itemList[ind].LineItemSectionName==oldName) && (itemList[ind].LineItemSectionType==sectionType)){
                itemList[ind].LineItemSectionName=sectionName;
            }

        }
        console.log('PackageRepairController.handleChangeSectionName sectionList::',sectionList);
        console.log('PackageRepairController.handleChangeSectionName itemList::',itemList);
        
        component.set('v.sectionList',sectionList);
        component.set('v.itemList',itemList);

    },

    // LMS 18/12/2020
    //     GD-1014
    // 
    //      Add a new section to "package list"
    handleNewSectionClick: function(cmp,  event, helper){
        console.log('Controller: handleNewSectionClick');

        helper.fn_RepairQuoteAltered(cmp, "PackageRepairController.onChangeClaimType");
       
        var sectionList=cmp.get('v.sectionList');
        sectionList.push({'name':'Change this title!','type':'User'});
        cmp.set('v.sectionList', sectionList);
        // $A.get('e.force:refreshView').fire();
    },
   
    handleNewPackageClick: function(cmp, event, helper){ 
        // LMS 20/12/2020  
        //     GD-1014
        // 
        //      Add a new packae to "package list"
        console.log('Controller: handleNewPackageClick');

        helper.fn_RepairQuoteAltered(cmp, "PackageRepairController.handleNewPackageClick");

        
        var sectionList=cmp.get('v.sectionList');
        

        // TODO: only add the package after the
        //       user selects the package in the popup window
        // sectionList.push({'name':'Package','type':'Pack'});
        cmp.set('v.sectionList', sectionList); 
        $A.get('e.force:refreshView').fire();

        var repairPackage = cmp.find('servicePackage');
        var param = {
            recordId: cmp.get('v.recordId'),
        };

        repairPackage.open(param);

    },
    /**
     * LMS 22/12/2020
     * Show the input element or a fixed label 
     */
    showInput: function(cmp){

        var item=cmp.get('v.item');

        var subTitle=item.substring(0,4);
        console.log('PackageRepairController.showInput '+ subTitle);

        if (subTitle=="Pack") {
            return false;
        } else {
            return false;
        }

    },
    
    handle_itemList_Event: function(component, event, helper) {
        /**
         *  LMS GD-1014  3/1/2021
         *    Receive the new list of items from the child  
         *    component  (labor or part)
         */
        helper.fn_RepairQuoteAltered(component, "PackageRepairController.handle_itemList_Event");

        var newItemsList = event.getParam("param");
        console.log("PackageRepairController.handle_itemList_Event:: Received component event with param = ");
        console.log(newItemsList);
        console.log(newItemsList.length);

        // add received values to the current item list
        // TODO: do the proper data insertion in a helper function
        var itemList=component.get('v.itemList');

        console.log('PackageRepairController.handle_itemList_Event:: itemList');
        console.log(itemList);
        var arraySize=newItemsList.length;
        for (var i=0; i < arraySize; i++){
            //console.log('PackageRepairController.handle_itemList_Event:: loop i='+i);
            var itemLine={
                LineItemCode: newItemsList[i].laborCode,
                LineItemName: newItemsList[i].laborName,                
                amount:  newItemsList[i].amount,
                quantity: newItemsList[i].quantity,
                hours: newItemsList[i].hours,
                tax: newItemsList[i].tax,
                
                // TODO: change from har code
                LineItemSectionName: 'Package Maintenance',
                LineItemSectionType:'Pack',
                LineItemType: 'Labor',
                listPrice: 50, // TODO: get the hourly rate from custom object
                
                taxCode: "-",
                totalAmount: 0  // more elegant to calculate on the outside
            }
            // (newItemsList[i].amount*newItemsList[i].quantity*(1+))
            // TODO: call the generic update
            itemLine.totalAmount=itemLine.amount*itemLine.quantity*(1+(itemLine.tax/100));

            console.log('PackageRepairController.handle_itemList_Event:: item to add===>'+itemLine);
            itemList.push(itemLine);
        }
        console.log('PackageRepairController.handle_itemList_Event:: itemList final');
        console.log(itemList); 
        
        component.set('v.itemList',itemList);

    }
})

/*
[
    {
       "componentName":"RelatedRecord",
       "label":"RPR_LAB_Vehicle_Info",
       "attributes":{
          "title":"RPR_LAB_Vehicle_Info",
          "relatedField":"Vehicle__c",
          "sobjName":"Asset",
          "fields":"Name,EngineNo__c,VIN__c,LatestMileage__c,PurchaseDate,Butler__c,Product2Id,fm_ButlerMobile__c"
       }
    },
    {
       "componentName":"RepairWarranty",
       "label":"RPR_TAB_Warranty",
       "attributes":{
          "title":"RPR_TAB_Warranty"
       }
    },
    {
       "componentName":"RepairPackage",
       "label":"RPR_LAB_Package",
       "attributes":{
          "title":"RPR_LAB_Package"
       }
    },
    {
       "componentName":"RepairCoupon",
       "label":"RPR_LAB_Coupon",
       "attributes":{
          "title":"RPR_LAB_Coupon"
       }
    },
    {
       "componentName":"RepairCustomerField",
       "label":"RPR_LAB_CustomerField",
       "attributes":{
          "title":"RPR_LAB_CustomerField"
       }
    }
 ]

 ==> 
[
    {
       "componentName":"RelatedRecord",
       "label":"RPR_LAB_Vehicle_Info",
       "attributes":{
          "title":"RPR_LAB_Vehicle_Info",
          "relatedField":"Vehicle__c",
          "sobjName":"Asset",
          "fields":"Name,EngineNo__c,VIN__c,LatestMileage__c,PurchaseDate,Butler__c,Product2Id,fm_ButlerMobile__c"
       }
    },
    {
       "componentName":"RepairWarranty",
       "label":"RPR_TAB_Warranty",
       "attributes":{
          "title":"RPR_TAB_Warranty"
       }
    },
    {
       "componentName":"RepairPackage",
       "label":"RPR_LAB_Package",
       "attributes":{
          "title":"RPR_LAB_Package"
       }
    }
 ]

 Translatable component to present Vehicle service package at the bottom 
 of the page

[
   {
      "componentName":"RepairPackage",
      "label":"RPR_LAB_Package",
      "attributes":{
         "title":"RPR_LAB_Package"
      }
   }
]



*/