/**
 * Created by H1812104 on 2019-03-27.
 */
({
    open: function (component, event, helper) {
        // Initialize
        // arguments is keyword, You cannot use the 'arguments' keyword. Component is not display if it's used.
         var args = event.getParam('arguments'); 
        
        if (args != null && args.param != null) {
            var param = args.param;

            console.log('ServiceNewLaborController.open:: param=', param);
            // console.log(param.recordId);
            // console.log(param.sectionUnitName);
            // console.log(param.itemList);

            var recordId = param.recordId;
            var title = param.title;
            var message = param.message;

            component.set('v.recordId', recordId);
            component.set('v.laborList', []);
            component.set('v.selectedLaborList', []);
            component.set('v.isOpen', true);
            component.set('v.saved', false);
            // LMS 3/1/2021  GD-1014
            //  
            //  Add variables that will help to better position the newly
            //  created items into the sections of the repair quote
            component.set('v.sectionUnitName', param.sectionUnitName);
            console.log('ServiceNewPartController.open ==> sectionUnitName::',param.sectionUnitName);
                    
            
            var sectionType=param.sectionType;
            console.log('ServiceNewLaborController.open ==> sectionType::',param.sectionType);
            component.set('v.sectionType',sectionType);

            var itemList=component.get('v.itemList');
            console.log('ServiceNewLaborController.open ==> itemList::', itemList);
        }
    },
    init: function (component, event, helper) {
        helper.fn_init(component, event, helper);
    },
    search: function (component, event, helper) {
        var allValid = true;
        var inputCmp = component.find("opCode");
        var opCode = inputCmp.get('v.value');

        var isValid = inputCmp.checkValidity();
        if (!isValid) {
            inputCmp.showHelpMessageIfInvalid();
            allValid = false;
        }

        var opDesc = component.find("opDesc").get("v.value");
        if (!opCode && !opDesc) {
//                alert("Already selected");
            var message2 = $A.get("$Label.c.RPR_MSG_Either_Field");
            var code = $A.get("$Label.c.RPR_LAB_LaborCode");
            var name = $A.get("$Label.c.RPR_LAB_LaborName");
            var message = helper.format(message2, code, name);
            var toastParams = {
                title: "Error",
                message: message, 
                type: "error"
            }; 
            // Fire error toast
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
            allValid = false;
        }
        console.log('valid ' + allValid);
        if (allValid) helper.fn_search(component, event, helper);
    },
    add: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-value');

        var laborList = component.get('v.laborList');
        var labor = laborList[index];
        labor.quantity = 1;

        var selectedLaborList = component.get('v.selectedLaborList');
        for (var i = 0; i < selectedLaborList.length; i++) {
            var item = selectedLaborList[i];

            if (labor.id == item.id) {
                var message = $A.get("$Label.unknown_custom_label");
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
        }
        selectedLaborList.push(labor);
        component.set('v.selectedLaborList', selectedLaborList);
    },
    remove: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-value');
        console.log('index :: ', index);

        var selectedLaborList = component.get('v.selectedLaborList');
        selectedLaborList.splice(index, 1);
        component.set('v.selectedLaborList', selectedLaborList);
    },
    save: function (component, event, helper) {
        console.log('ServiceNewLaborController.save:: Call Helper ====>');

        helper.fn_save(component, event, helper);
    },
    close: function (component, event, helper) {
        component.set('v.isOpen', false);
    },
    cancel: function (component, event, helper) {
//        var callback = component.get("v.closeCallback");
//        if (callback) callback();
    },
})