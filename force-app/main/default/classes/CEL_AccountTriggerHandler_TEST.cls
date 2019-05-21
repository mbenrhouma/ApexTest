@isTest
public class CEL_AccountTriggerHandler_TEST {

    @isTest
    static void testOnBeforeInsert() {
        Cel_DataFactoryForTests.createCustomSettings();
        Cel_DataFactoryForTests.createTranscodifications(1, CEL_Constants.transcoAreaRtID);
        Cel_DataFactoryForTests.createTranscodifications(1, CEL_Constants.transcoTitleRtID);
        Cel_DataFactoryForTests.createStores(1);
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        
    }

    @isTest
    static void testOnBeforeUpdate() {
        Cel_DataFactoryForTests.createCustomSettings();
        Cel_DataFactoryForTests.createTranscodifications(1, CEL_Constants.transcoAreaRtID);
        Cel_DataFactoryForTests.createTranscodifications(1, CEL_Constants.transcoTitleRtID);
        List<Account> stores = Cel_DataFactoryForTests.createStores(1);
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        a.PersonBirthDate = Date.newInstance(1993, 10, 12);
        update a;    
        Account s = stores.get(0);
        s.cel_addr_1_region__c = 'EMEA';
        update s;
        delete a;
        undelete a;    
    }
}