@isTest
public class CEL_AccountStyleAndSizeController_TEST {

    @isTest
    static void testGetAvailableList() {
        System.assertNotEquals(null,CEL_AccountStyleAndSizeController.getAvailableList());
    }
    
    @isTest
    static void testGetFieldsAccess() {
        System.assertNotEquals(null,CEL_AccountStyleAndSizeController.getFieldsAccess());        
    }
    
}