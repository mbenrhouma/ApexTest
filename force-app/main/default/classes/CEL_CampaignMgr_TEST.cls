@isTest
public class CEL_CampaignMgr_TEST {
    
    @isTest
    static void testCreateCampaignTransaction() {
        Campaign c0 = new Campaign();
        c0.Name = 'TEST';
        c0.startDate = Date.Today().addDays(-10);
        c0.endDate = Date.Today().addDays(+10);
        insert c0;
        
        Account a = new Account();
        a.LastName = 'Test';
        a.cel_ext_account_id__c = 'b';
        a.recordTypeId = CEL_Constants.peronAccountRtID;
        insert a;
        
        Contact ctt = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId =: a.id ];
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c();
        cms.cel_Campaign__c = c0.Id;
        cms.cel_Contact__c = ctt.Id;
        insert cms;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c0.Id;
        cm.ContactId = ctt.Id;
        insert cm;
        
        cel_Transaction__c transactions = new cel_Transaction__c();
        transactions.cel_AccountId__c = a.Id;
        transactions.cel_sale_date__c = Date.today();
        insert transactions;
        
        cel_Transaction_Line__c lines = new cel_Transaction_Line__c();
        lines.cel_transaction__c = transactions.Id;
        insert lines;
        
        Boolean result = false;
        try{
            result = CEL_CampaignMgr.createCampaignTransaction(String.valueOf(cm.CampaignId));
        }
        catch(Exception e){}
        
