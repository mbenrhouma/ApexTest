global class CEL_Update_CCM_Cosnent implements Database.Batchable<sObject>, Database.Stateful {
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} BC
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT ID, cel_start_date_consentment__c, cel_consent_log__r.cel_optin_postal_mail__c, cel_consent_log__r.cel_optin_sms__c, cel_consent_log__r.cel_do_not_email__c, cel_consent_log__r.PersonDoNotCall, cel_consent_log__r.cel_creation_date__c, cel_consent_status__c FROM Individual where cel_Purpose__c = 'CCM']);
    }

    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param [{cel_Transaction_Line__c}] transaction lines
     */
    global void execute(Database.BatchableContext BC, List<Individual> inds) {
        Boolean status = false;
        for(Individual ind : inds) {
            status = ind.cel_consent_log__r.cel_optin_postal_mail__c || ind.cel_consent_log__r.cel_optin_sms__c || ind.cel_consent_log__r.cel_do_not_email__c || ind.cel_consent_log__r.PersonDoNotCall;
            if(ind.cel_consent_status__c != String.valueOf(status) && String.valueOf(status) == CEL_Constants.consentStatus.get('ON'))  {
                ind.cel_start_date_consentment__c = ind.cel_consent_log__r.cel_creation_date__c;
            }
            ind.cel_consent_status__c = String.valueOf(status);
        }
        update inds;
    }

    
    /**
     * finish: Call at the end of the batch
     * @param  {BatchableContext} BC
     */
    global void finish(Database.BatchableContext BC) {
        System.debug( '================= FINISH ====================' );
    }

}