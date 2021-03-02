/*
Author: Neha Aggrawal
Created Date: 28-01-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1257
*/
public without sharing class AS_CreateVehicleInspectionReport {
     @AuraEnabled
    public static String getcount(String ServiceBookingrecordId){
       String query = 'SELECT count(Id) from StatusConfirmation__c where Repair__c=: ServiceBookingrecordId'; 
		List<AggregateResult> results = database.query(query);
        System.debug(results[0].get('expr0'));
       if(results[0].get('expr0')==0)
           return 'error';
        else
        return 'Noerror';
       
    }

    @AuraEnabled
    public static Map<String,String> getdata(String ServiceBookingrecordId){
        Map<String,String> repairdata=new Map<String,String>();
        String imgsrc='';
        
        
        StatusConfirmation__c vcr=[Select Id, OutsideCheckId__c from StatusConfirmation__c where Repair__c=: ServiceBookingrecordId limit 1];
        Repair__c rpr=[Select Id, Department__r.LegalCompanyDataPackage__c,Department__r.Name, Department__r.Address__c,Department__r.Legal_texts__c,Department__r.GDPRLegal__c, Vehicle__r.Account.Name,
                       Vehicle__r.Account.PersonMobilePhone, Vehicle__r.Account.PersonHomePhone, Vehicle__r.Account.PersonEmail,
                      Vehicle__r.Vehicle_Model_LTM__r.Model__c,Vehicle__r.Vehicle_Model_LTM__r.Engine_Capacity__c,
                       Vehicle__r.Model_Year__c,
                        Vehicle__r.Vehicle_Model_LTM__r.Fuel_Type__c,Vehicle__r.Color__c,
                         Vehicle__r.Latest_Mileage__c, Vehicle__r.Licence_plate_after_registration__c, Vehicle__r.VIN__c from Repair__c where Id=:ServiceBookingrecordId];
        
       repairdata.put('DepartmentLegalPackage',rpr.Department__r.LegalCompanyDataPackage__c);
       	repairdata.put('DepartmentName',rpr.Department__r.Name);
        repairdata.put('DepartmentAddress',rpr.Department__r.Address__c);
        repairdata.put('CustomerName',rpr.Vehicle__r.Account.Name);
        repairdata.put('CustomerMobilePhone',rpr.Vehicle__r.Account.PersonMobilePhone);
        repairdata.put('CustomerHomePhone',rpr.Vehicle__r.Account.PersonHomePhone);
        repairdata.put('CustomerEmail',rpr.Vehicle__r.Account.PersonEmail);
        repairdata.put('Model',rpr.Vehicle__r.Vehicle_Model_LTM__r.Model__c);
        repairdata.put('EngineCapacity',rpr.Vehicle__r.Vehicle_Model_LTM__r.Engine_Capacity__c);
        repairdata.put('ModelYear',rpr.Vehicle__r.Model_Year__c);
        repairdata.put('FuelType',rpr.Vehicle__r.Vehicle_Model_LTM__r.Fuel_Type__c);
        repairdata.put('Color',rpr.Vehicle__r.Color__c);
        if(rpr.Vehicle__r.Latest_Mileage__c!=null)
        repairdata.put('LatestMileage',rpr.Vehicle__r.Latest_Mileage__c.format());
        repairdata.put('PlateRegistration',rpr.Vehicle__r.Licence_plate_after_registration__c);
        repairdata.put('VIN',rpr.Vehicle__r.VIN__c);
        repairdata.put('OutsideCheck',vcr.OutsideCheckId__c);
        if(vcr.OutsideCheckId__c!=''){
        imgsrc='/servlet/servlet.FileDownload?file=' + vcr.OutsideCheckId__c + '&operationContext=S1';
        repairdata.put('OutsideCheckimgsrc', imgsrc);
        }
        repairdata.put('Legaltext',rpr.Department__r.Legal_texts__c);
        repairdata.put('GDPRtext',rpr.Department__r.GDPRLegal__c);
        return repairdata;
        
    }
     @AuraEnabled
    public static String savedata(Map<String,Object> compdata){
 		system.debug(JSON.serializePretty(compdata));
        StatusConfirmation__c vcr=[Select Id from StatusConfirmation__c where Repair__c=: (String)compdata.get('ServicebookingId') limit 1];
       Vehicle_Inspection_Report__c vir=new Vehicle_Inspection_Report__c();
       vir.Vehicle_Condition_Report__c=vcr.Id;
        vir.Service_Booking__c=(String)compdata.get('ServicebookingId');
        vir.Legal_Text_DPA__c=(String)compdata.get('legaltext');
        vir.Legal_Text_Terms_Conditions__c=(String)compdata.get('GDPRtext');
        vir.Head_Lights_Fog_Lights_Turn_Signals__c=(String)compdata.get('headlights');
        vir.Tail_Brake_Licence_Plate_Lights__c=(String)compdata.get('taillights');
         vir.Wiper_Blades__c=(String)compdata.get('WiperBlades');
         vir.Windshield__c=(String)compdata.get('Windshield');
        if(compdata.get('lfkpa')!='')
         vir.kPa_Left_Front__c=Double.valueOf(compdata.get('lfkpa'));
        if(compdata.get('tyredepthlf')!='')
         vir.Tyre_Tread_Depth_mm_Left_Front__c=Double.valueOf(compdata.get('tyredepthlf'));
         vir.Tyre_Tread_Depth_Left_Front__c=(String)compdata.get('lfTyreTreadDepth');
         vir.Brake_Lining_Left_Front__c=(String)compdata.get('lfBrakeLining');
         vir.Horn_Interior_Lights__c=(String)compdata.get('horn');
         vir.Heating_AC__c=(String)compdata.get('Heat');
        if(compdata.get('rfkpa')!='')
         vir.kPa_Right_Front__c=Double.valueOf(compdata.get('rfkpa'));
        if(compdata.get('tyredepthrf')!='')
         vir.Tyre_Tread_Depth_mm_Right_Front__c=Double.valueOf(compdata.get('tyredepthrf'));
         vir.Tyre_Tread_Depth_Right_Front__c=(String)compdata.get('rfTyreTreadDepth');
         vir.Brake_Lining_Right_Front__c=(String)compdata.get('rfBrakeLining');
         if(compdata.get('lrkpa')!='')
         vir.kPa_Left_Rear__c=Double.valueOf(compdata.get('lrkpa'));
          if(compdata.get('tyredepthlr')!='')
         vir.Tyre_Tread_Depth_mm_LeftRear__c=Double.valueOf(compdata.get('tyredepthlr'));
         vir.Tyre_Tread_Depth_Left_Rear__c=(String)compdata.get('lrTyreTreadDepth');
         vir.Brake_Lining_Left_Rear__c=(String)compdata.get('lrBrakeLining');
         if(compdata.get('rrkpa')!='')
         vir.kPa_Right_Rear__c=Double.valueOf(compdata.get('rrkpa'));
        if(compdata.get('tyredepthrr')!='')
         vir.Tyre_Tread_Depth_mm_Right_Rear__c=Double.valueOf(compdata.get('tyredepthrr'));
         vir.Tyre_Tread_Depth_Right_Rear__c=(String)compdata.get('rrTyreTreadDepth');
        
        vir.Brake_Lining_Right_Rear__c=(String)compdata.get('rrBrakeLining');
         vir.Battery_Performance__c=(String)compdata.get('battery');
         vir.Cooling_System__c=(String)compdata.get('cooling');
         vir.Radiator_Heater_AC_hoses__c=(String)compdata.get('radiator');
         vir.Drive_Belts__c=(String)compdata.get('driveBelts');
         if(compdata.get('sparekpa')!='')
         vir.kPa_Spare__c=Double.valueOf(compdata.get('sparekpa'));
        if(compdata.get('uneven')=='Yes')
         vir.Uneven_Tyre_Wear__c=true;
		List<String> reclist=new List<String>();
        for(Object o:(List<object>)compdata.get('recommend'))
        {
         reclist.add((String)o);    
        }
        System.debug((List<object>)compdata.get('icare'));
		
         vir.Tyre_Wear__c=String.join(reclist,';');
        
        List<String> icarelist=new List<String>();
        for(Object o:(List<object>)compdata.get('icare'))
        {
         icarelist.add((String)o);    
        }
        System.debug(icarelist);
		
        vir.iCare__c=String.join(icarelist,';');
         vir.Customer_s_Radio_Station__c=(String)compdata.get('cust_radio');
        if(compdata.get('brakeheader')==true)
         vir.Brakemeasurementsnotakenthisservicevisit__c=true;
        System.debug(compdata.get('tyres'));
        
         if(compdata.get('brakepads')!='')
          vir.Brake_Pads_Measurement__c=Double.valueOf(compdata.get('brakepads'));
        if(compdata.get('brakeshoes')!='')
         vir.Brake_Shoes_Measurement__c=Double.valueOf(compdata.get('brakeshoes'));
        
		insert vir;
        String base64data=(String)compdata.get('w_base64Data');
        
         Datetime d          = Datetime.now();
            String s            = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');
			//Save signature as attachment
            Attachment attach = new Attachment();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = 'Sign_' + s + '.png';
            attach.IsPrivate = false;
            attach.ParentId = vir.Id;
            insert attach;
        
        vir.WorkshopSignatureId__c=attach.Id;
        update vir;
        return vir.Id;
        
    }

}