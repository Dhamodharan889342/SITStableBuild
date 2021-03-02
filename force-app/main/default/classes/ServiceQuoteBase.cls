/****************************************************************************************
* @author          Lee Donghu
* @date            2019-07-30
*
* @group           Service
* @group-content   Service 
*
* @description     ServiceQuoteBase
****************************************************************************************/


public abstract class ServiceQuoteBase {

    @TestVisible
    private static Repair_Quote_Line_Item__c findItem(Map<String, Repair_Quote_Line_Item__c> lineItemMap, String key, Integer keyIndex) {
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
    }

    public class RepairType {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }

    public class WrapperLineItem {
        @AuraEnabled public String id { get; set; }   // Request quote line item  id
        @AuraEnabled public String laborCode { get; set; }
        @AuraEnabled public String laborName { get; set; }
        @AuraEnabled public String partCode { get; set; }
        @AuraEnabled public String partName { get; set; }

        // LMS GD-1014 create some fields that support the specific 
        //             type of each repair quote item
        @AuraEnabled public String LineItemType { get; set; }  // Part||Labor||Sublet
        @AuraEnabled public String LineItemCode { get; set; }  // code can point to part or labor
        @AuraEnabled public String LineItemName { get; set; }
        // LMS GD-1014
        //
        //  Each line will have an identifier of the section that
        //  the items belongs to (package or user defined section)
        //  as a rule:
        //            Pack  --> belongs to a package
        //            User  --> user defined section 
        @AuraEnabled public String LineItemSectionType { get; set; }  // should just be "Pack" or "User"
        @AuraEnabled public String LineItemSectionName { get; set; }  // name of package or user defined section

        @AuraEnabled public Decimal quantityOnHand { get; set; }       //Quantity On Hand
        @AuraEnabled public Double hours { get; set; } // Flat Rate
        @AuraEnabled public Double quantity { get; set; } // Flat Amount
        @AuraEnabled public String taxCode { get; set; } // Tax Code
        @AuraEnabled public Double tax { get; set; } // 이건 어떻게 처리할 지 아직 모름.
        @AuraEnabled public Double amount { get; set; } // list Amount
        @AuraEnabled public Double totalAmount { get; set; } // Total Amount
        @AuraEnabled public Double discount { get; set; } // Total Amount
        @AuraEnabled public String issueType { get; set; }
        @AuraEnabled public String claimType { get; set; }  // Warranty || Id of Vehicle_Service_Package_Item
        @AuraEnabled public String claimTypeTitle { get; set; }  // Title on combobox
        @AuraEnabled public Decimal listPrice { get; set; } // List Price
        @AuraEnabled public Date effectFromDate { get; set; } // Effective From Date
        @AuraEnabled public Date effectToDate { get; set; } // Effective To Date
        @AuraEnabled public String productId { get; set; } // Part Id
        @AuraEnabled public String vehicleId { get; set; } // Part Id
        @AuraEnabled public String repairPartId { get; set; } // Part Id  ==> GD-1014 not use
        @AuraEnabled public String repairLaborId { get; set; } // Labor Id ==> GD-1014 not use
        @AuraEnabled public Boolean isFlag { get; set; } // RQ Status 별 필드 활성 여부

        // LMS GD-1014
        // Extra id for labor type rate (these change in time)
        @AuraEnabled public String LaborTypeRateId { get; set; } // points to LaborTypeRate__c
        @AuraEnabled public String LaborTypeRateName { get; set; } // Warranty||Diagnosis ....
        // LMS GD-1014
        // Extra id for repair quote section
        @AuraEnabled public String RepairQuoteSectionId { get; set; } // points to Repair_Quote_Section__c
        //  In case that the item is claimable from a previously purhased
        //  vehicle service package (Repair_Quote_Line_Item__c.VehicleServicePackageItem__c)
        @AuraEnabled public String VehicleServicePackageItemId { get; set; }

    }

    public class WrapperServiceDiscount {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public Decimal amount { get; set; } // List Price
        @AuraEnabled public String repairQuoteId { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String type { get; set; }
    }
}