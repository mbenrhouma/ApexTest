public class CEL_Campaign_PicklistsController {
    
    /**
     * getAvailableList: Return available list for picklist
     * @return {Map<String, List<Map<String, String>>>}
    */
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableList(String recordId, String campaignParentId, String campaignRecordType) {
        Map<String, List<Map<String, String>>> result = new Map<String, List<Map<String, String>>>();
        result = CEL_CampaignMgr.getAvailableListZoneCountrieStore(recordId, campaignParentId, campaignRecordType);
        return result;
    }
}