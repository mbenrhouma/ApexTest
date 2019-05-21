@isTest
public class CEL_IndividualTriggerHandler_TEST {
    
    @isTest
    static void testIndividualTriggerHandler() {
        Account a = new Account();
        a.Name = 'Test';
        Insert a;
        
        Individual consentTransaction = CEL_IndividualMgr.constructIndividualFromAccount(a);
        
        consentTransaction.cel_consent_status__c = CEL_Constants.consentStatus.get('ON');
        insert consentTransaction;
        consentTransaction.cel_start_date_consentment__c = Date.today();
        consentTransaction.cel_consent_status__c = CEL_Constants.consentStatus.get('OFF');
        consentTransaction.cel_updated_by_trigger__c = false;
        update consentTransaction;
        delete consentTransaction;
    }
}