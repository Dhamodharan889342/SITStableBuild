/**
 * @author Daniel Varhidi
 * @Date 15/01/2021
 * @JIRA GD-2170, GD-2173
 * @description 
*/
public class AfterSales_AssignGTAToAccount {

	public static void assignNearestDepartment(List<Account> newItems, List<Account> oldItems) {
		List<Account> accountSelected = new List<Account> ();
		Map<Id, Account> oldItemMap = new Map<Id, Account> (oldItems);
		//Collect the relevant accounts for upate
		for (Account newItem : newItems) {
			if (newItem.Department__c == null) {
				Account oldItem = oldItemMap.get(newItem.Id);
				//Person Account
				if (newItem.IsPersonAccount &&
				    newItem.Customer_type__pc == 'Owner' && oldItem.Customer_type__pc != 'Owner'
				) {
					accountSelected.add(newItem);
				}
				//Business Account
				/*if (!newItem.IsPersonAccount &&
				  (newItem.BillingLatitude != oldItem.BillingLatitude || newItem.BillingLongitude != oldItem.BillingLongitude) &&
				  newItem.Customer_type__c == 'Owner' && oldItem.Customer_type__c != 'Owner'
				  ) {
				  accountSelected.add(newItem);
				  }*/
			}
		}

		if (!accountSelected.isEmpty()) {
			Id serviceCenterRecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service_Center').getRecordTypeId();
			//get the departments
			List<Department__c> departmentList = [
			                                      SELECT Id, Name, Country__c, Geolocation__Latitude__s, Geolocation__Longitude__s
			                                      FROM Department__c
			                                      WHERE Geolocation__Latitude__s != null
			                                      AND Geolocation__Longitude__s != null
			                                      AND RecordTypeId = :serviceCenterRecordTypeId];

			//getDistance
			if (!departmentList.isEmpty()) {
				List<Account> accountAssignedGTAList = new List<Account> ();
				//get closest Department
				for (Account accItem : accountSelected) {
					if (accItem.PersonMailingLatitude != null && accItem.PersonMailingLongitude != null) {
						Double minDistance = null;
						Department__c minDistanceDepartment;
						Location accLocation;
						/*if (!accItem.IsPersonAccount) {
						  accLocation = Location.newInstance(accItem.BillingLatitude, accItem.BillingLongitude);
						  } else {
						  accLocation = Location.newInstance(accItem.PersonMailingLatitude, accItem.PersonMailingLongitude);
						  }*/
						accLocation = Location.newInstance(accItem.PersonMailingLatitude, accItem.PersonMailingLongitude);
						System.debug('GME_AccountTriggerHandler > AfterUpdate > assignNearestDepartment > accLocation: ' + accLocation);
						for (Department__c depItem : departmentList) {
							//System.debug('GME_AccountTriggerHandler > AfterUpdate > assignNearestDepartment > minDistanceDepartment: ' + minDistanceDepartment);
							//System.debug('GME_AccountTriggerHandler > AfterUpdate > assignNearestDepartment > minDistance: ' + minDistance);
							//System.debug('GME_AccountTriggerHandler > AfterUpdate > assignNearestDepartment > depItem.Name: ' + depItem.Name);
							Location depLocation = Location.newInstance(depItem.Geolocation__Latitude__s, depItem.Geolocation__Longitude__s);
							//System.debug('GME_AccountTriggerHandler > AfterUpdate > assignNearestDepartment > depLocation: ' + depLocation);
							Double currentDistance = System.Location.getDistance(accLocation, depLocation, 'km');
							//System.debug('GME_AccountTriggerHandler > AfterUpdate > assignNearestDepartment > currentDistance: ' + currentDistance);

							//Check minDistance
							if (minDistance == null) {
								System.debug('GME_AccountTriggerHandler > AfterUpdate > assignNearestDepartment > minDistance == null ');
								minDistance = currentDistance;
								minDistanceDepartment = depItem;
							} else if (currentDistance <= minDistance) {
								minDistance = currentDistance;
								minDistanceDepartment = depItem;
							}

						}
						if (minDistanceDepartment != null) {
							accItem.Department__c = minDistanceDepartment.Id;
							accountAssignedGTAList.add(accItem);
						}

					}
				}

				//update Account
				if (!accountAssignedGTAList.isEmpty()) {
					assignGTAFromNearestDepartment(accountAssignedGTAList);
				}
			}
		}
	}

