@isTest
public class CEL_CampaignController_TEST {
    
    @isTest
    static void testCampaignController() {
        // Create Transco
        ID countryRtID =  CEL_Constants.transcoCountryRtID;
        ID regionRtID =  CEL_Constants.transcoRegionRtID;
        cel_transcodification__c transco03 = new cel_transcodification__c();
        transco03.Name = 'EMEA';
        transco03.RecordTypeID = regionRtID;
        transco03.cel_transcodification_code__c = 'EMEA';
        insert transco03;
        
        system.assertNotEquals(null, transco03);
        
        // Create stores
        ID storeRtID =  CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        Account store01 = new Account(Name='Store 01', RecordTypeID =  storeRtID);
        Account store02 = new Account(Name='Store 02', RecordTypeID =  storeRtID);
        
        store01.cel_addr_1_country__c = 'FRA';
        store01.cel_store_status__c = storeStatusOpen;
        store01.cel_store_area__c = String.valueOf(transco03.Id);
        store02.cel_addr_1_country__c = 'GBR';
        store02.cel_store_status__c = storeStatusOpen;
        store02.cel_store_area__c = String.valueOf(transco03.Id);
        
        insert store01;
        insert store02;
        
        Campaign c0 = new Campaign();
        c0.RecordTypeId = CEL_Constants.campaignParentRecordType;
        c0.Name = 'TEST';
        c0.startDate = Date.Today().addDays(-10);
        c0.endDate = Date.Today().addDays(+10);
        c0.cel_level__c = '1';
        insert c0;
        update c0;
        
        Campaign c1 = new Campaign();
        c1.RecordTypeId = CEL_Constants.campaignParentRecordType;
        c1.ParentId = c0.id;
        c1.Name = 'TEST';
        c1.startDate = Date.Today().addDays(-10);
        c1.endDate = Date.Today().addDays(+10);
        c1.cel_level__c = '1';
        insert c1;
        update c1;
        
        Campaign c = CEL_CampaignController.getCampaignDetails(c1.Id);
        system.assertNotEquals(null, c);
        
        Map<String,Map<String, String>> results = new Map<String,Map<String, String>>();
        results = CEL_CampaignController.initPicklistClienteling(String.valueOf(c1.Id), false);
        system.assertNotEquals(0, results.size());
        
        results = new Map<String,Map<String, String>>();
        results = CEL_CampaignController.initPicklistClienteling(String.valueOf(c1.Id), true);
        system.assertNotEquals(0, results.size());
        
        Map<String, String> results2 = new Map<String, String>();
        results2 = CEL_CampaignController.getCountriesListByRegion(String.valueOf(transco03.Id));
        system.assertNotEquals(0, results2.size()); 
        
        results2 = new Map<String, String>();
        results2 = CEL_CampaignController.getStoresListByCountry('FRA');
        system.assertNotEquals(0, results2.size());
        
        results2 = new Map<String, String>();
        results2 = CEL_CampaignController.getStoresListByCountry('GBR');
        system.assertNotEquals(0, results2.size());
        
        String storeRecordType = CEL_Constants.storeRecordType;
        List<Account> allStores = [SELECT Id,
                                           cel_long_name__c,
                                           cel_store_area__c,
                                           cel_addr_1_country__c
                                           FROM Account 
                                           WHERE RecordTypeId =: storeRecordType
                                           ORDER BY cel_long_name__c];
        
        Boolean isSave = CEL_CampaignController.savePicklistClienteling(String.valueOf(c1.Id), String.valueOf(allStores.get(0).Id));
        system.assertNotEquals(false, isSave);
        
        Map<String, List<String>> result = CEL_CampaignController.getRegionCountryStoresByCampaignId(c1.Id);
        system.assertNotEquals(0, result.size());
    }
    
    @isTest
    static void testGetDetailAndMakeCalcul() {
        Account s = new Account();
        s.Name = 'Paris';
        s.recordTypeId = CEL_Constants.storeRecordType;
        insert s;
        
        Campaign c1 = new Campaign();
        c1.RecordTypeId = CEL_Constants.campaignParentRecordType;
        c1.Name = 'TEST';
        c1.startDate = Date.Today().addDays(-10);
        c1.endDate = Date.Today().addDays(+10);
        c1.cel_level__c = '1';
        c1.IsActive = true;
        insert c1;
        update c1;
        
        Campaign c2 = new Campaign();
        c2.RecordTypeId = CEL_Constants.campaignParentRecordType;
        c2.ParentId = c1.Id;
        c2.Name = 'TEST';
        c2.startDate = Date.Today().addDays(-10);
        c2.endDate = Date.Today().addDays(+10);
        c2.cel_level__c = '2';
        c2.IsActive = true;
        insert c2;
        update c2;
        
        Campaign c3 = new Campaign();
        c3.RecordTypeId = CEL_Constants.campaignEnfantRecordType;
        c3.ParentId = c2.Id;
        c3.Name = 'TEST';
        c3.startDate = Date.Today().addDays(-10);
        c3.endDate = Date.Today().addDays(+10);
        c3.cel_level__c = '3';
        c3.IsActive = true;
        insert c3;
        update c3;
        
        Campaign c4 = new Campaign();
        c4.RecordTypeId = CEL_Constants.campaignEnfantRecordType;
        c4.ParentId = c3.Id;
        c4.Name = 'TEST';
        c4.startDate = Date.Today().addDays(-10);
        c4.endDate = Date.Today().addDays(+10);
        c4.cel_level__c = '4';
        c4.IsActive = true;
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
        transactions.cel_store__c = s.id;
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
        
        CEL_CampaignController.getDetailAndMakeCalcul(String.valueOf(c4.Id));
        CEL_CampaignController.getDetailAndMakeCalcul(String.valueOf(c3.Id));
        CEL_CampaignController.getDetailAndMakeCalcul(String.valueOf(c2.Id));
        CEL_CampaignController.getDetailAndMakeCalcul(String.valueOf(c1.Id));
    }
}