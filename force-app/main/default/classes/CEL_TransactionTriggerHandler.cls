public with sharing class CEL_TransactionTriggerHandler {
    
    
    /**
    * CEL_TransactionTriggerHandler : [description]
    * @param {}
    *
    */
    public CEL_TransactionTriggerHandler(){
        
    }
    
    
    
    
    
    /**
    * OnBeforeInsert : [description]
    * @param {(Map<Id,cel_Transaction__c> oldMap
    * @param List<cel_Transaction__c>} newItems
    *
    */
    public void OnBeforeInsert(Map<Id,cel_Transaction__c> oldMap, List<cel_Transaction__c> newItems){
        
    }
    
    
    /**
    * OnAfterInsert : [description]
    * @param {List<cel_Transaction__c>} newItems
    *
    */
    public void OnAfterInsert(List<cel_Transaction__c> newItems){
        List<Individual> individualToUpsert = createOrUpdateIndividual(newItems);
        if(!individualToUpsert.isEmpty()) {
            upsert individualToUpsert;
        }
    }
    
    
    /**
    * OnBeforeUpdate : [description]
    * @param {List<cel_Transaction__c>} oldItems
    * @param {List<cel_Transaction__c>} updatedItems
    * @param {Map<Id, cel_Transaction__c>} itemMap
    * @param {Map<Id, cel_Transaction__c>} oldItemMap
    */
    public void OnBeforeUpdate(List<cel_Transaction__c> oldItems, List<cel_Transaction__c> updatedItems, Map<Id, cel_Transaction__c> itemMap, Map<Id, cel_Transaction__c> oldItemMap) {
        
        
    }
    
    
    /**
    * OnAfterUpdate : [description]
    * @param {List<cel_Transaction__c>} oldItems
    * @param {List<cel_Transaction__c>} updatedItems
    * @param {Map<Id, cel_Transaction__c>} itemMap
    * @param {Map<Id, cel_Transaction__c>} oldItemMap
    */
    public void OnAfterUpdate(List<cel_Transaction__c> oldItems, List<cel_Transaction__c> updatedItems, Map<Id, cel_Transaction__c> itemMap, Map<Id, cel_Transaction__c> oldItemMap) {
        List<Individual> individualToUpsert = createOrUpdateIndividual(updatedItems);
        if(!individualToUpsert.isEmpty()) {
            upsert individualToUpsert;
        }
    }
    
    /**
    *  OnBeforeDelete : [description]
    * @param {List<cel_Transaction__c>} itemsToDelete
    * @param {Map<Id, cel_Transaction__c>} itemMap
    */
    public void OnBeforeDelete(List<cel_Transaction__c> itemsToDelete, Map<Id,cel_Transaction__c> itemMap){
        
    }
    
    /**
    * OnAfterDelete : [description]
    * @param {List<cel_Transaction__c>} itemsToDelete
    * @param {Map<Id, cel_Transaction__c>} itemMap
    *
    */
    public void OnAfterDelete(List<cel_Transaction__c> itemsToDelete, Map<Id,cel_Transaction__c> itemMap){
        
    }
    
    /**
    * OnUndelete : [description]
    * @param {List<cel_Transaction__c> } restoredItems
    *
    */
    public void OnUndelete(List<cel_Transaction__c> restoredItems) {
        
    }
    
    /**
    * createOrUpdateIndividual : Create or update consent from transactions
    * @param {Map<ID,cel_Transaction__c>} mapAccountTransa
    * @return {List<Individual>}
    */
    private List<Individual> createOrUpdateIndividual(List<cel_transaction__c> transactions) {
        List<Individual> individualsToUpsert = new List<Individual>();
        List<Id> relatedAccounts = new List<Id>();
        List<Individual> listExistingIndiv = new List<Individual>();
        Map<ID,Individual> mapAccountTransactionConsent = new Map<ID,Individual>();
        Map<ID,Individual> mapAccountCcmConsent = new Map<ID,Individual>();
        List<Individual> individualsToUpdate = new List<Individual>();
        Individual existingTransactionConsent;
        Individual newTransactionConsent;
        Individual existingOptinConsent;
        Id accountId;
        Boolean updateConsentTransaction = false;
        String ccmConsent = CEL_Constants.consentPurpose.get('CCM');
        String transactionConsent = CEL_Constants.consentType.get('Transaction');
        
        for(cel_Transaction__c transa : transactions){
            relatedAccounts.add(transa.cel_AccountId__c);
        }
        
        listExistingIndiv = [SELECT Id, cel_Consent_log__c, cel_consent_status__c, cel_purpose__c, cel_Type__c, cel_start_date_consentment__c FROM Individual WHERE cel_Consent_log__c = :relatedAccounts AND (cel_purpose__c = :ccmConsent OR cel_Type__c = :transactionConsent) order by createdDate DESC];
        
        for(Individual indiv : listExistingIndiv) {
            if (indiv.cel_purpose__c == ccmConsent) {
                mapAccountCcmConsent.put(indiv.cel_consent_log__c,indiv);
            }
            if (indiv.cel_Type__c == transactionConsent) {
                mapAccountTransactionConsent.put(indiv.cel_consent_log__c,indiv);
            }
        }
        
        for(cel_Transaction__c trans : transactions){
            updateConsentTransaction = false;
            accountId = trans.cel_AccountId__c;
            if (mapAccountTransactionConsent.containsKey(accountId)){
                existingTransactionConsent = mapAccountTransactionConsent.get(accountId);
                if(existingTransactionConsent.cel_start_date_consentment__c == null || existingTransactionConsent.cel_start_date_consentment__c < trans.cel_sale_date__c) {
                    Individual indToUpdate = CEL_IndividualMgr.constructIndividualFromTransaction(trans);
                    indToUpdate.Id = existingTransactionConsent.Id;
                    mapAccountTransactionConsent.put(existingTransactionConsent.cel_consent_log__c, indToUpdate);
                    updateConsentTransaction = true;
                }
            } else {
                newTransactionConsent = CEL_IndividualMgr.constructIndividualFromTransaction(trans);
                mapAccountTransactionConsent.put(accountId, newTransactionConsent);
                updateConsentTransaction = true;
            }
            
            // Update CCM Consent if is not OFF
            if(mapAccountCcmConsent.containsKey(accountId) && updateConsentTransaction) {
                existingOptinConsent = mapAccountCcmConsent.get(accountId);
                existingOptinConsent.cel_start_date_consentment__c = trans.cel_sale_date__c;
                existingOptinConsent.cel_consent_status__c = CEL_Constants.consentStatus.get('ON');
                mapAccountCcmConsent.put(accountId, existingOptinConsent);
            }
        }
        
        individualsToUpsert.addAll(mapAccountTransactionConsent.values());
        individualsToUpsert.addAll(mapAccountCcmConsent.values());
        
        return individualsToUpsert;
    }
    
}