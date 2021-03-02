({
  onfocus : function(component,event,helper) {
      $A.util.addClass(component.find("mySpinner"), "slds-show");
       let forOpen = component.find("searchRes");
           $A.util.addClass(forOpen, 'slds-is-open');
           $A.util.removeClass(forOpen, 'slds-is-close');
       // Get Default 5 Records order by createdDate DESC  
       let getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
   },
   onblur : function(component,event,helper) {
       component.set("v.listOfSearchRecords", null);
       let forclose = component.find("searchRes");
       $A.util.addClass(forclose, 'slds-is-close');
       $A.util.removeClass(forclose, 'slds-is-open');
   },
   keyPressController : function(component, event, helper) {
      // get the search Input keyword
      let getInputkeyWord = component.get("v.SearchKeyWord");
      // check if getInputKeyWord size id more then 0 then open the lookup result List and 
      // call the helper 
      // else close the lookup result List part.
       if(getInputkeyWord.length > 0) {
        let forOpen = component.find("searchRes");
              $A.util.addClass(forOpen, 'slds-is-open');
              $A.util.removeClass(forOpen, 'slds-is-close');
           helper.searchHelper(component,event,getInputkeyWord);
       } else {  
           component.set("v.listOfSearchRecords", null); 
           let forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
       }
 },

 // function for clear the Record Selection 
   clear :function(component,event,helper){
    let pillTarget = component.find("lookup-pill");
    let lookUpTarget = component.find("lookupField"); 


// console.log('#__flag_5__# record cleared');
if (component.get("v.label") === 'Vehicle Name') {
 // AS_ClearSelectedSObjectRecordEvent
 helper.fireClearRecordEvent(component);
 // alert('YES, it\'s an Vehicle Name custom lookup!');
}

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
   },

 // This function call when the end User Select any record from the result list.
   handleComponentEvent : function(component, event, helper) {
       // get the selected Account record from the COMPONENT event
       let selectedAccountGetFromEvent = event.getParam("recordByEvent");
       component.set("v.selectedRecord", selectedAccountGetFromEvent);

       let forclose = component.find("lookup-pill");
       $A.util.addClass(forclose, 'slds-show');
       $A.util.removeClass(forclose, 'slds-hide');

       forclose = component.find("searchRes");
       $A.util.addClass(forclose, 'slds-is-close');
       $A.util.removeClass(forclose, 'slds-is-open');

       let lookUpTarget = component.find("lookupField");
       $A.util.addClass(lookUpTarget, 'slds-hide');
       $A.util.removeClass(lookUpTarget, 'slds-show');
   },

 handleApplicationEvent : function(component, event, helper) {
// alert('[80] in handleApplicationEvent method');
  console.log('in handleApplicationEvent # event.getParam("recordByEvent") = ' + JSON.stringify(event.getParam("recordByEvent")));
  // alert('in handleApplicationEvent # event.getParam("recordByEvent") = ' + JSON.stringify(event.getParam("recordByEvent")));
  //  alert('### in correct method: handleApplicationEvent ### recordLabel: ' + event.getParam("recordLabel") + ' # recordByEvent: ' + event.getParam("recordByEvent"));
   // get the selected Account record from the COMPONETN event
   if (component.get("v.label") !== event.getParam("recordLabel")) {
     // console.log('1#handleApplicationEvent # inside if');
     return;
   }
   // console.log('2#handleApplicationEvent # outside of if');
   let selectedAccountGetFromEvent = event.getParam("recordByEvent");
// alert('[91] JSON.stringify(selectedAccountGetFromEvent) = ' + JSON.stringify(selectedAccountGetFromEvent));
   component.set("v.selectedRecord", selectedAccountGetFromEvent);

   let forclose = component.find("lookup-pill");
   $A.util.addClass(forclose, 'slds-show');
   $A.util.removeClass(forclose, 'slds-hide');

   forclose = component.find("searchRes");
   $A.util.addClass(forclose, 'slds-is-close');
   $A.util.removeClass(forclose, 'slds-is-open');

   let lookUpTarget = component.find("lookupField");
   $A.util.addClass(lookUpTarget, 'slds-hide');
   $A.util.removeClass(lookUpTarget, 'slds-show');
 },

  setValue : function(newRecordValue) {
    // alert('set value method triggered with newRecordValue = ' + JSON.stringify(newRecordValue));
    // component.set("v.selectedRecord", newRecordValue);

    // var forclose = component.find("lookup-pill");
    // $A.util.addClass(forclose, 'slds-show');
    // $A.util.removeClass(forclose, 'slds-hide');

    // var forclose = component.find("searchRes");
    // $A.util.addClass(forclose, 'slds-is-close');
    // $A.util.removeClass(forclose, 'slds-is-open');

    // var lookUpTarget = component.find("lookupField");
    // $A.util.addClass(lookUpTarget, 'slds-hide');
    // $A.util.removeClass(lookUpTarget, 'slds-show');
  }
})