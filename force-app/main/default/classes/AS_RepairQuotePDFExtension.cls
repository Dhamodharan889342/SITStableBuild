/*
 Author: Neha Aggrawal
Created Date: 02-02-2020
Story:https://jira.hyundai-autoever.eu/browse/GD-1015
*/

public class AS_RepairQuotePDFExtension {
    public list<VehicleWrapper> recordlist { get; set;}
    private static Set<Id> repairQuoteSectionSet=new Set<Id>();
   private static List<Repair_Quote_Line_Item__c> RepairQuoteLineList = new List<Repair_Quote_Line_Item__c>();
    List<RepairQuotesectionWrapper> RepairQuotesectionWrapperList { get; set;}
    private final RepairQuote__c repairQuote;
    private static Map<String,Integer> mapRpr = new Map<String,Integer>();
    
    public AS_RepairQuotePDFExtension(ApexPages.StandardController stdController){
        this.repairQuote=(RepairQuote__c)stdController.getRecord();
        for(Repair_Quote_Section__c rqc:[Select Id, Name from Repair_Quote_Section__c where RepairQuote__c=:repairQuote.Id])
		 repairQuoteSectionSet.add(rqc.Id);
           RepairQuoteLineList= [Select Id, LineItemType__c,Total_Price_VAT_excluded__c, Total_Price_VAT_included__c, Repair_Quote_Section__r.Name,Repair_Quote_Section__r.Id, Name,Hours__c,ListPrice__c, Quantity__c,Discount_in_Percentage__c, Tax_in_Percentage__c from Repair_Quote_Line_Item__c where Repair_Quote_Section__c in: repairQuoteSectionSet];                
        List<AggregateResult> RepairQuoteLineItemSize=[Select Repair_Quote_Section__r.Name rname, count(Id)ct from Repair_Quote_Line_Item__c where Repair_Quote_Section__c in: repairQuoteSectionSet group by Repair_Quote_Section__r.Name];
        
        for(AggregateResult aggResult : RepairQuoteLineItemSize)
                {
                  mapRpr.put((String)aggResult.get('rname'), (Integer)aggResult.get('ct'));
                }
        System.debug(mapRpr);
    }
public Boolean getrenderrepairQuoteLinemap(){
    if(repairQuoteLineItemMap.size()!=0)
        return true;
    else
        return false;
}
 public Boolean getrendersubtotoalmap(){
    if(SubtotalMap.size()!=0)
        return true;
     else
         return false;
}   
    public map<String,List<Repair_Quote_Line_Item__c>> repairQuoteLineItemMap{
        get {
            Map<String,List<Repair_Quote_Line_Item__c>> rprline=new Map<String,List<Repair_Quote_Line_Item__c>>();
            System.debug(rprline);
				if(RepairQuoteLineList.size()!=0)
                    for(Repair_Quote_Line_Item__c rqli:RepairQuoteLineList)
                    { 
             		  if (rprline.containsKey(rqli.Repair_Quote_Section__r.Name))
                        
                        rprline.get(rqli.Repair_Quote_Section__r.Name).add(rqli);
                        
                        else
                       rprline.put(rqli.Repair_Quote_Section__r.Name, new  List <Repair_Quote_Line_Item__c> { rqli });
                    }
                	System.debug(rprline);
						 return rprline;      
           }
         set;
          }
    //wrapper class to get vehicle and vehicle model information
    public list<VehicleWrapper> getvehicleinfo(){
        recordlist = new List<VehicleWrapper>();
        Id	 astId =[Select Repair__r.Vehicle__c from RepairQuote__c where Id =:repairQuote.Id].Repair__r.Vehicle__c;
        for(Asset ast: [Select Id,Account.Name, Account.PersonMailingCountry,Account.Account_Number__c,Account.PersonMailingStreet, Account.PersonMailingCity, Account.PersonMailingState, Account.PersonMailingPostalCode, Account.PersonMobilePhone, Account.PersonHomePhone, Account.PersonEmail, Vehicle_Model_LTM__r.Model__c,Vehicle_Model_LTM__r.Engine_Capacity__c,Model_Year__c,
                        Vehicle_Model_LTM__r.Fuel_Type__c,Color__c,
                         Latest_Mileage__c, Licence_plate_after_registration__c,Sales_Trim__c, VIN__c,Expiration_date__c,Date_of_Registration__c from Asset where Id =:astId] )
        {
            recordlist.add(new VehicleWrapper(ast));
        }
        System.debug(recordlist);
        return recordlist;
        
    }

