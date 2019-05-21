@isTest
public class CEL_IndividualMgr_TEST {

    @isTest
    static void testConstructIndividualFromTransaction() {
        List<Cel_Transaction__c> trs = Cel_DataFactoryForTests.createTransactions(1);
        Individual consentTransaction = CEL_IndividualMgr.constructIndividualFromTransaction(trs.get(0));
        System.assertNotEquals(null , consentTransaction);
    }

    @isTest
    static void testConstructIndividualFromCase() {
        
    }

    @isTest
    static void testConstructIndividualFromCaseClaim() {
        
    }

    @isTest
    static void testUpdateExtrationDate() {
        
    }

    @isTest
    static void testConstructIndividualFromAccount() {
        
    }
}