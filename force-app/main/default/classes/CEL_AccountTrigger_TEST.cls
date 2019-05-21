@isTest
public class CEL_AccountTrigger_TEST {
    
    @isTest
    static void testTrigger() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        update a;
        delete a;
        undelete a;
    }

}