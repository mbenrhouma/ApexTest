@isTest
public class CEL_CaseTrigger_TEST {

     Static ID  personAccountRtID = CEL_Constants.peronAccountRtID ;  
     Static ID  caseClaimRtID  = CEL_Constants.caseClaimRtID ; 
     Static ID caseCaseRtID =  CEL_Constants.caseCaseRtID ; 

   @testSetup static void setup() {
          // Create Accounts with Cases  Claim
            List<Account> getAccountWithCasesClaim = Cel_DataFactoryForTests.createAccountsWithCasesClaim(2,3) ; 
            
           // Create Accounts with Cases
             List<Account> getAccountWithCases = Cel_DataFactoryForTests.createAccountsWithCases(2,3) ; 
   
   }
    
   @isTest 
   Static void testingCaseInsert() {
   
        Map<ID, Account> mapAccounts= new Map<ID,Account>([Select ID from Account]);  

        Map<ID,Case> insertedCases = new  Map<ID,Case> ([Select id, LastModifiedDate from case  where AccountId in : mapAccounts.keySet() AND RecordTypeID =: caseCaseRtID]) ; 
               
        List<individual> ListIndivuals = new List<individual> ([ Select Id,cel_case__c , cel_start_date_consentment__c from individual where cel_case__c in : insertedCases.keySet() ]) ;   
               for(case cases : insertedCases.values()){
                       for(individual ind : ListIndivuals) {
                           if(cases.ID == ind.cel_case__c) {
                                System.assertEquals(cases.LastModifiedDate ,ind.cel_start_date_consentment__c);
                           }
                       }     
               }

    }
     @isTest 
   Static void testingCaseClaimInsert() {
   
        Map<ID, Account> mapAccounts= new Map<ID,Account>([Select ID from Account]);  

        Map<ID,Case> insertedCases = new  Map<ID,Case> ([Select id, LastModifiedDate from case  where AccountId in : mapAccounts.keySet() AND RecordTypeID =: caseClaimRtID]) ; 
               
        List<individual> ListIndivuals = new List<individual> ([ Select Id,cel_case__c,cel_start_date_consentment__c from individual where cel_case__c in : insertedCases.keySet() ]) ;   
               for(case cases : insertedCases.values()){
                       for(individual ind : ListIndivuals) {
                           if(cases.ID == ind.cel_case__c) {
                                System.assertEquals(cases.LastModifiedDate ,ind.cel_start_date_consentment__c);
                           }     
                       }     
               }

    } 
    
       
 @isTest 
   Static void testingCaseUpdate() {
   
        Map<ID, Account> mapAccounts= new Map<ID,Account>([Select ID from Account where lastName like '%Account%']);  
        // Get inserted Transactions from Data initialisation 
        Map<ID,case> insertedCase = new  Map<ID,case> ([Select id, LastModifiedDate from case  where AccountId in : mapAccounts.keySet() AND RecordTypeID =: caseCaseRtID]) ;     
             
        Test.startTest();  
           // Perform test                   
          
            for(case cases : insertedCase.values() ){
                cases.Priority = 'High';   
            }   
            
                    
           update insertedCase.values();   
         
        // Get inserted individuals from Transactions Trigger after case update 
        List<individual> ListIndivuals = new List<individual> ([ Select Id,cel_case__c, cel_start_date_consentment__c from individual where Cel_case__c in : insertedCase.keySet() ]) ; 
        
        List<Case> ListCaseUpdated =new List<Case>([Select id, LastModifiedDate from case  where ID in :  insertedCase.keySet()]) ; 
                  
        Test.stopTest();    
           
           
            for(Case Cases : ListCaseUpdated){
                for(individual ind : ListIndivuals) {
                    if(cases.ID == ind.cel_case__c) {
                        System.assertEquals(Cases.LastModifiedDate ,ind.cel_start_date_consentment__c);
                    }   
                }     
             }

    }   

     @isTest 
   Static void testingCaseClaimUpdate() {
   
        Map<ID, Account> mapAccounts= new Map<ID,Account>([Select ID from Account where lastName like '%Account%']);  
        // Get inserted Transactions from Data initialisation 
        Map<ID,case> insertedCase = new  Map<ID,case> ([Select id, LastModifiedDate from case  where AccountId in : mapAccounts.keySet() AND RecordTypeID =: caseClaimRtID]) ;     
             
        Test.startTest();  
           // Perform test                   
          
            for(case cases : insertedCase.values() ){
               cases.Priority = 'High';   
            }   
                    
           update insertedCase.values();   
         
        // Get inserted individuals from Transactions Trigger
        List<individual> ListIndivuals = new List<individual> ([ Select Id,cel_case__c,cel_start_date_consentment__c from individual where Cel_case__c in : insertedCase.keySet() ]) ; 
       
        List<Case> ListCaseUpdated =new List<Case>([Select id, LastModifiedDate from case  where ID in :  insertedCase.keySet()]) ;  
                  
        Test.stopTest();    
           
           
            for(Case Cases : ListCaseUpdated){
                for(individual ind : ListIndivuals) {
                    if(cases.ID == ind.cel_case__c) {
                        System.assertEquals(Cases.LastModifiedDate ,ind.cel_start_date_consentment__c);
                    }
                }     
             }

    }   
}