@isTest
public class CEL_AccountInformationController_TEST {
@isTest
    static void testGetAvailableList() {
        System.assertNotEquals(null,CEL_AccountOtherInformationController.getAvailableList());
    }
    
    @isTest
    static void testGetFieldsAccess() {
        System.assertNotEquals(null,CEL_AccountOtherInformationController.getFieldsAccess());        
    }
}