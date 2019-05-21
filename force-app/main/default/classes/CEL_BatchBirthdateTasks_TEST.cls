@isTest
public class CEL_BatchBirthdateTasks_TEST {
    @testSetup
    static void setup() {
        ID personAccountRtID = CEL_Constants.peronAccountRtID;
        List<Account> masters = new List<Account>{
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123456789', Type = 'CLI', FirstName = 'TestMaster1', LastName = 'TestName1',cel_birthdate_day__c = 10, cel_birthdate_month__c = 3,cel_segmentation__c='REPEAT')
        };    
        insert masters;
    }

    
    @isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new CEL_BatchBirthdateTasks('cel_birthday_normal'));
        CEL_BatchBirthdateTasks batch = new CEL_BatchBirthdateTasks('cel_birthday_normal');
        batch.execute(null);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE Subject = 'Birthday'];
        System.assertNotEquals(null, tasks);

    }

}