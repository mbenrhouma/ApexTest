@isTest
public class Cel_DataFactoryForTests{
 
    Static ID personAccountRtID = CEL_Constants.peronAccountRtID;
    Static ID caseClaimRtID  = CEL_Constants.caseClaimRtID;
    Static ID caseCaseRtID =  CEL_Constants.caseCaseRtID;     
    Static ID storeRtID =  CEL_Constants.storeRecordType; 

    /*
    ///   ACCOUNTS ////
    */
    
    public static List<Account> createAccountsWithTrasactions(Integer numAccts, Integer numTransasPerAcct) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(FirstName='Test', LastName='Account'+ i, RecordTypeID =  personAccountRtID   );
            accts.add(a);
        }
        insert accts;
        
        List<Cel_Transaction__c> transacs = new List<Cel_Transaction__c>();
        
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            // For each account just inserted, add Transactions
            for (Integer k=0;k<numTransasPerAcct;k++) {
                transacs.add(new Cel_Transaction__c(Name='TestTransac'+ K, cel_AccountId__c=acct.Id, cel_sale_date__c=System.Today()));
            }
        }
        // Insert all transactions for all accounts.
        insert transacs;
         
        return accts;
    }
    
    public static List<Account> createAccountsWithCasesClaim(Integer numAccts, Integer numCasesPerAcct) {  
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(FirstName='Test', LastName='Account'+ i, RecordTypeID= personAccountRtID );
            accts.add(a);
        }
        insert accts;
        
        List<Case> cases = new List<Case>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            // For each account just inserted, add Cases
            for (Integer k=0;k<numCasesPerAcct;k++) {
                cases.add(new Case(AccountId=acct.Id, RecordTypeID = caseClaimRtID) ) ; 
            }
        }
        // Insert all Cases for all accounts.
        insert cases;
        
        return accts;
    }
    
    public static List<Account> createAccountsWithCases(Integer numAccts, Integer numCasesPerAcct) {   
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(FirstName='Test', LastName='Account'+ i, RecordTypeID= personAccountRtID );
            accts.add(a);
        }
        insert accts;
        
        List<Case> cases = new List<Case>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            // For each account just inserted, add Cases
            for (Integer k=0;k<numCasesPerAcct;k++) {
                cases.add(new Case(AccountId=acct.Id, RecordTypeID = caseCaseRtID) ) ; 
            }
        }
        // Insert all Cases for all accounts.
        insert cases;
        
        return accts;
    }
    
    public static List<Account> createAccounts(Integer numAccts) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(FirstName='Test', LastName='Account'+ i, RecordTypeID =  personAccountRtID   );
            accts.add(a);
        }
        insert accts;
         
        return accts;
    }
    
     public static List<Account> createAccountsWithOwner(Integer numAccts) {
        List<Account> accts = new List<Account>();
        String interfaceUserId = Id.valueOf(String.valueOf([SELECT ID FROM User WHERE email = 'cubi@celine.fr' LIMIT 1].Id).subString(0, 15));
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(FirstName='Test', LastName='Account'+ i, RecordTypeID =  personAccountRtID, OwnerId = interfaceUserId);
            accts.add(a);
        }
        insert accts;
         
        return accts;
    }
    
    /*
    ///  Custom Setting ///
    */   
    public static CEL_Configurations__c createCustomSettings() {
        CEL_Configurations__c setting = new CEL_Configurations__c();
        String interfaceUserId = Id.valueOf(String.valueOf([SELECT ID FROM User WHERE email = 'cubi@celine.fr' LIMIT 1].Id).subString(0, 15));
        
        setting.cel_interface_user_id__c = interfaceUserId;
        setting.cel_gdpr_report_campaign__c = '';
        setting.cel_gdpr_report_case__c = '';
        setting.cel_gpdr_report_customer_card__c = '';
        setting.cel_gdpr_report_transactions__c = '';
        setting.cel_report_campaign_action__c = '';
        setting.cel_report_campaign_lines__c = '';
        setting.cel_report_campaign_members__c = '';
        setting.cel_report_campaign_transactions__c = '';
        setting.cel_task_open_status__c = 'LATE,TODO';
        

        insert setting;
        return setting;
    }

    public static CEL_unsubscribe__c createUnsubscribe(Account a) {
        CEL_unsubscribe__c u = new CEL_unsubscribe__c();
        u.cel_account_id__c = a.Id;
        u.cel_ext_ccmp_id__c = '123456';

        return u;
    }

    
    /*
    ///   Transactions   ///
    */
    
    public static List<Cel_Transaction__c> createTransactions(Integer numTransactions) {
        List<Account> accts = createAccounts(1);
        Account acc = accts.get(0);
        List<Cel_Transaction__c> transacs = new List<Cel_Transaction__c>();
        
        for (Integer k=0;k < numTransactions;k++) {
            transacs.add(new Cel_Transaction__c(Name = 'TestTransac'+ K, cel_AccountId__c = acc.Id, cel_sale_date__c = System.Today()));
        }
        insert transacs;
        return transacs;
    }
    
    /*
    ///  Transcodification  ///
    */

    public static List<cel_transcodification__c> createTranscodifications(Integer numTranscos, String recordtypeID) {
        List<cel_transcodification__c> transcos = new List<cel_transcodification__c>();
        for(Integer k=0;k < numTranscos;k++){
            transcos.add(new cel_transcodification__c(Name = 'TestTransco'+ K, recordtypeId = recordtypeID));
        }
        insert transcos;
        return transcos;
    }
    
    /*
    ///  Stores  ///
    */

    public static List<Account> createStores(Integer numStores) {
        List<Account> storess = new List<Account>();
        for(Integer i=0;i<numStores;i++) {
            Account a = new Account(Name='Store'+ i, RecordTypeID =  storeRtID);
            storess.add(a);
        }
        insert storess;
         
        return storess;
    }

    /*
    ///  Individual  ///
    */
    
    public static Individual createIndividual(Account a) {
        Individual ind = new Individual();
        ind.cel_consent_log__c = a.Id;
        ind.cel_consent_status__c = CEL_Constants.consentStatus.get('OFF');
        ind.LastName = CEL_Constants.consentPurpose.get('CCM');
        ind.cel_Purpose__c = CEL_Constants.consentPurpose.get('CCM');
        ind.cel_start_date_consentment__c = Date.newInstance(2002, 5, 1);

        return ind;
    }
    
    public static Individual createIndividual() {
        Individual ind = new Individual();
        ind.cel_start_date_consentment__c = Date.newInstance(2002, 5, 1);
        ind.cel_Consent_Status__c = CEL_Constants.consentStatus.get('ON');
        ind.cel_Purpose__c = CEL_Constants.consentPurpose.get('ASM');
        ind.LastName = CEL_Constants.consentPurpose.get('ASM');
        ind.cel_type__c = CEL_Constants.consentType.get('Case');
        insert ind;
        return ind;
    }
    
    /*
    ///  Task  ///
    */
    
    public static Task createTask(Account account){
        Date birthdateOfCurrentYear = Date.today().addDays(3);
        Task taskToAdd = new Task();
        
        taskToAdd.OwnerId = account.OwnerId;
        taskToAdd.ActivityDate = birthdateOfCurrentYear.addDays(1);
        taskToAdd.Status = CEL_Constants.taskStatus.get('To Do');
        taskToAdd.Subject = 'test subject';
        taskToAdd.WhatId = account.Id;
        taskToAdd.Description = 'test template';
        
        insert taskToAdd;
        return taskToAdd;
    }

}