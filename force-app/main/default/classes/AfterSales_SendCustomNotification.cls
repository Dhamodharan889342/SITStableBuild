/**
 * @author Daniel Varhidi
 * @date 18/01/2021
 * @description 
*/
global class AfterSales_SendCustomNotification {

	/**
	 * @description 
	 * @param title 
	 * @param body 
	 * @param notificationTypeId 
	 * @param targetId 
	 * @param recipientIdSet 
	 */
	public static void sendNotification(String title, String body, Id notificationTypeId, Id targetId, Set<String> recipientIdSet) {

		// Create a new custom notification
		Messaging.CustomNotification notification = new Messaging.CustomNotification();

		// Set the contents for the notification
		notification.setTitle(title);
		notification.setBody(body);

		// Set the notification type and target
		notification.setNotificationTypeId(notificationTypeId);
		notification.setTargetId(targetId);
		//Send 
		notification.send(recipientIdSet);
	}

	/**
	 * @description 
	 * @param title 
	 * @param body 
	 * @param notificationTypeDeveloperName 
	 * @param targetIdString 
	 * @param employeeIdString 
	 */
	@InvocableMethod(label = 'Send Custom Notification' description = 'Send Custom Notification' category = 'Custom Notification')
	public static void sendSampleNotificationFromProcessBuilder(List<FlowInputsSampleNotification> request) {
		String title;
		String body;
		String notificationTypeDeveloperName;
		String targetIdString;
		Employee__c emp;
		Id userId;

		for (FlowInputsSampleNotification input : request) {
			emp = AfterSales_SendCustomNotification.getEmployeeById(Id.valueOf(input.employeeIdString));
			if (emp != null) {
				userId = AfterSales_SendCustomNotification.getRecipientIdByEmployee(emp);
				if (userId != null) {
					if (emp.EmploymentStatus__c != 'On Leave') {
						if (emp.Country__c == 'Germany' || emp.Country__c == 'Switzerland') {
							title = input.titleGerman;
							body = input.bodyGerman;
						} else {
							title = input.titleEnglish;
							body = input.bodyEnglis;
						}
					} else {
						if (emp.Representative__r.Country__c == 'Germany' || emp.Representative__r.Country__c == 'Switzerland') {
							title = input.titleGerman;
							body = input.bodyGerman;
						} else {
							title = input.titleEnglish;
							body = input.bodyEnglis;
						}
					}

					notificationTypeDeveloperName = input.notificationTypeDeveloperName;
					targetIdString = input.targetIdString;
					Id notificationTypeId = getNotificationIdTypeByDeveloperName(notificationTypeDeveloperName);
					Set<String> recIdSet = new Set<String> ();
					recIdSet.add(userId);
					AfterSales_SendCustomNotification.sendNotification(title, body, notificationTypeId, Id.valueOf(targetIdString), recIdSet);
				}
			}
		}

	}

	/**
	 * @description input details that comes to apex from flow
	 */
	public class FlowInputsSampleNotification {

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
		public String employeeIdString;

	}

	/**
	 * @description 
	 * @param devName 
	 * @return 
	 */
	public static Id getNotificationIdTypeByDeveloperName(String devName) {
		CustomNotificationType notificationType = [
		                                           SELECT Id, DeveloperName
		                                           FROM CustomNotificationType
		                                           WHERE DeveloperName = :devName
		                                          ];
		return notificationType.Id;
	}


	/**
	 * @description 
	 * @param u 
	 * @return 
	 */
	public static Id getRecipientIdByEmployee(Employee__c u) {
		System.debug('AfterSales_SendCustomNotification > getRecipientIdByEmployeeId > u: ' + u);
		if (u.EmploymentStatus__c == 'Inactive') {
			return null;
		} else if (u.EmploymentStatus__c == 'On Leave' && u.Representative__c != null && u.Representative__r.User__c != null) {
			return u.Representative__r.User__c;
		}

		return u.User__c;
	}

	/**
	 * @description 
	 * @param employeeId 
	 */
	public static Employee__c getEmployeeById(Id employeeId) {
		System.debug('AfterSales_SendCustomNotification > getEmployeeById > employeeId: ' + employeeId);
		List<Employee__c> empList = [
		                             SELECT Id, User__c, EmploymentStatus__c, Country__c,
		                             Representative__c, Representative__r.User__c, Representative__r.Country__c
		                             FROM Employee__c
		                             WHERE Id = :employeeId
		                            ];
		if (!empList.isEmpty()) {
			return empList.get(0);
		}
		return null;
	}


}