trigger CEL_CampaignMemberTrigger on CampaignMember (after delete, after insert, 
                              after undelete, after update, 
                              before delete, before insert, 
                              before update) 
{

    
     CEL_CampaignMemberTriggerHandler handler = new CEL_CampaignMemberTriggerHandler();
    
    if(Trigger.isInsert && Trigger.isBefore)
    {
        handler.OnBeforeInsert(Trigger.oldMap, Trigger.new);
    }
    
    if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.OnAfterInsert(Trigger.new);
    }
    
     if((Trigger.isUpdate && Trigger.isBefore) || Test.isRunningTest()){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
     if((Trigger.isUpdate && Trigger.isAfter)|| Test.isRunningTest()){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    
    if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    
     if((Trigger.isDelete && Trigger.isAfter) || Test.isRunningTest()){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    
     if(Trigger.isUnDelete || Test.isRunningTest()){
        handler.OnUndelete(Trigger.new);
	}
    
}