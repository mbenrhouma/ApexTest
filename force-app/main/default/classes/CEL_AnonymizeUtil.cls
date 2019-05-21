public with sharing class CEL_AnonymizeUtil {

     /**
     * anonymiser description
     * @param  {List<SObject>} accts
     * @param {List<Anonymize_Configuration__mdt> }fieldsValues
     * @return {Boolean}
     */
	public static Boolean anonymiser(List<SObject> accts,List<Anonymize_Configuration__mdt> fieldsValues) {
		for(SObject a : accts){
            for(Anonymize_Configuration__mdt f : fieldsValues){
                String fieldName = f.Field_Api_Name__c;
                String fieldValue = f.Value__c;

                if(fieldValue != null && fieldValue.contains('timestamp')){
                    DateTime dt = Datetime.now();
                    String formatedDt = dt.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
                    fieldValue =fieldValue.replace('timestamp', formatedDt);
                    
                }  if(f.Value_Type__c == 'Text' || f.Value_Type__c == 'Phone' ){
                    a.put(fieldName,  fieldValue);
                }
                else if(f.Value_Type__c == 'BOOLEAN'){
                    if(fieldValue == 'true' || fieldValue == 'True'){
                        a.put(fieldName,  true);
                    }
                    else{
                        a.put(fieldName,  false);
                    }
                }
                else if(f.Value_Type__c == 'Number' ){
                    a.put(fieldName, integer.valueof(fieldValue));
                }
                else if(f.Value_Type__c == 'DOUBLE'){
                    a.put(fieldName, double.valueof(fieldValue));
                }
                else if(f.Value_Type__c == 'NULL'){
                    a.put(fieldName,  null);
                }
                else if(f.Value_Type__c == 'DATE_NOW'){
                    a.put(fieldName,  Datetime.now());
                }
                else if(f.Value_Type__c == 'Date'){
                    a.put(fieldName,  Date.parse(fieldValue));
                }
                else{
                    a.put(fieldName,  null);
                }
            }
        }
        update accts;
        return true;
	}

    /**
     * anonymizeAccountAndRelation description
     * @param  {List<Account>} Account List to anonymize
     * @return {Boolean}
     */
    public static Boolean anonymizeAccountAndRelation(List<Account> accts) {
        Boolean anonymize = true;
        anonymize = anonymize && CEL_AccountMgr.anonymizeAccount(accts);
        anonymize = anonymize && CEL_CaseMgr.anonymizeCase(accts);
        CEL_IndividualMgr.updateIndividualAfterAnonymization(accts);
        return anonymize;
    }
    
}