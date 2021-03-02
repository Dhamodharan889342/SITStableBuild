/****************************************************************************************
* @author          Lee Donghu
* @date            2019-07-30
*
* @group           Service
* @group-content   Service 
*
* @description     RepairQuoteUtil
****************************************************************************************/


public class RepairQuoteUtil {

    public static Set<String> rqStatusSet = new Set<String>{
            'Draft', 'In Review'
    };
    public static Set<String> claimSet = new Set<String>{
            'C'
    };

    public static Boolean isRepairQuoteClosed(String status) {
        if (rqStatusSet.contains(status)) {
            return false;
        } else {
            return true;
        }

    }
    public static Boolean isClaimClosed(String type) {
        if (claimSet.contains(type)) {
            return true;
        } else {
            return false;
        }
    }
    /**
     * getStandardLaborRate Obtain the standard labor rate for a specific quotation
     *
     * ## repairQuoteId (Id): repairQuoteId
     * ## dtRef (Date): dtRef
     * @@ Return LaborTypeRate__c: Return description
     */
    public static LaborTypeRate__c getStandardLaborRate(Id repairQuoteId, Date dtRef) {

        RepairQuote__c RepairQuoteRec= [select 
                                            id, Repair__c , 
                                            PriceBook__c,
                                            PriceBook__r.Country__c
                                        from
                                            RepairQuote__c where Id=:repairQuoteID ];
        // search for the "maintenance" labor rate
        List<LaborTypeRate__c> lstLaborRate = Util.getLaborRate(RepairQuoteRec.PriceBook__r.Country__c, 
                                                    'Maintenance', Date.today());
                                
        System.debug('===> RepairQuoteUtil.getStandardLaborRate ## list of records for '+RepairQuoteRec.PriceBook__r.Country__c);
        System.debug(lstLaborRate);                                                
        LaborTypeRate__c recLaborType=null;
        if (lstLaborRate!=null){
            recLaborType=lstLaborRate[0];
        }
        return recLaborType;
    }
    /**
     * findSectionIndex Find the position in the list of a repair
     *
     * ## lstRepairQuoteSection (List<Repair_Quote_Section__c>): lstRepairQuoteSection
     * ## strSectionName (String): strSectionName
     * ## strSectionType (String): strSectionType
     * @@ Return Integer: -1 ==> not found, otherwise index position
     */
    public static Integer findSectionIndex(
                                    List<Repair_Quote_Section__c> lstRepairQuoteSection,
                                    String strSectionName, String strSectionType){

        Integer indexList=-1;
                
        // some defensive programming
        String strSectionType2=strSectionType;

        if (strSectionType=='Pack') {
            strSectionType2='Package';
        } 
        if (strSectionType=='User') {
            strSectionType2='User Defined';
        }

        for (Integer ind2=0;ind2<lstRepairQuoteSection.size();ind2++) {
            if ((lstRepairQuoteSection[ind2].name==strSectionName) &&
                 (lstRepairQuoteSection[ind2].SectionType__c==strSectionType2)) {
                    indexList=ind2;
            }                
        }

        return indexList;
    }
    /**
     * getVSPI helper function to get a record  ()
     * @param  vspiId vspiId description
     * @return        return description
     */
    
    public static Vehicle_Service_Package_Item__c getVSPI(Id vspiId) {
        Vehicle_Service_Package_Item__c recVSPI=[
                                select id, name, CreatedDate, CreatedBy.name, 
                                        product__r.name,
                                        Vehicle_Service_Package__r.name, 
                                        Vehicle_Service_Package__r.Vehicle__c, 
                                        Product__c
                                    from 
                                        Vehicle_Service_Package_Item__c 
                                    Where
                                        Id=:vspiId];
                            
        return recVSPI;
    }

/*    @TestVisible
    private static RepairQuoteLineItem__c findItem(Map<String, RepairQuoteLineItem__c> lineItemMap, String key, Integer keyIndex) {
        Set<String> keySet = lineItemMap.keySet();
        System.debug('findItem keySet : ' + keySet + ', keyIndex : ' + keyIndex);
        for (String strKey : keySet) {
            String[] a = strKey.split('_');

            String b = a[keyIndex];// 뒤에 Product Id
            system.debug('b : ' + b);
            system.debug('key : ' + key);
//            System.debug('key :: ' + key + '|' + strKey + '|' + a[0] + '|' + a[1]);
            if (b == key) return lineItemMap.get(strKey);
        }

        return null;
    }*/

//    public class RepairType {
//        @AuraEnabled public String label { get; set; }
//        @AuraEnabled public String value { get; set; }
//    }
//
//    public class WrapperLineItem {
//        @AuraEnabled public String id { get; set; }
//        @AuraEnabled public String laborCode { get; set; }
//        @AuraEnabled public String laborName { get; set; }
//        @AuraEnabled public String partCode { get; set; }
//        @AuraEnabled public String partName { get; set; }
//        @AuraEnabled public Decimal quantityOnHand { get; set; }       //Quantity On Hand
//        @AuraEnabled public Double hours { get; set; } // Flat Rate
//        @AuraEnabled public Double quantity { get; set; } // Flat Amount
//        @AuraEnabled public String taxCode { get; set; } // Tax Code
//        @AuraEnabled public Double tax { get; set; } // 이건 어떻게 처리할 지 아직 모름.
//        @AuraEnabled public Double amount { get; set; } // list Amount
//        @AuraEnabled public Double totalAmount { get; set; } // Total Amount
//        @AuraEnabled public String issueType { get; set; }
//        @AuraEnabled public String claimType { get; set; }
//        @AuraEnabled public Decimal listPrice { get; set; } // List Price
//        @AuraEnabled public Date effectFromDate { get; set; } // Effective From Date
//        @AuraEnabled public Date effectToDate { get; set; } // Effective To Date
//        @AuraEnabled public String productId { get; set; } // Part Id
//        @AuraEnabled public String vehicleId { get; set; } // Part Id
//        @AuraEnabled public String repairPartId { get; set; } // Part Id
//        @AuraEnabled public String repairLaborId { get; set; } // Labor Id
//        @AuraEnabled public Boolean isFlag { get; set; } // RQ Status 별 필드 활성 여부
//    }
//
//    public class WrapperServiceDiscount {
//        @AuraEnabled public String id { get; set; }
//        @AuraEnabled public Decimal amount { get; set; } // List Price
//        @AuraEnabled public String repairQuoteId { get; set; }
//        @AuraEnabled public String title { get; set; }
//        @AuraEnabled public String type { get; set; }
//    }
}