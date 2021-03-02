/*Created By Mayank Pant
Purpose: This class will post the chatter message to Job order record owner.*/
global class AfterSales_JobOrder_CreateChatterPost {
   
   /* Invocable method is called from the flow when user clicks on Done button*/
   @InvocableMethod
   public static Void createChatterPost(List<Id> jobOrderId) {
        WorkOrder wo = new WorkOrder();
        wo = [SELECT ID,ownerid,ChatterPostMessage__c,workordernumber FROM WORKORDER 
             WHERE ID = :jobOrderId limit 1];
        FeedItem post = new FeedItem();
        post.ParentId = wo.ownerid;
        post.Body = wo.ChatterPostMessage__c;
        post.isrichtext = true;
        insert post;
   }
}