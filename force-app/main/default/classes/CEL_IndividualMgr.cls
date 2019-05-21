public class CEL_IndividualMgr {
    
    /**
     * constructIndividualFromTransaction : Create an individual from Transaction
     * @param  {cel_Transaction__c} Transaction
     * @return {Individual}
     */
    public static Individual constructIndividualFromTransaction(cel_Transaction__c tr) {
        Individual ind = new Individual();
        ind.cel_Type__c = CEL_Constants.consentType.get('Transaction');
        ind.cel_start_date_consentment__c = tr.cel_sale_date__c;
        ind.cel_consent_log__c = tr.cel_AccountId__c;
        ind.LastName = CEL_Constants.consentPurpose.get('CRM');
        ind.cel_Purpose__c = CEL_Constants.consentPurpose.get('CRM');
        ind.cel_consent_status__c = CEL_Constants.consentStatus.get('ON');
        ind.Cel_transaction__c = tr.Id;
        
        return ind;
    }
    
    /**
     * constructIndividualFromCase : Create an individual from Case
     * @param  {Case} Case
     * @return {Individual}
     */
    public static Individual constructIndividualFromCase(Case c) {
        Individual ind = new Individual();        
        ind.cel_type__c = CEL_Constants.consentType.get('Case');   
        ind.cel_Purpose__c = CEL_Constants.consentPurpose.get('ASM');
        ind.cel_start_date_consentment__c = c.LastModifiedDate;
        ind.cel_consent_log__c = c.accountId;
        ind.cel_case__c = c.id;
        ind.cel_consent_status__c = CEL_Constants.consentStatus.get('ON');
        ind.LastName = CEL_Constants.consentPurpose.get('ASM');
        
        return ind;
    }
    
    /**
     * constructIndividualFromCaseClaim : Create an individual from Case Claim
     * @param  {Case} Case
     * @return {Individual}
     */
    public static Individual constructIndividualFromCaseClaim(Case c) {
        Individual ind = new Individual();        
        ind.cel_type__c = CEL_Constants.consentType.get('Claim');
        ind.cel_Purpose__c = CEL_Constants.consentPurpose.get('ASM');
        ind.cel_start_date_consentment__c = c.LastModifiedDate;
        ind.cel_consent_log__c = c.accountId;
        ind.cel_case__c = c.id;
        ind.cel_consent_status__c = CEL_Constants.consentStatus.get('ON');
        ind.LastName = CEL_Constants.consentPurpose.get('ASM');
        
        return ind;
    }


    /**
     * updateExtrationDate update Extraction date when click on portability
     * @param  {String} account ID
     */
    public static void updateExtrationDate(String accountId) {
        if(accountId == null) {
            return;
        }

        List<Individual> inds = [SELECT Cel_ExtractionDate__c FROM Individual WHERE cel_Consent_log__c =: accountId];
        for(Individual i : inds) {
            i.Cel_ExtractionDate__c = Datetime.now();
        }
        if(inds != null && inds.size() > 0) {
            update inds;
        }
    }
    
    /**
     * constructIndividualFromAccount : Create an individual from Account
     * @param  {Account} Account
     * @return {Individual}
     */
    public static Individual constructIndividualFromAccount(Account acc) {
        Individual indiv = new Individual();
        indiv.LastName = CEL_Constants.consentPurpose.get('CCM');
        indiv.cel_Purpose__c = CEL_Constants.consentPurpose.get('CCM');
        indiv.cel_Consent_log__c = acc.Id;
        indiv.cel_start_date_consentment__c = acc.cel_creation_date__c;
        Boolean consentStatus = CEL_AccountMgr.getOptinConsent(acc);
        indiv.cel_consent_status__c = String.valueOf(consentStatus);
        
        return indiv;
    }

    /** 
     * updateIndividualAfterAnonymization Update anonimyzed field in individual after anonymization
     * @param {List<Account>} accounts
     */
    public static void updateIndividualAfterAnonymization(List<Account> accounts) {
        List<Individual> inds = [SELECT ID, cel_Anonymized__c FROM Individual WHERE cel_Consent_log__c IN :accounts];
        for(Individual i : inds) {
            i.cel_Anonymized__c = true;
        }
        update inds;
    }


}