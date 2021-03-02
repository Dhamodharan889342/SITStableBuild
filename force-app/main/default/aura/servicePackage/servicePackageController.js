/****************************************************************************************
 * @author          Lee Donghu
 * @date            2019-07-30
 *
 * @group           Service
 * @group-content   Service
 *
 * @description     ServicePackageController.js
 ****************************************************************************************/
({
    /**
     * Created by H1812104 on 2019-03-27.
     */
    open: function (component, event, helper) {
        // Initialize
        console.log('open ::', event);
        var args = event.getParam('arguments'); // arguments is keyword, You cannot use the 'arguments' keyword. Component is not display if it's used.
        console.log('open args :: ', args);
        if (args != null && args.param != null) {
            var param = args.param;

            var recordId = param.recordId;
            // var title = param.title;
            // var message = param.message;

            console.log('param :: ', param);
            console.log('recordId :: ', recordId);

            component.set('v.recordId', recordId);
            
            component.set('v.packageList', []);
            component.set('v.selectedPackageList', []);
            component.set('v.laborList', []);
            component.set('v.partList', []);
            component.set('v.isOpen', true);
            component.set('v.saved', false);
        }
    },
    init: function (component, event, helper) {
        helper.fn_init(component, event, helper);
    },
    search: function (component, event, helper) {
        console.log('servicePackageController.search');
        helper.fn_search(component, event, helper);
    },
    /**
     *  add the select package
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    add: function (component, event, helper) {
        var strValue = event.currentTarget.getAttribute('data-value');
        var arrValue = strValue.split('#');
        var packageId = arrValue[0];
        var packageName = arrValue[1];
        component.set('v.sectionName', packageName);

        console.log('servicePackageController.add packageId :: '+  packageId+ ' '+ packageName);
        helper.fn_add(component, event, helper, packageId);
    },
    reset: function (component, event, helper) {
        component.find("packageNo").set("v.value", '');
        component.find("packageName").set("v.value", '');
        component.find("laborCode").set("v.value", '');
        component.find("laborName").set("v.value", '');
        component.find("partNo").set("v.value", '');
        component.find("partName").set("v.value", '');
        component.set("v.packageList", []);
        component.set("v.laborList", []);
        component.set("v.partList", []);
    },
    save: function (component, event, helper) {
        helper.fn_save(component, event, helper);
    },
    close: function (component, event, helper) {
        component.set('v.isOpen', false);
    },
})