	public static void assignGTAFromNearestDepartment(List<Account> accList) {
		Set<Id> departmentIdSet = new Set<Id> ();
		Set<Id> accountIdSet = new Set<Id> ();
		for (Account accItem : accList) {
			if (accItem.Department__c != null) {
				departmentIdSet.add(accItem.Department__c);
				accountIdSet.add(accItem.Id);
			}
		}
		//System.debug('GME_AccountTriggerHandler > AfterUpdate  > assignGTAFromNearestDepartment > departmentIdSet.size(): ' + departmentIdSet.size());

		if (!departmentIdSet.isEmpty()) {
			//get GTA List per department
			Map<Id, List<GTA__c>> gtaGroupByDepartment = getGtaGroupByDepartment(departmentIdSet);
			//get NSC Aftersales manager per department
			Map<Id, Id> departmentNSCAfterSalesmanager = getNSCAftersalesMangers(gtaGroupByDepartment.keySet()); // key = departmentId, value = Department__r.NSC_Aftersales_Manager__c

			for (Account accItem : accList) {
				//System.debug('GME_AccountTriggerHandler > AfterUpdate  > assignGTAFromNearestDepartment > accItem.Name: ' + accItem.Name);
				//System.debug('GME_AccountTriggerHandler > AfterUpdate  > assignGTAFromNearestDepartment > accItem.Department__c: ' + accItem.Department__c);
				if (accItem.Department__c != null) {
					if (gtaGroupByDepartment.containsKey(accItem.Department__c)) {
						List<GTA__c> currentGTAList = gtaGroupByDepartment.get(accItem.Department__c);
						//System.debug('GME_AccountTriggerHandler > AfterUpdate  > assignGTAFromNearestDepartment > currentGTAList.size(): ' + currentGTAList.size());
						if (currentGTAList.size() == 1 && accItem.Assigned_GTA__c == null) {
							//System.debug('GME_AccountTriggerHandler > AfterUpdate  > assignGTAFromNearestDepartment > currentGTAList.get(0).Employee__r.Id: ' + currentGTAList.get(0).Employee__r.Id);
							accItem.Assigned_GTA__c = currentGTAList.get(0).Employee__r.Id;
						} else if (departmentNSCAfterSalesmanager.containsKey(accItem.Department__c)) {
							//System.debug('departmentNSCAfterSalesmanager.containsKey(accItem.Department__c)');
							//Notify the NSC Aftersales Manager
							List<AfterSales_SendCustomNotification.FlowInputsSampleNotification> inputList = new List<AfterSales_SendCustomNotification.FlowInputsSampleNotification> ();
							AfterSales_SendCustomNotification.FlowInputsSampleNotification input = new AfterSales_SendCustomNotification.FlowInputsSampleNotification();
							input.titleEnglish = System.Label.Custom_Notification_New_Customer_without_GTA_Title;
							input.bodyEnglis = System.Label.Custom_Notification_New_Customer_without_GTA_Body;
							input.titleGerman = System.Label.Custom_Notification_New_Customer_without_GTA_Title_GERMAN;
							input.bodyGerman = System.Label.Custom_Notification_New_Customer_without_GTA_Body_GERMAN;
							input.targetIdString = String.valueOf(accItem.Id);
							input.employeeIdString = String.valueOf(departmentNSCAfterSalesmanager.get(accItem.Department__c));
							input.notificationTypeDeveloperName = 'sendAccountNotification';
							inputList.add(input);
							AfterSales_SendCustomNotification.sendSampleNotificationFromProcessBuilder(inputList);

						}

					} else if (departmentNSCAfterSalesmanager.containsKey(accItem.Department__c)) {
						//System.debug('departmentNSCAfterSalesmanager.containsKey(accItem.Department__c)');
						//Notify the NSC Aftersales Manager
						List<AfterSales_SendCustomNotification.FlowInputsSampleNotification> inputList = new List<AfterSales_SendCustomNotification.FlowInputsSampleNotification> ();
						AfterSales_SendCustomNotification.FlowInputsSampleNotification input = new AfterSales_SendCustomNotification.FlowInputsSampleNotification();
						input.titleEnglish = System.Label.Custom_Notification_New_Customer_without_GTA_Title;
						input.bodyEnglis = System.Label.Custom_Notification_New_Customer_without_GTA_Body;
						input.titleGerman = System.Label.Custom_Notification_New_Customer_without_GTA_Title_GERMAN;
						input.bodyGerman = System.Label.Custom_Notification_New_Customer_without_GTA_Body_GERMAN;
						input.targetIdString = String.valueOf(accItem.Id);
						input.employeeIdString = String.valueOf(departmentNSCAfterSalesmanager.get(accItem.Department__c));
						input.notificationTypeDeveloperName = 'sendAccountNotification';
						inputList.add(input);
						AfterSales_SendCustomNotification.sendSampleNotificationFromProcessBuilder(inputList);

					}
				}
			}
		}
	}

