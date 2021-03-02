/****************************************************************************************
LMS 15/12/2020
GD-1014

Copied from the chinese sandbox ServiceLaborController

* @author          Lee Donghu
* @date            2019-07-30
*
* @group           Service
* @group-content   Service 
*
* @description     ServiceLaborController
****************************************************************************************/


public with sharing class PackageRepairController extends ServiceQuoteBase {

    /**
     * isRepairQuoteJustCreated verifies if the repair quote is just
     *    created by verifying if there are already repair quote line items
     *    in the database
     * 
     * ## repairQuoteID (Id): repairQuoteID 
     * @@ Return Boolean: true --> just created
     *                      false --> created before (and saved)
     */
    public static Boolean isRepairQuoteJustCreated(Id repairQuoteID) {
        // https://developer.salesforce.com/forums/?id=906F0000000945SIAQ
        Integer AlreadyThere =  [SELECT count()  
                                FROM Repair_Quote_Line_Item__c  
                                WHERE RepairQuote__c = :repairQuoteID LIMIT 1];
        if (AlreadyThere>0) {
            return false;
        } else {
            return true;
        }
    }
    /** 
     *   LMS 4/2/2020
     * 
     * getPriceBookentriesForProducts: for a set of product id and
     * a pricebook let's find the proper prices 
     *
     * ## setProductId (Set<string>): setProductId
     * ## priceBookId (ID): priceBookId
     * @@ Return Map<ID,PricebookEntry>: id of product + record of product
     */
    public static Map<ID,PricebookEntry> getPriceBookentriesForProducts(Set<string> setProductId, ID priceBookId){
        List<PricebookEntry> lstPriceBookentriesForProducts=[
                select 
                    id, 
                    Product2Id,
                    Product2.name,
                    // UnitPrice__c,  // altered UnitPrice__c--> UnitPrice Mayank, 10/2/2021 - GD-2168
                    UnitPrice
                from 
                    PricebookEntry
                Where   
                    Pricebook2Id=:priceBookId
                    and Product2Id in :setProductId
                    and IsActive=true
        ];

        System.debug('PackageRepairController.getPriceBookentriesForProducts - 1 ');
        System.debug('Size: '+lstPriceBookentriesForProducts.size());
        for (PricebookEntry rec: lstPriceBookentriesForProducts){
            System.debug(rec.Product2.name);
            System.debug(rec);
        }
        // System.debug(lstPriceBookentriesForProducts);

        Map<ID,PricebookEntry> mapPricebookEntry=new Map<ID,PricebookEntry>();
        for (PricebookEntry recPricebookEntry: lstPriceBookentriesForProducts){
            mapPricebookEntry.put(recPricebookEntry.Product2Id, recPricebookEntry);
        }
        System.debug(mapPricebookEntry);
        return mapPricebookEntry;
    }

    /**
     * getLstRepairPackageItems given a set of repair packages
     * and the applicable pricebook return all
     * the package items that are a part of those packages with
     * the correct pricing
     *
     * ## setRepairPackageId (Set<String>): setRepairPackageId
     * @@ Return List<WrapperLineItem>: Return description
     */
    public static List<WrapperLineItem> getLstRepairPackageItems(Set<String> setRepairPackageId, ID priceBookID, ID repairQuoteId) {

        List<WrapperLineItem> lstRepairPackageItems=new List<WrapperLineItem>();

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
                    RepairPackage__c in :setRepairPackageId
        ];

        System.debug('PackageRepairController.getLstRepairPackageItems -1 ');
        System.debug('Size: '+lstRepairPackageItem.size());
        

        // System.debug(lstRepairPackageItem);


        // based on the items of repair package we need to search the
        // corresponding entries in the pricebook
        // set of ids to search pricing
        Set<String> setProductID=new Set<String>();
        for (RepairPackageItem__c recRepairPackageItem : lstRepairPackageItem) {      
            System.debug(recRepairPackageItem);
            System.debug(recRepairPackageItem.Product__c+' ==> '+recRepairPackageItem.Product__r.name);
            setProductID.add(recRepairPackageItem.Product__c);
        }
        Map<ID,PricebookEntry> mapPriceBookentriesForProducts=getPriceBookentriesForProducts(setProductID, priceBookID);

        // memorize the standard labor rate
        LaborTypeRate__c recLaborRateStandard=RepairQuoteUtil.getStandardLaborRate(repairQuoteId, Date.today() ); 

        // this is where the items of the rapair packages will 
        // be "dumped"
        List<WrapperLineItem> ListItems = new List<WrapperLineItem>();
        // for each package item calculate the item value 
        RepairPackageItem__c memoRepairPackageItem=null;
        Double dblTotalRepairPackageBeforeDiscount=0;
        
        System.debug('PackageRepairController.getLstRepairPackageItems - 2 ');
        System.debug('Begin Loop of repair package items number of items ===> '+lstRepairPackageItem.size());
        
        for (RepairPackageItem__c recRepairPackageItem : lstRepairPackageItem) {
            // remember last record
            memoRepairPackageItem=recRepairPackageItem;
            
            System.debug('Registo='+ recRepairPackageItem);

            WrapperLineItem wl = new WrapperLineItem();

            // Id here will be void since 
            // these items don't come from repair quote line item
            // wl.id=recRepairPackageItem.id;
            wl.id='';
            wl.laborName = recRepairPackageItem.Product__r.name;
            wl.laborCode = recRepairPackageItem.Product__r.productcode;
            wl.productId = recRepairPackageItem.Product__c;
            if (wl.laborCode==null) {
                wl.laborCode='NA';
            }
            // new codes
            wl.LineItemType=recRepairPackageItem.LineItemType__c;
            wl.LineItemCode=recRepairPackageItem.Product__r.productcode;
            if (wl.LineItemCode==null) {
                wl.LineItemCode='NA';
            }
            wl.LineItemName=recRepairPackageItem.Product__r.name;
            // some defensive programming taking into account
            // bad test data
            
            if (recRepairPackageItem.Hours__c!=null) {
                wl.hours = recRepairPackageItem.Hours__c;
            } else {
                wl.hours = recRepairPackageItem.Product__r.Hours__c;
            }
            
            if (recRepairPackageItem.UnitPrice__c!=null){
                wl.listPrice = recRepairPackageItem.UnitPrice__c;
            } else {
                wl.listPrice = recRepairPackageItem.product__r.Price_Per_Unit__c;
                if (wl.listPrice==null){ wl.listPrice = 0;}
            }
            // just leave this code to keep testing
            
            if (recRepairPackageItem.UnitPrice__c!=null){
                wl.listPrice = recRepairPackageItem.UnitPrice__C;
            } else {
                wl.listPrice = recRepairPackageItem.product__r.Price_Per_Unit__c;
                if (wl.listPrice==null){ wl.listPrice = 0;}
            }
            
            // find the product price from the pricebook
            PricebookEntry recPricebookEntry=mapPriceBookentriesForProducts.get(recRepairPackageItem.Product__c);
            if (recPricebookEntry!=null) {
                // TODO: it can also be UnitPrice__c ??
                // altered UnitPrice__c--> UnitPrice Mayank, 10/2/2021 - GD-2168
                if (recPricebookEntry.UnitPrice!=null) {
                    wl.listPrice=recPricebookEntry.UnitPrice;
                }
            }

            if (recRepairPackageItem.Tax__c!=null) {
                wl.tax = recRepairPackageItem.Tax__c;
            } else {
                wl.tax = recRepairPackageItem.product__r.Taxrate__c;
                if (wl.tax==null){ wl.tax = 0;}
            }
            if (recRepairPackageItem.Quantity__c!=null){
                wl.quantity = recRepairPackageItem.Quantity__c;
            } else {
                wl.quantity = recRepairPackageItem.Product__r.Quantity__c;
                if (wl.quantity==null){ wl.quantity = 1;}
            }
            // Careful handling of discounts
            // all sorts of bad data
            wl.discount= 0;
            /*  
                LMS - 4/2/2021 
                      Discounts are defined at the top level

            if (recRepairPackageItem.DiscountType__c=='Rate') {
                if (recRepairPackageItem.DiscountRates__c!=null) {
                    wl.discount=recRepairPackageItem.DiscountRates__c;
                }
            }
            
            if (recRepairPackageItem.DiscountType__c=='Price') {
                if (recRepairPackageItem.DiscountAmounts__c!=null) {
                    // convert the amount into
                    // a percentage
                    wl.discount=recRepairPackageItem.DiscountAmounts__c/wl.listPrice;                    
                }
            }
            */
            if (recRepairPackageItem.RepairPackage__r.Discount__c!=null) {
                // just to handle crazy test data
                if (recRepairPackageItem.RepairPackage__r.ListPrice__c!=null) {
                    wl.discount=0;
                } else {
                    wl.discount=recRepairPackageItem.RepairPackage__r.Discount__c;
                }                
            }

            wl.taxCode = '-';            
            wl.amount = wl.quantity * wl.listPrice;            
            
            if (wl.LineItemType=='Labor') {
                // Just apply the standard labor rate "Maintenance"
                if (recLaborRateStandard!=null){
                    wl.LaborTypeRateId=recLaborRateStandard.Id;
                }                

                if (wl.hours==null){ wl.hours = 1;}
                wl.amount= wl.amount * wl.hours;
            }      
            // This will be used in the future in case 
            // the repair package has a global price
            dblTotalRepairPackageBeforeDiscount +=wl.amount;      

            if (wl.discount!=null) {
                wl.amount=wl.amount-(wl.amount*(wl.discount/100));
            }

            wl.totalAmount = wl.amount*(1+wl.tax/100) ;
                        
            wl.LineItemSectionType ='Pack';
            wl.LineItemSectionName=recRepairPackageItem.RepairPackage__r.name;
            
            System.debug('wl='+wl);

            // final verification to enforce the rule that all
            // prices must come from price book entries            
            if (recPricebookEntry!=null) {
                ListItems.add(wl);  
            }
        }
        
        // LMS 4/2/2021
        //  In case the repair package has a "goal price" we'll have to
        //  recalculate every item to reach that goal price

        /*
        // removed because we are mixing different
        //  packages and goals
        if (memoRepairPackageItem!=null){
            if (memoRepairPackageItem.RepairPackage__r.ListPrice__c!=null){

                Double goalPrice=memoRepairPackageItem.RepairPackage__r.ListPrice__c;
            
                double dblDiscount= (goalPrice * 100)/dblTotalRepairPackageBeforeDiscount;
                dblDiscount= (100 -  dblDiscount)/100;

                // go through the item list and update the total amount
                for (Integer ind=0;ind<ListItems.size();ind++ ){
                    ListItems[ind].discount=dblDiscount;
                    Double totalAmount= ListItems[ind].amount - ( ListItems[ind].amount*dblDiscount);
                    totalAmount= totalAmount * (1+ListItems[ind].tax/100);
                    ListItems[ind].totalAmount=totalAmount;
                }
            }
        }
        */
        System.debug('PackageRepairController.getLstRepairPackageItems - 2 ');
        System.debug('**********ListItems **********');
        System.debug('SIZE='+ ListItems.size());
        System.debug(ListItems);

        return ListItems;
    }
    /**
     * Test_getPackageItems Just a temp test method
     *
     PackageRepairController.Test_getPackageItems();
     
     */
    public static void Test_getPackageItems(){

        Map<String, Object> rmap;
        Map<String, List<WrapperLineItem>> rmapWL;
        
        Id repairQuoteID=Id.valueOf('a0u7a000002vpgZAAQ');         
        // Id repairQuoteID=Id.valueOf('a0u7a000002vZYhAAM');

        // https://genesismotoreurope--dev.lightning.force.com/lightning/r/RepairQuote__c/a0u7a000002vpgZAAQ/view

        rmapWL=PackageRepairController.doGetServiceBookingRepairPackageItems(repairQuoteID);
        System.debug('PackageRepairController.Test_getPackageItems');
        System.debug('Size: '+rmapWL.size());
        System.debug(rmapWL);

        List<Object> Lines = new List<Object>();
        Lines = rmapWL.get('itemList');
        System.debug('Lines Size: '+Lines.size());
        for (Integer ind=0; ind<Lines.size(); ind++){
            System.debug(Lines[ind]);
        }
        
	}

    /**
     * doGetServiceBookingRepairPackageItems 
     * 
     *      Retrieve the list of items in a repair package that is associated 
     *      with the service booking repair package
     * 
     * ## repairQuoteID (Id): repairQuoteID  (id of the quote that points to service booking) 
     * @@ Return Map<String,Object>: Returns a Map of associated objects
     */
    @AuraEnabled
    public static Map<String, List<WrapperLineItem>> doGetServiceBookingRepairPackageItems(Id repairQuoteID) {

        // find the ID of the Service Booking in the repair quote
        RepairQuote__c RepairQuoteRec= [select 
                                            id, Repair__c , PriceBook__c
                                        from
                                            RepairQuote__c where Id=:repairQuoteID ];
        
        Id serviceBookingId=RepairQuoteRec.Repair__c;        
        System.debug('PackageRepairController.doGetServiceBookingRepairPackageItems - 1');
        System.debug(RepairQuoteRec);    

        // Search all the service booking records associated to ths
        // ServiceBookingRepairPackageItems ...
        List<Service_Booking_Repair_Package__c> lstSBRP= [
            select id, Service_Booking_Repair__c, Repair_Package__c 
                FROM 
                    Service_Booking_Repair_Package__c
                WHERE 
                Service_Booking_Repair__c=: serviceBookingId
        ];
        System.debug('PackageRepairController.doGetServiceBookingRepairPackageItems - 2');
        System.debug(lstSBRP);
        // set of Repair package IDs to search
        Set<String> setRepairPackageId = new Set<String>();	
        for (Service_Booking_Repair_Package__c SBRP : lstSBRP){
            setRepairPackageId.add(SBRP.Repair_Package__c);
        }
        // Find all items that are associated to the Repair Packages
        // that are implicitly included in the service booking
        //
        //  TODO: verify validity (StartDate__c, EndDate__c)
        //  Note: the formula fields are redundant
        //              fm_ProductCode__c,
        //             fm_PartName__c,
        //             fm_PartCode__c,
        //             fm_LaborName__c,
        //             fm_LaborCode__c,
        //  Others not used:~
        //                PART_PRC__c,  
/* 3/2/2021
[9:44 AM] Pant, Mayank (Cognizant)
    Today I have meeting with Sebastian to go through repair package and repair package item fields.
     I will discuss about these fields in that meeting. I will also discuss with him if the price
      should come from the master file as master file will have the latest price for any part
       (Integration via DAOS and LTS). Or should we use repair package items prices (these prices are calculated at
        the time when repair packages are created and there prices my be old)
*/
      
        // this is where the items of the rapair packages will 
        // be "dumped"
        List<WrapperLineItem> ListItems = getLstRepairPackageItems(setRepairPackageId, RepairQuoteRec.PriceBook__c,RepairQuoteRec.Id );
       
        // LMS 18/2/2021
        //
        //  Add the "Indiviadual repair items from the service booking
        //  Name is not being properly filled by service booking (name=ID)
        //  use the 
        List<Individual_Repair_Item__c> lstIndividualItems=[
            select id, name, Skill__c, Description__c
            from Individual_Repair_Item__c 
            where 
                Service_Booking__c=:serviceBookingId
        ];

        for (Individual_Repair_Item__c recIRI: lstIndividualItems){
            // create a "fake item" for the new section çç
            WrapperLineItem wl = new WrapperLineItem();
            wl.id='';
            wl.LineItemType='Part';
            wl.LineItemCode='fake';   // this is the "signal item" 
            wl.LineItemName=recIRI.Description__c;   // name not useable
            wl.LineItemSectionType='User';
            wl.LineItemSectionName=recIRI.Description__c+'-' + recIRI.Skill__c; // name not useable

            ListItems.add(wl);
        }


        System.debug('PackageRepairController.doGetServiceBookingRepairPackageItems - 3');
        System.debug('**********ListItems **********');
        System.debug('SIZE='+ ListItems.size());
        System.debug(ListItems);
       

        Map<String, List<WrapperLineItem>> rmapWL = new Map<String, List<WrapperLineItem>>();
        rmapWL.put('itemList', ListItems);
        
        return rmapWL;    
    }

    /**
     * GD-1014
     * doGetLaborList Return the list of repair quote line items
     * already stored
     * 
     * NOTE: the name of the function is "erroneous" to labor but 
     *       it was so "hard wired" in the aura code that I kept it 
     *
     * ## pmap (Map<StringObject>): pmap
     * @@ Return Map<String,Object>: Return description
     */
    @AuraEnabled
    public static Map<String, Object> doGetLaborList(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        Boolean disabledApply = false;

        // LMS 8/2/2021
        //
        //   If this is the first time the request quote is accessed 
        //   then get the data from the service booking
        // 
        if (isRepairQuoteJustCreated(recordId)==true) {
            Map<String, List<WrapperLineItem>> rmapWL;
            rmapWL=PackageRepairController.doGetServiceBookingRepairPackageItems(recordId);            

            List<WrapperLineItem> laborListTemp=rmapWL.get('itemList');
            Map<String, Object> rmap=new Map<String, Object>();
            // laborList is expected
            rmap.put('laborList',laborListTemp);
            rmap.put('disabledApply', disabledApply);

            return (rmap);
        }
        // ============> Let's search for the data in repair quote items <==========

        RepairQuote__c rq = [SELECT Id, Status__c FROM RepairQuote__c WHERE Id = :recordId];
        if (RepairQuoteUtil.isRepairQuoteClosed(rq.Status__c)) disabledApply = true;
        List<Repair_Quote_Line_Item__c> l = [
                SELECT                        
                        // LaborCode__c,
                        fm_Amount__c,
                        Tax__c,
                        Tax_in_Percentage__c,
                        fm_TotalAmount__c,
                        Hours__c,
                        Id,
                        LineItemType__c,
                        ListPrice__c,
                        
                        Name,
                        Quantity__c,
                        RepairQuote__c,
                        Repair_Quote_Section__r.name,
                        Repair_Quote_Section__r.SectionType__c,
                        Repair_Quote_Section__c,
                        Labor__c,
                        Labor__r.ProductCode,
                        LaborTypeRate__c, 
                        LaborTypeRate__r.name,
                        Part__c,
                        Part__r.ProductCode,
                        Issue_Type__c,
                        VehicleServicePackageItem__c,

                        // fm_LaborCode__c,   // TODO: GD-1014 Not existant in Salesforce
                        //fm_LaborName__c,    // TODO: GD-1014 Not existant in Salesforce
                        //fm_PartCode__c,     // TODO: GD-1014 Not existant in Salesforce
                        // fm_PartName__c,    // TODO: GD-1014 Not existant in Salesforce
                        // IssueType__c,      // TODO: GD-1014 Not existant in Salesforce
                        //ClaimType__c,       // TODO: GD-1014 Not existant in Salesforce    
                        Discount__c,
                        Discount_in_Percentage__c,
                        Total_Price_VAT_included__c
                FROM Repair_Quote_Line_Item__c
                WHERE 
                
                //LineItemType__c = 'Labor'
                //AND 
                
                RepairQuote__c = :recordId
                // ORDER BY fm_LaborCode__c
        ];

        // Some labor rates could not come filled from the items
        // remember the standard one to apply
        LaborTypeRate__c recStandardLaborRate=RepairQuoteUtil.getStandardLaborRate(recordId,Date.today());
        

        List<WrapperLineItem> laborList = new List<WrapperLineItem>();

        for (Repair_Quote_Line_Item__c rqli : l) {
            WrapperLineItem wl = new WrapperLineItem();

            wl.LineItemName=rqli.name;
            wl.id = rqli.Id;
            wl.LineItemType=rqli.LineItemType__c;

            if (wl.LineItemType=='Labor') {
                wl.productId=rqli.labor__c;
                wl.LineItemCode=rqli.labor__r.ProductCode;
            } else {
                wl.productId=rqli.part__c;
                wl.LineItemCode=rqli.part__r.ProductCode;
            }

            // make a "subtle adjustment" 
            if (wl.LineItemType=='Additional Services') {
                wl.LineItemType='Sublet';
            }
            
            wl.hours = rqli.Hours__c;
            wl.listPrice = rqli.ListPrice__c;
            wl.taxCode = '-';
            wl.tax=rqli.Tax_in_Percentage__c;

            wl.totalAmount = rqli.Total_Price_VAT_included__c;
            wl.amount = rqli.fm_Amount__c;
            wl.discount = rqli.Discount_in_Percentage__c;
            wl.quantity = rqli.Quantity__c;

            if (rqli.LaborTypeRate__c!=null){
                wl.LaborTypeRateId=rqli.LaborTypeRate__c;
            } else {
                // more defensive code for bad test data in labor type
                if (recStandardLaborRate!=null) {
                    wl.LaborTypeRateId=recStandardLaborRate.Id;
                }
                
            }

            wl.issueType=rqli.Issue_Type__c;   
            if (wl.issueType!=null){
                if (wl.issueType=='Claimable'){

                    // in case it is a part
                    if ((wl.LineItemType=='Part') || (wl.LineItemType=='Sublet'))  {
                        if (rqli.VehicleServicePackageItem__c==null) {
                            wl.claimType='Warranty';
                            wl.claimTypeTitle='Original = Warranty';    
                        } else {
                            wl.claimType=rqli.VehicleServicePackageItem__c;
                            Vehicle_Service_Package_Item__c recVSPI=RepairQuoteUtil.getVSPI(rqli.VehicleServicePackageItem__c);
                            wl.claimTypeTitle= 'Original=' +  recVSPI.Vehicle_Service_Package__r.name+ 
                                                '-' + recVSPI.product__r.name;
                            
                        }

                    } 
                    if (wl.LineItemType=='Labor') {
                        // TODO: adapt to other languages
                        if (rqli.VehicleServicePackageItem__c==null) {
                            wl.claimType='Warranty';
                            wl.claimTypeTitle='Original = Warranty';
                        } else {
                            if (rqli.VehicleServicePackageItem__c!=null) {
                                // not elegant, but gets the name 
                                Vehicle_Service_Package_Item__c recVSPI=RepairQuoteUtil.getVSPI(rqli.VehicleServicePackageItem__c);
                                // title name in "readable" fashion                            
                                wl.claimTypeTitle= 'Original=' +  recVSPI.Vehicle_Service_Package__r.name+ 
                                                    '-' + recVSPI.product__r.name;
                                wl.claimType=rqli.VehicleServicePackageItem__c;
                                wl.VehicleServicePackageItemId=rqli.VehicleServicePackageItem__c;
                            }
                        }
                    }            
                }             
            }            

            // section naming
            wl.RepairQuoteSectionId=rqli.Repair_Quote_Section__c;
            wl.LineItemSectionName=rqli.Repair_Quote_Section__r.name;
            if (rqli.Repair_Quote_Section__r.SectionType__c=='Package') {
                wl.LineItemSectionType='Pack';                
            } else {
                wl.LineItemSectionType='User';
            }
             // çç

            // wl.issueType = rqli.IssueType__c;    // TODO: GD-1014 Not existant in Salesforce
            // wl.claimType = rqli.ClaimType__c;    // TODO: GD-1014 Not existant in Salesforce
            // TODO: GD-1014 Not existant in Salesforce
            //if (RepairQuoteUtil.isClaimClosed(rqli.ClaimType__c)) wl.isFlag = true;
            if (RepairQuoteUtil.isRepairQuoteClosed(rq.Status__c)) wl.isFlag = true;

            laborList.add(wl);
        }


        Map<String, Object> rmap = new Map<String, Object>();
        rmap.put('laborList', laborList);
        rmap.put('disabledApply', disabledApply);

        return rmap;
    }


    /**
     * getLaborRates description
     *
     * ## dtRef (Datetime): dtRef
     * ## strCountry (String): strCountry
     * @@ Return Map<String,Object>: Return description
     */
    @AuraEnabled
    public static  Map<String, Object> getLaborRates(Date dtRef, string strCountry){
        
        Map<String, Object> rmap=new Map<String, Object>();
        // util.getAllLaborRates(country, referenceDate)
        List<LaborTypeRate__c> lstLaborRates=Util.getAllLaborRates(strCountry, dtRef);

        //
        rmap.put('lstLaborRates', lstLaborRates);

        return rmap;
    }

    @AuraEnabled
    /**
     * doSearchLabor description
     * @param  pmap pmap description
     * @return      return description
     */ 
    public static List<WrapperLineItem> doSearchLabor(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        String repairType = (String) pmap.get('repairType');
        String opCode = (String) pmap.get('opCode');
        String opDesc = (String) pmap.get('opDesc');

        opCode = opCode + '%';
        opDesc = '%' + opDesc + '%';

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,Product__r.VehicleModelLabor__c,
                        PriceBook__c,
                        PriceBook__r.Country__c
                        // PriceBook__r.Name,Repair__r.ServiceCenter__r.HourlyLaborPrice__c,
                        // Repair__r.ServiceCenter__r.Language__c
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];

        Set<String> prodCodeSet = new Set<String>();
        Set<String> prodIdSet = new Set<String>();
        Map<String, Product2> prodMap = new Map<String, Product2>();

        List<Product2> prodSearchList = [
                SELECT Id,Name,ProductCode
                FROM Product2
                WHERE 
                
                //Locale__c = :Util.getUserDepartmentLocale()  // TODO: GD-1014 Not existant in Salesforce
                RecordType.DeveloperName = 'Labor'
                AND ProductCode LIKE :opCode
                AND Name LIKE :opDesc
        ];
        for (Product2 prod : prodSearchList) {
            prodMap.put(prod.ProductCode, prod);
        }
        System.debug('rq.Product__r.VehicleModelLabor__c => ' +rq.Product__r.VehicleModelLabor__c);
        // TODO: GD-1014 Not existant in Salesforce
        //       This object does not exist
        //        Where to get cost of labor ??
        /*
        List<RepairLabor__c> rlList = [
                SELECT
                        Id, Name, Labor__c, Labor__r.ProductType__c, Labor__r.RepairType__c,
                        Labor__r.Name, Labor__r.ProductCode, Labor__r.Description, Hours__c
                FROM RepairLabor__c
                WHERE VehicleModel__c = :rq.Product__r.VehicleModelLabor__c
                AND Labor__r.ProductCode IN:prodMap.keySet()
        ];
        for (RepairLabor__c rl : rlList) {
            prodCodeSet.add(rl.Labor__r.ProductCode);
        }
        */

        List<Product2> prodList = [
                SELECT Id,Name,ProductCode
                FROM Product2
                WHERE 
                // TODO: GD-1014 Not existant in Salesforce
                // Locale__c = :Util.getUserDepartmentLocale()
                // ProductType__c = 'Labor' // TODO: GD-1014 Not existant in Salesforce
                ProductCode IN:prodCodeSet
        ];
        for (Product2 prod : prodList) {
            prodMap.put(prod.ProductCode, prod);
            prodIdSet.add(prod.Id);
        }

        List<WrapperLineItem> laborList = new List<WrapperLineItem>();
        
        // TODO: GD-1014 Not existant in Salesforce
        //       RepairLabor__c  not existant
        /*
        for (RepairLabor__c rl : rlList) {

            WrapperLineItem wl = new WrapperLineItem();
            if (!prodMap.containsKey(rl.Labor__r.ProductCode)) continue;
            Product2 prod = prodMap.get(rl.Labor__r.ProductCode);
            wl.id = rl.Id;
            wl.vehicleId = rq.Product__c; // Vehicle Model

            wl.laborName = prod.Name;                              //No
            wl.laborCode = prod.ProductCode;                //Labor Code
            wl.productId = prod.id; // Labor or Part

            wl.hours = rl.Hours__c;                                      //Flat Rate
            wl.amount = wl.hours * rq.Repair__r.ServiceCenter__r.HourlyLaborPrice__c;    //Total Amount

            laborList.add(wl);
        }
        */

        return laborList;
    }

    // GD-1014 Not used in Europe
    // 추가 김성일
    @AuraEnabled
    public static Map<String, Object> doSave(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,Product__c,Product__r.VehicleModelPart__c,Product__r.VehicleModelLabor__c,
                        PriceBook__c
                        // TODO: GD-1014 Not existant in Salesforce
                        //, PriceBook__r.Name,Repair__r.ServiceCenter__r.Language__c
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
                // rqli.Product__c = rq.Product__c; // TODO: GD-1014 Not existant in Salesforce

                rqli.Hours__c = wl.hours;
                rqli.LineItemType__c = 'Labor';
                rqli.ListPrice__c = wl.listPrice;
                rqli.Quantity__c = wl.quantity;
                rqli.CurrencyIsoCode = rq.CurrencyIsoCode;


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
                SELECT Id, 
                        RepairQuote__c, 
                        // fm_LaborCode__c, // TODO: GD-1014 Not existant in Salesforce
                        LineItemType__c,     
                        //ClaimType__c,     // TODO: GD-1014 Not existant in Salesforce
                        RepairQuote__r.Vehicle__c
                FROM Repair_Quote_Line_Item__c
                WHERE Id = :rqliId
        ];

