/****************************************************************************************
* @author          Lee Donghu
* @date            2019-07-30
*
* @group           Service
* @group-content   Service 
*
* @description     ServiceLaborController
****************************************************************************************/


public with sharing class ServiceLaborController extends ServiceQuoteBase {

    /**
     * doGetLaborList description
     * @param  pmap pmap description
     * @return      return description
     */ 
    public static Map<String, Object> doGetLaborList(Map<String, Object> pmap) {
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
                        //fm_LaborCode__c,      // TODO: not existant in Genesis Sandbox
                        //fm_LaborName__c,      // TODO: not existant in Genesis Sandbox
                        //fm_PartCode__c,       // TODO: not existant in Genesis Sandbox    
                        //fm_PartName__c,       // TODO: not existant in Genesis Sandbox
                        // IssueType__c,        // TODO: not existant in Genesis Sandbox
                        // ClaimType__c,        // TODO: not existant in Genesis Sandbox
                        Discount__c
                FROM Repair_Quote_Line_Item__c 
                WHERE LineItemType__c = 'Labor'
                AND RepairQuote__c = :recordId
               //  ORDER BY fm_LaborCode__c   // TODO: not existant in Genesis Sandbox
        ];

        List<WrapperLineItem> laborList = new List<WrapperLineItem>();

        for (Repair_Quote_Line_Item__c rqli : l) {
            WrapperLineItem wl = new WrapperLineItem();

            wl.id = rqli.Id;
            //wl.laborName = rqli.fm_LaborName__c;      // TODO: not existant in Genesis Sandbox
            //wl.laborCode = rqli.fm_LaborCode__c;      // TODO: not existant in Genesis Sandbox
            wl.hours = rqli.Hours__c;
            wl.listPrice = rqli.ListPrice__c;
            wl.taxCode = '-';
            wl.tax = rqli.Tax__c; // 이건 어떻게 처리할 지 아직 모름.
            wl.totalAmount = rqli.fm_TotalAmount__c;
            wl.amount = rqli.fm_Amount__c;
            wl.discount = rqli.Discount__c;
            wl.quantity = rqli.Quantity__c;
            //wl.issueType = rqli.IssueType__c;         // TODO: not existant in Genesis Sandbox
            //wl.claimType = rqli.ClaimType__c;         // TODO: not existant in Genesis Sandbox
            // if (RepairQuoteUtil.isClaimClosed(rqli.ClaimType__c)) wl.isFlag = true;
            if (RepairQuoteUtil.isRepairQuoteClosed(rq.Status__c)) wl.isFlag = true;

            laborList.add(wl);
        }

        Map<String, Object> rmap = new Map<String, Object>();
        rmap.put('laborList', laborList);
        rmap.put('disabledApply', disabledApply);

        return rmap;
    }

    /**
     * doSearchLabor description
     *     LMS 31/12/2020 GD-1014
     *      Search for a labor item that fits a certain code
     *      and/or a descriptions
     * 
     * @param  pmap pmap description
     * @return      return description
     */ 
    @AuraEnabled
    public static List<WrapperLineItem> doSearchLabor(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        String repairType = (String) pmap.get('repairType');  // LMS not used??
        String opCode = (String) pmap.get('opCode');
        String opDesc = (String) pmap.get('opDesc');

        opCode = opCode + '%';
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

        Set<String> prodCodeSet = new Set<String>();
        Set<String> prodIdSet = new Set<String>();
        Map<String, Product2> prodMap = new Map<String, Product2>();

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
                // Product2.Product_Type__c, 
                Product2.name, 
                Product2.id,
                Product2.ProductCode ,
                Product2.Quantity__c, 
                Product2.Hours__c,
                Product2.UnitPriceVAT__c,  
                Pricebook2Id,

                Product2Id
            FROM 
                 PricebookEntry 
            WHERE 
                // Product2.Product_Type__c='Labor' 
                Product2.LineItemType__c='Labor'  // LMS: Mayank request 28/1/2021
                AND Product2.ProductCode LIKE :opCode
                AND Product2.Name LIKE :opDesc
                // LMS Have to make the check--> just in case the security
                //      settings fail
                AND (Pricebook2.id=:rq.PriceBook__c)  
        ];

        // LMS 31-12-2020 GD-1014
        //      Not needed for this search since
        //      there seems to be no association between
        //      labor and vehicle models
        // for (Product2 prod : prodSearchList) {
        //     prodMap.put(prod.ProductCode, prod);
        // }
        System.debug('rq.Product__r.VehicleModelLabor__c => ' +rq.Product__r.VehicleModelLabor__c);
    

        List<WrapperLineItem> laborList = new List<WrapperLineItem>();
        //  LMS 31/12/2020 
        //      There are no repair labor object
        //      so we'll use the pricebook entries to generate the 
        //      possible labor items to add to the repair quote
        
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

            wl.laborName = product.Name;    // the name of the pricebook entry
            wl.laborCode = product.Product2.ProductCode;                //Labor Code
            wl.productId = product.Product2Id; // Labor or Part

            wl.hours = product.Product2.Hours__c;          //Flat Rate
            // some defensive code to avoid errors
            if (wl.hours==null){
                wl.hours=1;  // at least one hour ??
            }
            // GD-1014 
            //     We're adding the tax 
            wl.tax=product.Product2.UnitPriceVAT__c;
            if (wl.tax==null){
                wl.tax=0;  // defensive value against bad test data
            }

            // LMS GD-1014
            //     TODO: query the "custom object for hourly labor rates" 
            //           and find the standard "maintenance hourly rate" for
            //           the department of the repair quote 
            
            // wl.amount = wl.hours * rq.Repair__r.ServiceCenter__r.HourlyLaborPrice__c;    //Total Amount
            

            wl.amount = wl.hours * 50;    //Total Amount TODO:


            laborList.add(wl);
        }
        
        return laborList;
    }

    // 추가 김성일
    @AuraEnabled
    public static Map<String, Object> doSave(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');

        // TODO: not existant in Genesis Sandbox
        // 
        //      LMS GD-1014  the Chinese version used a strategy to update the database
        //                   and then refreshing the screen
        //                   (as agreed with Mayank this strategy is not going to be used
        //                   in the european version )
        //                      
        /*
        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,Product__c,Product__r.VehicleModelPart__c,Product__r.VehicleModelLabor__c,
                        PriceBook__c, PriceBook__r.Name,Repair__r.ServiceCenter__r.Language__c
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];
        if (pmap.get('selectedLaborList') != null) {
            List<WrapperLineItem> selectedLaborList = (List<WrapperLineItem>) JSON.deserialize((String) pmap.get('selectedLaborList'), List<WrapperLineItem>.Class);

            System.debug('selectedLaborList :: ' + pmap.get('selectedLaborList'));

            List<Repair_Quote_Line_Item__c> rqliList = new List<Repair_Quote_Line_Item__c>();

            for (WrapperLineItem wl : selectedLaborList) {
                Repair_Quote_Line_Item__c rqli = new Repair_Quote_Line_Item__c();

                rqli.RepairQuote__c = recordId;

                //repair Labor = > Labor 변경 19.07.26
                rqli.Labor__c = wl.ProductId;
                rqli.Product__c = rq.Product__c;

                rqli.Hours__c = wl.hours;
                rqli.LineItemType__c = 'Labor';
                rqli.ListPrice__c = wl.listPrice;
                rqli.Quantity__c = wl.quantity;
                rqli.CurrencyIsoCode = rq.CurrencyIsoCode;


                rqliList.add(rqli);
            }

            if (rqliList.isEmpty() == false) insert rqliList;
        }
        */
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
                // fm_LaborCode__c,         // TODO: not existant in Genesis Sandbox
                LineItemType__c, 
                //ClaimType__c,             // TODO: not existant in Genesis Sandbox
                RepairQuote__r.Vehicle__c
                FROM Repair_Quote_Line_Item__c
                WHERE Id = :rqliId
        ];

