global class CEL_Update_Consent_CCM_From_Transaction implements Database.Batchable<sObject>, Database.Stateful {
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} BC
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT ID, cel_start_date_consentment__c, cel_consent_status__c, cel_consent_log__c FROM Individual where cel_Purpose__c = 'CRM']);
    }

    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param [{cel_Transaction_Line__c}] transaction lines
     */
    global void execute(Database.BatchableContext BC, List<Individual> inds) {
        Map<ID, Individual> mapsIndivdualsTransactionsAccount = new Map<ID, Individual>();
        for(Individual ind : inds) {
            if(ind.cel_consent_log__c != null) {
                mapsIndivdualsTransactionsAccount.put(ind.cel_consent_log__c, ind);
            }
        }
        Set<Id> accountIds = mapsIndivdualsTransactionsAccount.keySet();
        
        if(accountIds != null && !accountIds.isEmpty()) {
            List<Individual> indsCCM = [SELECT ID, cel_start_date_consentment__c, cel_consent_status__c, cel_consent_log__c FROM Individual where cel_Purpose__c = 'CCM' and cel_consent_log__c in :accountIds];
            
            Individual indTransaction;
            for(Individual indCCM : indsCCM) {
                if(mapsIndivdualsTransactionsAccount.containsKey(indCCM.cel_consent_log__c)) {
                    indTransaction = mapsIndivdualsTransactionsAccount.get(indCCM.cel_consent_log__c);
                    if(indCCM.cel_start_date_consentment__c < indTransaction.cel_start_date_consentment__c) {
                        indCCM.cel_start_date_consentment__c = indTransaction.cel_start_date_consentment__c;
                        indCCM.cel_Consent_Status__c = indTransaction.cel_consent_status__c;
                    }
                }
            }
            update indsCCM;
        }
    }

    
    /**
     * finish: Call at the end of the batch
     * @param  {BatchableContext} BC
     */
    global void finish(Database.BatchableContext BC) {
        System.debug( '================= FINISH ====================' );
    }

}