public class CEL_AccountMgr { 
    
    /**
     * getContactDetails Return available country list for account.
     * @param {Id} AccountId
     * @return   {List<Map<String, String>>}
     */
    public static Account getContactDetails(Id accountId) {
        if(accountId == null) {
            return null;
        }
        
        List<Account> accounts = [SELECT Id, 
                                  PersonEmail,
                                  cel_email_2__c,
                                  cel_CQ_CP__c,
                                  cel_CQ_LV__c,
                                  cel_CQ_NV__c,
                                  cel_line_id__c,
                                  cel_CQ_City__c,
                                  PersonHomePhone,
                                  PersonDoNotCall,
                                  cel_wechat_id__c, 
                                  cel_optin_sms__c,
                                  PersonOtherPhone,
                                  cel_CQ_Region__c,
                                  cel_rcu_update__c,
                                  PersonMobilePhone,
                                  cel_addr_1_city__c, 
                                  cel_PersonEmail__c,
                                  cel_do_not_email__c,
                                  cel_addr_1_line_1__c, 
                                  cel_addr_1_line_2__c, 
                                  cel_email_validity__c,
                                  cel_addr_1_region__c, 
                                  cel_addr_1_line_3__c, 
                                  cel_email_mailable__c,
                                  cel_addr_1_zipcode__c, 
                                  cel_addr_1_country__c, 
                                  cel_mobile_validity__c,
                                  cel_addr_1_validity__c,
                                  cel_mobile_mailable__c,
                                  cel_address_mailable__c,
                                  cel_optin_postal_mail__c, 
                                  cel_do_not_send_to_dqm__c,
                                  cel_personal_assistant__c,
                                  cel_homephone_mailable__c,
                                  cel_homephone_validity__c,
                                  cel_otherphone_validity__c, 
                                  cel_otherphone_mailable__c,
                                  cel_True_Email_Address_2__c,
                                  cel_is_email_contactibiliy__c,
                                  cel_is_post_contactability__c,
                                  cel_communication_language__c, 
                                  cel_is_phone_contactability__c,
                                  cel_preferred_contact_method__c,
                                  cel_is_general_contactability__c,    
                                  cel_preferred_appointment_time__c
                                  FROM Account 
                                  WHERE Id = :accountId];
        
        if(accounts.size() > 0) { 
            return accounts.get(0);
        }
        
        return null;
    }
   
    /**
     * getAvailableCountryList Return available country list for account.
     * @return   {List<Map<String, String>>}
     */
      public static List<Map<String, String>> getAvailableCountryList() {
        return CEL_Utils.getFieldValues(Account.cel_addr_1_country__c.getDescribe(), true, null);
    }
   
    /**
     * getAvailableLanguageList Return available language list for account.
     * @return   {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableLanguageList() {
        return CEL_Utils.getFieldValues(Account.cel_communication_language__c.getDescribe(), true, null);
    }
   
    /**
     * getAvailableChannelList Return available channel list for account.
     * @return   {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableChannelList() {
        return CEL_Utils.getFieldValues(Account.cel_preferred_contact_method__c.getDescribe(), true, null);
    }
    
    /**
     * getAvailablePreferredAppointmentTime Return available preferred appointment time list.
     * @return   {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailablePreferredAppointmentTime() {
        return CEL_Utils.getFieldValues(Account.cel_preferred_appointment_time__c.getDescribe(), true, null);
    }
    
    /**
     * getAvailableSalutationList Return available salutation list for account.
     * @return   {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableSalutationList() {
        return CEL_Utils.getFieldValues(Account.Salutation.getDescribe(), true, null);
    }
    
    /**
     * getAvailableNationalityList Return available nationalities list for account.
     * @return   {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableNationalityList() {
        return CEL_Utils.getFieldValues(Account.cel_nationality__c.getDescribe(), true, null);
    }
    /**
     * anonymizeAccount Return available channel list for account.
     * @return   {List<Map<String, String>>}
     */
    public static Boolean anonymizeAccount(List<Account> accounts) {
        if(accounts.size() > 0){
           List<Anonymize_Configuration__mdt> fieldsValues = [SELECT Field_Api_Name__c, Value__c, Value_Type__c FROM Anonymize_Configuration__mdt where object_name__c =: 'Account'];
           if(fieldsValues.size() > 0){
                List<String> fieldApiName = new List<String>();             
                for(Integer i = 0; i < fieldsValues.size(); i++){
                    fieldApiName.add(fieldsValues.get(i).Field_Api_Name__c);
                }
                String fieldsNames = String.join(fieldApiName,','); 
                String query = 'SELECT ' + fieldsNames + ' FROM Account WHERE Id IN: accounts';
                List<SObject> accts = Database.Query(query);
                CEL_AnonymizeUtil.anonymiser(accts,fieldsValues);
            }
            else {
                return false;
            }
        }
        return true;
    }
    
