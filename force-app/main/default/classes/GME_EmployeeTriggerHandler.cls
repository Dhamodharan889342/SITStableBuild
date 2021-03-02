public class GME_EmployeeTriggerHandler implements GME_ITriggerHandler {

	public static Boolean TriggerDisabled = false;

	public Boolean IsDisabled()
	{
		if (GME_TriggerSettings__c.getOrgDefaults().EmployeeTriggerDisabled__c == true) {
			return true;
		}
		else {
			return TriggerDisabled;
		}
	}

	public void BeforeInsert(List<SObject> newItems) { }

	public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

	public void BeforeDelete(Map<Id, SObject> oldItems) {
		if (!IsDisabled() && oldItems.size() == 1) {
			Employee__c e = (Employee__c) oldItems.values() [0];
			GME_EmployeeTriggerHandler.removeUserAccountTeamMembers(e.User__c);
		}
	}

	public void AfterInsert(Map<Id, SObject> newItems) {
		if (!IsDisabled() && newItems.size() == 1) {
			this.createAccountTeamMembers((Employee__c) newItems.values() [0], null);

			this.createUserSharing((Employee__c) newItems.values() [0]);
			addToPublicGroup(newItems.values());

			CXP_EmployeeCallout.sendRecordToDIH(newItems.keySet()); // Added as part of ERP interfaces making callouts to DIH
			System.debug('Future method called for the inserted Employee record');
		}
	}

	public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
		if (!IsDisabled() && newItems.size() == 1) {
			this.createAccountTeamMembers((Employee__c) newItems.values() [0], (Employee__c) oldItems.values() [0]);
			AfterSales_AssignGTAToAccount.assignOtherGTAToAccount((Map<Id, Employee__c>) newItems, (Map<Id, Employee__c>) oldItems); //GD-2170, GD-2173

			// Added as part of ERP interfaces making callouts to DIH			
			if (isRecordChanged((Employee__c) newItems.values() [0], (Employee__c) oldItems.values() [0])) {
				System.debug('Future method called for the updated Employee record');
				CXP_EmployeeCallout.sendRecordToDIH(newItems.keySet());				              
			}
			else {
				System.debug('Future method was not called because no values were changed in the Employee record');
			}

		}
	}

	public void AfterDelete(Map<Id, SObject> oldItems) {
		if (!IsDisabled() && oldItems.size() == 1) {
			this.removeAccountTeamMembers(((Employee__c) oldItems.values() [0]));
		}
	}

	public void AfterUndelete(Map<Id, SObject> oldItems) { }

	public void createUserSharing(Employee__c newEmployee) {
		try {
			List<Employee__c> Employees = new List<Employee__c> ([SELECT Id, User__c FROM Employee__c WHERE Department__c = :newEmployee.Department__c AND Role__c = 'Store Manager' limit 1]);

			Employee__c storeManager = Employees[0];

			UserShare us = new UserShare(UserAccessLevel = 'Read', UserOrGroupId = storeManager.User__c, UserId = newEmployee.User__c);
			insert us;


		} catch(Exception e) {
			System.debug('Exception: ' + e);
		}
	}

	public void createAccountTeamMembers(Employee__c newEmployee, Employee__c oldEmployee) {
		if (newEmployee.User__c != null && newEmployee.Department__c != null) {
			if (oldEmployee == null) {
				this.addAccountTeamMembers(newEmployee);
				GME_EmployeeTriggerHandler.createUserAccountTeamMembers(newEmployee.Department__c, newEmployee.User__c);
			}
			else if (oldEmployee.Department__c == null && newEmployee.Department__c != null) {
				GME_EmployeeTriggerHandler.createUserAccountTeamMembers(newEmployee.Department__c, newEmployee.User__c);
			}
			else if (oldEmployee.Department__c != newEmployee.Department__c) {
				GME_EmployeeTriggerHandler.createUserAccountTeamMembers(newEmployee.Department__c, newEmployee.User__c);
				this.removeAccountTeamMembers(oldEmployee);
				this.addAccountTeamMembers(newEmployee);
				List<UserAccountTeamMember> listUATM = new List<UserAccountTeamMember> ([SELECT Id FROM UserAccountTeamMember WHERE UserId = :oldEmployee.User__c OR OwnerId = :oldEmployee.User__c]);
				if (listUATM.size() > 0) {
					GME_EmployeeTriggerHandler.removeUserAccountTeamMembers(oldEmployee.User__c);
				}
			}
		}
	}

	@future
	public static void createUserAccountTeamMembers(Id departmentId, Id employeeUserId) {
		try {
			List<Employee__c> employees = new List<Employee__c> ([SELECT Department__c, User__c, Role__c FROM Employee__c WHERE Department__c = :departmentId AND User__c != :employeeUserId]);
			Employee__c currentEmployee = [SELECT Role__c FROM Employee__c WHERE Department__c = :departmentId AND User__c = :employeeUserId LIMIT 1];

			Flow.Interview.Create_User_AccountTeam_Member_2 myFlow =
			new Flow.Interview.Create_User_AccountTeam_Member_2(
			                                                    new map<String, Object> { 'Employee_Collection' => employees, 'UserId_CurrentUser' => employeeUserId, 'Role_CurrentUser' => currentEmployee.Role__c }
			);

			myFlow.start();
		} catch(Exception e) {
			System.debug('Exception: ' + e);
		}
	}

	@future
	public static void removeUserAccountTeamMembers(Id employeeUserId) {
		try {
			Flow.Interview.delete_UserAccountTeamMember myFlow =
			new Flow.Interview.delete_UserAccountTeamMember(
			                                                new map<String, Object> { 'UserId_CurrentUser' => employeeUserId }
			);

			myFlow.start();
		} catch(Exception e) {
			System.debug('Exception: ' + e);
		}
	}

	public void removeAccountTeamMembers(Employee__c oldEmployee) {
		try {
			delete[SELECT Id FROM AccountTeamMember WHERE Account.PreferredFacility__c = : oldEmployee.Department__c AND UserId = : oldEmployee.User__c];
		} catch(Exception e) {
			System.debug('Exception: ' + e);
		}
	}

	public void addAccountTeamMembers(Employee__c newEmployee) {
		System.debug('Adding new AccountTeamMembers...');
		List<AccountTeamMember> newTeams = new List<AccountTeamMember> ();

		for (Account acc :[SELECT Id FROM Account WHERE PreferredFacility__c = :newEmployee.Department__c]) {
			newTeams.add(
			             new AccountTeamMember(
			                                   AccountId = acc.Id,
			                                   UserId = newEmployee.User__c,
			                                   TeamMemberRole = newEmployee.Role__c,
			                                   AccountAccessLevel = 'Read',
			                                   OpportunityAccessLevel = 'None',
			                                   CaseAccessLevel = 'None',
			                                   ContactAccessLevel = 'Read'
			)
			);
		}

		insert newTeams;
		System.debug('Teams added: ' + newTeams);
	}

	public static void addToPublicGroup(List<Employee__c> newEmps) {
		Set<Id> empIds = new Set<Id> ();
		for (Employee__c emp : newEmps) {
			empIds.add(emp.Id);
		}
		addToPublicGroupFuture(empIds);
	}

	@future
	private static void addToPublicGroupFuture(Set<Id> empIds) {
		Set<Id> groupIds = new Set<Id> ();
		Set<Id> departmentIds = new Set<Id> ();
		List<GroupMember> listGroupMember = new List<GroupMember> ();
		List<Employee__c> newEmps = [SELECT Id, Department__c, User__c FROM Employee__c WHERE Id IN :empIds];

		for (Employee__c emp : newEmps) {
			departmentIds.add(emp.Department__c);
		}
		for (Department__c dep :[SELECT Id, Department_Public_Group_Id__c FROM Department__c WHERE Id IN :departmentIds]) {
			for (Employee__c emp : newEmps) {
				if (dep.Department_Public_Group_Id__c != null && dep.Id == emp.Department__c) {
					GroupMember gm = new GroupMember();
					gm.GroupId = dep.Department_Public_Group_Id__c;
					gm.UserOrGroupId = emp.User__c;
					listGroupMember.add(gm);
				}
			}
		}
		insert listGroupMember;
	}

	// Added as part of ERP interfaces making callouts to DIH
	public static Boolean isRecordChanged(Employee__c newRecord, Employee__c oldRecord) {
        
		if (newRecord.SalesCompanyCode__c != oldRecord.SalesCompanyCode__c || newRecord.SalesPersonCode__c != oldRecord.SalesPersonCode__c
		    || newRecord.name != oldRecord.name || newRecord.dealerCode__c != oldRecord.dealerCode__c
		    || newRecord.role__c != oldRecord.role__c || newRecord.department__c != oldRecord.department__c
		    || newRecord.jobPosition__c != oldRecord.jobPosition__c || newRecord.fm_Email__c != oldRecord.fm_Email__c
		    || newRecord.phone__c != oldRecord.phone__c || newRecord.blockFlag__c != oldRecord.blockFlag__c)
		return true;
		else
		return false;
	}

	
}