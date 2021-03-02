({
 
 init : function(component, event, helper) {
     //gets the Repair Id from URL
		       var ServiceBookingrecordId =component.get('v.recordId');
             component.set("v.ServiceBookingrecordId",component.get('v.recordId') );

     var action = component.get("c.getcount");
    		action.setParams(
            {
                "ServiceBookingrecordId":ServiceBookingrecordId
            });
        action.setCallback(this, function(actionresult) {
     var state = actionresult.getState();
            console.log('state ::', state);
            if (state === "SUCCESS") {
                console.log(actionresult.getReturnValue());
        	  component.set('v.errorvar',actionresult.getReturnValue()); 
              console.log('errorvar1',component.get("v.errorvar"));
             if(component.get('v.errorvar')==='Noerror')
    		 {
           component.set("v.showerror", false);
        var action = component.get("c.getdata");
    		action.setParams(
            {
                "ServiceBookingrecordId":ServiceBookingrecordId
            });
        action.setCallback(this, function(actionresult) {
     var state = actionresult.getState();
            console.log('state ::', state);
            if (state === "SUCCESS") {
        	  component.set('v.RepairData',actionresult.getReturnValue()); 
            }
        });
        $A.enqueueAction(action);          
     }   
      else if(component.get('v.errorvar')==='error')
        {
        component.set("v.showerror", true);
		component.set("v.errormessage", "Please create vehicle condition report before creating inspection report.");
        }
            }
        });
        $A.enqueueAction(action);          
    
  

 },
	getrecommend : function(component, event, helper) {
        
        // to show we recommend section if user checks uneven tyre wear
        console.log(event.getParam("value"));
		if(event.getParam("value")=='NO')
        {
             component.set("v.showrecommend" , false);
        console.log(component.get("v.showrecommend"));
        }
        else if(event.getParam("value")=='YES')
        {
             component.set("v.showrecommend" , true);
        console.log(component.get("v.showrecommend"));
        }
      
	},
    	getbrakemeasure : function(component, event, helper) {
            //to not show brake shoes section if user checks brake measurements were not taken
            
        console.log(event.getParam("value"));
		if(event.getParam("checked")===true)
        {
             component.set("v.brakemeasure" , true);
        console.log(component.get("v.brakemeasure"));
        }
        else if(event.getParam("checked")===false)
        {
             component.set("v.brakemeasure" , false);
        console.log(component.get("v.brakemeasure"));
        }
      
	},
    	getcustomerradiotext : function(component, event, helper) {
            //to show text input field for customer radio station if user checks on Customer Radio Station in iCare
        console.log(event.getParam("value"));
		if(event.getParam("value").includes('Customer Radio Station'))
        {
             component.set("v.showcustomerradiotext" , true);
        console.log(component.get("v.showcustomerradiotext"));
        }
        else if(!event.getParam("value").includes('Customer Radio Station'))
        {
             component.set("v.showcustomerradiotext" , false);
        console.log(component.get("v.showcustomerradiotext"));
        }
      
	},
    
    
    doInit: function(component, event, helper) {
  
        //get current data and time
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD mm:hh:ss");
    	component.set('v.today', today);
       //Initialize signature canvas for both workshop 
		      console.log('doInit');
       
		var w_canvas = component.find('w_padd').getElements()[0], signaturePad_w;
		function resizeCanvasw() {
			var ratio_w = Math.max(window.devicePixelRatio || 1, 1);
			w_canvas.width = w_canvas.offsetWidth * ratio_w;
			w_canvas.height = w_canvas.offsetHeight * ratio_w;
			w_canvas.getContext('2d').scale(ratio_w, ratio_w);
		}

		window.onresize = resizeCanvasw;
		resizeCanvasw();

        var optionsw = {
//            dotSize : 50,
            minWidth : 2,
            maxWidth : 4
        };
		signaturePad_w = new SignaturePad(w_canvas, optionsw);
        	
       
        
	},
     cancel: function(component, event, helper) {
         console.log('cancel');
     $A.get('e.force:closeQuickAction').fire();
         
    },
    save: function(component, event, helper) {
        //save all data entered by user
        var headlights='';
         var taillights='';
         var WiperBlades='';
         var Windshield='';
         var lfTyreTreadDepth='';
         var lfBrakeLining='';
        var lfkpa='';
         var horn='';
         var Heat='';
        var rfkpa='';
        var rfTyreTreadDepth='';
        var rfBrakeLining='';
        var lrkpa='';
        var lrTyreTreadDepth='';
        var lrBrakeLining='';
        var rrkpa='';
        var rrTyreTreadDepth='';
        var rrBrakeLining='';
        var battery='';
        var cooling='';
        var radiator='';
        var driveBelts='';
        var sparekpa='';var uneven='';var icare=[];var recommend=[];var cust_radio='';var brakeheader='';
        var brakepads='';var brakeshoes='';var w_canvas='';var w_dataURI='';var w_base64Data='';
        var tyredepthlf=''; var tyredepthrf='';var tyredepthlr=''; var tyredepthrr='';
        
        var headlights_r=component.find('headlights_r').get('v.checked');
        var headlights_y=component.find('headlights_y').get('v.checked');
        var headlights_g=component.find('headlights_g').get('v.checked');
       
        if(headlights_r===true)
             headlights ='REQUIRES IMMEDIATE ATTENTION';
        else if(headlights_y===true)
            headlights='WILL REQUIRE FUTURE ATTENTION';
        else if(headlights_g===true)
            headlights='CHECKED AND OK';
        
         var taillights_r=component.find('taillights_r').get('v.checked');
        var taillights_y=component.find('taillights_y').get('v.checked');
        var taillights_g=component.find('taillights_g').get('v.checked');
        if(taillights_r===true)
            taillights ='REQUIRES IMMEDIATE ATTENTION';
        else if(taillights_y===true)
            taillights='WILL REQUIRE FUTURE ATTENTION';
        else if(taillights_g===true)
            taillights='CHECKED AND OK';
        
        var WiperBlades_r=component.find('WiperBlades_r').get('v.checked');
        var WiperBlades_y=component.find('WiperBlades_y').get('v.checked');
        var WiperBlades_g=component.find('WiperBlades_g').get('v.checked');
          if(WiperBlades_r===true)
            WiperBlades ='REQUIRES IMMEDIATE ATTENTION';
        else if(WiperBlades_y===true)
            WiperBlades='WILL REQUIRE FUTURE ATTENTION';
        else if(WiperBlades_g===true)
            WiperBlades='CHECKED AND OK';
            
            
        var Windshield_r=component.find('Windshield_r').get('v.checked');
        var Windshield_y=component.find('Windshield_y').get('v.checked');
        var Windshield_g=component.find('Windshield_g').get('v.checked');
          if(Windshield_r===true)
             Windshield ='REQUIRES IMMEDIATE ATTENTION';
        else if(Windshield_y===true)
            Windshield='WILL REQUIRE FUTURE ATTENTION';
        else if(Windshield_g===true)
            Windshield='CHECKED AND OK';
        
        lfkpa=component.find('leftfrontkpa').get('v.value');
      tyredepthlf=component.find('tyredepthlf').get('v.value');
      //  console.log(lfkpa);
         var lfTyreTreadDepth_r=component.find('lfTyreTreadDepth_r').get('v.checked');
        var lfTyreTreadDepth_y=component.find('lfTyreTreadDepth_y').get('v.checked');
        var lfTyreTreadDepth_g=component.find('lfTyreTreadDepth_g').get('v.checked');
         if(lfTyreTreadDepth_r===true)
            lfTyreTreadDepth ='REQUIRES IMMEDIATE ATTENTION';
        else if(lfTyreTreadDepth_y===true)
            lfTyreTreadDepth='WILL REQUIRE FUTURE ATTENTION';
        else if(lfTyreTreadDepth_g===true)
            lfTyreTreadDepth='CHECKED AND OK';
        
        var lfBrakeLining_r=component.find('lfBrakeLining_r').get('v.checked');
        var lfBrakeLining_y=component.find('lfBrakeLining_y').get('v.checked');
        var lfBrakeLining_g=component.find('lfBrakeLining_g').get('v.checked');
         if(lfBrakeLining_r===true)
            lfBrakeLining ='REQUIRES IMMEDIATE ATTENTION';
        else if(lfBrakeLining_y===true)
            lfBrakeLining='WILL REQUIRE FUTURE ATTENTION';
        else if(lfBrakeLining_g===true)
            lfBrakeLining='CHECKED AND OK';
        
        
         var horn_r=component.find('horn_r').get('v.checked');
        var horn_y=component.find('horn_y').get('v.checked');
        var horn_g=component.find('horn_g').get('v.checked');
		 if(horn_r===true)
            horn ='REQUIRES IMMEDIATE ATTENTION';
        else if(horn_y===true)
            horn='WILL REQUIRE FUTURE ATTENTION';
        else if(horn_g===true)
            horn='CHECKED AND OK';
        
        
        var Heat_r=component.find('Heat_r').get('v.checked');
        var Heat_y=component.find('Heat_y').get('v.checked');
        var Heat_g=component.find('Heat_g').get('v.checked');
         if(Heat_r===true)
             Heat ='REQUIRES IMMEDIATE ATTENTION';
        else if(Heat_y===true)
            Heat='WILL REQUIRE FUTURE ATTENTION';
        else if(Heat_g===true)
            Heat='CHECKED AND OK';
        
        rfkpa=component.find('rightfrontkpa').get('v.value');
        tyredepthrf=component.find('tyredepthrf').get('v.value');
		var rfTyreTreadDepth_r=component.find('rfTyreTreadDepth_r').get('v.checked');
        var rfTyreTreadDepth_y=component.find('rfTyreTreadDepth_y').get('v.checked');
        var rfTyreTreadDepth_g=component.find('rfTyreTreadDepth_g').get('v.checked');
         if(rfTyreTreadDepth_r===true)
             rfTyreTreadDepth ='REQUIRES IMMEDIATE ATTENTION';
        else if(rfTyreTreadDepth_y===true)
            rfTyreTreadDepth='WILL REQUIRE FUTURE ATTENTION';
        else if(rfTyreTreadDepth_g===true)
            rfTyreTreadDepth='CHECKED AND OK';    
        
     var rfBrakeLining_r=component.find('rfBrakeLining_r').get('v.checked');
        var rfBrakeLining_y=component.find('rfBrakeLining_y').get('v.checked');
        var rfBrakeLining_g=component.find('rfBrakeLining_g').get('v.checked');
         if(rfBrakeLining_r===true)
            rfBrakeLining ='REQUIRES IMMEDIATE ATTENTION';
        else if(rfBrakeLining_y===true)
            rfBrakeLining='WILL REQUIRE FUTURE ATTENTION';
        else if(rfBrakeLining_g===true)
            rfBrakeLining='CHECKED AND OK';
        
      lrkpa=component.find('leftrearkpa').get('v.value');
        tyredepthlr=component.find('tyredepthlr').get('v.value');
      var lrTyreTreadDepth_r=component.find('lrTyreTreadDepth_r').get('v.checked');
       var lrTyreTreadDepth_y=component.find('lrTyreTreadDepth_y').get('v.checked');
      var lrTyreTreadDepth_g=component.find('lrTyreTreadDepth_g').get('v.checked');
         if(lrTyreTreadDepth_r===true)
            lrTyreTreadDepth ='REQUIRES IMMEDIATE ATTENTION';
        else if(lrTyreTreadDepth_y===true)
            lrTyreTreadDepth='WILL REQUIRE FUTURE ATTENTION';
        else if(lrTyreTreadDepth_g===true)
            lrTyreTreadDepth='CHECKED AND OK';
        
        var lrBrakeLining_r=component.find('lrBrakeLining_r').get('v.checked');
        var lrBrakeLining_y=component.find('lrBrakeLining_y').get('v.checked');
        var lrBrakeLining_g=component.find('lrBrakeLining_g').get('v.checked');
         if(lrBrakeLining_r===true)
            lrBrakeLining ='REQUIRES IMMEDIATE ATTENTION';
        else if(lrBrakeLining_y===true)
            lrBrakeLining='WILL REQUIRE FUTURE ATTENTION';
        else if(lrBrakeLining_g===true)
            lrBrakeLining='CHECKED AND OK';
        
         rrkpa=component.find('rightrearkpa').get('v.value');
        tyredepthrr=component.find('tyredepthrr').get('v.value');
        var rrTyreTreadDepth_r=component.find('rrTyreTreadDepth_r').get('v.checked');
        var rrTyreTreadDepth_y=component.find('rrTyreTreadDepth_y').get('v.checked');
        var rrTyreTreadDepth_g=component.find('rrTyreTreadDepth_g').get('v.checked');
         if(rrTyreTreadDepth_r===true)
            rrTyreTreadDepth ='REQUIRES IMMEDIATE ATTENTION';
        else if(rrTyreTreadDepth_y===true)
            rrTyreTreadDepth='WILL REQUIRE FUTURE ATTENTION';
        else if(rrTyreTreadDepth_g===true)
            rrTyreTreadDepth='CHECKED AND OK';
        
        var rrBrakeLining_r=component.find('rrBrakeLining_r').get('v.checked');
        var rrBrakeLining_y=component.find('rrBrakeLining_y').get('v.checked');
        var rrBrakeLining_g=component.find('rrBrakeLining_g').get('v.checked');
         if(rrBrakeLining_r===true)
            rrBrakeLining ='REQUIRES IMMEDIATE ATTENTION';
        else if(rrBrakeLining_y===true)
            rrBrakeLining='WILL REQUIRE FUTURE ATTENTION';
        else if(rrBrakeLining_g===true)
            rrBrakeLining='CHECKED AND OK';
        
        var battery_r=component.find('battery_r').get('v.checked');
        var battery_y=component.find('battery_y').get('v.checked');
        var battery_g=component.find('battery_g').get('v.checked');
         if(battery_r===true)
            battery ='REQUIRES IMMEDIATE ATTENTION';
        else if(battery_y===true)
            battery='WILL REQUIRE FUTURE ATTENTION';
        else if(battery_g===true)
            battery='CHECKED AND OK';
        
         var cooling_r=component.find('cooling_r').get('v.checked');
        var cooling_y=component.find('cooling_y').get('v.checked');
        var cooling_g=component.find('cooling_g').get('v.checked');
         if(cooling_r===true)
            cooling ='REQUIRES IMMEDIATE ATTENTION';
        else if(cooling_y===true)
            cooling='WILL REQUIRE FUTURE ATTENTION';
        else if(cooling_g===true)
            cooling='CHECKED AND OK';
        
       var radiator_r=component.find('radiator_r').get('v.checked');
        var radiator_y=component.find('radiator_y').get('v.checked');
        var radiator_g=component.find('radiator_g').get('v.checked');
         if(radiator_r===true)
            radiator ='REQUIRES IMMEDIATE ATTENTION';
        else if(radiator_y===true)
            radiator='WILL REQUIRE FUTURE ATTENTION';
        else if(radiator_g===true)
            radiator='CHECKED AND OK';
        
         var driveBelts_r=component.find('driveBelts_r').get('v.checked');
        var driveBelts_y=component.find('driveBelts_y').get('v.checked');
        var driveBelts_g=component.find('driveBelts_g').get('v.checked');
         if(driveBelts_r===true)
            driveBelts ='REQUIRES IMMEDIATE ATTENTION';
        else if(driveBelts_y===true)
            driveBelts='WILL REQUIRE FUTURE ATTENTION';
        else if(driveBelts_g===true)
            driveBelts='CHECKED AND OK';
         sparekpa=component.find('sparekpa').get('v.value');
       // console.log(spacekpa);
        uneven= component.find("UnevenTyreWear").get("v.value");
        //console.log('uneven',uneven);
      if(uneven!='NO') recommend= component.find("recommend").get("v.value");
       // console.log(recommend);
        icare= component.find("icare").get("v.value");
        //console.log('icare',icare);

    if(icare.includes('Customer Radio Station')) cust_radio=component.find('cust_radio').get('v.value');
       brakeheader=component.get("v.brakemeasure");
        //console.log(cust_radio);
        console.log('brakeheader',brakeheader);
        if(brakeheader===false){
     	
        brakepads=component.find('brakepads').get('v.value');
        brakeshoes=component.find('brakeshoes').get('v.value');
        
        }
        w_canvas = component.find('w_padd').getElements()[0];
		w_dataURI = w_canvas.toDataURL.apply(w_canvas);
		w_base64Data = w_dataURI.replace(/^data:image\/(png|jpg);base64,/, '');   
        
    var legaltext=component.find('legal-text').get('v.value');
    var GDPRtext=component.find('GDPR-text').get('v.value');
     var ServicebookingId= component.get("v.ServiceBookingrecordId" );        
       
 var compdata ={
            headlights:headlights,
            taillights:taillights,
            WiperBlades:WiperBlades,
            Windshield:Windshield,
            lfkpa:lfkpa,
    		tyredepthlf:tyredepthlf,
            lfTyreTreadDepth:lfTyreTreadDepth,
            lfBrakeLining:lfBrakeLining,
            horn:horn,
            Heat:Heat,
            rfkpa:rfkpa,
     		tyredepthrf:tyredepthrf,
            rfTyreTreadDepth:rfTyreTreadDepth,
            rfBrakeLining:rfBrakeLining,
            lrkpa:lrkpa,
     		tyredepthlr:tyredepthlr,
            lrTyreTreadDepth:lrTyreTreadDepth,
            lrBrakeLining:lrBrakeLining,
            rrkpa:rrkpa,
     		tyredepthrr:tyredepthrr,
            rrTyreTreadDepth:rrTyreTreadDepth,
            rrBrakeLining:rrBrakeLining,
            battery:battery,
            cooling:cooling,
            radiator:radiator,
            driveBelts:driveBelts,
            sparekpa:sparekpa,
            uneven:uneven,
            recommend:recommend,
            icare:icare,
            cust_radio:cust_radio,
            brakeheader:brakeheader, 
            brakepads:brakepads,
            brakeshoes:brakeshoes,
            w_base64Data:w_base64Data,
     		legaltext:legaltext,
     		GDPRtext:GDPRtext,
     		ServicebookingId:ServicebookingId
    		
        };
        
         
        
    var action = component.get("c.savedata");
    
       
    		action.setParams(
            {
                "compdata":compdata,
               
            });
        action.setCallback(this, function(actionresult) {
     var state = actionresult.getState();
            console.log('state ::', state);
            if (state === "SUCCESS") {
                var vehicleInsId= actionresult.getReturnValue(); 
        			var navService = component.find("navService");
					 var pageReference = {
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: vehicleInsId, // this is what you will need
                                actionName: 'view',
                                objectApiName: 'Vehicle_Inspection_Report__c' // the object's api name
                            }
                        };
                        
                        navService.navigate(pageReference);
            }
        });
        $A.enqueueAction(action);         
          
    }
})