    /**
     * getPersonContactID Return personContactID.
     * @param {Id} AccountId
     * @return {Account}
     */
    public static String getPersonContactID(String accountId) {
        if(accountId == null) {
            return null;
        }
        
        List<Account> accounts = [SELECT Id, PersonContactID FROM Account WHERE Id = :accountId];
        
        if(accounts.size() > 0) { 
            return accounts.get(0).PersonContactID;
        }
        
        return null;
    }
    
    /**
     * getOptinConsent Get optin consent from optins
     * @param  {Account} a
     * @return {Boolean}
     */
    public static Boolean getOptinConsent(Account a) {
        return a.cel_optin_postal_mail__c || a.cel_optin_sms__c || a.cel_do_not_email__c || a.PersonDoNotCall;
    }
    
    /**
     * getAllStoresOpen Get all stores open
     * @return {List<Account>}
     */
    public static List<Account> getAllStoresOpen(){
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        
        allStores = [SELECT Id,
                            cel_long_name__c,
                            RecordTypeId,
                            cel_store_status__c,
                            cel_store_area__c,
                            cel_addr_1_country__c,
                            toLabel(cel_addr_1_country__c) country1Label
                            FROM Account 
                            WHERE RecordTypeId =: storeRecordType
                            AND cel_store_status__c =: storeStatusOpen
                            ORDER BY cel_long_name__c];
        
        return allStores;
    }
    
    /**
     * getOpenStoresCountries Get open stores countries list
     * @return {Set<String>}
     */
    public static Set<String> getOpenStoresCountries(){
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        Set<String> countriesSet = new Set<String>();
        
        allStores = [SELECT Id,
                            cel_long_name__c,
                            RecordTypeId,
                            cel_store_status__c,
                            cel_store_area__c,
                            cel_addr_1_country__c,
                            toLabel(cel_addr_1_country__c) country1Label
                            FROM Account 
                            WHERE RecordTypeId =: storeRecordType
                            AND cel_store_status__c =: storeStatusOpen
                            ORDER BY cel_long_name__c];
        
        for(Account storeAccount : allStores){
            countriesSet.add(storeAccount.cel_addr_1_country__c);
        }
        return countriesSet;
    }
    
    /**
     * getStoresBySetIds Get stores by set ids
     * @param  {Set<Id>} storesIds
     * @return {List<Account>}
     */
    public static List<Account> getStoresBySetIds(Set<Id> storesIds){
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        
        allStores = [SELECT Id,
                           cel_long_name__c,
                           RecordTypeId,
                           cel_store_status__c,
                           cel_store_area__c,
                           cel_addr_1_country__c,
                           toLabel(cel_addr_1_country__c) country1Label
                           FROM Account 
                           WHERE RecordTypeId =: storeRecordType
                           AND cel_store_status__c =: storeStatusOpen
                           AND Id = :storesIds
                           ORDER BY cel_long_name__c];
        
        return allStores;
    }
    
    /**
     * getStoresByIds Get stores by list ids
     * @param  {List<Id>} storesIds
     * @return {List<Account>}
     */
    public static List<Account> getStoresByIds(List<Id> storesIds){
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        
        allStores = [SELECT Id,
                           cel_long_name__c,
                           RecordTypeId,
                           cel_store_status__c,
                           cel_store_area__c,
                           cel_addr_1_country__c,
                           toLabel(cel_addr_1_country__c) country1Label,
                           cel_store_code_Y2__c
                           FROM Account 
                           WHERE RecordTypeId =: storeRecordType
                           AND cel_store_status__c =: storeStatusOpen
                           AND Id = :storesIds
                           ORDER BY cel_long_name__c];
        
        return allStores;
    }
    
