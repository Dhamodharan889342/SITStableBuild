/**
  Author: Neha Aggrawal
  Created Date: 18-01-2020
  Story:https://jira.hyundai-autoever.eu/browse/GD-1026
 */

public without sharing class AS_GeneratePDF {


	@AuraEnabled
	public static Map<String, Object> doInit(Map<String, Object> pmap) {
		Id recordId = (String) pmap.get('recordId');
		String recordtypename = '';
		String localName = recordId.getSobjectType().getDescribe().localName;
		if ('StatusConfirmation__c'.equals(localName)) {
			Id RecordtypeId = [SELECT Id, RecordtypeId FROM StatusConfirmation__c where Id = :recordId].RecordtypeId;
			recordtypename = [Select Id, Name from RecordType where Id = :RecordtypeId and SobjectType = 'StatusConfirmation__c'].Name;
		} else if ('Courtesy_Car_Contract__c'.equals(localName)) {
			Id RecordtypeId = [SELECT Id, RecordtypeId FROM Courtesy_Car_Contract__c where Id = :recordId].RecordtypeId;
			recordtypename = [Select Id, Name from RecordType where Id = :RecordtypeId and SobjectType = 'Courtesy_Car_Contract__c'].Name;
		}
		Map<String, Object> rmap = new Map<String, Object> ();


		// Custom Setting 이용.
		if ('StatusConfirmation__c'.equals(localName)) { // 상태확인서.
			rmap.put('initUrl', '/apex/AS_StatusConfirmationPDF?id=' + recordId + '&recordtypename=' + recordtypename);
		} /*else if ('Repair__c'.equals(localName)) { // 상세정비내역서
		   rmap.put('initUrl', '/apex/RepairDetailList?id=' + recordId);
		   } else if ('Invoice__c'.equals(localName)) { // 상세정비내역서
		   rmap.put('initUrl', '/apex/InvoicePDF?id=' + recordId);
		   } else if ('RepairQuote__c'.equals(localName)) { // 가견적서
		   rmap.put('initUrl', '/apex/RepairQuoteTempPDF?id=' + recordId);
		   } else if ('ServicePayment__c'.equals(localName)) {
		   rmap.put('initUrl', '/apex/PaymentReceiptPDF?id=' + recordId);
		   }*/ else if ('Courtesy_Car_Contract__c'.equals(localName)) {
			rmap.put('initUrl', '/apex/AS_CourtesyCarContractPDF?id=' + recordId + '&recordtypename=' + recordtypename);
		}

		return rmap;
	}

	@AuraEnabled
	public static Map<String, Object> doSavePDF(Map<String, Object> pmap) {
		System.debug('pmap :: ' + JSON.serialize(pmap));
		Id recordId = (String) pmap.get('recordId');
		String type = (String) pmap.get('type'); // delivery
		String recordtypename = '';
		String localName = recordId.getSobjectType().getDescribe().localName;
		// Custom Setting 이용.
		PageReference pdf = null;
		if ('StatusConfirmation__c'.equals(localName)) { // 상태확인서.
			Id RecordtypeId = [SELECT Id, RecordtypeId FROM StatusConfirmation__c where Id = :recordId].RecordtypeId;
			recordtypename = [Select Id, Name from RecordType where Id = :RecordtypeId and SobjectType = 'StatusConfirmation__c'].Name;
			pdf = Page.AS_StatusConfirmationPDF;
         
		} else if ('Courtesy_Car_Contract__c'.equals(localName)) {
			Id RecordtypeId = [SELECT Id, RecordtypeId FROM Courtesy_Car_Contract__c where Id = :recordId].RecordtypeId;
			recordtypename = [Select Id, Name from RecordType where Id = :RecordtypeId and SobjectType = 'Courtesy_Car_Contract__c'].Name;
			pdf = Page.AS_CourtesyCarContractPDF;
		}

		pdf.getParameters().put('Id', recordId);
		//
		Blob body = Test.isRunningTest() ? Blob.valueOf('unit.Test') : pdf.getContentAsPDF();

		Datetime d = Datetime.now();
		//        String s = d.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
		String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');

		if ('StatusConfirmation__c'.equals(localName)) {
			String label = StatusConfirmation__c.getSObjectType().getDescribe().getLabel(); // 상태확인서
			if (recordtypename == 'Pickup')
			s = recordtypename + '_' + label + '.' + s;
			else
			s = label + '.' + s;
		} else if ('Courtesy_Car_Contract__c'.equals(localName)) {
			String label = Courtesy_Car_Contract__c.getSObjectType().getDescribe().getLabel();
			if (recordtypename == 'Pickup')
			s = recordtypename + '_' + label + '.' + s;
			else
			s = label + '.' + s;
		}
		//Save generated PDF as file
		ContentVersion cv = new ContentVersion();

		cv.ContentLocation = 'S';
		cv.ContentDocumentId = null; //contentDocumentId;
		cv.VersionData = body; //EncodingUtil.base64Decode(base64Data);
		cv.Title = s + '.pdf';
		cv.PathOnClient = s + '.pdf';

		insert cv;

		ContentDocumentLink cdl = new ContentDocumentLink();

		cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
		cdl.LinkedEntityId = recordId;
		cdl.ShareType = 'V';

		insert cdl;

		Map<String, Object> rmap = new Map<String, Object> ();

		rmap.put('ContentVersion', cv.Id);
		rmap.put('ContentDocumentLink', cdl.Id);
		//update completed
		if ('StatusConfirmation__c'.equals(localName)) {
			StatusConfirmation__c sc = new StatusConfirmation__c();
			if (recordtypename == 'ReadOnly') {
				sc.Id = recordId;
				sc.Completed__c = true;
				update sc;
			}
		}else if ('Courtesy_Car_Contract__c'.equals(localName)) {
			Courtesy_Car_Contract__c ccc = new Courtesy_Car_Contract__c();
			if (recordtypename == 'ReadOnly') {
				ccc.Id = recordId;
				ccc.Completed__c = true;
				update ccc;
			}
		}
		return rmap;
	}


}