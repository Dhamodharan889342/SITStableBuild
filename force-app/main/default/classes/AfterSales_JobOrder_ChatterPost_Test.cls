/**/
@isTest
public class AfterSales_JobOrder_ChatterPost_Test {
    
    @testSetup
    public static void setup()
    {
   WorkOrder wo = new WorkOrder();
   insert wo;
    }
    
    static testmethod  void testWorkOrder(){
        test.starttest();
        List<ID> workOrderIds = new List<ID>();
         WorkOrder wo = new WorkOrder();
         insert wo;
            workOrderIds.add(wo.id);
        AfterSales_JobOrder_CreateChatterPost.createChatterPost(workOrderIds);
        test.stoptest();
            
    }
}