	private static Map<Id, List<GTA__c>> getGtaGroupByDepartment(Set<Id> departmentIdSet) {
		List<GTA__c> gtaActiveList = [
		                              SELECT Id, Employee__r.Id, Department__c, Department__r.NSC_Aftersales_Manager__c
		                              FROM GTA__c
		                              WHERE Department__c IN :departmentIdSet
		                              AND Employee__r.EmploymentStatus__c != 'Inactive'
		                              AND IsPrimary__c = true
		                              LIMIT 1
		                             ];

		//gtaGroupByDepartment
		Map<Id, List<GTA__c>> gtaGroupByDepartment = new Map<Id, List<GTA__c>> ();
		for (GTA__c item : gtaActiveList) {
			List<GTA__c> cont = new List<GTA__c> ();
			if (gtaGroupByDepartment.containsKey(item.Department__c)) {
				cont.addAll(gtaGroupByDepartment.get(item.Department__c));
			}
			cont.add(item);
			gtaGroupByDepartment.put(item.Department__c, cont);
			//departmentNSCAfterSalesmanager.put(item.Department__c, item.Department__r.NSC_Aftersales_Manager__c);
		}

		// add department without gta to gtaGroupByDepartment
		for (Id depId : departmentIdSet) {
			if (!gtaGroupByDepartment.containsKey(depId)) {
				List<GTA__c> cont = new List<GTA__c> ();
				gtaGroupByDepartment.put(depId, cont);
			}
		}
		return gtaGroupByDepartment;
	}

	/**
	 * @description 
	 * @param depIdSet 
	 * @return Department ID - NSC Aftersales Manager ID
	 */
	private static Map<Id, Id> getNSCAftersalesMangers(Set<Id> depIdSet) {
		List<Department__c> depList = [
		                               SELECT Id, NSC_Aftersales_Manager__c
		                               FROM Department__c
		                               WHERE Id IN :depIdSet
		                               AND NSC_Aftersales_Manager__c != null
		                              ];
		Map<Id, Id> retVal = new Map<Id, Id> (); // key = departmentId, value = Department__r.NSC_Aftersales_Manager__c
		for (Department__c item : depList) {
			retVal.put(item.Id, item.NSC_Aftersales_Manager__c);
		}
		return retVal;
	}

