/**
 * @author Daniel Varhidi
 * @description 
 * @created 21/01/2021
*/
public class AfterSales_SendCustNotiHandler_GTAofDep {

	/**
	 * @description 
	 * @param request 
	 */
	@InvocableMethod(label = 'Send Custom Notification to GTA of Department' description = 'Send Custom Notification' category = 'Custom Notification')
	public static void sendNotificationFromProcessBuilderToGTAofDepartment(List<FlowInputs> request) {

		for (FlowInputs input : request) {
			GTA__c gta = AfterSales_SendCustNotiHandler_GTAofDep.getGTAEmployeeFromDepartmentId(input.servicecenterIdString);
			if (gta != null) {
				List<AfterSales_SendCustomNotification.FlowInputsSampleNotification> sampleNotiInputList = new List<AfterSales_SendCustomNotification.FlowInputsSampleNotification> ();
				AfterSales_SendCustomNotification.FlowInputsSampleNotification sampleNotiInput = new AfterSales_SendCustomNotification.FlowInputsSampleNotification();
				sampleNotiInput.titleEnglish = input.titleEnglish;
				sampleNotiInput.bodyEnglis = input.bodyEnglis;
				sampleNotiInput.titleGerman = input.titleGerman;
				sampleNotiInput.bodyGerman = input.bodyGerman;
				sampleNotiInput.notificationTypeDeveloperName = input.notificationTypeDeveloperName;
				sampleNotiInput.targetIdString = input.targetIdString;
				sampleNotiInput.employeeIdString = String.valueOf(AfterSales_SendCustomNotification.getEmployeeById(gta.Employee__r.Id).Id);
				sampleNotiInputList.add(sampleNotiInput);
				AfterSales_SendCustomNotification.sendSampleNotificationFromProcessBuilder(sampleNotiInputList);
			}
		}

	}

	/**
	 * @description input details that comes to apex from flow
	 */
	public class FlowInputs {

		@InvocableVariable
		public String titleEnglish;

		@InvocableVariable
		public String bodyEnglis;

		@InvocableVariable
		public String titleGerman;

		@InvocableVariable
		public String bodyGerman;

		@InvocableVariable
		public String notificationTypeDeveloperName;

		@InvocableVariable
		public String targetIdString;

		@InvocableVariable
		public String servicecenterIdString;

	}

	/**
	 * @description 
	 * @param servicecenterIdString 
	 * @return 
	 */
	public static GTA__c getGTAEmployeeFromDepartmentId(String servicecenterIdString) {
		List<GTA__c> gtaList = [
		                        SELECT Id, Employee__r.Id
		                        FROM GTA__c
		                        WHERE Department__c = :servicecenterIdString
		                        AND Employee__r.Role__c != 'Inactive'
                				AND IsPrimary__c = True
		                        LIMIT 1
		                       ];
		if (!gtaList.isEmpty()) {
			return gtaList.get(0);
		}
		return null;
	}
}