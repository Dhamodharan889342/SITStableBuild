({
    init: function(component, event, helper) {

        var actionAPI = component.find("quickActionAPI");
//        console.table(actionAPI);
        console.log('actionAPI getGlobalId :: ', actionAPI.getGlobalId());
        console.log('actionAPI getLocalId :: ', actionAPI.getLocalId());
        console.log('actionAPI getEvent :: ', actionAPI.getEvent());
        console.log('actionAPI get v name :: ', actionAPI.get('v.name'));
        console.log('actionAPI getAvailableActions :: ', actionAPI.getAvailableActions());
//        console.log('actionAPI getAvailableActionFields :: ', actionAPI.getAvailableActionFields()); // error
//        console.log('actionAPI getCustomAction :: ', actionAPI.getCustomAction()); // error
        console.log('actionAPI getSelectedActions :: ', actionAPI.getSelectedActions());
        console.log('actionAPI toString :: ', actionAPI.toString());

        console.table($A);
        var comp = $A.getComponent();
        console.table(comp);
        helper.fn_init(component, event, helper);
    },
    save: function(component, event, helper) {
        console.log('controller doSave');
        helper.fn_save(component, event, helper);
    },
    cancel: function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    }
})