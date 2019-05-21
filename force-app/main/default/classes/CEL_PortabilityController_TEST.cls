@isTest
public class CEL_PortabilityController_TEST {

    @isTest
    static void testGetAvailableReports() {
        system.assertNotEquals(null, CEL_PortabilityController.getAvailableReports());
    }

    @isTest
    static void testUpdateExtractionDate() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        CEL_PortabilityController.updateExtractionDate(a.Id);
    }

    @isTest
    static void testGetAccount() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        system.assertNotEquals(null, CEL_PortabilityController.getAccount(a.Id));
    }
}