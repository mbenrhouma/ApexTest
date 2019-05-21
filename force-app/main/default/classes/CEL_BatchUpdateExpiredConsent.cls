global class CEL_BatchUpdateExpiredConsent implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} BC
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = Date.Today();
        String consentOn = CEL_Constants.consentStatus.get('ON');
        return Database.getQueryLocator([SELECT ID FROM Individual WHERE cel_end_date_consentment__c < :today and cel_Consent_Status__c = :consentOn]);
    }
    
    /**
     * execute
     * @param {SchedulableContext} sc
     */    
    global void execute(SchedulableContext sc)
    {
        CEL_BatchUpdateExpiredConsent b = new CEL_BatchUpdateExpiredConsent();      
        database.executebatch(b);
    }

    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param [{Account}] accounts
     */
    global void execute(Database.BatchableContext BC, List<Individual> consents) {
        String consentOff = CEL_Constants.consentStatus.get('OFF');
        for(Individual ind : consents) {
            ind.cel_Consent_Status__c = consentOff;
        }
        update consents;
    }

    
    /**
     * finish: Call at the end of the batch
     * @param  {BatchableContext} BC
     */
    global void finish(Database.BatchableContext BC) {
        System.debug( '================= FINISH ====================' );
    }

}