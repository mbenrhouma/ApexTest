@isTest
public class CEL_BatchUpdateExpiredConsent_TEST {
    
    @isTest
    static void testBatch() {
        Test.startTest();
            Database.executeBatch(new CEL_BatchUpdateExpiredConsent());
        Test.stopTest();
    }

    @isTest
    static void testExpiredConsent() {
        Cel_DataFactoryForTests.createIndividual();
        Test.startTest();
            Database.executeBatch(new CEL_BatchUpdateExpiredConsent());
            CEL_BatchUpdateExpiredConsent batch = new CEL_BatchUpdateExpiredConsent();
            batch.execute(null);
        Test.stopTest();
    }

}