//        if (rqli.LineItemType__c == 'Labor') {
//            // 묶인 Part를 모두 삭제.
//            delete [
//                    SELECT Id FROM RepairQuoteLineItem__c WHERE RepairQuote__c = :rqli.RepairQuote__c AND LaborCode__c = :rqli.fm_LaborCode__c
//            ];
//        }

        //Line Item Type이 Customer Field 이면 연관된 데이터 삭제
        // TODO: GD-1014 Not existant in Salesforce
        // 
        // Entire Logic has to go
        /*
        if (rqli.ClaimType__c == 'C') {
            List<RepairQuoteLineItem__c> delList = [SELECT Id, RepairQuote__c, ClaimType__c FROM RepairQuoteLineItem__c WHERE RepairQuote__c = :rqli.RepairQuote__c AND ClaimType__c = 'C'];
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
                    FROM RepairQuoteLineItem__c
                    WHERE Id = :rqliId
            ];
        }
        */
        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('result', 'ok');
        rmap.put('id', recordId);

        return rmap;
    }

 
    /**
     * doSaveRepairQuote ==> Save the repair quote items in the database
     *            
     *
     * ## pmap (Map<StringObject>): pmap list of items + list of sections
     * @@ Return Map<String,Object>: Return description
     */
    @AuraEnabled
    public static Map<String, Object> doSaveRepairQuote(Map<String, Object> pmap) {
        String recordId = (String) pmap.get('recordId');
        String strItemList = (String) pmap.get('itemList');

        if (String.isEmpty(strItemList)) {
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
                        PriceBook__c, PriceBook__r.Name,
                        PriceBook__r.Country__c
                FROM RepairQuote__c
                WHERE Id = :recordId
        ];

        System.debug('========================== PackageRepairController.doSaveRepairQuote ==============================');
        System.debug(rq);

        List<WrapperLineItem> lstItemList = (List<WrapperLineItem>) JSON.deserialize(strItemList, List<WrapperLineItem>.Class);
        Set<String> setRepairQuoteLineItemsID = new Set<String>();	
        
        for (Integer ind=0; ind<lstItemList.size();ind++){
            setRepairQuoteLineItemsID.add(lstItemList[ind].id);
        }

        // remove the deleted items from the database
        List<Repair_Quote_Line_Item__c> lstRepairLineItemsDelele=[
            select id 
                from Repair_Quote_Line_Item__c
                where
                    RepairQuote__c=:rq.Id 
                    and id not in :setRepairQuoteLineItemsID
        ];

        delete lstRepairLineItemsDelele;

        // go through the item list and identify the quote sections that need to
        // be created or updated
        List<Repair_Quote_Section__c> lstRepairQuoteSection=new List<Repair_Quote_Section__c>();
        // set of repair quote sections NOT to delele
        Set<ID> setRQSnotDelete=new Set<ID>();
        for (Integer ind=0; ind<lstItemList.size();ind++){        
            
            String strSectionName=lstItemList[ind].LineItemSectionName;
            String strSectionType=lstItemList[ind].LineItemSectionType;

            if (strSectionType=='User') strSectionType='User Defined';
            if (strSectionType=='Pack') strSectionType='Package';
            
           
            // search section 
            Integer indexList;
            indexList=RepairQuoteUtil.findSectionIndex(lstRepairQuoteSection, strSectionName, strSectionType);
          
            if (indexList==-1){
                Repair_Quote_Section__c recRepairQuoteSection=new Repair_Quote_Section__c();
                // could have been created before
                if (lstItemList[ind].RepairQuoteSectionId!=null){
                    recRepairQuoteSection.Id=lstItemList[ind].RepairQuoteSectionId;
                    setRQSnotDelete.add(recRepairQuoteSection.Id);
                }
                recRepairQuoteSection.Name=strSectionName;
                recRepairQuoteSection.SectionType__c=strSectionType;
                recRepairQuoteSection.RepairQuote__c=recordId;
                // add to list of sections to upsert
                lstRepairQuoteSection.add(recRepairQuoteSection);
            }

        }  // end for loop

        // remove all the quote sections that weren't identified in the previous loop
        // (and were previously inserted into the data base)
        List<Repair_Quote_Section__c> lstRepairQuoteSectionsDelete=[
            select id from Repair_Quote_Section__c 
                where
                    RepairQuote__c=:recordId
                    and id not in :setRQSnotDelete
        ];
        delete lstRepairQuoteSectionsDelete;
        // upsert the final list of section quotes
        // IDs ficam atribuidos nesta fase
        upsert lstRepairQuoteSection; 
        // Some labor rates could not come standard from the items
        // remember the standard one to apply in the future
        LaborTypeRate__c recStandardLaborRate=RepairQuoteUtil.getStandardLaborRate(recordId,Date.today());
        //  Create a list to upsert the remaining items
        List<Repair_Quote_Line_Item__c> lstRepairQuoteLineItem=new List<Repair_Quote_Line_Item__c>();

        for (Integer ind=0; ind<lstItemList.size();ind++){    
            
            System.debug('*** PackageRepairController.doSaveRepairQuote ==> Wrapper line to process');
            System.debug(lstItemList[ind]);
            setRepairQuoteLineItemsID.add(lstItemList[ind].id);

            Repair_Quote_Line_Item__c recRQLI=new Repair_Quote_Line_Item__c();
        
            // repair quote must be
            recRQLI.RepairQuote__c=recordId;

            // the id field should only be created/filled if it exists in memory
            if (lstItemList[ind].id.length()>1) {
                recRQLI.Id=lstItemList[ind].id;
            }
            // item type: Labor|Part|Sublet
            // TODO: handle other languages

            if (lstItemList[ind].LineItemType=='Sublet') {
                recRQLI.LineItemType__c='Additional Services';
                //                       Additional Services
            } else {
                recRQLI.LineItemType__c=lstItemList[ind].LineItemType;  // Part||Labor
            }
            
            // issue type: Billable || Claimable || Insurance
            recRQLI.Issue_Type__c=lstItemList[ind].issueType;
            // if "Claimable" then check if redeemable issue type
            // points to Vehicle Service Package Item
            // NOTE: Warranty are by default "definid" in the labor rate
            if (lstItemList[ind].claimType instanceOf Id) {
                recRQLI.VehicleServicePackageItem__c=lstItemList[ind].claimType;
            } else {
                recRQLI.VehicleServicePackageItem__c=null;
            }

            // quantity and list price and discount and total amount
            recRQLI.Quantity__c=lstItemList[ind].quantity;
            recRQLI.ListPrice__c=lstItemList[ind].listPrice;
           
            
            recRQLI.ListPrice__c=lstItemList[ind].listPrice;
            recRQLI.Name=lstItemList[ind].LineItemName;
            
            //  Add the id to labor or part|aditional 
            if ((recRQLI.LineItemType__c=='Part')||recRQLI.LineItemType__c=='Additional Services' ) {
                // recRQLI.Part__c=lstItemList[ind].repairPartId;
                recRQLI.Part__c=lstItemList[ind].productId;
                recRQLI.Labor__c=null;
                Id idRecordType = Schema.SObjectType.Repair_Quote_Line_Item__c.getRecordTypeInfosByName().get('Part Repair Quote Line Item').getRecordTypeId();
                recRQLI.RecordtypeId=idRecordType;
            } else {  // labor
                Id idRecordType = Schema.SObjectType.Repair_Quote_Line_Item__c.getRecordTypeInfosByName().get('Labor Repair Quote Line Item').getRecordTypeId();
                recRQLI.RecordtypeId=idRecordType;

                recRQLI.Hours__c=lstItemList[ind].hours;
                recRQLI.Part__c=null;
                recRQLI.Labor__c=lstItemList[ind].productId;

                if (lstItemList[ind].LaborTypeRateId!=null) {
                    System.debug('PackageRepairController.doSaveRepairQuote  ==> labor rate id from wl::'+lstItemList[ind].LaborTypeRateId);
                    recRQLI.LaborTypeRate__c=lstItemList[ind].LaborTypeRateId;
                } else {
                    
                    if (recStandardLaborRate!=null){
                        System.debug('PackageRepairController.doSaveRepairQuote  ==> Standard labor rate applied');
                        System.debug(recStandardLaborRate);
                        // apply the standard rate
                        recRQLI.LaborTypeRate__c=recStandardLaborRate.id;
                        // TODO: verify if the current list price is correct
                        // recRQLI.ListPrice__c=recRQLI.rate;
                    }
                }
            }
            // discount in percentage is being used in the UI for repair quote
            recRQLI.Discount_in_Percentage__c=lstItemList[ind].discount;
            // calculate the discount
            Double dblCalc=(recRQLI.ListPrice__c*recRQLI.Quantity__c);
            if (recRQLI.LineItemType__c=='Labor') {
                if (recRQLI.hours__c!=null) {
                    dblCalc=dblCalc*recRQLI.hours__c;
                }                
            }          

            if (recRQLI.Discount_in_Percentage__c==null) {
                recRQLI.discount__c=0;
                recRQLI.Discount_in_Percentage__c=0;
            } else {
                recRQLI.discount__c=(dblCalc*(recRQLI.Discount_in_Percentage__c/100));
            }
            
            // apply tax
            recRQLI.Tax_in_Percentage__c=lstItemList[ind].tax;
            if (recRQLI.Tax_in_Percentage__c==null) {
                recRQLI.Tax_in_Percentage__c=0;
            }
            dblCalc=dblCalc - recRQLI.discount__c;
            recRQLI.Tax__c=dblCalc*(recRQLI.Tax_in_Percentage__c/100);

            // TODO: repair quote sections
            if (lstItemList[ind].RepairQuoteSectionId!=null) {
                recRQLI.Repair_Quote_Section__c=lstItemList[ind].RepairQuoteSectionId;
            } else {
                // search for the corresponding section id  çç
                Integer indexPosition;
                String strSectionName=lstItemList[ind].LineItemSectionName;
                String strSectionType=lstItemList[ind].LineItemSectionType;
                indexPosition=RepairQuoteUtil.findSectionIndex(lstRepairQuoteSection, strSectionName, strSectionType);

                if (indexPosition>=0) {
                    recRQLI.Repair_Quote_Section__c=lstRepairQuoteSection[indexPosition].id;
                }
            }
                
            // add the item to the final list 
            System.debug('*** PackageRepairController.doSaveRepairQuote ==> record to include');
            System.debug(recRQLI);
            lstRepairQuoteLineItem.add(recRQLI);
        }  // end of loop

        // write all to database
        try  {
            upsert lstRepairQuoteLineItem;
        } catch(DmlException e) {
            System.debug('PackageRepairController.doSaveRepairQuote ==>The following exception has occurred: ' + e.getMessage());
            System.debug(e);
            System.debug(lstRepairQuoteLineItem);
            throw new DmlException('Error insert items in repair quote items:',e);
        }
        

        Map<String, Object> rmap = new Map<String, Object>();

        rmap.put('result', 'ok');
        rmap.put('id', recordId);

        return rmap;
    }  // end of function

    /**
     * GD-1225
     * getListRedeemableItems Get the list of "redeemable" related service line items 
     *
     * ## repairQuoteId (ID): repairQuoteId
     * ## productCodeId (Id): product that can be redeemed (if possible)
     * @@ Return Map<String,Object>: Return List of probable items to be redeemed
     */
    @AuraEnabled
    public static Map<String, Object> getListRedeemableItems(ID repairQuoteId, Id productCodeId) {

        RepairQuote__c rq = [
                SELECT
                        Id, Repair__c, Repair__r.Vehicle__c, CurrencyIsoCode,
                        Repair__r.Vehicle__r.Product2Id,Product__r.VehicleModelLabor__c,                       
                        PriceBook__c, PriceBook__r.Name,
                        PriceBook__r.Country__c
                FROM RepairQuote__c
                WHERE Id = :repairQuoteId
        ];

        // reference date        
        Date dtRef=Date.today();
        // direct access to simple items in 
        // avalailable service packages
        List<Vehicle_Service_Package_Item__c> lstVSPI_1=[
            select id, name, CreatedDate, CreatedBy.name, 
                    product__r.name,
                    Vehicle_Service_Package__r.name, 
                    Vehicle_Service_Package__r.Vehicle__c, 
                    Product__c

                from 
                    Vehicle_Service_Package_Item__c 
                Where
                    Vehicle_Service_Package__r.Vehicle__c=:rq.Repair__r.Vehicle__c
                    and Product__c=:productCodeId
                    and (StartDate__c<=:dtRef or StartDate__c=null)
                    and (EndDate__c>=:dtRef or EndDate__c=null)          
                    and  Quantity_Available__c>0        
        ];

        System.debug('PackageRepairController.getListRedeemableItems===> list size='+lstVSPI_1.size());

        Map<String, Object> rmap = new Map<String, Object>();


        rmap.put('lstItemsRedeem', lstVSPI_1);

        return rmap;
    }


}  // end of class