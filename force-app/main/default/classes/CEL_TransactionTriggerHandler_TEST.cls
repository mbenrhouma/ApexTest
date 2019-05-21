@isTest
public class CEL_TransactionTriggerHandler_TEST {

    @isTest
    static void testAfterInsert() {
        List<Cel_Transaction__c> trs = Cel_DataFactoryForTests.createTransactions(1);
        update trs;
        delete trs;
        undelete trs;
    }

}