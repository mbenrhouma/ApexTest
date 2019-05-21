global class CEL_BatchAnonymization implements Database.Batchable<AggregateResult>, Database.Stateful, Schedulable {
    
    
    /**
     * start
     * @param {Database.BatchableContext} bc
     * @return {Iterable<AggregateResult>}
     */
    global Iterable<AggregateResult> start(Database.BatchableContext bc) {  
        return new AggregateResultIterable('SELECT cel_consent_log__c FROM Individual WHERE cel_consent_status__c = \'false\' and cel_Anonymized__c = false group by cel_consent_log__c having count(ID) > 2');
 	}
    
    /**
     * execute
     * @param {SchedulableContext} sc
     */    
    global void execute(SchedulableContext sc)
    {
        CEL_BatchAnonymization b = new CEL_BatchAnonymization();      
        database.executebatch(b);
    }
    
    
    /**
     * execute
     * @param {Database.BatchableContext} bc
     * @param List<sObject> scope
     */
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Account> anonymAcc= new List<Account>();
        Id accountId;
        Account acc;
        for(sObject sObj : scope) {
            AggregateResult ar = (AggregateResult)sObj;
            accountId = Id.valueOf(String.valueOf(ar.get('cel_consent_log__c')));
            acc = new Account();
            acc.Id = accountId;
            anonymAcc.add(acc);
        } 
        if(!anonymAcc.isEmpty()){
            CEL_AnonymizeUtil.anonymizeAccountAndRelation(anonymAcc);
        }

    }
    
    /**
     * finish
     * @param {Database.BatchableContext} bc
     */
    global void finish(Database.BatchableContext bc) {
        System.debug( '================= FINISH ====================' );
    }   
}