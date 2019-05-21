public class CEL_IndividualTriggerHandler {

    public CEL_IndividualTriggerHandler() {

    }

    /**
     * Trigger handle on before insert
     * @param {Map<Id, Individual>} oldMap
     * @param {List<Individual>} newItems
     */
    public void OnBeforeInsert(Map<Id, Individual> oldMap, List<Individual> newItems) {

    }

    /**
     * Trigger handle on after insert
     * @param {List<Individual>} newItems
     */
    public void OnAfterInsert(List<Individual> newItems) {
    }

    /**
     * Trigger handle on before update
     * @param {List<Individual>} oldItems
     * @param {List<Individual>} updatedItems
     * @param {Map<Id, Individual>} itemMap
     * @param {Map<Id, Individual>} oldItemMap
     */
    public void OnBeforeUpdate(List<Individual>  oldItems, List<Individual> updatedItems, Map<Id, Individual> itemMap, Map<Id, Individual> oldItemMap) {
        List<Id> accounts = new List<Id>();
        for (Individual ind : updatedItems) {
            Individual oldConsent = oldItemMap.get(ind.Id);
            Individual newConsent = itemMap.get(ind.Id);
            if (oldConsent.cel_consent_status__c != newConsent.cel_consent_status__c 
                    && !newConsent.cel_updated_by_trigger__c
                    && newConsent.cel_consent_status__c == CEL_Constants.consentStatus.get('OFF')
                    ) {
                accounts.add(newConsent.cel_consent_log__c);
            }
            ind.cel_updated_by_trigger__c = false;
        }

        if(!accounts.isEmpty()){
            List<Account> accountsToUpdate = [SELECT ID, cel_optin_postal_mail__c, cel_optin_sms__c, cel_do_not_email__c FROM Account WHERE Id in :accounts];
            for (Account a: accountsToUpdate) {
                a.cel_optin_postal_mail__c = false;
                a.cel_optin_sms__c = false;
                a.cel_do_not_email__c = false;
                a.AccountSource = CEL_Constants.accountModificationFrom.get('IndividualTrigger');
            }
            update accountsToUpdate;
        }
    }

    /**
     * Trigger handle on after update
     * @param {List<Individual>} olditems
     * @param {List<Individual>} updatedItems
     * @param {Map<Id, Individual>} itemMap
     * @param {Map<Id, Individual>} oldItemMap
     */
    public void OnAfterUpdate(List<Individual> oldItems, List<Individual> updatedItems, Map<Id, Individual> itemMap, Map<Id, Individual> oldItemMap) {
    }

    /**
     * Trigger handle on before delete
     * @param {List<Individual>} itemsToDelete
     * @param {Map<Id, Individual>} itemMap
     */
    public void OnBeforeDelete(List<Individual> itemsToDelete, Map<Id, Individual> itemMap) {

    }

    /**
     * Trigger handle on after delete
     * @param {List<Individual>} itemsToDelete
     * @param {Map<Id, Individual>} itemMap
     */
    public void OnAfterDelete(List<Individual> itemsToDelete, Map<Id, Individual> itemMap) {

    }

    /**
     * Trigger handle on after undelete
     * @param {List<Individual>} restoredItems
     */
    public void OnUndelete(List<Individual> restoredItems) {

    }
}