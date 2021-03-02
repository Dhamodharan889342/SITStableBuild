/**
 * Created by H1812104 on 2019-03-27.
 */
({
    fn_init: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId ::', recordId);

        var sObjectTypeList = [];
        
        // TODO: GD-1014 object not existant in Genesis Europe
        //sObjectTypeList.push('RepairLabor__c');
        sObjectTypeList.push('Repair_Quote_Line_Item__c');
//        console.log('sObjectTypeList :: ', sObjectTypeList);
        helper.fn_getSObjectType(component,
            sObjectTypeList,
            this.fn_getLaborList(component, event, helper)
        );
    },
    /** GD-1014
     * Get the list of items that should be displayed
     * initially when the repair quote appears
     * 
     * The logic to handle getting the data from repair quote line
     * items or from the vehicle 
     * 
     */
    fn_getRepairQuoteLineItems: function (component, event, helper) {


    },
    fn_refresh: function (component, event, helper) {
        this.fn_getLaborList(component, event, helper);
    },
    /**
     * 
     * @param {*} component 
     * @param {*} helper 
     * @param {*} strLaborType 
     */
    fn_searchLaborType: function(component, helper,strLaborType){
        var LaborRateOptions=component.get('v.LaborRateOptions');
        for (var ind=0;ind<LaborRateOptions.length;ind++){
            if (LaborRateOptions[ind].text==strLaborType){
                return LaborRateOptions[ind];
            }
        }
        return null;
    },

    /**
     * set the current list of availabe labor rates 
     * 
     * @param {} component 
     * @param {*} helper 
     * @param {*} refDate 
     */
    fn_setLaborRates: function(component, helper, refDate, country){
       
        // TODO: use the controller to get
        //       the labor rates  çç
        var lstLaborRates=component.get('v.LaborRateOptions');

        if (lstLaborRates.length>0) {
            return;
        }

        var params = {
            dtRef: refDate,
            strCountry: country
        };
        console.log('PackageRepairHelper.fn_setLaborRates call.=======>  params ::', params);

        var action = component.get("c.getLaborRates");
        action.setParams(params);
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var l = response.getReturnValue();
                console.log('PackageRepairHelper.fn_setLaborRates result =======> labor rates ::', l.lstLaborRates);
                var lstLaborRates_2=l.lstLaborRates;
                for (var ind=0;ind<lstLaborRates_2.length;ind++) {
                    lstLaborRates.push (
                        {value: lstLaborRates_2[ind].Id,   // has to be unique
                        text: lstLaborRates_2[ind].LaborType__c, 
                        hour_rate: lstLaborRates_2[ind].Rate__c,
                        id:lstLaborRates_2[ind].Id}
                    );
                }

                component.set("v.LaborRateOptions", lstLaborRates);

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
        /*
        lstLaborRates.push({value:"50", text:"Maintenance", id:"1"});
        lstLaborRates.push({value:"51", text:"Diagnosis/EE", id:"2"});
        lstLaborRates.push({value:"52", text:"Internal", id:"3"});
        lstLaborRates.push({value:"53", text:"Genesis", id:"4"});
        lstLaborRates.push({value:"54", text:"Warranty", id:"5"});
        lstLaborRates.push({value:"55", text:"Bodywork", id:"6"});
        
        component.set("v.LaborRateOptions", lstLaborRates);
        */
    },
    /**
     *   Verifiy that a section exists in the array of sections
     *    if it exists return the index
     * @param {*} lstSections 
     * @param {*} strName 
     */
    fn_searchNameSection: function(lstSections,strName){
        for (var i=0; i < lstSections.length; i++){
            if (lstSections[i].name===strName){
                return i;
            }
        }
        return -1;
    },
    /**
     *   Create the section for the current repair quote
     *   based in the list of items supplied
     * 
     * @param {*} itemList 
     */
    fn_setSections: function(component,helper, itemList){

        var lstSections=[];

        for (var i=0; i<itemList.length; i++){
            if (helper.fn_searchNameSection(lstSections, itemList[i].LineItemSectionName)==-1) {
                var rec={
                    'name': itemList[i].LineItemSectionName,
                    'type': itemList[i].LineItemSectionType
                };
                lstSections.push(rec);
            } 
        }
        component.set("v.sectionList", lstSections);
    },
    /**
     * LMS 28/12/2020
     *      Function to get the items of the repair quote
     *      the controller makes sure that the proper data is obtained
     *      from the database
     * 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    fn_getLaborList: function (component, event, helper) {
        component.set('v.IsLoading', true);
        // adjust labor rates
        // TODO: find the country
        helper.fn_setLaborRates(component, helper, new Date(),'Germany');

        // var evt1=component.get()

        var recordId = component.get('v.recordId');
        
        var params = {
            recordId: recordId
        };
        console.log('PackageRepairHelper.fn_getLaborList call.=======>  recordId ::', recordId);

        var action = component.get("c.doGetLaborList");
        action.setParams({"pmap": params});
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var l = response.getReturnValue();
                console.log('PackageRepairHelper.fn_getLaborList result =======> labor ::', l.laborList);
                console.log('PackageRepairHelper.fn_getLaborList result =======> labor.length ::', l.laborList.length);
                // make last adjustments
                helper.fn_setSections(component, helper, l.laborList);
                // clean the "fake" items that are
                // related to additional services commented in 
                // the service booking 
                var itemList=[];
                for (var ind=0; ind < l.laborList.length; ind++) {
                    //console.log('PackageRepairHelper.fn_getLaborList l.laborList[ind]=',l.laborList[ind]);
                    //console.log('PackageRepairHelper.fn_getLaborList l.laborList[ind].LineItemCode=',l.laborList[ind].LineItemCode);
                    if (l.laborList[ind].LineItemCode!='fake') {
                        // console.log('PackageRepairHelper.fn_getLaborList ======> add l.laborList[ind]='+ind+' ',l.laborList[ind]);
                        itemList.push(l.laborList[ind]);
                    }
                }
                console.log('PackageRepairHelper.fn_getLaborList result =======> final itemList ::',itemList);

                component.set("v.itemList", itemList);
                component.set('v.disabledApply', l.disabledApply);
                //component.find("SectionTitle0").set("v.value","mudei");

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    /**
     *   Remove an item from the quote 
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    fn_remove: function (component, event, helper) {
        // component.set('v.IsLoading', true);
        
        var itemListIndex = event.getSource().get("v.value"); // from lightning
        
        console.log('PackageRepairHelper.fn_remove ===> itemListIndex ::', itemListIndex);
        var itemList = component.get('v.itemList');

        // simply remove the index from the array
        itemList.splice(itemListIndex,1);

        component.set('v.itemList', itemList);

    },
    /**
     * GD-1014
     * send the repair quote to the database
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    fn_saveRepairQuote: function (component, event, helper) {
        component.set('v.IsLoading', true);


        var recordId = component.get('v.recordId');
        console.log('PackageRepairHelper.fn_saveRepairQuote =====> .recordId ::', recordId);
        var itemList = component.get('v.itemList');
        console.log('PackageRepairHelper.fn_saveRepairQuote itemList::',itemList);
        // TODO: send valid quote sections
        var params = {
            recordId: recordId,
            itemList: JSON.stringify(itemList)
        };
        console.log('PackageRepairHelper.fn_saveRepairQuote =====> JSON Object to use::',params);
        // the new method to save everything
        var action = component.get("c.doSaveRepairQuote");
        action.setParams({"pmap": params});
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var o = response.getReturnValue();
                console.log('PackageRepairHelper.fn_saveRepairQuote =====> response to controller::',o);
                $A.get('e.force:refreshView').fire();
                // only time the repair stays in a saved mode
                component.set('v.RepairQuoteState',false);  
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
     *   NOT USED
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    fn_save: function (component, event, helper) {
        component.set('v.IsLoading', true);

        var recordId = component.get('v.recordId');
        //console.log('recordId ::', recordId);
        var laborList = component.get('v.itemList');

        var params = {
            recordId: recordId,
            laborList: JSON.stringify(laborList)
        };
        console.log('PackageRepairHelper.fn_save params::', params);

        var action = component.get("c.doSaveLabor");
        action.setParams({"pmap": params});
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var o = response.getReturnValue();
//                console.log('o ::', o);
                $A.get('e.force:refreshView').fire();
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
     * LMS GD-1014
     *   Handle the "save button" im the repair quote screen
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     * @param {*} state of the repair quote 
     *                  true - when repair needs to be saved
     *                  false - when repair quote doesn't need to be saved
     */
    fn_RepairQuoteState_Change: function(component, event, helper, state) {
        var buttonStateful=event.getSource();
        var buttonState = component.get('v.RepairQuoteState');

        var itemList = component.get('v.itemList');
        console.log(itemList);

        console.log('PackageRepairHelper.fn_RepairQuoteState_Change called')
        if (state==true) {
            //buttonStateful.set('v.disabled',true);
            helper.fn_RepairQuoteAltered(component,'fn_RepairQuoteState_Change');
        }

    },
    /**
     * Handle the state change 
     * @param {*} component 
     * @param {*} strComment 
     */
    fn_RepairQuoteAltered: function(component,strComment) {
        console.log('PackageRepairHelper.fn_RepairQuoteAltered:: message='+strComment);
        
        // this makes the repair quote "dirty" --> needs to be saved
        component.set('v.RepairQuoteState',true);        
    },
    /**
     *   Call the controller to get the list of redeemable items
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     * @param {*} repairQuoteId_p 
     * @param {*} productCodeId_p 
     */
    fn_getListRedeemableItems: function(component, event, helper, repairQuoteId_p, productCodeId_p){
              
        component.set('v.IsLoading', true);
        
        var params = {
            repairQuoteId: repairQuoteId_p,
            productCodeId: productCodeId_p
        };
        console.log('PackageRepairHelper.fn_getListRedeemableItems call.=======>  recordId ::', params);

        var action = component.get("c.getListRedeemableItems");
        action.setParams(params);
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.IsLoading', false);
            if (state === "SUCCESS") {
                var l = response.getReturnValue();
                console.log('PackageRepairHelper.fn_getListRedeemableItems call lstItemsRedeem ::', l.lstItemsRedeem);
                // , selected: "true"
                var opts = [
                    { "class": "optionClass", label: "Warranty", value: "Warranty" }                   
                ];
                // event.getSource().set("v.options", opts);

                
                for (var ind=0; ind<l.lstItemsRedeem.length;ind++){

                    var strLabel=l.lstItemsRedeem[ind].Vehicle_Service_Package__r.Name;
                    strLabel+='-'+l.lstItemsRedeem[ind].Product__r.Name;    
                    // the value has to point to vehicle servce package item                 
                    var strValue=l.lstItemsRedeem[ind].Id;
                    opts.push({'value':strValue, 'label':strLabel})
                }
                console.log('PackageRepairHelper.fn_getListRedeemableItems  item for options::',opts);
                event.getSource().set("v.options", opts);

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    /**
     * LMS GD-1014
     * 
     *  Update the "Total Amount" field of the itemList displayed
     * 
     *  It takes into account all the relevant parts of Total amount 
     *  (item type, hours, quantity, list price, discount and tax)
     * 
     * @param {*} itemList 
     * 
     *   --> returns the updated totak  itemList
     * Array elements:
        LineItemCode: "0001Mock"
        LineItemName: "Labor Name 001Mock"
        LineItemSectionName: "Package Maintenance"
        LineItemSectionType: "Pack"
        LineItemType: "Labor"
        amount: 400
        claimType: "1"
        hours: 10
        issueType: ""
        laborCode: "TestCode"
        laborName: "Test Name"
        listPrice: 40
        quantity: "12"
        tax: "12"
        taxCode: "-"
        totalAmount: 476
    
     */
    fn_updateTotalAmount: function(itemList){

        for (var i=0;i<itemList.length;i++){
            var tempTotal=itemList[i].listPrice;
            // Ligthning UI can convert number to String;

            tempTotal=tempTotal*parseFloat(itemList[i].quantity);
            // if the item is labor then the number of hours has to used
            if (itemList[i].LineItemType=='Labor'){
                tempTotal=tempTotal*itemList[i].hours;
            }
            itemList[i].amount=tempTotal;
            if (itemList[i].discount){
                var discount=parseFloat(itemList[i].discount);
                discount=(discount/100)*tempTotal;
                tempTotal=tempTotal-discount;
            }       
            tempTotal=tempTotal * (1 + (itemList[i].tax/100));

            itemList[i].totalAmount=tempTotal;
        }

        // return itemList;
    }
})


/*
LMS 1/2/2020 

Some other code that allow testing data


List<Product2> lstMasterfile=[select id, LineItemType__c, Product_Type__c from product2 where Product_Type__c in ('Labor','Part')];

for (Product2 itemMasterfile: lstMasterfile){    
    itemMasterfile.LineItemType__c=itemMasterfile.Product_Type__c;    
}

update lstMasterfile;




*/