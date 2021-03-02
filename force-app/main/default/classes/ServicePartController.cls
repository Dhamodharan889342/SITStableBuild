/****************************************************************************************
* @author          Lee Donghu
* @date            2019-07-30
*
LMS 21/12/2020  GD-1014
Migrated from the chinese sandbox

* @group           Service
* @group-content   Service 
*
* @description     ServicePartController
****************************************************************************************/


public with sharing class ServicePartController extends ServiceQuoteBase {

    @AuraEnabled
    public static Map<String, Object> doGetPartList(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        Boolean disabledApply = false;
        RepairQuote__c rq = [SELECT Id, Status__c FROM RepairQuote__c WHERE Id = :recordId];
        if (RepairQuoteUtil.isRepairQuoteClosed(rq.Status__c)) disabledApply = true;

        List<Repair_Quote_Line_Item__c> l = [
                SELECT
                //LaborCode__c,
                        fm_Amount__c,
                        Tax__c,
                        fm_TotalAmount__c,
                        Hours__c,
                        Id,
                        LineItemType__c,
                        ListPrice__c,
                        Name,
                        Quantity__c,
                        RepairQuote__c,
                        Labor__c,
                        Part__c,
                        //fm_LaborCode__c,              // TODO: GD-1014  Not existant in Genesis Europe
                        // fm_LaborName__c,             // TODO: GD-1014  Not existant in Genesis Europe
                        // fm_PartCode__c,              // TODO: GD-1014  Not existant in Genesis Europe
                        // fm_PartName__c,              // TODO: GD-1014  Not existant in Genesis Europe
                        // IssueType__c,                // TODO: GD-1014  Not existant in Genesis Europe
                        // ClaimType__c,                // TODO: GD-1014  Not existant in Genesis Europe
                        Discount__c
                FROM Repair_Quote_Line_Item__c
                WHERE LineItemType__c = 'Part'
                AND RepairQuote__c = :recordId
                // ORDER BY fm_PartCode__c      // TODO: GD-1014  Not existant in Genesis Europe
        ];

        List<WrapperLineItem> partList = new List<WrapperLineItem>();

        for (Repair_Quote_Line_Item__c rqli : l) {
            WrapperLineItem wp = new WrapperLineItem();

            wp.id = rqli.Id;
            //wp.partName = rqli.fm_PartName__c;                            // TODO: GD-1014  Not existant in Genesis Europe
            //wp.partCode = rqli.fm_PartCode__c;                            // TODO: GD-1014  Not existant in Genesis Europe
            wp.tax = rqli.Tax__c; // 이건 어떻게 처리할 지 아직 모름.
            wp.amount = rqli.fm_Amount__c;
            wp.totalAmount = rqli.fm_TotalAmount__c;
            wp.discount = rqli.Discount__c;
            wp.listPrice = rqli.ListPrice__c;
            wp.quantity = rqli.Quantity__c;
            //wp.issueType = rqli.IssueType__c;                             // TODO: GD-1014  Not existant in Genesis Europe
            //wp.claimType = rqli.ClaimType__c;                             // TODO: GD-1014  Not existant in Genesis Europe
            //if (RepairQuoteUtil.isClaimClosed(rqli.ClaimType__c)) wp.isFlag = true;   // TODO: GD-1014  Not existant in Genesis Europe
            if (RepairQuoteUtil.isRepairQuoteClosed(rq.Status__c)) wp.isFlag = true;

            //wp.laborCode = rqli.LaborCode__c;

            partList.add(wp);
        }
        Map<String, Object> rmap = new Map<String, Object>();
        rmap.put('partList', partList);
        rmap.put('disabledApply', disabledApply);

        return rmap;
    }

    
    // TODO: GD-1014  Not existant in Genesis Europe
    //       there is no object CodeDetail__c
    /*
    @AuraEnabled
    public static List<CodeDetail__c> getModelList() {
        List<CodeDetail__c> modelList = [
                select  Name,
                        IsActive__c,
                        SortOrder__c,
                        Label__c,
                        LabelKR__c,
                        LabelCN__c,
                        LabelEN__c
                from CodeDetail__c
                where CodeMaster__r.Name = 'DAOS.CarModel'
                order by CodeMaster__r.Code__c, CodeMaster__r.Name, SortOrder__c, Name
        ];

        return modelList;
    }
    */
    /**   GD-1014 LMS 21/12/2020 copied from the Chinese Sandbox (util class)
     * getUser
     * User 의 정보를 반환한다.
     * e.g.) Util.getUserInfo() -->
     **/
    public static User getUserInfo() {
        User userSession;
        userSession = [
                SELECT Id
                        , Name
                        //, CountryName__c  //i2max이관시 에러
                        //, CountryCd__c
                        //, Headquarter__c  //i2max이관시 에러
                        //, Subsidiary__c       //i2max이관시 에러
                        //, Region__c //i2max이관시 에러
                        //, Department__c
                        //, DepartmentName__c
                        , ProfileId
                        , Profile.Name
                        //, Language__c     //i2max이관시 에러
                        // , DepartmentLocale__c    // TODO: GD-1014 Not existant in Genesis Europe
                        , EmployeeNumber
                        , ContactId
                        , Country       // LMS 21/12/2020 Seems to be place to get the locale of the user
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
        return userSession;
    }
    // LMS 21/12/2020
    //     Copied from the chinese sandbox
    public static String getUserDepartmentLocale() {
        
        return getUserInfo().Country;   
        
        //return getUserInfo().DepartmentLocale__c;
    }

    /**
     * LMS: GD-1014
     * 
     *    Redo the part search based in a simpler criteria
     *    similar to labor search
     */ 
    @AuraEnabled
    public static List<WrapperLineItem> doSearchPart(Map<String, Object> pmap) {

        String recordId = (String) pmap.get('recordId');
        String opPartNo = (String) pmap.get('opPartNo');
        String opDesc = (String) pmap.get('opDesc');
        // String model = (String) pmap.get('model');      // Product Applied model

        String opCode = opPartNo + '%';
        opDesc = '%' + opDesc + '%';

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,Product__r.VehicleModelLabor__c,
                        PriceBook__c 
                        // TODO: not existant in Genesis Sandbox
                        //PriceBook__r.Name,Repair__r.ServiceCenter__r.HourlyLaborPrice__c,
                        // Repair__r.ServiceCenter__r.Language__c
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];
        System.debug('ServicePartController.doSearchPart RepairQuote__C');
        System.debug(rq);

                // LMS 31/12/2020  GD-1014
        //
        //   This query will go straigth into 
        //   the pricebook entries and  get all the relevant information
        //   for the "add labor" screen
        //
        //  	Labor Code +	Labor Name +	*Hours +	Quantity +	*Amount
        //       
        List<PricebookEntry> prodSearchList = [
            SELECT 
                id, name,   // not used
                UnitPrice, // altered UnitPrice__c--> UnitPrice Mayank, 10/2/2021 - GD-2168
                Product2.LineItemType__c,

                // Product2.Product_Type__c, 
                Product2.name, 
                Product2.id,
                Product2.ProductCode ,
                Product2.Quantity__c, 
                // Product2.Hours__c,               
                Product2.UnitPriceVAT__c,  
                Pricebook2Id,

                Product2Id
            FROM 
                 PricebookEntry 
            WHERE             
                (Product2.LineItemType__c='Part'  // LMS: Mayank request 28/1/2021
                or  Product2.LineItemType__c='Additional Services')                 
                AND (Product2.ProductCode LIKE :opCode or Product2.LineItemType__c='Additional Services')
                AND Product2.Name LIKE :opDesc
                // LMS Have to make the check--> just in case the security
                //      settings fail
                AND (Pricebook2.id=:rq.PriceBook__c)  
        ];

        System.debug('ServicePartController.doSearchPart Queried Items prodSearchList:');
        System.debug(prodSearchList);

        List<WrapperLineItem> partList = new List<WrapperLineItem>();
        //  LMS 31/12/2020 
        //      There are no repair labor object
        //      so we'll use the pricebook entries to generate the 
        //      possible labor items to add to the repair quote
        
        Integer subletPartNumber=1;
        for (PricebookEntry  product : prodSearchList) {

            WrapperLineItem wl = new WrapperLineItem();
            
            // LMS 31/12/2020 GD-1014
            //
            // In case the Request Quote has a specific priceBook
            // then the pricebookentry to list has to belong to 
            // the same pricebook
            if (rq.PriceBook__c!=null) {
                if (product.Pricebook2Id!=rq.PriceBook__c) {
                    continue;
                }

            }
            
            wl.id = product.Product2Id;  // TODO: verify if this is the one
            wl.vehicleId = rq.Repair__r.Vehicle__c; // The labor

            wl.partName = product.Name;    // the name of the pricebook entry
            
            wl.partCode = product.Product2.ProductCode;                //part Code
            wl.productId = product.Product2Id; // Part or Sublet

            if (product.Product2.LineItemType__c!='Part') {
                wl.LineItemType='Sublet';
                wl.partName= '(SUBLET): ' + product.Name;
                if (product.Product2.ProductCode==null) {
                    wl.partCode ='S-'+String.valueOf(subletPartNumber);
                    subletPartNumber++;
                }
            } else {
                wl.LineItemType='Part';
            }

            
            // GD-1014 
            //     We're adding the tax 
            wl.tax=product.Product2.UnitPriceVAT__c;
            if (wl.tax==null){
                wl.tax=0;  // defensive value against bad test data
            }
            // wl.amount=product.UnitPrice__c;
            // altered UnitPrice__c--> UnitPrice Mayank, 10/2/2021 - GD-2168
            wl.listPrice = product.UnitPrice; 
            wl.taxCode = '-';
            wl.quantityOnHand = -1;  // TODO: Where to get the stock in a department ??
            
            wl.amount=50;
            partList.add(wl);
        }

        System.debug('ServicePartController.doSearchPart Final List');
        System.debug(partList);

        return partList;
    }
  
    // 추가 김성일
    @AuraEnabled
    public static Map<String, Object> doSave(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,Product__c,Product__r.VehicleModelPart__c,Product__r.VehicleModelLabor__c,
                        PriceBook__c, PriceBook__r.Name
                        // Repair__r.ServiceCenter__r.Language__c   // TODO: GD-1014  Not existant in Genesis Europe
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];

        //Selected Part List
        if (pmap.get('selectedPartList') != null) {
            List<WrapperLineItem> selectedPartList = (List<WrapperLineItem>) JSON.deserialize((String) pmap.get('selectedPartList'), List<WrapperLineItem>.Class);

            List<Repair_Quote_Line_Item__c> rqliList = new List<Repair_Quote_Line_Item__c>();

            for (WrapperLineItem wp : selectedPartList) {
                Repair_Quote_Line_Item__c rqli = new Repair_Quote_Line_Item__c();

                rqli.RepairQuote__c = recordId;
                // rqli.Product__c = rq.Product__c;      // TODO: GD-1014  Not existant in Genesis Europe
//                rqli.StartDate__c = wp.effectFromDate;
//                rqli.EndDate__c = wp.effectToDate;
                rqli.LineItemType__c = 'Part';
                rqli.ListPrice__c = wp.listPrice;
                rqli.Quantity__c = wp.quantity;
                rqli.CurrencyIsoCode = rq.CurrencyIsoCode;
                rqli.LineItemType__c = 'Part'; // 중요 -> Trigger 작동 기준.

                rqli.Part__c = wp.productId;

                rqliList.add(rqli);
            }

            if (rqliList.isEmpty() == false) insert rqliList;
        }

        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('result', 'ok');
        rmap.put('id', recordId);

        return rmap;
    }

    @AuraEnabled
    public static Map<String, Object> doDelete(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        String rqliId = (String) pmap.get('repairQuoteLineItemId');

        Repair_Quote_Line_Item__c rqli = [
                SELECT Id, RepairQuote__c, 
                        //fm_LaborCode__c,       // TODO: GD-1014  Not existant in Genesis Europe
                         LineItemType__c, 
                         // ClaimType__c,        // TODO: GD-1014  Not existant in Genesis Europe
                          RepairQuote__r.Vehicle__c
                FROM Repair_Quote_Line_Item__c
                WHERE Id = :rqliId
        ];

        //Line Item Type이 Customer Field 이면 연관된 데이터 삭제
         // TODO: GD-1014  Not existant in Genesis Europe
         //                 logic does not make sense
         /*
        if (rqli.ClaimType__c == 'C') {
            List<Repair_Quote_Line_Item__c> delList = 
                [SELECT 
                    Id, RepairQuote__c
                    //ClaimType__c   // TODO: GD-1014  Not existant in Genesis Europe
                    FROM Repair_Quote_Line_Item__c WHERE RepairQuote__c = :rqli.RepairQuote__c 
                    //AND ClaimType__c = 'C'     // TODO: GD-1014  Not existant in Genesis Europe
                    ];
            if (Util.isNotEmpty(delList)) delete delList;
            List<VehicleCustomerField__c> customerFieldList = [
                    SELECT
                            Id,
                            Status__c,
                            RelatedRepairQuote__c
                    FROM VehicleCustomerField__c
                    WHERE Vehicle__c = :rqli.RepairQuote__r.Vehicle__c
                    AND Status__c != 'Used'
            ];
            for (VehicleCustomerField__c vr : customerFieldList) {
                vr.Status__c = 'Registered';
                vr.RelatedRepairQuote__c = null;
            }
            update customerFieldList;


        } else {
            delete [
                    SELECT Id
                    FROM Repair_Quote_Line_Item__c
                    WHERE Id = :rqliId
            ];
        }
        */
        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('result', 'ok');
        rmap.put('id', recordId);

        return rmap;
    }

    /* GD-1014

        Not needed in Genesis Europe

    @AuraEnabled
    public static Map<String, Object> doSavePart(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        String partList = (String) pmap.get('partList');

        if (String.isEmpty(partList)) {
            Map<String, Object> rmap = new Map<String, Object>();

            rmap.put('result', 'fail');
            rmap.put('message', 'List is empty.');
            rmap.put('id', recordId);

            return rmap;
        }

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,
                        PriceBook__c, PriceBook__r.Name
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];

        List<WrapperLineItem> selectedPartList = (List<WrapperLineItem>) JSON.deserialize(partList, List<WrapperLineItem>.Class);
        List<Service_Discount__c> serviceDiscountList = [
                SELECT Id,
                        Amount__c,
                        // Title__c,            // TODO: GD-1014  Not existant in Genesis Europe
                        //ProductCode__c,       // TODO: GD-1014  Not existant in Genesis Europe
                        //DiscountCategory__c,  // TODO: GD-1014  Not existant in Genesis Europe
                        //DiscountType__c,      // TODO: GD-1014  Not existant in Genesis Europe
                        RepairQuote__c
                        //ApplyedVehicleRepairPackageItem__c,                       // TODO: GD-1014  Not existant in Genesis Europe
                        //ApplyedVehicleRepairPackageItem__r.DiscountAmounts__c,    // TODO: GD-1014  Not existant in Genesis Europe
                        //AppliedAssignedCoupon__c,                                 // TODO: GD-1014  Not existant in Genesis Europe
                        //AppliedAssignedCoupon__r.Coupon__r.DiscountAmounts__c,    // TODO: GD-1014  Not existant in Genesis Europe
                        //fm_Rate__c                                                // TODO: GD-1014  Not existant in Genesis Europe
                FROM Service_Discount__c
                WHERE RepairQuote__c = :recordId

        ];
        List<Repair_Quote_Line_Item__c> rqliList = new List<Repair_Quote_Line_Item__c>();

        for (WrapperLineItem wp : selectedPartList) {
            Repair_Quote_Line_Item__c rqli = new Repair_Quote_Line_Item__c(Id = wp.id);

//                rqli.Hours__c = wl.hours;
            //rqli.LaborCode__c = wp.laborCode;
            rqli.Quantity__c = wp.quantity;
            // rqli.IssueType__c = wp.issueType;    // TODO: GD-1014  Not existant in Genesis Europe
            // TODO: GD-1014  Not existant in Genesis Europe
            
            if (rqli.IssueType__c == 'Billable') {
                rqli.ClaimType__c = null;
            } else {
                rqli.ClaimType__c = wp.claimType;
            }
            rqliList.add(rqli);
            

            for (Service_Discount__c serviceDiscount : serviceDiscountList) {
                // TODO: GD-1014  Not existant in Genesis Europe
                
                if (wp.partCode.equals(serviceDiscount.ProductCode__c)) {
                    if ('Rate'.equals(serviceDiscount.DiscountType__c)) {
                        // wp.totalAmount로 계산할 경우 수량을 낮췄을 때(quantity: 2 -> 1) 계산이 정상적으로 안되어 입력한 값으로 계산.
                        serviceDiscount.Amount__c = (wp.listPrice * wp.quantity) * serviceDiscount.fm_Rate__c / 100;
                    } else if ('Price'.equals(serviceDiscount.DiscountType__c)) {
                        if ('Package'.equals(serviceDiscount.DiscountCategory__c)) {
                            serviceDiscount.Amount__c = serviceDiscount.ApplyedVehicleRepairPackageItem__r.DiscountAmounts__c * wp.quantity;
                        } else if ('Coupon'.equals(serviceDiscount.DiscountCategory__c)) {
                            serviceDiscount.Amount__c = serviceDiscount.AppliedAssignedCoupon__r.Coupon__r.DiscountAmounts__c * wp.quantity;
                        }
                    }
                }
                
            }

        }

        if (rqliList.isEmpty() == false) update rqliList;
        if (!serviceDiscountList.isEmpty()) update serviceDiscountList;

        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('result', 'ok');
        rmap.put('id', recordId);

        return rmap;
    } */

}