public class CEL_CaseMgr {
    
    
    /**
     *   anonymizeCase : [description]
     * @param {List<Account> } cases
     * @return {Boolean}
     * 
     */
    public static Boolean anonymizeCase(List<Account> accounts) {
       if(accounts.size() > 0){
           List<Anonymize_Configuration__mdt> fieldsValues = [SELECT Field_Api_Name__c, Value__c, Value_Type__c FROM Anonymize_Configuration__mdt where object_name__c =: 'Case'];
           if(fieldsValues.size() > 0){
               List<String> fieldApiName = new List<String>();               
               for(Integer i = 0; i < fieldsValues.size(); i++){
                   fieldApiName.add(fieldsValues.get(i).Field_Api_Name__c);
               }               
               String fieldsNames = String.join(fieldApiName,','); 
               String query = 'SELECT ' + fieldsNames + ' FROM Case WHERE AccountId IN: accounts';
               List<SObject> cas = Database.Query(query);
               CEL_AnonymizeUtil.anonymiser(cas,fieldsValues);
           } else {
               return false;
           }
        }
        return true;
    }
    
}