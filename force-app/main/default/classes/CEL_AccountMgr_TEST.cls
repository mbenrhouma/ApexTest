@isTest
public class CEL_AccountMgr_TEST {
    
    @isTest
    static void testGetContactDetailsNull() {
        System.assertEquals(null, CEL_AccountMgr.getContactDetails(null));
    }
       
    @isTest
    static void testGetContactDetailsNotNullNotExisting() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        delete a;
        System.assertEquals(null, CEL_AccountMgr.getContactDetails(a.Id));
    }
       
    @isTest
    static void testGetContactDetailsNotNullExisting() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        System.assertNotEquals(null, CEL_AccountMgr.getContactDetails(a.Id));
    }
    
    @isTest
    static void testGetAvailableLists() {
        System.assertNotEquals(null,CEL_AccountMgr.getAvailableCountryList());
        System.assertNotEquals(null,CEL_AccountMgr.getAvailableChannelList());
        System.assertNotEquals(null,CEL_AccountMgr.getAvailableLanguageList());
    }

    @isTest
    static void testGetPersonContactIDNotNullExisting() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        System.assertNotEquals(null, CEL_AccountMgr.getPersonContactID(a.Id));
    }

    @isTest
    static void testGetPersonContactIDNull() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        System.assertEquals(null, CEL_AccountMgr.getPersonContactID(null));
    }

    
    @isTest
    static void testGetPersonContactNotNullNotExisting() {
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        delete a;       
        System.assertEquals(null, CEL_AccountMgr.getPersonContactID(a.Id));
    }
    
    @isTest
    static void testGetAvailableAppoitementList() {
        System.assertNotEquals(null,CEL_AccountMgr.getAvailablePreferredAppointmentTime());
    }

}