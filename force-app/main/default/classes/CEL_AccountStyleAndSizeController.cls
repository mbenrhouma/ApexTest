public with sharing class CEL_AccountStyleAndSizeController {


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
            'allColourTone' => CEL_TranscodificationMgr.getColourTone()
        };
    }

    
    
    /**
    * getFieldsAccess: return a map of fields with their access rights based on the profile logged
    * @return {Map<String, Boolean>}
    */
    @AuraEnabled
    public static Map<String, Boolean> getFieldsAccess() {
        Map<String, Boolean> mapp = new Map<String, Boolean>();

        mapp.put('trousers_skirt_size', CEL_Utils.hasFieldEditAccess('Account','cel_trousers_skirt_size__c'));
        mapp.put('general_style', CEL_Utils.hasFieldEditAccess('Account','cel_style__c'));
        mapp.put('celine_wearing_style', CEL_Utils.hasFieldEditAccess('Account','cel_celine_wearing_style__c'));
        mapp.put('top_shirt_size', CEL_Utils.hasFieldEditAccess('Account','cel_top_shirt_size__c'));
        mapp.put('dress_jacketcoat_size', CEL_Utils.hasFieldEditAccess('Account','cel_dress_jacketcoat_size__c'));
        mapp.put('colourtone', CEL_Utils.hasFieldEditAccess('Account','cel_colourtone__c'));
        mapp.put('knitwear', CEL_Utils.hasFieldEditAccess('Account','cel_knitwear__c'));
        mapp.put('preferred_brands', CEL_Utils.hasFieldEditAccess('Account','cel_preferred_brands__c'));
        mapp.put('shoes_size', CEL_Utils.hasFieldEditAccess('Account','cel_shoes_size__c'));
        mapp.put('comment_pref', CEL_Utils.hasFieldEditAccess('Account','cel_comment_pref__c'));
        mapp.put('comment_size_style', CEL_Utils.hasFieldEditAccess('Account','cel_comment_size_style__c'));
        return mapp; 
    }
}