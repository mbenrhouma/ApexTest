public class CEL_CampaignTriggerHandler {
    
     public CEL_CampaignTriggerHandler(){
        
    }
    
    /**
    * Trigger handle on before insert
    * @param {Map<Id, Campaign>} oldMap
    * @param {List<Campaign>} newItems
    */
    public void OnBeforeInsert(Map<Id,Campaign> oldMap, List<Campaign> newItems) {
        List<Campaign> listCamp = newItems;
        
        String campaignEnfantRecordType = CEL_Constants.campaignEnfantRecordType;
        String campaignParentRecordType = CEL_Constants.campaignParentRecordType;
        Map<String, decimal> mapCurrentRate = new Map<String, decimal>();
        mapCurrentRate = CEL_DatedConversionRateMgr.getMapCurrentConversionRate();
        
        // Return error if we want add a child level 5
        for(campaign c : newItems){
            // Test if c is a child
            if(c.ParentId != null && c.RecordTypeId == campaignEnfantRecordType){
                // Get his parent
                List<Campaign> parentChild = [SELECT Id, ParentId, RecordTypeId FROM Campaign WHERE id = :c.ParentId LIMIT 1];
                // Test if his parent is a child
                if(parentChild != null && parentChild.size() > 0 && parentChild.get(0).ParentId != null && parentChild.get(0).RecordTypeId == campaignEnfantRecordType){
                    // Get the parent of his parent
                    List<Campaign> parent = [SELECT Id, ParentId, RecordTypeId FROM Campaign WHERE id = :parentChild.get(0).ParentId LIMIT 1];
                    // Test if the parent of his parent is a chil, if true, return error
                    if(parent != null && parent.size() > 0 && parent.get(0).RecordTypeId == campaignEnfantRecordType){
                        c.addError(System.Label.cel_campaign_ErrorMessageBeforeInsertChild);
                    }
                }
            }
            
            //Set level Campaign
            if(c.cel_region_all__c){
                c.cel_level__c = CEL_Constants.levelsCampaign.get('Level_1');
            }
            else if(!c.cel_region_all__c && c.RecordTypeId == campaignParentRecordType){
                c.cel_level__c = CEL_Constants.levelsCampaign.get('Level_2');
            }
            else if(c.ParentId != null && c.RecordTypeId == campaignEnfantRecordType){
                List<Campaign> parentChild = [SELECT Id, ParentId, RecordTypeId FROM Campaign WHERE id = :c.ParentId LIMIT 1];
                if(parentChild != null && parentChild.size() > 0 ){
                    if(parentChild.get(0).RecordTypeId == campaignParentRecordType){
                        c.cel_level__c = CEL_Constants.levelsCampaign.get('Level_3');
                    }
                    else{
                        c.cel_level__c = CEL_Constants.levelsCampaign.get('Level_4');
                    }
                }
            }
            
            String defaultCurrency = UserInfo.getDefaultCurrency();
            c.CurrencyIsoCode = defaultCurrency;
            c.cel_local_Currency__c = defaultCurrency;
            c.cel_Currency_Locale_formula__c = defaultCurrency;
            
            if (c.ParentId != null && c.RecordTypeId == campaignEnfantRecordType){
               c = CEL_CampaignMgr.fillingChildFieldsWithParent(c);
           }
           
            c = CEL_CampaignMgr.convertAmount(c, mapCurrentRate);
        }
    }
    
    /**
    * Trigger handle on after insert
    * @param {List<Campaign>} newItems
    */
    public void OnAfterInsert(List<Campaign> newItems) 
    {
       // If campaign is type Parent and has Region : ALL
       // Creating a child by Region ( Type Parent ) 
       // Create CEL_Campaign_RegionCountryStore__c for the ALL campaign
       for(Campaign c : newItems){
           if(c.cel_region_all__c){
               CEL_CampaignMgr.createChildForCampaignAll(c);
               CEL_CampaignMgr.createCampaignRegionCountryStoreForAllCampaign(c);
           }
       }
    }
    
    /**
    * Trigger handle on before update
    * @param {List<Campaign>} oldItems
    * @param {List<Campaign>} updatedItems
    * @param {Map<Id, Campaign>} itemMap
    * @param {Map<Id, Campaign>} oldItemMap
    */
    public void OnBeforeUpdate(List<Campaign> oldItems, List<Campaign> updatedItems, Map<Id, Campaign> itemMap, Map<Id, Campaign> oldItemMap){
        String campaignEnfantRecordType = CEL_Constants.campaignEnfantRecordType;
        String campaignParentRecordType = CEL_Constants.campaignParentRecordType;
        Map<String, decimal> mapCurrentRate = new Map<String, decimal>();
        mapCurrentRate = CEL_DatedConversionRateMgr.getMapCurrentConversionRate();
        
        Campaign oldCampaign;
        for(Campaign c : updatedItems){
            if(oldItemMap.containsKey(c.Id)) {
                oldCampaign = oldItemMap.get(c.Id);
                // Return error if startDate and EndDate modified and if c is parent and Has children
                if(oldCampaign != null && oldCampaign.IsActive && c.IsActive){
                    Date oldStartDate = oldCampaign.StartDate;
                    Date oldEndDate = oldCampaign.EndDate;
                    if(oldStartDate != c.StartDate || oldEndDate != c.EndDate){
                        Integer nbChilds = 0;
                        nbChilds = CEL_CampaignMgr.getNumberOfChilren(c);
                        if(nbChilds != 0){
                            c.addError(System.Label.cel_campaign_ErrorMessageBeforeUpdateParentDate);
                        }
                    }
                }
                
                // Return error if c is active updated and one of his child startDate et endDate are not on Parent Range
                if(oldCampaign != null && !oldCampaign.IsActive && c.IsActive){
                    List<String> namesChild = CEL_CampaignMgr.getNameChildrenOutRangeDate(c);
                    if(namesChild != null && !namesChild.isEmpty()){
                        String names = ' ' + string.join(namesChild,',') + ' ';
                        c.addError(System.Label.cel_campaign_ErrorMessageBeforeActiveParentStart + names + System.Label.cel_campaign_ErrorMessageBeforeActiveParentEnd);
                    }
                }
            }
            c = CEL_CampaignMgr.convertAmount(c, mapCurrentRate);
        }
    }
    
    /**
    * Trigger handle on after update
    * @param {List<Campaign>} olditems
    * @param {List<Campaign>} updatedItems
    * @param {Map<Id, Campaign>} itemMap
    * @param {Map<Id, Campaign>} oldItemMap
    */
    public void OnAfterUpdate(List<Campaign> oldItems, List<Campaign> updatedItems, Map<Id, Campaign> itemMap, Map<Id, Campaign> oldItemMap) 
    {
        
    }
    
    /**
    * Trigger handle on before delete
    * @param {List<Campaign>} itemsToDelete
    * @param {Map<Id, Campaign>} itemMap
    */
    public void OnBeforeDelete(List<Campaign> itemsToDelete, Map<Id, Campaign> itemMap) {
        
    }
    
    /**
    * Trigger handle on after delete
    * @param {List<Campaign>} itemsToDelete
    * @param {Map<Id, Campaign>} itemMap
    */
    public void OnAfterDelete(List<Campaign> itemsToDelete, Map<Id, Campaign> itemMap) {
        
    }
    
    /**
    * Trigger handle on after undelete
    * @param {List<Campaign>} restoredItems
    */
    public void OnUndelete(List<Campaign> restoredItems) {
        
    }
}