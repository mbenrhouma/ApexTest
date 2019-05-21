@isTest
public class CEL_UnsubscribeTrigger_TEST {
    
    @isTest
    static void testTrigger() {
        List<Account> accounts = Cel_DataFactoryForTests.createAccounts(1);
        CEL_unsubscribe__c u = Cel_DataFactoryForTests.createUnsubscribe(accounts.get(0));
        insert u;
        update u;
        delete u;
        undelete u;
    }

}