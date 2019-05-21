@isTest
public class CEL_BatchAlertTasks_TEST {
    @testSetup
    static void setup() {
        ID personAccountRtID = CEL_Constants.peronAccountRtID;
        Date lastPurchaseDate = Date.today().addDays(-120);
        Date lastContactDate = Date.today().addDays(-121);
        List<Account> masters = new List<Account>{
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123456789', Type = 'CLI', FirstName = 'TestMaster1', LastName = 'TestName1',cel_last_purchase_date__c =lastPurchaseDate,cel_Last_Contact_Date__c=lastContactDate,cel_segmentation__c='VIC')
        };    
        insert masters;
    }

    
    @isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new CEL_BatchAlertTasks('cel_Downgrade_Alert_VIC'));
        CEL_BatchAlertTasks batch = new CEL_BatchAlertTasks('cel_Downgrade_Alert_VIC');
        batch.execute(null);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE Subject = 'Downgrade Alert'];
        System.assertNotEquals(null, tasks);

    }

}