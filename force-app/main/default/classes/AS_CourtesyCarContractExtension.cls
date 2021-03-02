/*
 *	Author: Daniel Varhidi
 *	Created Date: 15-Febr-2020
 *	Story: GD-2328
*/
public class AS_CourtesyCarContractExtension {
	public boolean showPickUpSection { get; set; }
	private final Courtesy_Car_Contract__c courtesyCarContract;
	public final String recordtypename;
	public AS_CourtesyCarContractExtension(ApexPages.StandardController stdController) {
		this.courtesyCarContract = (Courtesy_Car_Contract__c) stdController.getRecord();
		Id RecordtypeId = [SELECT Id, RecordtypeId FROM Courtesy_Car_Contract__c where Id = :courtesyCarContract.Id].RecordtypeId;
		recordtypename = [Select Id, Name from RecordType where Id = :RecordtypeId and SobjectType = 'Courtesy_Car_Contract__c'].Name;
		System.debug(recordtypename);

		if (recordtypename == 'Delivery') {
			showPickUpSection = false;
		} else {
			showPickUpSection = true;
		}

	}

	public PageReference SaveAttachment() {
		PageReference myPdf = Page.AS_CourtesyCarContractPDF;
		String label = Courtesy_Car_Contract__c.getSObjectType().getDescribe().getLabel();
		Datetime d = Datetime.now();
		String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');
		System.debug(recordtypename);
		if (recordtypename == 'Delivery') {
			s = recordtypename + '_' + label + '.' + s;
		} else {
			s = label + '.' + s;
		}
		ContentVersion cv = new ContentVersion();
		cv.ContentLocation = 'S';
		cv.ContentDocumentId = null; //contentDocumentId;
		Blob body = Test.isRunningTest() ? Blob.valueOf('unit.Test') : myPdf.getContentAsPDF();
		cv.VersionData = body; //EncodingUtil.base64Decode(base64Data);
		//cv.VersionData=Blob.valueOf('mytext');
		cv.Title = s + '.pdf';
		cv.PathOnClient = s + '.pdf';
		insert cv;
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
		cdl.LinkedEntityId = courtesyCarContract.Id;
		cdl.ShareType = 'V';
		insert cdl;

		PageReference pageRef = new PageReference('/lightning/r/Courtesy_Car_Contract__c/' + courtesyCarContract.Id + '/view');
		pageRef.setRedirect(true); return pageRef;


	}
}