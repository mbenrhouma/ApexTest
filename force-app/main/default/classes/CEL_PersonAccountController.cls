public class CEL_PersonAccountController {

    /**
    * getPersonAccount: Account infos for Account Page
	* @param {Id} account ID
    * @return {Account}
    */
    @AuraEnabled
    public static Account getContactDetails(Id accountId) {
        return CEL_AccountMgr.getContactDetails(accountId);
    }

    /**
     * getAvailableList: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableList() {
        return new Map<String, List<Map<String, String>>> {
            'allCountries' => CEL_AccountMgr.getAvailableCountryList(),
            'allLanguages' => CEL_AccountMgr.getAvailableLanguageList(),
            'allChannels'  => CEL_AccountMgr.getAvailableChannelList(),
            'allAppointment'  => CEL_AccountMgr.getAvailablePreferredAppointmentTime()
                
        };
    }
    
    
    /**
    * saveAccount: Save account
	* @param {Account} account
    * @return {Account}
    */
	@AuraEnabled
	public static Account saveAccount(Account acc) {
        update acc;
        return acc;
	}
    
    
    /**
    * updateDQM: Update DQM field
	* @param {Account} account
    * @return {Account}
    */
    @AuraEnabled
	public static Account updateDQM(Account acc) {
        update acc;
        return acc;
	}
    
    /**
    * getFieldsAccess: return a map of fields with their access rights based on the profile logged
    * @return {Map<String, Boolean>}
    */
    @AuraEnabled
    public static Map<String, Boolean> getFieldsAccess() {
        Map<String, Boolean> mapp = new Map<String, Boolean>();
        mapp.put('personEmail', hasFieldEditAccess('Account','cel_PersonEmail__c'));
        mapp.put('emailValidity', hasFieldEditAccess('Account','cel_email_validity__c'));
        mapp.put('emailOptin', hasFieldEditAccess('Account','cel_do_not_email__c'));
        mapp.put('secondaryEmail', hasFieldEditAccess('Account','cel_email_2__c'));
        mapp.put('phone_1_number', hasFieldEditAccess('Account','PersonHomePhone'));
        mapp.put('phone1Validity', hasFieldEditAccess('Account','cel_homephone_validity__c'));
        mapp.put('phoneOptin', hasFieldEditAccess('Account','PersonDoNotCall'));
        mapp.put('phone_2_number', hasFieldEditAccess('Account','PersonMobilePhone'));
        mapp.put('phone2Validity', hasFieldEditAccess('Account','cel_mobile_validity__c'));
        mapp.put('phone_3_number', hasFieldEditAccess('Account','PersonOtherPhone'));
        mapp.put('phone3Validity', hasFieldEditAccess('Account','cel_otherphone_validity__c'));
        mapp.put('wechatId', hasFieldEditAccess('Account','cel_wechat_id__c'));
        mapp.put('linechatId', hasFieldEditAccess('Account','cel_line_id__c'));
        mapp.put('chatOptin', hasFieldEditAccess('Account','cel_optin_sms__c'));
        mapp.put('addrOptin', hasFieldEditAccess('Account','cel_optin_postal_mail__c'));
        mapp.put('addr1', hasFieldEditAccess('Account','cel_addr_1_line_1__c'));
        mapp.put('addressValidity', hasFieldEditAccess('Account','cel_addr_1_validity__c'));
        mapp.put('addr2', hasFieldEditAccess('Account','cel_addr_1_line_2__c'));
        mapp.put('addr3', hasFieldEditAccess('Account','cel_addr_1_line_3__c'));
        mapp.put('zipcode', hasFieldEditAccess('Account','cel_addr_1_zipcode__c'));
        mapp.put('region', hasFieldEditAccess('Account','cel_addr_1_region__c'));
        mapp.put('city', hasFieldEditAccess('Account','cel_addr_1_city__c'));
        mapp.put('addr_1_country', hasFieldEditAccess('Account','cel_addr_1_country__c'));
        mapp.put('preference_lang', hasFieldEditAccess('Account','cel_communication_language__c'));
        mapp.put('preference_channel', hasFieldEditAccess('Account','cel_preferred_contact_method__c'));
        mapp.put('preference_appointment_time', hasFieldEditAccess('Account','cel_preferred_appointment_time__c'));
        return mapp; 
    }
    
    /**
    * hasFieldEditAccess: return if logged user has edit access right on a field
    * @param {String} Field APIname
    * @return {Boolean}
    */
    @AuraEnabled
    public static Boolean hasFieldEditAccess(String objectName,String fieldName) {
        return CEL_UserMgr.hasFieldEditAccess(objectName, fieldName);
    }

}