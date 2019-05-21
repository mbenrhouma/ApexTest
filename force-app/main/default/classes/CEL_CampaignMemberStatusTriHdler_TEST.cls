@istest
public class CEL_CampaignMemberStatusTriHdler_TEST {

    @isTest
    static void theTest()
    {
        List<Recordtype> listRec = [select id, name from recordtype where 
                                    developerName = 'ParentAction' or developerName = 'ChildAction'
                                    order by developerName ];
        Campaign c = new Campaign(
                                    recordtypeid=listRec.get(0).id,
            						name='TEst',
            						cel_Category__c = 'Collection',
                                    cel_SubCatergory__c = 'Collectionlaunch',
            						startDate = System.Today(),
            						enddate = System.Today() + 15
                                 );
        insert c;
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c( cel_Campaign__c = c.id,
                                                                              CurrencyIsoCode='USD');
        insert cms;
        string theName = cms.name;
        Test.startTest();
        
        c.cel_Category__c = 'CARESReward';
        c.cel_SubCatergory__c = 'Runway';
        update c;
        
        cms.cel_Purchasing__c = TRUE;
        update cms;
        
        //The delete test
        delete cms;
        
        
      
        Test.stopTest();
    }
    
    
     @isTest
    static void theTest2()
    {
        List<Recordtype> listRec = [select id, name from recordtype where 
                                    developerName = 'ParentAction' or developerName = 'ChildAction'
                                    order by developerName ];
        Campaign c = new Campaign(
                                    recordtypeid=listRec.get(0).id,
            						name='TEst',
            						cel_Category__c = 'Collection',
                                    cel_SubCatergory__c = 'Collectionlaunch',
            						startDate = System.Today(),
            						enddate = System.Today() + 15
                                 );
        insert c;
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c( cel_Campaign__c = c.id,
                                                                              CurrencyIsoCode='USD');
        insert cms;
        string theName = cms.name;
        Test.startTest();
        
      
        delete cms;
        
        
        //undelete records
        cel_Campaign_Member_Status__c[] savedcmss = [SELECT Id, Name FROM cel_Campaign_Member_Status__c WHERE Name = :theName ALL ROWS];
       try 
       {
            undelete savedcmss;
        } catch (DmlException e) {
            // Process exception here
        }
        
         //The delete test
      
        Test.stopTest();
    }
    
}