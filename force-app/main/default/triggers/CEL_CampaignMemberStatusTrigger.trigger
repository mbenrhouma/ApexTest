trigger CEL_CampaignMemberStatusTrigger on cel_Campaign_Member_Status__c (after delete, after insert, 
                              after undelete, after update, 
                              before delete, before insert, 
                              before update) {
                                 
                                
    CEL_CampaignMemberStatusTriggerHandler handler = new CEL_CampaignMemberStatusTriggerHandler();
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.oldMap, Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
    }                                  
 

}