@isTest
public class CEL_BatchSecondVisit_TEST {
    @testSetup
    static void setup() {
        ID personAccountRtID = CEL_Constants.peronAccountRtID;
        Date lastPurchaseDate = Date.today().addDays(-120);
        Date lastContactDate = Date.today().addDays(-121);
        List<Account> masters = new List<Account>{
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123456789', Type = 'CLI', FirstName = 'TestMaster1', LastName = 'TestName1',cel_last_purchase_date__c =lastPurchaseDate,cel_Last_Contact_Date__c=lastContactDate,cel_segmentation__c='CRUSH')
        };    
        insert masters;
    }

    
    @isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new CEL_BatchSecondVisit('cel_second_visit_activation'));
        CEL_BatchSecondVisit batch = new CEL_BatchSecondVisit('cel_second_visit_activation');
        batch.execute(null);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE Subject = 'Second Visit Activation'];
        System.assertNotEquals(null, tasks);

    }

}