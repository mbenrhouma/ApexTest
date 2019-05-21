public with sharing class CEL_AccountOtherInformationController {


    /**
     * getAvailableList: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableList() {
        return new Map<String, List<Map<String, String>>> {
            'allTrousers' => CEL_TranscodificationMgr.getTrousersSize(),
            'allTop' => CEL_TranscodificationMgr.getTop(),
            'allDress' => CEL_TranscodificationMgr.getDress(),
            'allKnitwear' => CEL_TranscodificationMgr.getKnitwear(),
            'allShoes' => CEL_TranscodificationMgr.getShoes(),
            'allGeneralStyle' => CEL_TranscodificationMgr.getGeneralStyle(),
            'allWearing' => CEL_TranscodificationMgr.getWearing(),
            'allColourTone' => CEL_TranscodificationMgr.getColourTone(),
            'allFamilyStatus' => CEL_TranscodificationMgr.getFamilyStatus(),
            'allChildrenNumber' => CEL_TranscodificationMgr.getChildrenNumber(),
            'allCountries' => CEL_TranscodificationMgr.getCountries()
        };
    }

    
    
    /**
    * getFieldsAccess: return a map of fields with their access rights based on the profile logged
    * @return {Map<String, Boolean>}
    */
    @AuraEnabled
    public static Map<String, Boolean> getFieldsAccess() {
        Map<String, Boolean> mapp = new Map<String, Boolean>();


        mapp.put('professionalActivity', CEL_Utils.hasFieldEditAccess('Account','cel_professional_activity__c'));
        mapp.put('family_status', CEL_Utils.hasFieldEditAccess('Account','cel_family_status__c'));
        mapp.put('ageRange', CEL_Utils.hasFieldEditAccess('Account','cel_age_range__c'));
        mapp.put('leisure', CEL_Utils.hasFieldEditAccess('Account','cel_leisure__c'));
        mapp.put('children_number', CEL_Utils.hasFieldEditAccess('Account','cel_children_number__c'));
        mapp.put('foodBeveragePref', CEL_Utils.hasFieldEditAccess('Account','cel_food_beverage_preferences__c'));
        mapp.put('personalAssistant', CEL_Utils.hasFieldEditAccess('Account','cel_personal_assistant__c'));
        mapp.put('personalShopper2', CEL_Utils.hasFieldEditAccess('Account','cel_personal_shopper_2__c'));
        mapp.put('personalShopper1', CEL_Utils.hasFieldEditAccess('Account','cel_personal_shopper_1__c'));
        mapp.put('personalShopper3', CEL_Utils.hasFieldEditAccess('Account','cel_personal_shopper_3__c'));
        mapp.put('addr2Line1', CEL_Utils.hasFieldEditAccess('Account','cel_addr_2_line_1__c'));
        mapp.put('addr2Zipcode', CEL_Utils.hasFieldEditAccess('Account','cel_addr_2_zipcode__c'));
        mapp.put('addr2Line2', CEL_Utils.hasFieldEditAccess('Account','cel_addr_2_line_2__c'));
        mapp.put('addr2Region', CEL_Utils.hasFieldEditAccess('Account','cel_addr_2_region__c'));
        mapp.put('addr2Line3', CEL_Utils.hasFieldEditAccess('Account','cel_addr_2_line_3__c'));
        mapp.put('addr2City', CEL_Utils.hasFieldEditAccess('Account','cel_addr_2_city__c'));
        mapp.put('addr2Country', CEL_Utils.hasFieldEditAccess('Account','cel_addr_2_country__c'));
        mapp.put('addr3Line1', CEL_Utils.hasFieldEditAccess('Account','cel_addr_3_line_1__c'));
        mapp.put('addr3Zipcode', CEL_Utils.hasFieldEditAccess('Account','cel_addr_3_zipcode__c'));
        mapp.put('addr3Line2', CEL_Utils.hasFieldEditAccess('Account','cel_addr_3_line_2__c'));
        mapp.put('addr3Region', CEL_Utils.hasFieldEditAccess('Account','cel_addr_3_region__c'));
        mapp.put('addr3Line3', CEL_Utils.hasFieldEditAccess('Account','cel_addr_3_line_3__c'));
        mapp.put('addr3City', CEL_Utils.hasFieldEditAccess('Account','cel_addr_3_city__c'));
        mapp.put('addr3Country', CEL_Utils.hasFieldEditAccess('Account','cel_addr_3_country__c'));
        mapp.put('addr4Line1', CEL_Utils.hasFieldEditAccess('Account','cel_addr_4_line_1__c'));
        mapp.put('addr4Zipcode', CEL_Utils.hasFieldEditAccess('Account','cel_addr_4_zipcode__c'));
        mapp.put('addr4Line2', CEL_Utils.hasFieldEditAccess('Account','cel_addr_4_line_2__c'));
        mapp.put('addr4Region', CEL_Utils.hasFieldEditAccess('Account','cel_addr_4_region__c'));
        mapp.put('addr4Line3', CEL_Utils.hasFieldEditAccess('Account','cel_addr_4_line_3__c'));
        mapp.put('addr4City', CEL_Utils.hasFieldEditAccess('Account','cel_addr_4_city__c'));
        mapp.put('addr4Country', CEL_Utils.hasFieldEditAccess('Account','cel_addr_4_country__c'));

        return mapp; 
    }

}