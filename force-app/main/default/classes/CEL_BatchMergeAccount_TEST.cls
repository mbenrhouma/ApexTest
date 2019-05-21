@isTest
public class CEL_BatchMergeAccount_TEST {
    
    @testSetup
    static void setup() {
        ID personAccountRtID = CEL_Constants.peronAccountRtID;
        List<Account> masters = new List<Account>{
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123456789', Type = 'CLI', FirstName = 'TestMaster1', LastName = 'TestName1', PersonEmail = 'monprenom1@test.com', cel_total_sales_full_history__c = 5200, cel_nb_transactions_12_months__c = 2, PersonBirthDate = Date.newInstance(1982, 05, 12), cel_birthdate_day__c = 12, cel_birthdate_month__c = 05, cel_birthdate_year__c = 1985, cel_email_mailable__c = 'N', PersonMobilePhone = '0234567891', cel_is_email_contactibiliy__c = false, PersonOtherPhone = '051346789', cel_is_phone_contactability__c = false, cel_mobile_mailable__c = 'Y'),
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123789465', Type = 'CLI', FirstName = 'TestMaster2', LastName = 'TestName2', PersonEmail = 'monprenom2@test.com', cel_total_sales_full_history__c = 2200, cel_nb_transactions_12_months__c = 1, PersonBirthDate = Date.newInstance(1965, 09, 15), cel_birthdate_day__c = 15, cel_birthdate_month__c = 09, cel_birthdate_year__c = 1965),
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '784512963', Type = 'PRO', FirstName = 'TestMaster3', LastName = 'TestName3', PersonEmail = 'monprenom3@test.com', cel_total_sales_full_history__c = 2200, cel_nb_transactions_12_months__c = 1, PersonBirthDate = Date.newInstance(1965, 09, 15), cel_birthdate_day__c = 15, cel_birthdate_month__c = 09, cel_birthdate_year__c = 1965)
        };
        List<Account> duplicates = new List<Account>{
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123796485', Type = 'CLI', FirstName = 'TestFirstName11', LastName = 'TestName11', PersonEmail = 'monprenom11@test.com', cel_total_sales_full_history__c = 2100, cel_nb_transactions_12_months__c = 1, PersonBirthDate = Date.newInstance(1985, 05, 25), cel_birthdate_day__c = 25, cel_birthdate_month__c = 05, cel_birthdate_year__c = 1985, cel_email_mailable__c = 'Y', cel_mobile_mailable__c = 'Y', PersonMobilePhone = '0123456789', cel_is_email_contactibiliy__c = true, cel_homephone_mailable__c = 'Y', PersonOtherPhone = '0123456789', cel_is_phone_contactability__c = true, cel_address_mailable__c = 'Y', cel_addr_1_line_1__c = 'ADDR_1_LINE_1', cel_addr_1_line_2__c = 'ADDR_1_LINE_2', cel_addr_1_line_3__c = 'ADDR_1_LINE_3', cel_addr_1_zipcode__c = '75001', cel_addr_1_city__c = 'PARIS', cel_addr_1_validity__c = true),
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123456987', Type = 'CLI', FirstName = 'TestFirstName12', LastName = 'TestName12', PersonEmail = 'monprenom12@test.com', cel_total_sales_full_history__c = 3200, cel_nb_transactions_12_months__c = 1, PersonBirthDate = Date.newInstance(1945, 06, 05), cel_birthdate_day__c = 05, cel_birthdate_month__c = 06, cel_birthdate_year__c = 1945),
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123456897', Type = 'CLI', FirstName = 'TestFirstName13', LastName = 'TestName13', PersonEmail = 'monprenom4@test.com', cel_total_sales_full_history__c = 2500, cel_nb_transactions_12_months__c = 1, PersonBirthDate = Date.newInstance(1995, 07, 11), cel_birthdate_day__c = 11, cel_birthdate_month__c = 07, cel_birthdate_year__c = 1995),
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123956487', Type = 'CLI', FirstName = 'TestFirstName21', LastName = 'TestName21', PersonEmail = 'monprenom2@test.com', cel_total_sales_full_history__c = 2800, cel_nb_transactions_12_months__c = 1, PersonBirthDate = Date.newInstance(1975, 02, 16), cel_birthdate_day__c = 16, cel_birthdate_month__c = 02, cel_birthdate_year__c = 1975),
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '123968574', Type = 'CLI', FirstName = 'TestFirstName22', LastName = 'TestName22', PersonEmail = 'monprenom2@test.com', cel_total_sales_full_history__c = 1500, cel_nb_transactions_12_months__c = 1, PersonBirthDate = Date.newInstance(1955, 01, 31), cel_birthdate_day__c = 31, cel_birthdate_month__c = 01, cel_birthdate_year__c = 1955),
            new Account(RecordTypeId = personAccountRtID, cel_ext_account_id__c = '986532741', Type = 'PRO', FirstName = 'TestFirstName31', LastName = 'TestName31', PersonEmail = 'monprenom3@test.com', cel_total_sales_full_history__c = 1800, cel_nb_transactions_12_months__c = 10, PersonBirthDate = Date.newInstance(1955, 02, 25), cel_birthdate_day__c = 25, cel_birthdate_month__c = 02, cel_birthdate_year__c = 1955)
        };
            
        insert masters;
        insert duplicates;
        
        Date masterCreatedDate = Date.today().addMonths(-1);
        masters.get(0).cel_creation_date__c = masterCreatedDate;
        masters.get(1).cel_creation_date__c = masterCreatedDate;
        masters.get(2).cel_creation_date__c = masterCreatedDate;
        duplicates.get(0).cel_creation_date__c = masterCreatedDate.addDays(1);
        duplicates.get(1).cel_creation_date__c = masterCreatedDate.addDays(2);
        duplicates.get(2).cel_creation_date__c = masterCreatedDate.addDays(3);
        duplicates.get(3).cel_creation_date__c = masterCreatedDate.addDays(1);
        duplicates.get(4).cel_creation_date__c = masterCreatedDate.addDays(2);
        duplicates.get(5).cel_creation_date__c = masterCreatedDate.addDays(5);
        update masters;
        update duplicates;
        
        List<Campaign> cmps = new List<Campaign>{
        	new Campaign(Description = 'AAAAAAAAAAAAA', Name = 'AAAAAAAAAAAAA'),
            new Campaign(Description = 'BBBBBBBBBBBBB', Name = 'BBBBBBBBBBBBB')
        };
        
        insert cmps;
                       
        List<CampaignMember> cms = new List<CampaignMember>{
        	new CampaignMember(CampaignId = cmps.get(0).Id, ContactId = masters.get(0).PersonContactId, status='Sent'),
        	new CampaignMember(CampaignId = cmps.get(1).Id, ContactId = duplicates.get(0).PersonContactId, status='Sent'),
        	new CampaignMember(CampaignId = cmps.get(1).Id, ContactId = duplicates.get(1).PersonContactId, status='Sent')
        };
                       
        List<CEL_Transaction__c> trs = new List<CEL_Transaction__c>{
        	new CEL_Transaction__c(cel_AccountId__c = duplicates.get(0).Id)
        };
        insert trs;
        
        Date todayDate = Date.today();
        List<CEL_Customer_Duplication__c> cd = new List<CEL_Customer_Duplication__c>{
          new CEL_Customer_Duplication__c(cel_account__c = masters.get(0).Id, cel_idGroup__c = '0', cel_insertionDate__c = todayDate, cel_customercode__c = '123456789', cel_customerCode_IdGroup_Date__c = '123456798741'),
          new CEL_Customer_Duplication__c(cel_account__c = duplicates.get(0).Id, cel_idGroup__c = '0', cel_insertionDate__c = todayDate, cel_customercode__c = '123796485', cel_customerCode_IdGroup_Date__c = '123456798741'),
          new CEL_Customer_Duplication__c(cel_account__c = masters.get(1).Id, cel_idGroup__c = '0', cel_insertionDate__c = todayDate, cel_customercode__c = '123456987', cel_customerCode_IdGroup_Date__c = '123456798741'),
          new CEL_Customer_Duplication__c(cel_account__c = duplicates.get(1).Id, cel_idGroup__c = '1', cel_insertionDate__c = todayDate, cel_customercode__c = '123789465', cel_customerCode_IdGroup_Date__c = '123456798741'),
          new CEL_Customer_Duplication__c(cel_account__c = duplicates.get(3).Id, cel_idGroup__c = '1', cel_insertionDate__c = todayDate, cel_customercode__c = '123956487', cel_customerCode_IdGroup_Date__c = '123456798741'),
          new CEL_Customer_Duplication__c(cel_account__c = duplicates.get(4).Id, cel_idGroup__c = '1', cel_insertionDate__c = todayDate, cel_customercode__c = '123968574', cel_customerCode_IdGroup_Date__c = '123456798741'),
          new CEL_Customer_Duplication__c(cel_account__c = masters.get(2).Id, cel_idGroup__c = '2', cel_insertionDate__c = todayDate, cel_customercode__c = '784512963', cel_customerCode_IdGroup_Date__c = '123456798741'),
          new CEL_Customer_Duplication__c(cel_account__c = duplicates.get(5).Id, cel_idGroup__c = '2', cel_insertionDate__c = todayDate, cel_customercode__c = '986532741', cel_customerCode_IdGroup_Date__c = '123456798741')
        };
            
        insert cd;
        update duplicates;
    }

    
    @isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new CEL_BatchMergeAccount());
        CEL_BatchMergeAccount batch = new CEL_BatchMergeAccount();
        batch.execute(null);
        Test.stopTest();

        List<Account> accts = [SELECT Id FROM Account WHERE PersonEmail = 'monprenom2@test.com'];
        System.assertEquals(3, accts.size());

    }

}