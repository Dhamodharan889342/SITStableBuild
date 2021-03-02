/**
 * @author Daniel Varhidi
 * @createdDate 05/February/2021
 * @JIRA GD-2328
 * @description
*/
public class AS_CourtesyCarContract {

	@AuraEnabled
	public static Map<String, Object> doSaveOutsideCheck(Map<String, Object> pmap, String recordTypeName) {
		System.debug('pmap :: ' + JSON.serialize(pmap));
		//Save the outside check image as attachment
		String recordId = (String) pmap.get('recordId');
		String base64Data = (String) pmap.get('base64Data');
		System.debug('doSaveOutsideCheck recordId ::' + recordId);

		Attachment attach = new Attachment();

		attach.Body = EncodingUtil.base64Decode(base64Data);
		Datetime d = Datetime.now();
		//        String s = d.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
		String s = d.format('yyyy-MM-dd\' \'HH:mm:ss.SSS');
		attach.Name = recordTypeName + '_OutsideCheck_' + s + '.png';
		attach.IsPrivate = false;
		attach.ParentId = recordId;

		insert attach;
		// update the outside check id fields as per record type
		Courtesy_Car_Contract__c sc = [SELECT Id, OutsideCheckId__c, Delivery_OutsideCheckId__c FROM Courtesy_Car_Contract__c WHERE Id = :recordId];
		if (recordTypeName == 'Pickup') {
			sc.OutsideCheckId__c = attach.Id;
		} else if(recordTypeName == 'Delivery'){
			sc.Delivery_OutsideCheckId__c = attach.Id;
		}
		update sc;

		Map<String, Object> rmap = new Map<String, Object> ();

		rmap.put('attach', attach.Id);

		return rmap;
	}
}