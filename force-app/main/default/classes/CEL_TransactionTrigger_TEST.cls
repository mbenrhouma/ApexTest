@isTest
public class CEL_TransactionTrigger_TEST {

   @testSetup static void setup() {
          List<Account> getAccountsWithTransacs = Cel_DataFactoryForTests.createAccountsWithTrasactions(10,3) ; 
   
   }
    
   @isTest 
   Static void testingTransactionInsert() {
   
        Map<ID, Account> mapAccounts= new Map<ID,Account>([Select ID from Account]);  

        Map<ID,cel_transaction__c> insertedTrans = new  Map<ID,cel_transaction__c> ([Select id, cel_sale_date__c from cel_transaction__c where cel_AccountId__c in : mapAccounts.keySet()]) ; 
               
        List<individual> ListIndivuals = new List<individual> ([ Select Id, cel_start_date_consentment__c from individual where Cel_transaction__c in : insertedTrans.keySet() ]) ;   
               for(cel_Transaction__c trans : insertedTrans.values()){
                       for(individual ind : ListIndivuals) {
                            System.assertEquals(trans.cel_sale_date__c ,ind.cel_start_date_consentment__c);
                       }     
               }

    }
    
    
       
/*   @isTest 
   Static void testingTransactionUpdate() {
   
        Map<ID, Account> mapAccounts= new Map<ID,Account>([Select ID from Account where lastName like '%Account%']);  
        // Get inserted Transactions from Data initialisation 
        Map<ID,cel_transaction__c> insertedTrans = new  Map<ID,cel_transaction__c> ([Select id, cel_sale_date__c from cel_transaction__c where cel_AccountId__c in : mapAccounts.keySet()]) ;     
             
        Test.startTest();  
           // Perform test                   
          
            for(cel_transaction__c trans : insertedTrans.values() ){
               trans.cel_sale_date__c = date.newInstance(2018, 07, 05);   
            }   
                    
           update insertedTrans.values();   
         
        // Get inserted individuals from Transactions Trigger
        List<individual> ListIndivuals = new List<individual> ([ Select Id, cel_start_date_consentment__c from individual where Cel_transaction__c in : insertedTrans.keySet() ]) ; 
         
                  
        Test.stopTest();    
           
           
            for(cel_Transaction__c trans : insertedTrans.values()){
                for(individual ind : ListIndivuals) {
                    System.assertEquals(trans.cel_sale_date__c ,ind.cel_start_date_consentment__c);
                }     
             }

    }   
*/
}