({
    selectRecord : function(component, event, helper) {
        var getSelectRecord = component.get("v.oRecord");
        var compEvent = component.getEvent("oSelectedRecordEvent");
// console.log('___in AS_CustomLookupResultController.js___ #1# getSelectRecord = ' + getSelectRecord);
// console.log('#2# JSON.stringify(getSelectRecord) = ' + JSON.stringify(getSelectRecord));
// alert('JSON.stringify(getSelectRecord)' + JSON.stringify(getSelectRecord))
        compEvent.setParams({"recordByEvent" : getSelectRecord});
        compEvent.fire();
    }
})