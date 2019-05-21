@isTest
public class CEL_BatchTasksEvolution_TEST {
    @testSetup
    static void setup() {
        Cel_DataFactoryForTests.createCustomSettings();
        Date testDate = Date.today().addDays(3);
        List<Account> accts = Cel_DataFactoryForTests.createAccountsWithOwner(1);
        Account a = accts.get(0);
        Task taskToCreateTest = Cel_DataFactoryForTests.createTask(a);
        taskToCreateTest.ActivityDate = Date.today().addDays(-1);
    }

    
    @isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new CEL_BatchTasksEvolution());
        CEL_BatchTasksEvolution batch = new CEL_BatchTasksEvolution();
        batch.execute(null);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE Subject = 'Birthday' AND Status ='LATE'];
        System.assertNotEquals(null, tasks);

    }
}