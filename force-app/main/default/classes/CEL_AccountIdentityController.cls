public with sharing class CEL_AccountIdentityController {
    /**
     * getAvailableList: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableList() {
        return new Map<String, List<Map<String, String>>> {
            'allCountries' => CEL_AccountMgr.getAvailableNationalityList(),
            'allTitles' => CEL_AccountMgr.getAvailableSalutationList()
        };
    }


    
    
    /**
    * getFieldsAccess: return a map of fields with their access rights based on the profile logged
    * @return {Map<String, Boolean>}
    */
    @AuraEnabled
    public static Map<String, Boolean> getFieldsAccess() {
        Map<String, Boolean> mapp = new Map<String, Boolean>();

        mapp.put('title', CEL_Utils.hasFieldEditAccess('Account','Name'));
        mapp.put('birthdate', CEL_Utils.hasFieldEditAccess('Account','cel_birthdate_day__c'));
        mapp.put('firstname2', CEL_Utils.hasFieldEditAccess('Account','cel_firstname_2__c'));
        mapp.put('lastname2', CEL_Utils.hasFieldEditAccess('Account','cel_lastname_2__c'));
        mapp.put('customerCode', CEL_Utils.hasFieldEditAccess('Account','cel_ext_account_id__c'));
        mapp.put('passeportNumber', CEL_Utils.hasFieldEditAccess('Account','cel_passeport_number__c'));
        mapp.put('passeportExpirationDate', CEL_Utils.hasFieldEditAccess('Account','cel_passeport_expiry_date__c'));
        mapp.put('localCustomer', CEL_Utils.hasFieldEditAccess('Account','cel_local_customer__c'));
        mapp.put('nationality', CEL_Utils.hasFieldEditAccess('Account','cel_nationality__c'));
        mapp.put('clientIsCompany', CEL_Utils.hasFieldEditAccess('Account','cel_Client_Is_Company__c'));
        mapp.put('gender', CEL_Utils.hasFieldEditAccess('Account','cel_Gender__c'));
        return mapp; 
    }
}