@isTest
public class CEL_TaskMainController_TEST {
    @isTest
    static void testSaveTasksByStore() {
        Cel_DataFactoryForTests.createCustomSettings();
        Date testDate = Date.today().addDays(3);
        List<Account> accts = Cel_DataFactoryForTests.createAccountsWithOwner(1);
        Account a = accts.get(0);
        List<Account> storesList = Cel_DataFactoryForTests.createStores(2);
        String storeListId = '';
        for(Account store : storesList){
            storeListId = storeListId + ',' +store.Id;
        }
        Task taskToCreate = new Task(ActivityDate = testDate, Subject= 'TestSubject', Description='test Template');
        Map<String,String> createResult = CEL_TaskMainController.saveTasksByStore(taskToCreate,storeListId);

        System.assertNotEquals(null, createResult); 
    }
    
    @isTest
    static void testGeUserAccess() {
        Profile p;
        List<Profile> profileList = [SELECT id FROM profile where NAME like '%sys%'];
        if (profileList.size()>0) p=profileList.get(0); 
        else throw new System.Nullpointerexception();
        User u = new User(alias = 'test123', email='test1234@noemail.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                          localesidkey='fr_FR_EURO', profileid = p.Id, country='France',cel_Code_CGID_of_store__c='CEL01',
                          timezonesidkey='Europe/Paris', username='test213@noemail.com');
        insert u;
        
        System.runAs(u){
          System.assertEquals(true,CEL_TaskMainController.getUserAccess());  
        }
        
        
    }
    
    @isTest
    static void testGetAvailableList() {
        System.assertNotEquals(null, CEL_TaskMainController.getAvailableList()); 
    }

}