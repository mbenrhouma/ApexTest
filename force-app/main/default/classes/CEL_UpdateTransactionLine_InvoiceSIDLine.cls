global class CEL_UpdateTransactionLine_InvoiceSIDLine implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} BC
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = Date.Today();
        String consentOn = CEL_Constants.consentStatus.get('ON');
        return Database.getQueryLocator([SELECT ID, cel_invoice_sid__c, cel_invoice_line__c, cel_invoice_SID_Line__c  FROM cel_Transaction_Line__c]);
    }
    
    /**
     * execute
     * @param {SchedulableContext} sc
     */    
    global void execute(SchedulableContext sc)
    {
        CEL_UpdateTransactionLine_InvoiceSIDLine b = new CEL_UpdateTransactionLine_InvoiceSIDLine();      
        database.executebatch(b);
    }

    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param [{cel_Transaction_Line__c}] transaction lines
     */
    global void execute(Database.BatchableContext BC, List<cel_Transaction_Line__c> trls) {
        for(cel_Transaction_Line__c trl : trls) {
            trl.cel_invoice_SID_Line__c = trl.cel_invoice_sid__c + '_' + String.valueOf(trl.cel_invoice_line__c.intValue());
        }
        update trls;
    }

    
    /**
     * finish: Call at the end of the batch
     * @param  {BatchableContext} BC
     */
    global void finish(Database.BatchableContext BC) {
        System.debug( '================= FINISH ====================' );
    }

}