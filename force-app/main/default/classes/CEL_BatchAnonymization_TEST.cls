@isTest
public class CEL_BatchAnonymization_TEST {
    
    @testSetup
    static void setup() {
        
        List<Individual> listIndividuals = new  List<Individual>() ; 
        List<Account> listAccounts = new List<Account>{
            new Account( cel_ext_account_id__c = '123456789', FirstName = 'Test1', LastName = 'TestName1', cel_PersonEmail__c = 'prenom1@test.com', PersonBirthDate = Date.newInstance(1993, 06, 06), cel_birthdate_day__c = 6, cel_birthdate_month__c = 06, cel_birthdate_year__c = 1993, cel_email_mailable__c = 'N', PersonMobilePhone = '0653452478', cel_is_email_contactibiliy__c = false, cel_is_phone_contactability__c = false, cel_mobile_mailable__c = 'Y')
                };
                    insert listAccounts ; 
        for(account acc : listAccounts){
            Individual indi = new Individual(LastName='Indiv', cel_Consent_log__c= acc.Id, cel_Deletion__c=true) ; 
                listIndividuals.add(indi)  ; 
                }
        insert listIndividuals; 
    }
    
    @isTest
    static void testBatch() {
        Test.startTest();
        CEL_BatchAnonymization batch = new CEL_BatchAnonymization();
        batch.execute(null);
        Test.stopTest();
        
        List<Account> accts = [SELECT Id FROM Account WHERE cel_PersonEmail__c = 'prenom1@test.com'];
        System.assertEquals(0, accts.size());
        
    }
    
}