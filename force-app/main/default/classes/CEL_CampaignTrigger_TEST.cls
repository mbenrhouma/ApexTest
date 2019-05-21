@isTEst
public class CEL_CampaignTrigger_TEST {

     @isTest
    static void theTest()
    {
        List<Recordtype> listRec = [select id, name from recordtype where 
                                    developerName = 'ParentAction' or developerName = 'ChildAction'
                                    order by developerName ];
        Campaign c1_parent = new Campaign(
                                            recordtypeid=listRec.get(1).id,
                                            name='TEst',
                                            cel_Category__c = 'Collection',
                                            cel_SubCatergory__c = 'Collectionlaunch',
                                            startDate = System.Today(),
                                            enddate = System.Today() + 15);
        insert c1_parent;
        
        Campaign c1_enfant = new Campaign(
                                            recordtypeid=listRec.get(0).id,
                                            name='TEst',
                                            cel_Category__c = 'Collection',
                                            cel_SubCatergory__c = 'Collectionlaunch',
                                            startDate = System.Today(),
                                            enddate = System.Today() + 15,
                                            parentId = c1_parent.id);
        insert c1_enfant;
        
    
        account acc = new account(name='accTest');
        insert acc;
        
        contact c = new contact(firstname='Test', lastName='Test2', salutation='res');
        insert c;
        
        cel_Campaign_Member_Status__c cms1 = new cel_Campaign_Member_Status__c( cel_Campaign__c =  c1_enfant.id,
                                                                               cel_contact__c = c.id,
                                                                               cel_SLG__c = 10,
                                                                               cel_RTW__c = 20,
                                                                               cel_Shoes__c = 20,
                                                                               cel_Bags__c = 10,
                                                                               cel_ACC__c = 20,
                                                                              CurrencyIsoCode='USD');
         cel_Campaign_Member_Status__c cms2 = new cel_Campaign_Member_Status__c( cel_Campaign__c =  c1_enfant.id,
                                                                                cel_contact__c = c.id,
                                                                              CurrencyIsoCode='USD');
         cel_Campaign_Member_Status__c cms3 = new cel_Campaign_Member_Status__c( cel_Campaign__c =  c1_enfant.id,
                                                                                cel_contact__c = c.id,
                                                                            CurrencyIsoCode='USD');
        
        List<cel_Campaign_Member_Status__c> listCMS= new List<cel_Campaign_Member_Status__c>{cms1, cms2, cms3};
            
        insert listCMS;
        String theName =  c1_parent.name;
        
        
        Test.startTest();
            c1_parent.name = 'TheTest';
            update c1_parent;
    
            c1_enfant.name = 'TheEnfantTest';
            update c1_enfant;
            //The delete test
            delete c1_parent;
        
        
        Campaign[] savedcmss = [SELECT Id, Name FROM Campaign WHERE Name = :theName ALL ROWS];
       try 
       {
            undelete savedcmss;
        } catch (DmlException e) {
            // Process exception here
        }
        Test.stopTest();
    }
    
    
}