	/**
	* @description If inactivate an Employee, the system check is there any other Primary GTA. If yes, assign the GTA to the inactivated GTA's accounts
	* @param newItems 
	* @param oldItems 
	*/ 
	public static void assignOtherGTAToAccount(Map<Id, Employee__c> newItems, Map<Id, Employee__c> oldItems) {
		List<Account> accountUpdate = new List<Account> ();
		//Collect relevant Employee record
		Map<Id, Employee__c> inactivatedGTAMap = new Map<Id, Employee__c> ();
		for (Id i : newItems.keySet()) {
			Employee__c newItem = newItems.get(i);
			Employee__c oldItem = oldItems.get(i);
			if (newItem.EmploymentStatus__c == 'Inactive' && oldItem.EmploymentStatus__c != 'Inactive' && newItem.Role__c == 'GTA') {
				inactivatedGTAMap.put(newItem.Id, newItem);
			}
		}

		if (!inactivatedGTAMap.isEmpty()) {
			//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > !inactivatedGTAMap.isEmpty()');
			//Select the related accounts
			List<Account> accountList = [
			                             SELECT Id, Assigned_GTA__c, Department__c
			                             FROM Account
			                             WHERE Assigned_GTA__c IN :inactivatedGTAMap.keySet()
			                            ];
			if (!accountList.isEmpty()) {
				//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > !accountList.isEmpty()');
				//Collect the Departments from Accounts
				Set<Id> departmentIdSet = new Set<Id> ();
				for (Account accItem : accountList) {
					departmentIdSet.add(accItem.Department__c);
				}
				//Seelct the related GTAs from junction object
				List<GTA__c> gtaJunctionList = [
				                                SELECT Id, Department__c, Employee__c
				                                FROM GTA__c
				                                WHERE Department__c IN :departmentIdSet
				                                AND Employee__r.EmploymentStatus__c != 'Inactive'
				                                AND IsPrimary__c = true
				                                LIMIT 1
				                               ];

				if (!gtaJunctionList.isEmpty()) {
					//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > !gtaJunctionList.isEmpty()');
					//Group GTAs by Department
					Map<Id, List<GTA__c>> gtaJunctionGroupedByDepartment = new Map<Id, List<GTA__c>> (); //Id = Department__c
					for (GTA__c item : gtaJunctionList) {
						List<GTA__c> cont = new List<GTA__c> ();
						if (gtaJunctionGroupedByDepartment.containsKey(item.Department__c)) {
							cont.addAll(gtaJunctionGroupedByDepartment.get(item.Department__c));
						}
						cont.add(item);
						gtaJunctionGroupedByDepartment.put(item.Department__c, cont);
					}
					//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > gtaJunctionGroupedByDepartment.size(): ' + gtaJunctionGroupedByDepartment.size());

					//Group Account by AssignedGTA
					Map<Id, List<Account>> accountGroupedByAssignedGTA = new Map<Id, List<Account>> (); //Id = AssignedGTA
					for (Account item : accountList) {
						List<Account> cont = new List<Account> ();
						if (accountGroupedByAssignedGTA.containsKey(item.Assigned_GTA__c)) {
							cont.addAll(accountGroupedByAssignedGTA.get(item.Assigned_GTA__c));
						}
						cont.add(item);
						accountGroupedByAssignedGTA.put(item.Assigned_GTA__c, cont);
					}
					//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > accountGroupedByAssignedGTA.size(): ' + accountGroupedByAssignedGTA.size());

					for (Id i : inactivatedGTAMap.keyset()) {
						Employee__c inactivatedGTA = inactivatedGTAMap.get(i);
						if (accountGroupedByAssignedGTA.containsKey(inactivatedGTA.Id)) {
							//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > accountGroupedByAssignedGTA.containsKey(inactivatedGTA.Id)');
							//Account List that relates to inactivated GTA
							List<Account> inactivatedGTAAccountList = accountGroupedByAssignedGTA.get(inactivatedGTA.Id);
							for (Account accItem : inactivatedGTAAccountList) {
								if (gtaJunctionGroupedByDepartment.containsKey(accItem.Department__c)) {
									//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > gtaJunctionGroupedByDepartment.containsKey(accItem.Department__c)');
									//GTA list that relates to department of account
									List<GTA__c> gtaList = gtaJunctionGroupedByDepartment.get(accItem.Department__c);
									if (!gtaList.isEmpty()) {
										//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > !gtaList.isEmpty()');
										//Assigned the first GTA of the List to Account
										accItem.Assigned_GTA__c = gtaList.get(0).Employee__c;
										//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > accItem.Assigned_GTA__c: ' + accItem.Assigned_GTA__c);
										accountUpdate.add(accItem);
									}
								}
							}
						}
					}
				}
			}
		}
		if (!accountUpdate.isEmpty()) {
			//System.debug('GME_EmployeeTriggerHandler > assignOtherGTAToAccount > !accountUpdate.isEmpty()');
			update accountUpdate;
		}
	}
}