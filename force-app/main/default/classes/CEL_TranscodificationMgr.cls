public with sharing class CEL_TranscodificationMgr {  
    
    /**
     * getTitlesS: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getTitles() {
        return getTranscodifcationList('cel_title','','');
    }
    
    /**
     * getFamilyStatus: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getFamilyStatus() {
        return getTranscodifcationList('cel_familystatus','','');
    }
    
     /**
     * getChildrenNumber: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getChildrenNumber() {
        return getTranscodifcationList('cel_childrennumber','','');
    }
    
     /**
     * getCountries: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getCountries() {
        return getTranscodifcationList('Country','','');
    }
    
     /**
     * getPreferredContactMethod: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getPreferredContactMethod() {
        return getTranscodifcationList('cel_preferredcontactmethod','','');
    }
    
     /**
     * getSpokenLangage: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getSpokenLangage() {
        return getTranscodifcationList('cel_spokenlanguage','Name','ASC');
    }
    
    /**
     * getSpokenAppoitmentTime: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getPreferredAppointmentTime() {
        return getTranscodifcationList('cel_preferredappointmenttime','','');
    }
    
    /**
     * getTrousersSize: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getTrousersSize() {
        return getTranscodifcationList('cel_trousersskirtsize','','');
    }
    
    /**
     * getTop: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getTop() {
        return getTranscodifcationList('cel_topshirtsize','','');
    }
    
    /**
     * getDress: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getDress() {
        return getTranscodifcationList('cel_dressjacketcoatsize','','');
    }
    
    /**
     * getKnitwear: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getKnitwear() {
        return getTranscodifcationList('cel_knitwearsize','','');
    }
    
    /**
     * getShoes: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getShoes() {
        return getTranscodifcationList('cel_shoessize','','');
    }
    
    /**
     * getGeneralStyle: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getGeneralStyle() {
        return getTranscodifcationList('cel_generalstyle','','');
    }
    
    /**
     * getWearing: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getWearing() {
        return getTranscodifcationList('cel_celinewearingstyle','','');
    }
    
    /**
     * getColourTone: Return available lists for screen
     * @return {Map<String, List<Map<String, String>>>}
    */
    public static List<Map<String, String>> getColourTone() {
        return getTranscodifcationList('cel_colourtones','','');
    }

    /**
     * getTranscodifcationList: Return available lists for screen
     * @param recordTypeName
     * @return {Map<String, List<Map<String, String>>>}
    */
    private static List<Map<String, String>> getTranscodifcationList(String recordTypeName,String sortedField, String sortOrder) {
        String transcoRecordType = [SELECT Id FROM RecordType WHERE DeveloperName =: recordTypeName LIMIT 1].Id;
        String query = 'SELECT ID, Name from cel_transcodification__c where RecordtypeId = \'' + transcoRecordType+'\'';
        
        if(String.isNotBlank(sortedField)){
            query +=' ORDER BY '+sortedField;
            if(String.isNotBlank(sortOrder)){
                query +=' '+sortOrder;
            }
        }
        
        List<cel_transcodification__c> transcodification  = Database.query(query);
        
        List<Map<String, String>> res = new List<Map<String, String>>();
        res.add(new Map<String, String>{
                'value' => '',
                'label' => ''
            });
        for(cel_transcodification__c t : transcodification)
        {
            res.add(new Map<String, String>{
                'value' => t.Id,
                'label' => t.Name
            });
        }
        
        return res;
    }
    
    /**
    * getTranscodificationBySetId : return the list transcodifications object By set d'Ids
    * @param {Set<Id>} transcoIds
    * @return {List<cel_transcodification__c>}
    */
    public static List<cel_transcodification__c> getTranscodificationBySetId(Set<Id> transcoIds){
        List<cel_transcodification__c> transcodifications = new List<cel_transcodification__c>();
        
        transcodifications = [SELECT Id, Name, cel_transcodification_code__c 
                              FROM cel_transcodification__c 
                              WHERE Id IN :transcoIds ORDER BY Name];
        
        return transcodifications;
    }
    
    /**
    * getTranscodificationByCodes : return the list transcodifications object By list of codes
    * @param {List<String>} transcoIds
    * @return {List<cel_transcodification__c>}
    */
    public static List<cel_transcodification__c> getTranscodificationByCodes(List<String> transcoCodes){
        List<cel_transcodification__c> transcodifications = new List<cel_transcodification__c>();
        
        transcodifications = [SELECT Id, Name, cel_transcodification_code__c 
                               FROM cel_transcodification__c 
                               WHERE cel_transcodification_code__c IN :transcoCodes
                               ORDER BY Name];
        
        return transcodifications;
    }
}