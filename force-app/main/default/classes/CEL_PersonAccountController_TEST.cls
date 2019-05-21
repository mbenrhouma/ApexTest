@isTest
public class CEL_PersonAccountController_TEST { 
    
    @isTest
    static void testGetContactDetailsNull() {
        System.assertEquals(null, CEL_PersonAccountController.getContactDetails(null));
    }
    
    @isTest
    static void testGetAvailableList() {
        System.assertNotEquals(null,CEL_PersonAccountController.getAvailableList());
    }
    
    @isTest
    static void testSaveAccount() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        System.assertNotEquals(null,CEL_PersonAccountController.saveAccount(a));        
    }
    
    @isTest
    static void testUpdateDQM() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        System.assertNotEquals(null,CEL_PersonAccountController.updateDQM(a));   
    }
    
    @isTest
    static void testGetFieldsAccess() {
        System.assertNotEquals(null,CEL_PersonAccountController.getFieldsAccess());
    }
    
    @isTest
    static void testHasFieldEditAccess() {
        System.assertEquals(false,CEL_PersonAccountController.hasFieldEditAccess('Account', 'ID'));
    }
    
    
}