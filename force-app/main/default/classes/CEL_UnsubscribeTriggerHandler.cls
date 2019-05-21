public with sharing class CEL_UnsubscribeTriggerHandler {
    
    public CEL_UnsubscribeTriggerHandler(){
        
    }
    
    /**
    * Trigger handle on before insert
    * @param {Map<Id, CEL_unsubscribe__c>} oldMap
    * @param {List<CEL_unsubscribe__c>} newItems
    */
    public void OnBeforeInsert(Map<Id,CEL_unsubscribe__c> oldMap, List<CEL_unsubscribe__c> newItems) {
    }
    
    /**
    * Trigger handle on after insert
    * @param {List<CEL_unsubscribe__c>} newItems
    */
    public void OnAfterInsert(List<CEL_unsubscribe__c> newItems) {
        List<Id> accountsID = new List<Id>();
        for(CEL_unsubscribe__c un : newItems) {
            accountsID.add(un.cel_account_id__c);
        }

        List<Account> accts = [SELECT ID, cel_do_not_email__c FROM Account WHERE ID IN :accountsID];
        for(Account a : accts) {
            a.cel_do_not_email__c = true;
        }

        update accts;
    }
    
    /**
    * Trigger handle on before update
    * @param {List<CEL_unsubscribe__c>} oldItems
    * @param {List<CEL_unsubscribe__c>} updatedItems
    * @param {Map<Id, CEL_unsubscribe__c>} itemMap
    * @param {Map<Id, CEL_unsubscribe__c>} oldItemMap
    */
    public void OnBeforeUpdate(List<CEL_unsubscribe__c> oldItems, List<CEL_unsubscribe__c> updatedItems, Map<Id, CEL_unsubscribe__c> itemMap, Map<Id, CEL_unsubscribe__c> oldItemMap) {
    } 
    
    /**
    * Trigger handle on after update
    * @param {List<CEL_unsubscribe__c>} olditems
    * @param {List<CEL_unsubscribe__c>} updatedItems
    * @param {Map<Id, CEL_unsubscribe__c>} itemMap
    * @param {Map<Id, CEL_unsubscribe__c>} oldItemMap
    */
    public void OnAfterUpdate(List<CEL_unsubscribe__c> oldItems, List<CEL_unsubscribe__c> updatedItems, Map<Id, CEL_unsubscribe__c> itemMap, Map<Id, CEL_unsubscribe__c> oldItemMap) {    	
    }
    
    /**
    * Trigger handle on before delete
    * @param {List<CEL_unsubscribe__c>} itemsToDelete
    * @param {Map<Id, CEL_unsubscribe__c>} itemMap
    */
    public void OnBeforeDelete(List<CEL_unsubscribe__c> itemsToDelete, Map<Id, CEL_unsubscribe__c> itemMap) {
        
    }
    
    /**
    * Trigger handle on after delete
    * @param {List<CEL_unsubscribe__c>} itemsToDelete
    * @param {Map<Id, CEL_unsubscribe__c>} itemMap
    */
    public void OnAfterDelete(List<CEL_unsubscribe__c> itemsToDelete, Map<Id, CEL_unsubscribe__c> itemMap) {
        
    }
    
    /**
    * Trigger handle on after undelete
    * @param {List<CEL_unsubscribe__c>} restoredItems
    */
    public void OnUndelete(List<CEL_unsubscribe__c> restoredItems) {
    }

}