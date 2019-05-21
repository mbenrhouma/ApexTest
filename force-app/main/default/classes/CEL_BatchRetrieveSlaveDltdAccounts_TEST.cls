@isTest
public class CEL_BatchRetrieveSlaveDltdAccounts_TEST {

    
    @testSetup
    static void setup() {
        List<Account> masters = new List<Account>{
            new Account(FirstName = 'TestMaster', LastName = 'TestName', PersonEmail = 'monprenom@gmail.com'),
            new Account(FirstName = 'TestMaster2', LastName = 'TestName2', PersonEmail = 'monprenom2@gmail.com')
        };
        List<Account> duplicates = new List<Account>{
            new Account(FirstName = 'TestFirstName', LastName = 'TestName', PersonEmail = 'monprenom11@gmail.com'),
            new Account(FirstName = 'TestFirstName', LastName = 'TestName', PersonEmail = 'monprenom12@gmail.com'),
            new Account(FirstName = 'TestFirstName', LastName = 'TestName', PersonEmail = 'monprenom13@gmail.com'),
            new Account(FirstName = 'TestFirstName', LastName = 'TestName', PersonEmail = 'monprenom14@gmail.com')
        };
            
        insert masters;
        insert duplicates;
        
        duplicates.get(0).PersonEmail = 'monprenom@gmail.com';
        duplicates.get(1).PersonEmail = 'monprenom1@gmail.com';
        duplicates.get(2).PersonEmail = 'monprenom2@gmail.com';
        duplicates.get(3).PersonEmail = 'monprenom2@gmail.com';
        update duplicates;
        
    }

    @isTest
    static void batchTest() {
        Test.startTest();
            Account master = [SELECT Id, RecordTypeId FROM Account WHERE FirstName = 'TestMaster' LIMIT 1];
            List<Account> accounts = [SELECT Id FROM Account WHERE PersonEmail = 'monprenom@gmail.com' AND Id != :master.Id];
            List<Id> duplicates = new List<Id>();
            for(Account a : accounts) {
                duplicates.add(a.Id);
            }
            Database.merge(master, duplicates);
            CEL_BatchRetrieveSlaveDeletedAccounts batch = new CEL_BatchRetrieveSlaveDeletedAccounts();
            batch.execute(null);
        Test.stopTest();

        Account duplicate = [SELECT Id, RecordTypeId,cel_master_account_id__c FROM Account WHERE FirstName = 'TestFirstName' LIMIT 1];
        
        System.assertEquals(CEL_Constants.peronAccountRtID, master.RecordTypeId);
        System.assertEquals(CEL_Constants.slavePersonAccountRtID, duplicate.RecordTypeId);
        System.assertEquals(master.Id, duplicate.cel_master_account_id__c);
    }
}