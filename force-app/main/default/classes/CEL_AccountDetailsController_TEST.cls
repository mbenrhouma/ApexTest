@isTest
public class CEL_AccountDetailsController_TEST {
@isTest
    static void testGetAvailableList() {
        System.assertNotEquals(null,CEL_AccountDetailsController.getAvailableList());
    }
    
    @isTest
    static void testGetFieldsAccess() {
        System.assertNotEquals(null,CEL_AccountDetailsController.getFieldsAccess());        
    }
}