    /**
     * getStoresCountriesByIds Get stores ountries list by ids
     * @param  {List<Id>} storesIds
     * @return {Set<String>}
     */
    public static Set<String> getStoresCountriesByIds(List<Id> storesIds){
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        Set<String> countriesSet = new Set<String>();
        
        allStores = [SELECT Id,
                           cel_long_name__c,
                           RecordTypeId,
                           cel_store_status__c,
                           cel_store_area__c,
                           cel_addr_1_country__c
                           FROM Account 
                           WHERE RecordTypeId =: storeRecordType
                           AND cel_store_status__c =: storeStatusOpen
                           AND Id = :storesIds
                           ORDER BY cel_long_name__c];
        
        for(Account storeAccount : allStores){
            countriesSet.add(storeAccount.cel_addr_1_country__c);
        }
        return countriesSet;
    }
    
    /**
     * getStoresByCodeY2 Get stores by list of Y2 code
     * @param  {Set<String>} allStoresCodes
     * @return {List<Account>}
     */
    public static List<Account> getStoresByCodeY2(List<String> allStoresCodes){
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        
        allStores = [SELECT Id,
                           cel_long_name__c,
                           RecordTypeId,
                           cel_store_status__c,
                           cel_store_area__c,
                           cel_addr_1_country__c,
                           toLabel(cel_addr_1_country__c) country1Label
                           FROM Account 
                           WHERE RecordTypeId =: storeRecordType
                           AND cel_store_status__c =: storeStatusOpen
                           AND cel_store_code_Y2__c = :allStoresCodes
                           ORDER BY cel_long_name__c];
        
        return allStores;
    }
    
    /**
     * getStoresByCountryId : Get stores by list id country
     * @param  {List<String>} transcoCountriesIds
     * @return {List<Account>}
     */
    public static List<Account> getStoresByCountryId(List<String> transcoCountriesIds){
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        
        Set<String> transcoCountries = new Set<String>();
        List<cel_transcodification__c> listOfTranscodification = [Select Id, cel_transcodification_code__c,RecordTypeId From cel_transcodification__c Where Id IN :transcoCountriesIds];
        for(cel_transcodification__c transco : listOfTranscodification){
            transcoCountries.add(transco.cel_transcodification_code__c);
        }
        
        allStores = [SELECT Id,
                           cel_long_name__c,
                           RecordTypeId,
                           cel_store_status__c,
                           cel_store_area__c,
                           cel_addr_1_country__c,
                           toLabel(cel_addr_1_country__c) country1Label
                           FROM Account 
                           WHERE RecordTypeId =: storeRecordType
                           AND cel_store_status__c =: storeStatusOpen
                           AND cel_addr_1_country__c IN :transcoCountries
                           ORDER BY cel_long_name__c];
        
        return allStores;
    }
    
    /**
     * getStoresByAreaId : Get stores by list id area
     * @param  {Set<Id>} transcoRegionsIds
     * @return {List<Account>}
     */
    public static List<Account> getStoresByAreaId(List<String> transcoRegionsIds){
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        
        allStores = [SELECT Id,
                           cel_long_name__c,
                           RecordTypeId,
                           cel_store_status__c,
                           cel_store_area__c,
                           cel_addr_1_country__c,
                           toLabel(cel_addr_1_country__c) country1Label
                           FROM Account 
                           WHERE RecordTypeId =: storeRecordType
                           AND cel_store_status__c =: storeStatusOpen
                           AND cel_store_area__c IN :transcoRegionsIds
                           ORDER BY cel_long_name__c];
        
        return allStores;
    }
    
    /**
     * getAvailableStoresList Return available stores list.
     * @return   {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableStoresList() {
        List<Account> allStores = new List<Account>();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        
        allStores = [SELECT Id,
                            cel_long_name__c,
                            RecordTypeId,
                            cel_store_status__c,
                            cel_store_area__c,
                            cel_addr_1_country__c,
                            toLabel(cel_addr_1_country__c) country1Label
                            FROM Account 
                            WHERE RecordTypeId =: storeRecordType
                            AND cel_store_status__c =: storeStatusOpen
                            AND cel_Is_Seamless_Active__c = true
                            ORDER BY cel_long_name__c];
        
        //return allStores;
        List<Map<String, String>> values = new List<Map<String, String>>();
        
        for(Account a : allStores) {
            values.add(new Map<String, String>{
                'value' => a.Id,
                'label' => a.cel_long_name__c
            }); 
        }

        return values;
    }
}