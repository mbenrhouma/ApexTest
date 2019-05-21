public class CEL_CampaignMemberTriggerHandler {
    
    /**
    * Trigger handle on before insert
    * @param {Map<Id, Account>} oldMap
    * @param {List<CampaignMember>} newList
    */
    public void OnBeforeInsert(Map<Id, CampaignMember> oldMap, List<CampaignMember> newList){
    }
    
    /**
    * Trigger handle on after insert
    * @param {List<CampaignMember>} newList
    */
    public void OnAfterInsert(List<CampaignMember> newList){
        //Get the Campaigns of type Parent or Child
        List<CampaignMember> theCampaignMembers = new List<CampaignMember>();
        Set<String> setIdContacts = new Set<String>();
        List<cel_Campaign_Member_Status__c> resultExistingOnes =  new List<cel_Campaign_Member_Status__c>();
        List<cel_Campaign_Member_Status__c> results =  new List<cel_Campaign_Member_Status__c>();
       
        String devRecordTypeChildActionId = '';
        String devRecordTypeParentActionId = '';
        
        try{
            devRecordTypeChildActionId = CEL_Constants.campaignEnfantRecordType;
            devRecordTypeParentActionId = CEL_Constants.campaignParentRecordType;
        }
        catch(Exception ex){
            system.debug('Error '+ ex);
        }
        
        List<String> listStringCampaign = new List<String>();
        List<Campaign> theCampaigns = new List<Campaign>();
        List<Id> listIdCampaignMemberToDelete = new List<Id>();
        Map<String, Campaign> Map_idCamp_campaign = new Map<String, Campaign>();
        List<String> listidContacts=new List<String>();
        
        for(CampaignMember cm : newList){
            listStringCampaign.add(cm.CampaignId);
            listidContacts.add(cm.contactId);
        }
        
        resultExistingOnes = [select id, cel_Contact__c, cel_campaign__c from cel_Campaign_Member_Status__c 
                                 where cel_contact__c in :listidContacts
                                 and cel_campaign__c in : listStringCampaign ];
       
        Set<String> toExcludeContact = new Set<String>();
        Map<String, String> MaptoExcludeCampaign = new Map<String, String>();
        for(cel_Campaign_Member_Status__c c : resultExistingOnes){
            toExcludeContact.add(c.cel_Contact__c);
            MaptoExcludeCampaign.put(c.cel_Contact__c, c.cel_campaign__c);
        }
        
        theCampaigns = [select id, recordtypeId from Campaign where id in : listStringCampaign];
       
        for(Campaign cp : theCampaigns){
            Map_idCamp_campaign.put(cp.id, cp);
        }
       
        for(CampaignMember cm : newList){
            if(!Map_idCamp_campaign.isempty()){
                if(Map_idCamp_campaign.get(cm.campaignId) != null){
                    String recordTypeCampaign = Map_idCamp_campaign.get(cm.campaignId).recordtypeId;
                    
                    if(recordTypeCampaign == devRecordTypeChildActionId)  {
                        if(!toExcludeContact.isempty()){
                            if(!toExcludeContact.contains(cm.contactId)){
                                theCampaignMembers.add(cm);
                                setIdContacts.add(cm.contactId);
                            }
                        }
                        else{
                            theCampaignMembers.add(cm);
                            setIdContacts.add(cm.contactId);
                        }
                    }
                    
                    // Delete campaign members object for campaign clienteling only
                    if(recordTypeCampaign == devRecordTypeParentActionId ||
                       recordTypeCampaign == devRecordTypeChildActionId){
                        listIdCampaignMemberToDelete.add(cm.id);
                    }
                }
            }
        }
        
        if(!theCampaignMembers.isEmpty()){
            CreateCampaignMemberStatus(theCampaignMembers, setIdContacts);
        }
        if(!listIdCampaignMemberToDelete.isEmpty()){
            DeleteCampaignMembers(listIdCampaignMemberToDelete);
        }
    }
    
    /**
    * Trigger handle on before update
    * @param {List<CampaignMember>} oldList
    * @param {List<CampaignMember>} newList
    * @param {Map<Id, CampaignMember>} newMap
    * @param {Map<Id, CampaignMember>} oldMap
    */
    public void OnBeforeUpdate(List<CampaignMember> oldList, List<CampaignMember> newList , Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap){
    }
    
    /**
    * Trigger handle on after update
    * @param {List<CampaignMember>} oldList
    * @param {List<CampaignMember>} newList
    * @param {Map<Id, CampaignMember>} newMap
    * @param {Map<Id, CampaignMember>} oldMap
    */
    public void OnAfterUpdate(List<CampaignMember> oldList, List<CampaignMember> newList , Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap){
    }
    
    /**
    * Trigger handle on before delete
    * @param {List<CampaignMember>} oldList
    * @param {List<CampaignMember>} newList
    */
    public void OnBeforeDelete(List<CampaignMember> oldList, Map<Id, CampaignMember> oldMap){
    }
    
    /**
    * Trigger handle on after delete
    * @param {List<CampaignMember>} oldList
    * @param {List<CampaignMember>} newList
    */
    public void OnAfterDelete(List<CampaignMember> oldList, Map<Id, CampaignMember> oldMap){
    }
    
    /**
    * Trigger handle on Un delete
    * @param {List<CampaignMember>} newList
    */
    public void OnUndelete(List<CampaignMember> newList ){
    }
    
    /**
    * CreateCampaignMemberStatus : create campaign members status with campaign members and contacts Ids
    * @param {List<CampaignMember>} theCampaignMembers
    * @param {Set<String>} setIdContacts
    * @return {List<cel_Campaign_Member_Status__c>} newList
    */
    public List<cel_Campaign_Member_Status__c> CreateCampaignMemberStatus(List<CampaignMember> theCampaignMembers, Set<String> setIdContacts){
        List<cel_Campaign_Member_Status__c> lstCampMemberStatus = new List<cel_Campaign_Member_Status__c>();
        List<contact> listContacts = new List<contact>();
        listContacts = [select id, accountid from contact where id in : setIdContacts];
        
        Map<String, String> map_idContact_idAccount = new Map<string, String>();
        
        
        for(contact c : listContacts){
            map_idContact_idAccount.put(c.id, c.accountId);
        }
        
        for(CampaignMember cm : theCampaignMembers ){
            //afect members to Campaign member Status
            cel_Campaign_Member_Status__c cmpMemStatus = new cel_Campaign_Member_Status__c(
                                        cel_Member_Name__c = map_idContact_idAccount.get(cm.ContactId),
                                        cel_Campaign__c = cm.CampaignId,
                                        cel_Contact__c = cm.ContactId
                                        );
            
            lstCampMemberStatus.add(cmpMemStatus);
        }
        
        if(!lstCampMemberStatus.isEmpty()){
            try{
                insert lstCampMemberStatus;
            }
            catch(Exception ex){
                system.debug('error on creating Campaignmembers CLASS = CEL_TheContactsController '+ lstCampMemberStatus);
            }
        }
        return lstCampMemberStatus;
    }
    
    /**
    * DeleteCampaignMembers : delete campaign memebrs for clienteling campaign
    * @param {List<Id>} listIdCampaignMemberToDelete
    */
    public void DeleteCampaignMembers(List<Id> listIdCampaignMemberToDelete){
        try{
            if(!listIdCampaignMemberToDelete.isempty()){
                Database.delete(listIdCampaignMemberToDelete);
            }
        }
        catch(Exception ex){
            system.debug('The CampaignMembers delete fail'+ ex);
        }
    }
}