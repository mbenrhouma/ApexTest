@isTest
public class CEL_CampaignMemberTriggerHandler_TEST {
    @isTest
    public static void testTest(){
        
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
            List<CampaignMember> theCampaignMembers = new List<CampaignMember>();
            Id devRecordTypeChildActionId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Child Action').getRecordTypeId();
            Id devRecordTypeParentActionId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Parent Action').getRecordTypeId();
            Id devRecordT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Campaign Recordtype').getRecordTypeId();
            
            account acc = new account(name='accTest');
            insert acc;
            
            contact c = new contact(firstname='Test', lastName='Test2', salutation='res', accountId=acc.id);
            insert c;
            
            Campaign c1_enfant = new Campaign(
                                            recordtypeid=devRecordTypeChildActionId,
                                            name='TEst',
                                            cel_Category__c = 'Collection',
                                            cel_SubCatergory__c = 'Collectionlaunch',
                                            startDate = System.Today(),
                                            enddate = System.Today() + 15,
                                            CurrencyIsoCode='USD',
                                            isactive=true
                                            );
            
            insert c1_enfant;
            
            Campaign c2_enfant = new Campaign(
                                            recordtypeid=devRecordTypeParentActionId,
                                            name='TEsté',
                                            cel_Category__c = 'Collection',
                                            cel_SubCatergory__c = 'Collectionlaunch',
                                            startDate = System.Today(),
                                            enddate = System.Today() + 15,
                                            CurrencyIsoCode='USD',
                                            isactive=true  );
            
            insert c2_enfant;
            
            CampaignMember cm = new CampaignMember(
                                                     CampaignId = c1_enfant.id,
                                                     ContactId = c.id,
                                                     CurrencyIsoCode='USD'
                                                    );
            
            insert cm;
            
            CampaignMember cm2 = new CampaignMember(
                                                     CampaignId = c2_enfant.id,
                                                     ContactId = c.id,
                                                     CurrencyIsoCode='USD'
                                                    );
            
            insert cm2;
            
            Test.startTest();
            
            string theName = cm2.id;
            cm2.status = 'Responded';
            try{
                  update cm2;
            }
            catch(Exception e){
                
            }
                
            CampaignMember[] savedcmss = [SELECT Id, Name FROM CampaignMember WHERE name = :theName ALL ROWS];
            try{
                 undelete savedcmss;
            }
            catch (DmlException e) {
            }
                
            Test.stopTest();
        }
    }
}