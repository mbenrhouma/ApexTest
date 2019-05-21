@isTest
public class CEL_KpiCrossSellingBatch_TEST {
    
    @isTest
    static void testCEL_KpiCrossSellingBatch() {
        Test.startTest();
        
        Campaign c1 = new Campaign();
        c1.RecordTypeId = CEL_Constants.campaignParentRecordType;
        c1.Name = 'TEST';
        c1.startDate = Date.Today().addDays(-10);
        c1.endDate = Date.Today().addDays(+10);
        c1.cel_level__c = '1';
        insert c1;
        update c1;
        
        Campaign c2 = new Campaign();
        c2.RecordTypeId = CEL_Constants.campaignParentRecordType;
        c2.ParentId = c1.Id;
        c2.Name = 'TEST';
        c2.startDate = Date.Today().addDays(-10);
        c2.endDate = Date.Today().addDays(+10);
        c2.cel_level__c = '2';
        insert c2;
        update c2;
        
        Campaign c3 = new Campaign();
        c3.RecordTypeId = CEL_Constants.campaignEnfantRecordType;
        c3.ParentId = c2.Id;
        c3.Name = 'TEST';
        c3.startDate = Date.Today().addDays(-10);
        c3.endDate = Date.Today().addDays(+10);
        c3.cel_level__c = '3';
        insert c3;
        update c3;
        
        Campaign c4 = new Campaign();
        c4.RecordTypeId = CEL_Constants.campaignEnfantRecordType;
        c4.ParentId = c3.Id;
        c4.Name = 'TEST';
        c4.startDate = Date.Today().addDays(-10);
        c4.endDate = Date.Today().addDays(+10);
        c4.cel_level__c = '4';
        insert c4;
        update c4;
        
        List<Campaign> allC = New List<Campaign>();
        allC.add(c4);
        allC.add(c3);
        allC.add(c2);
        allC.add(c1);
        
        Account a = new Account();
        a.LastName = 'Test';
        a.cel_ext_account_id__c = 'b';
        a.recordTypeId = CEL_Constants.peronAccountRtID;
        insert a;
        update a;
        
        Contact ctt = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId =: a.id ];
        
        cel_Campaign_Member_Status__c cms = new cel_Campaign_Member_Status__c();
        cms.cel_Campaign__c = c4.Id;
        cms.cel_Contact__c = ctt.Id;
        insert cms;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c4.Id;
        cm.ContactId = ctt.Id;
        insert cm;
        
        cel_Transaction__c transactions = new cel_Transaction__c();
        transactions.cel_AccountId__c = a.Id;
        transactions.cel_sale_date__c = Date.today();
        insert transactions;
        
        Product2 p1 = new Product2();
        p1.Name = 'Product 01';
        p1.cel_product_category__c = 'BAGS';
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Name = 'Product 02';
        p2.cel_product_category__c = 'SHOES';
        insert p2;
        
        
        cel_Transaction_Line__c line01 = new cel_Transaction_Line__c();
        line01.cel_transaction__c = transactions.Id;
        line01.cel_Product2Id__c = p1.Id;
        line01.cel_net_value_local_tax_inc_eur__c = 100;
        insert line01;
        
        cel_Transaction_Line__c line02 = new cel_Transaction_Line__c();
        line02.cel_transaction__c = transactions.Id;
        line02.cel_Product2Id__c = P2.Id;
        line01.cel_net_value_local_tax_inc_eur__c = 10;
        insert line02;
        
        CEL_KpiCrossSellingBatch batch = new CEL_KpiCrossSellingBatch();
        Database.executeBatch(batch);
        batch.execute(null);
        batch.execute(null, allC);
        Test.stopTest();
    }
}