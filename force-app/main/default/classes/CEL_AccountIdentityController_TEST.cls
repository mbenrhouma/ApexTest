@isTest
public class CEL_AccountIdentityController_TEST {
 @isTest
    static void testGetAvailableList() {
        System.assertNotEquals(null,CEL_AccountIdentityController.getAvailableList());
    }
    
    @isTest
    static void testGetFieldsAccess() {
        System.assertNotEquals(null,CEL_AccountIdentityController.getFieldsAccess());        
    }
}