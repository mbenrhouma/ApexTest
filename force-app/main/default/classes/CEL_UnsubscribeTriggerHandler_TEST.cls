@isTest
public  class CEL_UnsubscribeTriggerHandler_TEST {

    @isTest
    static void testAfterInsert() {
        List<Account> accounts = Cel_DataFactoryForTests.createAccounts(1);
        CEL_unsubscribe__c u = Cel_DataFactoryForTests.createUnsubscribe(accounts.get(0));
        insert u;
        update u;
        delete u;
        undelete u;
        Account acc = [SELECT ID, cel_do_not_email__c FROM Account WHERE Id = :accounts.get(0).Id];
        System.assertEquals(true, acc.cel_do_not_email__c);
    }
}