      public List<RepairQuotesectionWrapper> getRepairQuoteSectioninfo(){
        RepairQuotesectionWrapperList = new List<RepairQuotesectionWrapper>();
           for(Repair_Quote_Section__c rqs:[Select Id, Name from Repair_Quote_Section__c where RepairQuote__c=:repairQuote.Id])
        {
            if(mapRpr.containsKey(rqs.name))
                        RepairQuotesectionWrapperList.add(new RepairQuotesectionWrapper(rqs));
        }    
          return RepairQuotesectionWrapperList;
    }
    
	public map<String,List<Decimal>> SubtotalMap{
        get {
                            Map<String,List<Decimal>> SubtotalMap=new Map<String, List<Decimal>>();
            			if(RepairQuoteLineList.size()!=0)
                            for(Repair_Quote_Line_Item__c rqli:RepairQuoteLineList)
                            { 
                     		 if (SubtotalMap.containsKey(rqli.Repair_Quote_Section__r.Name))
                                {
                                    Decimal totalPricevat=(SubtotalMap.get(rqli.Repair_Quote_Section__r.Name)[3]+rqli.Total_Price_VAT_included__c).setScale(2);
                                    Decimal totalPriceexcludeVat=(SubtotalMap.get(rqli.Repair_Quote_Section__r.Name)[0]+rqli.Total_Price_VAT_excluded__c).setScale(2);
                                    Decimal taxAmt=(totalPricevat-totalPriceexcludeVat).setScale(2);
                                    Decimal taxPercentage=0;
                                    if(totalPriceexcludeVat!=0)
                                    taxPercentage=(((totalPricevat/totalPriceexcludeVat)-1)*100).setScale(2);
                                    Decimal totaleuros=(totalPriceexcludeVat+taxAmt).setScale(2);
                                    List<Decimal> tempList = new List<Decimal>{totalPriceexcludeVat,taxPercentage,taxAmt,totaleuros};
                                  
                                    SubtotalMap.get(rqli.Repair_Quote_Section__r.Name).clear();
                                     SubtotalMap.put(rqli.Repair_Quote_Section__r.Name,tempList); 
                                }
                                else
                                {
                                    Decimal taxAmt=(rqli.Total_Price_VAT_included__c-rqli.Total_Price_VAT_excluded__c).setScale(2);
                                    Decimal taxPercentage=0;
                                    if(rqli.Total_Price_VAT_excluded__c!=0)
                                    taxPercentage=(((rqli.Total_Price_VAT_included__c/rqli.Total_Price_VAT_excluded__c)-1)*100).setScale(2);
                                    Decimal totaleuros=(rqli.Total_Price_VAT_excluded__c+taxAmt).setScale(2);
                                    List<Decimal> tempList = new List<Decimal>{rqli.Total_Price_VAT_excluded__c,taxPercentage,taxAmt,totaleuros};
                                    SubtotalMap.put(rqli.Repair_Quote_Section__r.Name,tempList);
                               
                                }
                            }
                            System.debug(SubtotalMap);
                            return SubtotalMap;
    }
	set;
 }
    public list<Decimal> getGrandTotal(){
        List<Decimal>Grandtotal =new List<Decimal>();
        Decimal TotalNet=0;
        Decimal TotalTaxAmt=0;
        Decimal GrandTotalEuors=0;
        Decimal GrandTaxPer=null;
        for(String key:SubtotalMap.keyset())
        {
            TotalNet +=SubtotalMap.get(key)[0];
            TotalTaxAmt +=SubtotalMap.get(key)[2];
            GrandTotalEuors +=SubtotalMap.get(key)[3];
        }
        Grandtotal.add(TotalNet);
        Grandtotal.add(GrandTaxPer);
        Grandtotal.add(TotalTaxAmt);
        Grandtotal.add(GrandTotalEuors);
        
        System.debug(GrandTotal);
        return GrandTotal;
    }    
    
public class VehicleWrapper {
public Asset record  { get; set;}
        public VehicleWrapper(Asset record){
            this.record = record;
           
        }
}


public class RepairQuotesectionWrapper {
public Repair_Quote_Section__c record  { get; set;}
        public RepairQuotesectionWrapper(Repair_Quote_Section__c record){
            this.record = record;
           
        }     
}
    
   
}