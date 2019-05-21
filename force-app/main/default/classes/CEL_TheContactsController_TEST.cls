@isTest
public class CEL_TheContactsController_TEST {
    
    @isTest
    static void testGetCampaignCurrency() {
        Campaign c0 = new Campaign();
        c0.Name = 'TEST';
        insert c0;
        
        Campaign c = CEL_TheContactsController.getCampaignCurrency(String.valueOf(c0.Id));
        System.assertNotEquals(null, c); 
    }
    
    @isTest
    static void testGetCampaignMemberStatusList() {
        Campaign c0 = new Campaign();
        c0.Name = 'TEST';
        insert c0;
        
        Account a = new Account();
        a.Name = 'TEST';
        a.cel_ext_account_id__c = 'b';
        insert a;
        
        Contact ctt = new Contact();
        ctt.LastName = 'Test';
        ctt.firstName = 'a';
        ctt.AccountId = a.Id;
        insert ctt;
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c();
        cms.cel_Campaign__c = c0.Id;
        cms.cel_Contact__c = ctt.Id;
        insert cms;
        
        List<cel_Campaign_Member_Status__c> allCms = CEL_TheContactsController.getCampaignMemberStatusList(String.valueOf(c0.Id), 'a', 'b');
        System.assertNotEquals(null, allCms); 
        System.assertNotEquals(0, allCms.size());
         
        allCms = CEL_TheContactsController.getCampaignMemberStatusList(String.valueOf(c0.Id), 'a', '');
        System.assertNotEquals(null, allCms); 
        System.assertNotEquals(0, allCms.size());
         
        allCms = CEL_TheContactsController.getCampaignMemberStatusList(String.valueOf(c0.Id), '', 'b');
        System.assertNotEquals(null, allCms); 
        System.assertNotEquals(0, allCms.size()); 
    }
    
    @isTest
    static void testUpdateTheCampaignMembersStatus() {
        Campaign c0 = new Campaign();
        c0.Name = 'TEST';
        insert c0;
        
        Account a = new Account();
        a.Name = 'TEST';
        a.cel_ext_account_id__c = 'b';
        insert a;
        
        Contact ctt = new Contact();
        ctt.LastName = 'Test';
        ctt.firstName = 'a';
        ctt.AccountId = a.Id;
        insert ctt;
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c();
        cms.cel_Campaign__c = c0.Id;
        cms.cel_Contact__c = ctt.Id;
        insert cms;
        
        List<String> campaignMembersId = new List<String>();
        campaignMembersId.add(String.valueOf(cms.Id));
        List<Boolean> inviteds = new List<Boolean>();
        inviteds.add(true);
        List<Boolean> contacteds = new List<Boolean>();
        contacteds.add(true);
        List<Boolean> confirmeds = new List<Boolean>();
        confirmeds.add(true);
        List<Boolean> showups = new List<Boolean>();
        showups.add(true);
        List<Boolean> purchasings = new List<Boolean>();
        purchasings.add(true);
        List<Decimal> reswdeps = new List<Decimal>();
        reswdeps.add(12);
        List<Decimal> reswodeps = new List<Decimal>();
        reswodeps.add(7);
        
        Boolean result = CEL_TheContactsController.updateTheCampaignMembersStatus(campaignMembersId, inviteds, contacteds, confirmeds, showups, purchasings, reswdeps, reswodeps);
        
        System.assertNotEquals(false, result); 
    }
    
    @isTest
    static void testGetContacts() {
        String textCLI = CEL_Constants.typeAccountKey;
        Id personAccountRt = CEL_Constants.peronAccountRtID;
        
        Campaign c0 = new Campaign();
        c0.Name = 'TEST';
        insert c0;
        
        Account a = new Account();
        a.LastName = 'a';
        a.cel_ext_account_id__c = 'b';
        a.type = textCLI;
        a.recordTypeId = personAccountRt;
        insert a;
        
        Contact ctt = [SELECT Id FROM Contact WHERE AccountId =: a.Id  LIMIT 1];
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c();
        cms.cel_Campaign__c = c0.Id;
        insert cms;
        
        List<String> acctIds = new List<String>();
        acctIds.add(String.valueOf(ctt.Id));
        CEL_TheContactsController.addContactToCampaignmemberStatus(String.valueOf(c0.Id), acctIds);
        
        List<Account> accounts = CEL_TheContactsController.getContacts(String.valueOf(c0.Id), 'a', 'b');
        System.assertNotEquals(null, accounts); 
        System.assertNotEquals(0, accounts.size());
        
        accounts = CEL_TheContactsController.getContacts(String.valueOf(c0.Id), '', 'b');
        System.assertNotEquals(null, accounts); 
        System.assertNotEquals(0, accounts.size());
        
        accounts = CEL_TheContactsController.getContacts(String.valueOf(c0.Id), 'a', '');
        System.assertNotEquals(null, accounts); 
        System.assertNotEquals(0, accounts.size());
    }
    
    @isTest
    static void testAddContactToCampaignmemberStatus() {
        String textCLI = CEL_Constants.typeAccountKey;
        Id personAccountRt = CEL_Constants.peronAccountRtID;
        
        Campaign c0 = new Campaign();
        c0.Name = 'TEST';
        insert c0;
        
        Account a = new Account();
        a.LastName = 'a';
        a.cel_ext_account_id__c = 'b';
        a.type = textCLI;
        a.recordTypeId = personAccountRt;
        insert a;
        
        Contact ctt = [SELECT Id FROM Contact WHERE AccountId =: a.Id  LIMIT 1];
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c();
        cms.cel_Campaign__c = c0.Id;
        insert cms;
        
        List<String> acctIds = new List<String>();
        acctIds.add(String.valueOf(ctt.Id));
        CEL_TheContactsController.addContactToCampaignmemberStatus(String.valueOf(c0.Id), acctIds);
    }
    
    @isTest
    static void testGotoReportFolderCampaignAction() {
        String url = CEL_TheContactsController.gotoReportFolderCampaignAction();
        System.assertNotEquals(null, url);
        System.assertNotEquals('', url);
    }
}