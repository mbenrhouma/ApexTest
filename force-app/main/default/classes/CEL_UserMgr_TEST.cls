@isTest
public class CEL_UserMgr_TEST {    
    
    @isTest
    static void testHasFieldEditAccess() {
        System.assertEquals(false,CEL_UserMgr.hasFieldEditAccess('Account', 'ID'));
    }

}