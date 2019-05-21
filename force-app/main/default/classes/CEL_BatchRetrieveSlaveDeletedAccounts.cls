global with sharing class CEL_BatchRetrieveSlaveDeletedAccounts implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} BC
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext BC )
    {
        return Database.getQueryLocator([SELECT Id,MasterRecordId,cel_master_account_id__c FROM Account 
                                        WHERE isDeleted = true AND (MasterRecordId != null OR cel_master_account_id__c != null) AND LastModifiedDate >= Last_N_Days:15 ALL ROWS]);
    }
    
    /**
     * execute
     * @param {SchedulableContext} sc
     */    
    global void execute(SchedulableContext sc)
    {
        CEL_BatchRetrieveSlaveDeletedAccounts b = new CEL_BatchRetrieveSlaveDeletedAccounts();      
        database.executebatch(b);
    }
    
    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param [{LIst<Account>}] items
     */
    global void execute(Database.BatchableContext BC, List<Account> items)
    {
        if( items != null && !items.isEmpty()){
            //to save masterRecordId since it will be to null after undelete
            Map<String,String> mapDeletedAccountAndMaster = new Map<String,String>();
            for(Account act : items){
                String masterRecordIdValue = String.isNotBlank(act.MasterRecordId) ? act.MasterRecordId : act.cel_master_account_id__c;
                mapDeletedAccountAndMaster.put(act.Id,masterRecordIdValue);      
            }
            
            undelete items;
            List<Account> accountsToUpdate = [select Id, RecordTypeId, MasterRecordId, cel_master_account_id__c,cel_desactivation_date__c,cel_is_active__pc from Account where Id in :items];
            for (Account a: accountsToUpdate) {
                // Change recordType to Slave
                a.RecordTypeId = CEL_Constants.slavePersonAccountRtID;
                a.cel_master_account_id__c = mapDeletedAccountAndMaster.get(a.Id);
                a.cel_desactivation_date__c = Date.today();
                a.cel_is_active__pc = false;
            }
            
            Database.update(accountsToUpdate);
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