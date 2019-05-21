@isTest
public class CEL_CaseMgr_TEST {
    
    @isTest
    static void testAnonymizeCase() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accounts = Cel_DataFactoryForTests.createAccountsWithCases(2,2);
        
        Boolean result = CEL_CaseMgr.anonymizeCase(accounts);
        
        System.assertNotEquals(false, result);
    }
}