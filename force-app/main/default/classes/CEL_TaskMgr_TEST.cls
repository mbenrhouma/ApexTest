@isTest
public class CEL_TaskMgr_TEST {
    @isTest
    static void testCreateBirthDateTask() {
        Cel_DataFactoryForTests.createCustomSettings();
        Date testDate = Date.today().addDays(3);
        List<Account> accts = Cel_DataFactoryForTests.createAccountsWithOwner(1);
        Account a = accts.get(0);
        Task taskToCreateTest = CEL_TaskMgr.createBirthDateTask(a,testDate,'TestSubject', 1 , 'test Template');
        System.assertEquals(testDate.addDays(1),taskToCreateTest.ActivityDate);
    }
    
    @isTest
    static void testUpdateTaskToLate() {
        Cel_DataFactoryForTests.createCustomSettings();
        Date testDate = Date.today().addDays(3);
        List<Account> accts = Cel_DataFactoryForTests.createAccountsWithOwner(1);
        Account a = accts.get(0);
        Task taskToCreateTest = Cel_DataFactoryForTests.createTask(a);
        taskToCreateTest = CEL_TaskMgr.updateTaskToLate(taskToCreateTest);
        update taskToCreateTest;
        System.assertEquals('LATE',taskToCreateTest.Status);
    }
    
    @isTest
    static void testUpdateTaskToOverdue() {
        Cel_DataFactoryForTests.createCustomSettings();
        Date testDate = Date.today().addDays(3);
        List<Account> accts = Cel_DataFactoryForTests.createAccountsWithOwner(1);
        Account a = accts.get(0);
        Task taskToCreateTest = Cel_DataFactoryForTests.createTask(a);
        CEL_TaskMgr.updateTaskToOverdue(taskToCreateTest);
        update taskToCreateTest;
        System.assertEquals('NOTD',taskToCreateTest.Status);
    }

}