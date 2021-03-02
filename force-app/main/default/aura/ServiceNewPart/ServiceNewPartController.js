/**
 * Created by H1812104 on 2019-03-27.
 */
({
    open: function (component, event, helper) {
        // Initialize
        var args = event.getParam('arguments'); // arguments is keyword, You cannot use the 'arguments' keyword. Component is not display if it's used.
        if (args != null && args.param != null) {
            var param = args.param;

            var recordId = param.recordId;
            var laborCode = param.laborCode;
            var title = param.title;
            var message = param.message;

            component.set('v.recordId', recordId);
            component.set('v.laborCode', laborCode);
            component.set('v.partList', []);
            component.set('v.selectedPartList', []);
            component.set('v.isOpen', true);
            component.set('v.saved', false);
            // GD-1014
            // new members           
            var sectionUnitName=param.sectionUnitName;
            console.log('ServiceNewPartController.open ==> sectionUnitName::',sectionUnitName);
            component.set('v.sectionUnitName',sectionUnitName);

            var sectionType=param.sectionType;
            console.log('ServiceNewPartController.open ==> sectionType::',sectionType);
            component.set('v.sectionType',sectionType);

            //component.set('v.sectionUnitName', sectionUnitName);
            //var itemList=param.itemList;
            //component.set('v.itemList', itemList);
            var itemList=component.get('v.itemList');
            console.log('ServiceNewPartController.open ==> itemList::', itemList);
            // teste
            //itemList[0].amount=500;
            //component.set('v.itemList', itemList);
        }
    },
    init: function (component, event, helper) {
        console.log('ServiceNewPart Call.');
        helper.fn_init(component, event, helper);
    },
    search: function (component, event, helper) {
        var allValid = true;
        var inputCmp = component.find("opPartNo");
        var opCode = inputCmp.get('v.value');

        var isValid = inputCmp.checkValidity();
        if (!isValid) {
            inputCmp.showHelpMessageIfInvalid();
            allValid = false;
        }

        var opDesc = component.find("opDesc").get("v.value");
        console.log('ServiceNewPartController.search: step1');
        if (!opCode && !opDesc) {
//                alert("Already selected");
            var message2 = $A.get("$Label.c.RPR_MSG_Either_Field");
            var code = $A.get("$Label.c.RPR_LAB_PartCode");
            var name = $A.get("$Label.c.RPR_LAB_PartName");
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
        console.log('ServiceNewPartController.search: step2');
        if (allValid) helper.fn_search(component, event, helper);
    },
    add: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-value');
        console.log('index :: ', index);

        var partList = component.get('v.partList');
        var part = partList[index];
        part.quantity = 1;
        var selectedPartList = component.get('v.selectedPartList');
        for (var i = 0; i < selectedPartList.length; i++) {
            var item = selectedPartList[i];
            if (part.partCode == item.partCode) {
//                alert("Already selected");
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
        selectedPartList.push(part);
        component.set('v.selectedPartList', selectedPartList);
    },
    remove: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-value');
        console.log('index :: ', index);

        var selectedPartList = component.get('v.selectedPartList');
        selectedPartList.splice(index, 1);
        component.set('v.selectedPartList', selectedPartList);
    },
    save: function (component, event, helper) {
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