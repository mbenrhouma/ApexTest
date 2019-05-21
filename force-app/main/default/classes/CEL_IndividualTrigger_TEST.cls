@isTest
public class CEL_IndividualTrigger_TEST {
    
    @isTest
    static void testTrigger() {
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account acc = accts.get(0);
        Individual ind = Cel_DataFactoryForTests.createIndividual(acc);
        insert ind;
        update ind;
        delete ind;
        undelete ind;
    }

}