//        if (rqli.LineItemType__c == 'Labor') {
//            // 묶인 Part를 모두 삭제.
//            delete [
//                    SELECT Id FROM Repair_Quote_Line_Item__c WHERE RepairQuote__c = :rqli.RepairQuote__c AND LaborCode__c = :rqli.fm_LaborCode__c
//            ];
//        }

        //Line Item Type이 Customer Field 이면 연관된 데이터 삭제
        // TODO: not existant in Genesis Sandbox
        /*
        if (rqli.ClaimType__c == 'C') {
            List<Repair_Quote_Line_Item__c> delList = [SELECT Id, RepairQuote__c, ClaimType__c FROM Repair_Quote_Line_Item__c WHERE RepairQuote__c = :rqli.RepairQuote__c AND ClaimType__c = 'C'];
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

       not needed  in Genesis Europe

    @AuraEnabled
    public static Map<String, Object> doSaveLabor(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        String laborList = (String) pmap.get('laborList');

        if (String.isEmpty(laborList)) {
            Map<String, Object> rmap = new Map<String, Object>();

            rmap.put('result', 'fail');
            rmap.put('message', 'List is empty.');
            rmap.put('id', recordId);

            return rmap;
        }

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,Product__r.VehicleModelLabor__c,
                        PriceBook__c, PriceBook__r.Name
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];

        List<WrapperLineItem> selectedLaborList = (List<WrapperLineItem>) JSON.deserialize(laborList, List<WrapperLineItem>.Class);
        List<Service_Discount__c> serviceDiscountList = [
                SELECT Id,
                        Amount__c, 
                        // Title__c,                // TODO: not existant in Genesis Sandbox
                        //ProductCode__c,           // TODO: not existant in Genesis Sandbox
                        //DiscountCategory__c,      // TODO: not existant in Genesis Sandbox
                        //DiscountType__c,          // TODO: not existant in Genesis Sandbox
                        RepairQuote__c
                        //ApplyedVehicleRepairPackageItem__c,   // TODO: not existant in Genesis Sandbox
                        //ApplyedVehicleRepairPackageItem__r.DiscountAmounts__c,    // TODO: not existant in Genesis Sandbox
                        //AppliedAssignedCoupon__c,                                 // TODO: not existant in Genesis Sandbox
                        //AppliedAssignedCoupon__r.Coupon__r.DiscountAmounts__c,    // TODO: not existant in Genesis Sandbox
                        // fm_Rate__c
                FROM Service_Discount__c
                WHERE RepairQuote__c = :recordId

        ];
        List<Repair_Quote_Line_Item__c> rqliList = new List<Repair_Quote_Line_Item__c>();
        for (WrapperLineItem wl : selectedLaborList) {
            Repair_Quote_Line_Item__c rqli = new Repair_Quote_Line_Item__c(Id = wl.id);
            rqli.Hours__c = wl.hours;
            rqli.Quantity__c = wl.quantity;
            // rqli.IssueType__c = wl.issueType;        // TODO: not existant in Genesis Sandbox
            // TODO: not existant in Genesis Sandbox
            
            if (rqli.IssueType__c == 'Billable') {
                rqli.ClaimType__c = null;
            } else {
                rqli.ClaimType__c = wl.claimType;
            }
            rqliList.add(rqli);
            
            for (Service_Discount__c serviceDiscount : serviceDiscountList) {
                if (wl.laborCode.equals(serviceDiscount.ProductCode__c)) {
                    serviceDiscount.Amount__c = serviceDiscount.fm_Rate__c * wl.totalAmount / 100;
                }
            }
            
            for (Service_Discount__c serviceDiscount : serviceDiscountList) {
                // TODO: not existant in Genesis Sandbox
                //       logic
                
                if (wl.laborCode.equals(serviceDiscount.ProductCode__c)) {
                    if ('Rate'.equals(serviceDiscount.DiscountType__c)) {
                        // wl.totalAmount로 계산할 경우 수량을 낮췄을 때(quantity: 2 -> 1) 계산이 정상적으로 안되어 입력한 값으로 계산.
                        serviceDiscount.Amount__c = (wl.listPrice * wl.quantity + wl.tax) * serviceDiscount.fm_Rate__c / 100;
                    } else if ('Price'.equals(serviceDiscount.DiscountType__c)) {
                        if ('Package'.equals(serviceDiscount.DiscountCategory__c)) {
                            serviceDiscount.Amount__c = serviceDiscount.ApplyedVehicleRepairPackageItem__r.DiscountAmounts__c * wl.quantity;
                        } else if ('Coupon'.equals(serviceDiscount.DiscountCategory__c)) {
                            serviceDiscount.Amount__c = serviceDiscount.AppliedAssignedCoupon__r.Coupon__r.DiscountAmounts__c * wl.quantity;
                        }
                    }
                }
                
            }
        }
        System.debug('rqliList :: ' + JSON.serialize(rqliList));

        if (rqliList.isEmpty() == false) update rqliList;
        if (!serviceDiscountList.isEmpty()) update serviceDiscountList;

        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('result', 'ok');
        rmap.put('id', recordId);

        return rmap;
    } */

}