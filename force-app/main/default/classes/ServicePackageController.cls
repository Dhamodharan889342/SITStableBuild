/****************************************************************************************
* @author          Lee Donghu
* @date            2019-07-30
*
* @group           Service
* @group-content   Service 
*
* @description     ServicePackageController
****************************************************************************************/


public with sharing class ServicePackageController {
    @AuraEnabled
    public static Map<String, Object> doInit(Map<String, Object> pmap) {
        Id recordId = (String) pmap.get('recordId');
        Map<String, Object> rmap = new Map<String, Object>();
        rmap.put('recordId', recordId);
        return rmap;
    }

    @AuraEnabled
    public static List<WrapperPackage> doSearchPackage(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        String packageNo = (String) pmap.get('packageNo');
        String packageName = (String) pmap.get('packageName');
        String laborCode = (String) pmap.get('laborCode');
        String laborName = (String) pmap.get('laborName');
        String partNo = (String) pmap.get('partNo');
        String partName = (String) pmap.get('partName');

        

        packageNo = '%' + packageNo + '%';   // LMS ignored --> not used in Europe
        packageName = '%' + packageName + '%';
        laborCode = '%' + laborCode + '%';
        laborName = '%' + laborName + '%';
        partNo = '%' + partNo + '%';
        partName = '%' + partName + '%';

        // 'ServicePackageController.doSearchPackage  ::',
        System.debug('ServicePackageController.doSearchPackage  recordId::'+recordId);
        System.debug('ServicePackageController.doSearchPackage  packageNo::'+packageNo);
        System.debug('ServicePackageController.doSearchPackage  packageName::'+packageName);
        System.debug('ServicePackageController.doSearchPackage  laborCode::'+laborCode);
        System.debug('ServicePackageController.doSearchPackage  laborName::'+laborName);
        System.debug('ServicePackageController.doSearchPackage  partNo::'+partNo);
        System.debug('ServicePackageController.doSearchPackage  partName::'+partName);

        // , Repair__r.ServiceCenter__r.Language__c 
        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Product__c,
                        Repair__r.Vehicle__r.Product2Id,
                        PriceBook__c, PriceBook__r.Name,
                        PriceBook__r.Country__c   // LMS Got to know the country 
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];

        System.debug('ServicePackageController.doSearchPackage  rq::'+rq);
        System.debug('ServicePackageController.doSearchPackage  rq.PriceBook__r.Country__c::'+rq.PriceBook__r.Country__c);

        /*
SELECT Brand__c, fm_VehicleName__c, Id, IsForAllModel__c, Name, PackageNumber__c, StartDate__c, EndDate__c, VehicleModel__c, VehicleModel__r.ProductCode, VehicleModel__r.Name 
FROM RepairPackage__c 
WHERE (IsActive__c = TRUE AND Name LIKE '%%' AND PackageNumber__c LIKE '%%' 
AND
Id IN 
(SELECT RepairPackage__c 
FROM 
RepairPackageItem__c WHERE 
(Product__r.country__c = 'Germany' 
AND ((LineItemType__c = 'Labor' AND fm_LaborCode__c LIKE '%%' AND fm_LaborName__c LIKE '%%') 
OR (LineItemType__c = 'Part' AND fm_PartCode__c LIKE '%%' AND fm_PartName__c LIKE '%a%')))))

        */

        // Product__r.Locale__c = :Util.getUserDepartmentLocale()  AND // removed
        List<RepairPackage__c> rpList = [
                SELECT
                        Brand__c,
                        fm_VehicleName__c,
                        Id,
                        IsForAllModel__c,
                        Name,
                        PackageNumber__c,
                        StartDate__c,
                        EndDate__c,
                        VehicleModel__c,
                        VehicleModel__r.ProductCode,
                        VehicleModel__r.Name
                FROM RepairPackage__c
                WHERE IsActive__c = true
                   AND Name LIKE :packageName
                // AND PackageNumber__c LIKE :packageNo  // LMS not used in Genesis Europe
                 AND (IsForAllModel__c = True OR VehicleModel__c = :rq.Repair__r.Vehicle__c)
                AND Id IN (
                        SELECT RepairPackage__c
                        FROM RepairPackageItem__c
                        WHERE // Product__r.Locale__c = :Util.getUserDepartmentLocale()  AND
                         // Product__r.country__c=:rq.PriceBook__r.Country__c  AND // LMS only parts/labor from the same country
                    
                        ((
                                LineItemType__c = 'Labor'
                                AND fm_LaborCode__c LIKE :laborCode
                                AND fm_LaborName__c LIKE :laborName
                        ) OR (
                                LineItemType__c = 'Part'
                                AND fm_PartCode__c LIKE :partNo
                                AND fm_PartName__c LIKE :partName
                        ))
                )
        ];

        System.debug('ServicePackageController.doSearchPackage  rpList::'+rpList);

        List<WrapperPackage> packageList = new List<WrapperPackage>();
        Integer PackageNumber=1;
        for (RepairPackage__c rp : rpList) {
            WrapperPackage wp = new WrapperPackage();

            wp.id = rp.id;
            // wp.packageNo = rp.PackageNumber__c;                              //No
            wp.packageNo=String.valueOf(PackageNumber);
            PackageNumber++;

            wp.packageName = rp.Name;                //Labor Code
            wp.brand = rp.Brand__c;
            if (rp.isForAllModel__c) {
                wp.modelCode = 'All Vehicle';
            } else {
                wp.modelCode = rp.VehicleModel__r.Name;
            }
            wp.startDate = rp.StartDate__c;
            wp.endDate = rp.EndDate__c;

            packageList.add(wp);
        }

        return packageList;
    }

    /*
    @AuraEnabled
    public static List<WrapperPackageDetail> doAddPackage(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');// Repair Quote Id
        String packageId = (String) pmap.get('packageId');
        System.debug('packageId :: ' + packageId);

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c,Product__r.VehicleModelPart__c,
                        Product__r.VehicleModelLabor__c,
                        Repair__r.Product__c,
                        Repair__r.Vehicle__r.Name,
                        Repair__r.Vehicle__r.Product2Id,
                        Repair__r.Vehicle__r.Product2.Name,
                        Repair__r.Product__r.VehicleModelLabor__c,
                        Repair__r.Product__r.VehicleModelPart__c
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];

        List<RepairPackageItem__c> rpdList = [
                SELECT
                        fm_ProductCode__c,
                        fm_ProductName__c,
                        Hours__c,
                        Id,
                        LineItemType__c,
                        Name,
                        Product__c,
                        Product__r.ProductCode,
                        Quantity__c,
                        fm_LaborCode__c,
                        RepairPackage__c
                FROM RepairPackageItem__c
                WHERE RepairPackage__c = :packageId
                ORDER BY fm_ProductCode__c
        ];

        Set<String> laborCodeSet = new Set<String>();
        Set<String> partCodeSet = new Set<String>();
        for (RepairPackageItem__c rpItem : rpdList) {
            if (rpItem.LineItemType__c == 'Labor') {
                laborCodeSet.add(rpItem.Product__r.ProductCode);
            } else if (rpItem.LineItemType__c == 'Part') {
                partCodeSet.add(rpItem.Product__r.ProductCode);
            }
        }
        system.debug('laborCodeSet : '+laborCodeSet);
        system.debug('rq.Product__r.VehicleModelLabor__c : '+rq.Product__r.VehicleModelLabor__c);
        system.debug('partCodeSet : '+partCodeSet);
        system.debug('rq.Product__r.VehicleModelPart__c : '+rq.Product__r.VehicleModelPart__c);

        List<RepairLabor__c> rlList = [
                SELECT
                        Id, VehicleModel__c, Labor__c,Labor__r.ProductCode, Hours__c, Quantity__c, VehicleModel__r.name
                FROM RepairLabor__c
                WHERE VehicleModel__c = :rq.Product__r.VehicleModelLabor__c
                AND Labor__r.ProductCode IN:laborCodeSet
        ];
        Map<String, RepairLabor__c> repairLaborMap = new Map<String, RepairLabor__c>();

        // Applicable to the model Labor Add
        for (RepairLabor__c rl : rlList) {
            repairLaborMap.put(rl.Labor__r.ProductCode, rl);
        }

        List<RepairPart__c> rpList = [
                SELECT
                        Id, VehicleModel__c, Part__c,Part__r.ProductCode, Quantity__c, VehicleModel__r.name
                FROM RepairPart__c
                WHERE VehicleModel__c = :rq.Product__r.VehicleModelPart__c
                AND Part__r.ProductCode IN:partCodeSet
        ];
        // Applicable to the model Part Add
        Map<String, RepairPart__c> repairPartMap = new Map<String, RepairPart__c>();
        for (RepairPart__c rp : rpList) {
            repairPartMap.put(rp.Part__r.ProductCode, rp);
        }

        System.debug('rpdList : ' + JSON.serialize(rpdList));
        List<WrapperPackageDetail> packageDetailList = new List<WrapperPackageDetail>();

        for (RepairPackageItem__c rpd : rpdList) {
            WrapperPackageDetail wpd = new WrapperPackageDetail();

            wpd.name = rpd.fm_ProductName__c;
            wpd.code = rpd.fm_ProductCode__c;
            wpd.lineItemType = rpd.LineItemType__c;
            wpd.measuringUnit = 'EA';

            wpd.productId = rq.Repair__r.Product__c; // Labor or Part
            if (rpd.LineItemType__c == 'Labor') {
                RepairLabor__c rl = repairLaborMap.get(rpd.Product__r.ProductCode);
                if (rl == null) continue;

                wpd.hours = rpd.Hours__c;
                wpd.quantity = rpd.Quantity__c;
                wpd.vehicleModelId = rq.Repair__r.Product__r.VehicleModelLabor__c;
                wpd.laborId = rpd.Product__c;
            } else if (rpd.LineItemType__c == 'Part') {
                RepairPart__c rp = repairPartMap.get(rpd.Product__r.ProductCode);
                if (rp == null) continue;

                wpd.quantity = rpd.Quantity__c;
                wpd.vehicleModelId = rq.Repair__r.Product__r.VehicleModelPart__c;
                wpd.partId = rpd.Product__c;
            }

            packageDetailList.add(wpd);
        }
        System.debug('return : ' + packageDetailList);
        return packageDetailList;
    }
    */   
    /**
     * doAddPackage Add a package repair to the list of available items 
     * 
     * @param  pmap pmap description  (recordId and PackageId)
     * @return      return description
     */ 
    @AuraEnabled
    public static List<WrapperPackageDetail> doAddPackage(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');// Repair Quote Id
        String packageId = (String) pmap.get('packageId');
        System.debug('packageId :: ' + packageId);

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,
                        PriceBook__c, PriceBook__r.Name
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];
        
        // all items in the repair package should be added
        List<RepairPackageItem__c> lstRepairPackageItem=[
            select 
                    id,
                    LineItemType__c,
                    Tax__c,
                    Quantity__c,
                    Hours__c,                  
                    UnitPrice__c,    
                    DiscountAmounts__c,     
                    DiscountRates__c,     
                    DiscountType__c,       
                    StartDate__c,     
                    EndDate__c,
                    Product__c,
                    Product__r.name,
                    Product__r.productcode,
                    product__r.Price_Per_Unit__c,
                    Product__r.Hours__c,
                    product__r.Taxrate__c,
                    Product__r.Quantity__c,
                    RepairPackage__r.name,
                    RepairPackage__r.Discount__c,
                    RepairPackage__r.ListPrice__c
                FROM
                    RepairPackageItem__c
                Where
                    RepairPackage__c = :packageId
        ];

        List<WrapperPackageDetail> packageDetailList = new List<WrapperPackageDetail>();

        for (RepairPackageItem__c rpd : lstRepairPackageItem){
            WrapperPackageDetail wpd = new WrapperPackageDetail();

            wpd.name = rpd.Product__r.name;
            wpd.code = rpd.Product__r.productcode;
            wpd.lineItemType = rpd.LineItemType__c;
            wpd.measuringUnit = 'EA';

            wpd.tax=rpd.tax__c;   // the data type is percent ??
            wpd.listPrice=rpd.UnitPrice__c;

            // wpd.productId = rq.Repair__r.Product__c; // Labor or Part
            if (rpd.LineItemType__c == 'Labor') {
                // at least one hour to quote
                wpd.hours = 1;
                if (rpd.Hours__c!=null){
                    wpd.hours = rpd.Hours__c;
                }
                
                wpd.quantity = rpd.Quantity__c;
                // wpd.vehicleModelId = rq.Repair__r.Product__r.VehicleModelLabor__c;
                wpd.laborId = rpd.Product__c;
            } 
            if (rpd.LineItemType__c == 'Part') {
                

                wpd.quantity = rpd.Quantity__c;
                // wpd.vehicleModelId = rq.Repair__r.Product__r.VehicleModelPart__c;
                wpd.partId = rpd.Product__c;
            }
            if (rpd.LineItemType__c == 'Additional Services') {
                wpd.name = 'SUBLET: ' + rpd.Product__r.name;
                // additional services should be treated as "parts"
                wpd.quantity = rpd.Quantity__c;
                // wpd.vehicleModelId = rq.Repair__r.Product__r.VehicleModelPart__c;
                wpd.partId = rpd.Product__c;
            }
            

            packageDetailList.add(wpd);
        }


        return packageDetailList;
    }

    @AuraEnabled
    public static Map<String, Object> doSave(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        // ,Repair__r.ServiceCenter__r.Language__c
        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,
                        PriceBook__c, PriceBook__r.Name
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];
        if (pmap.get('laborList') != null) {
            List<WrapperPackageDetail> laborList = (List<WrapperPackageDetail>) JSON.deserialize((String) pmap.get('laborList'), List<WrapperPackageDetail>.Class);

            System.debug('laborList :: ' + pmap.get('laborList'));

            List<Repair_Quote_Line_Item__c> rqliList = new List<Repair_Quote_Line_Item__c>();

            for (WrapperPackageDetail wl : laborList) {
                Repair_Quote_Line_Item__c rqli = new Repair_Quote_Line_Item__c();

                rqli.RepairQuote__c = recordId;
                rqli.LineItemType__c = 'Labor';
//                rqli.Product__c = wl.productId;// Labor or Part
//                rqli.Hours__c = -1;// null or minus value, Default set from Trigger (RepairQuoteLineItem_tr)
//                rqli.Quantity__c = -1;// null or minus value,  Default set from Trigger (RepairQuoteLineItem_tr)
//                rqli.ListPrice__c = -1;// null or minus value,  Default set from Trigger (RepairQuoteLineItem_tr)
                
                //rqli.Product__c = wl.productId;

                rqli.Labor__c = wl.laborId;

                rqliList.add(rqli);
            }
            System.debug('rqliList : ' + rqliList);
            if (rqliList.isEmpty() == false) insert rqliList;
        }

        //Selected Part List
        if (pmap.get('partList') != null) {
            List<WrapperPackageDetail> partList = (List<WrapperPackageDetail>) JSON.deserialize((String) pmap.get('partList'), List<WrapperPackageDetail>.Class);

            List<Repair_Quote_Line_Item__c> rqliList = new List<Repair_Quote_Line_Item__c>();

            for (WrapperPackageDetail wp : partList) {
                Repair_Quote_Line_Item__c rqli = new Repair_Quote_Line_Item__c();

                rqli.RepairQuote__c = recordId;
                rqli.LineItemType__c = 'Part';
                rqli.QuantityUnitOfMeasure__c = wp.measuringUnit;
//                rqli.Product__c = wp.productId;// Labor or Part
//                rqli.Hours__c = wp.hours;
//                rqli.Quantity__c = -1;// null or minus value,  Default set from Trigger (RepairQuoteLineItem_tr)
//                rqli.ListPrice__c = -1;// null or minus value,  Default set from Trigger (RepairQuoteLineItem_tr)
                // rqli.Product__c = wp.productId;
                rqli.Part__c = wp.partId;
                //rqli.LaborCode__c = wp.laborCode;

                rqliList.add(rqli);
            }
            if (rqliList.isEmpty() == false) insert rqliList;
        }

        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('result', 'ok');
        rmap.put('id', recordId);

        return rmap;
    }


    public class WrapperPackage {
        @AuraEnabled public String id { get; set; } // packageId
        @AuraEnabled public String packageNo { get; set; } // Package Number
        @AuraEnabled public String packageName { get; set; } // Package Name
        @AuraEnabled public String brand { get; set; } // Brand
        @AuraEnabled public String modelCode { get; set; } // Model Code
        @AuraEnabled public Date startDate { get; set; } // Start Date
        @AuraEnabled public Date endDate { get; set; } // End Date
    }

    public class WrapperPackageDetail {
        @AuraEnabled public String code { get; set; } // Code
        @AuraEnabled public String name { get; set; } // Name
        @AuraEnabled public String laborCode { get; set; } // Name
        @AuraEnabled public String repairType { get; set; } // Repair Type
        @AuraEnabled public String measuringUnit { get; set; } // Measuring Unit
        @AuraEnabled public Decimal hours { get; set; } // Model Code
        @AuraEnabled public Decimal quantity { get; set; } // Model Code
        @AuraEnabled public String lineItemType { get; set; } // type
        // GD-1014 need taxes
        @AuraEnabled public Decimal tax { get; set; } // applicable tax
        @AuraEnabled public Decimal listPrice { get; set; } // applicable UnitPrice__c
        

        @AuraEnabled public String productId { get; set; } // Part Id
        @AuraEnabled public String vehicleModelId { get; set; } // Part Id
        @AuraEnabled public String partId { get; set; } // Part Id
        @AuraEnabled public String laborId { get; set; } // Labor Id
    }
}