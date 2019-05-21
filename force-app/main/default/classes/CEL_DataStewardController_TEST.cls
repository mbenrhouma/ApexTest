@isTest
public class CEL_DataStewardController_TEST {
    
    @isTest
    static void testDataStewardController() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Account a = CEL_DataStewardController.getContactDetails(acc.Id); 
        System.assertNotEquals(null, a);
    }
}