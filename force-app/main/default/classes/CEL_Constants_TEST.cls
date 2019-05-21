@isTest
public class CEL_Constants_TEST {
    
    @isTest
    static void testConstants() {
        Cel_DataFactoryForTests.createCustomSettings();
        System.assertNotEquals(null, CEL_Constants.interfaceUserId, 'The interface user id should not be null.');
    }
}