        System.assertEquals(true, result);
    }
    
    @isTest
    static void testCreateCampaignTransactionFalse() {
        Boolean result ;
        try{
            result = CEL_CampaignMgr.createCampaignTransaction(null);
        }
        catch(Exception e){}
        System.assertEquals(false, result);
    }

    @isTest
    static void testCreateCampaignTransactionLine() {
        Campaign c0 = new Campaign();
        c0.Name = 'TEST';
        c0.startDate = Date.Today().addDays(-10);
        c0.endDate = Date.Today().addDays(+10);
        insert c0;
        
        Account a = new Account();
        a.LastName = 'Test';
        a.cel_ext_account_id__c = 'b';
        a.recordTypeId = CEL_Constants.peronAccountRtID;
        insert a;
        
        Contact ctt = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId =: a.id ];
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c();
        cms.cel_Campaign__c = c0.Id;
        cms.cel_Contact__c = ctt.Id;
        insert cms;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c0.Id;
        cm.ContactId = ctt.Id;
        insert cm;
        
        cel_Transaction__c transactions = new cel_Transaction__c();
        transactions.cel_AccountId__c = a.Id;
        transactions.cel_sale_date__c = Date.today();
        insert transactions;
        
        cel_Transaction_Line__c lines = new cel_Transaction_Line__c();
        lines.cel_transaction__c = transactions.Id;
        insert lines;
        
        Boolean result = CEL_CampaignMgr.createCampaignTransactionLine(String.valueOf(cm.CampaignId));
        System.assertEquals(true, result);
    }

    @isTest
    static void testCreateCampaignTransactionLineFalse() {
        Boolean result = CEL_CampaignMgr.createCampaignTransactionLine(null);
        System.assertEquals(false, result);
    }

    @isTest
    static void testGetAvailableListZoneCountrieStore(){
        String campaignParentRecordType =  CEL_Constants.campaignParentRecordType;
        Campaign c = new Campaign();
        c.Name = 'TEST';
        insert c;
        
        Map<String, List<Map<String, String>>> results = CEL_CampaignMgr.getAvailableListZoneCountrieStore(c.Id,c.Id,campaignParentRecordType);
       
        System.assertNotEquals(null,results);
    }
    
    @isTest
    static void testCreateChildForCampaignAll(){
        String campaignParentRecordType =  CEL_Constants.campaignParentRecordType;
        
        Campaign c = new Campaign();
        c.recordTypeId = campaignParentRecordType;
        c.cel_region_all__c = true;
        c.Name = 'TEST';
        insert c;
        
        CEL_CampaignMgr.createChildForCampaignAll(c);
    }
    
    @isTest
    static void testFillingChildFieldsWithParent(){
        String campaignParentRecordType =  CEL_Constants.campaignParentRecordType;
        
        cel_transcodification__c t01 = new cel_transcodification__c();
        t01.Name = 'transco01';
        insert t01;
        
        cel_transcodification__c t02 = new cel_transcodification__c();
        t02.Name = 'transco02';
        insert t02;
        
        ID storeRtID =  CEL_Constants.storeRecordType;
        Account a01 = new Account(Name='Store 01', RecordTypeID =  storeRtID);
        a01.cel_store_area__c = String.valueOf(t01.Id);
        a01.cel_store_status__c = 'Open';
        insert a01;
        
        Account a02 = new Account(Name='Store 02', RecordTypeID =  storeRtID);
        a02.cel_store_area__c = String.valueOf(t02.Id);
        a02.cel_store_status__c = 'Open';
        insert a02;
        
        Campaign c = new Campaign();
        c.recordTypeId = campaignParentRecordType;
        c.cel_region_all__c = true;
        c.Name = 'TEST';
        insert c;
        
        CEL_CampaignMgr.createChildForCampaignAll(c);
        
        Campaign child = [SELECT Id, ParentId FROM Campaign WHERE ParentId =: c.id LIMIT 1];
        
        CEL_CampaignMgr.fillingChildFieldsWithParent(child);
    }
    
    @isTest
    static void testGetNumberOfChilren(){
        String campaignParentRecordType =  CEL_Constants.campaignParentRecordType;
        
        cel_transcodification__c t01 = new cel_transcodification__c();
        t01.Name = 'transco01';
        insert t01;
        
        cel_transcodification__c t02 = new cel_transcodification__c();
        t02.Name = 'transco02';
        insert t02;
        
        ID storeRtID =  CEL_Constants.storeRecordType;
        Account a01 = new Account(Name='Store 01', RecordTypeID =  storeRtID);
        a01.cel_store_area__c = String.valueOf(t01.Id);
        a01.cel_store_status__c = 'Open';
        insert a01;
        
        Account a02 = new Account(Name='Store 02', RecordTypeID =  storeRtID);
        a02.cel_store_area__c = String.valueOf(t02.Id);
        a02.cel_store_status__c = 'Open';
        insert a02;
        
        Campaign c = new Campaign();
        c.recordTypeId = campaignParentRecordType;
        c.cel_region_all__c = true;
        c.Name = 'TEST';
        insert c;
        
        CEL_CampaignMgr.createChildForCampaignAll(c);
        
        Integer nb = CEL_CampaignMgr.getNumberOfChilren(c);
        System.assertNotEquals(null,nb);
        System.assertNotEquals(0,nb);
    }
    
    @isTest
    static void testGetNameChildrenOutRangeDate(){
        String campaignParentRecordType =  CEL_Constants.campaignParentRecordType;
        
        cel_transcodification__c t01 = new cel_transcodification__c();
        t01.Name = 'transco01';
        insert t01;
        
        cel_transcodification__c t02 = new cel_transcodification__c();
        t02.Name = 'transco02';
        insert t02;
        
        ID storeRtID =  CEL_Constants.storeRecordType;
        Account a01 = new Account(Name='Store 01', RecordTypeID =  storeRtID);
        a01.cel_store_area__c = String.valueOf(t01.Id);
        a01.cel_store_status__c = 'Open';
        insert a01;
        
        Account a02 = new Account(Name='Store 02', RecordTypeID =  storeRtID);
        a02.cel_store_area__c = String.valueOf(t02.Id);
        a02.cel_store_status__c = 'Open';
        insert a02;
        
        Campaign c = new Campaign();
        c.recordTypeId = campaignParentRecordType;
        c.cel_region_all__c = true;
        c.Name = 'TEST';
        c.startDate = date.today();
        c.endDate = date.today();
        insert c;
        
        CEL_CampaignMgr.createChildForCampaignAll(c);
        
        Campaign child = [SELECT Id, endDate FROM Campaign WHERE ParentId =: c.id LIMIT 1];
        child.endDate = date.Today().addDays(+100);
        update child;
        
        List<String> nb = CEL_CampaignMgr.getNameChildrenOutRangeDate(c);
        System.assertNotEquals(null,nb);
        System.assertNotEquals(0,nb.size());
    }
}