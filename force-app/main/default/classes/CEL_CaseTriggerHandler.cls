public class CEL_CaseTriggerHandler {
         
    public CEL_CaseTriggerHandler(){
        
    }
    
    /**
    * Trigger handle on before insert
    * @param {Map<Id, Case>} oldMap
    * @param {List<Case>} newItems
    */
    public void OnBeforeInsert(Map<Id,Case> oldMap, List<Case> newItems) {
        Set<String> productReferences = new Set<String>();
        Set<Id> productIds = new Set<Id>();
        Set<String> customerCodes = new Set<String>();
        Set<Id> accountsId = new Set<Id>();
        Set<String> countiesIsoCode = new Set<String>();
        Set<Id> transcodificationIds = new Set<Id>();
        for (Case i : newItems) {
            if (i.cel_Product__c == null && String.isNotBlank(i.cel_Productreference__c)) {
                productReferences.add(i.cel_Productreference__c);
            }
            if (i.cel_Product__c != null) {
                productIds.add(i.cel_Product__c);
            }
            if (i.AccountId == null && String.isNotBlank(i.cel_ext_account_id__c)) {
                customerCodes.add(i.cel_ext_account_id__c);
            }
            if (i.AccountId != null) {
                accountsId.add(i.AccountId);
            }
            if (i.cel_WebCountry__c == null && String.isNotBlank(i.cel_country_iso_code__c)) {
                countiesIsoCode.add(i.cel_country_iso_code__c);
            }
            if (i.cel_WebCountry__c != null) {
                transcodificationIds.add(i.cel_WebCountry__c);
            }
        }
        
        newItems = attachProductInfos(newItems, productReferences, productIds);
        newItems = attachCountry(newItems, countiesIsoCode, transcodificationIds);
        newItems = attachAccount(newItems, customerCodes, accountsId);
    }
    
    /**
    * Trigger handle on after insert
    * @param {List<Case>} newItems
    */
    public void OnAfterInsert(List<Case> newItems) {
        List<Individual> individualToUpsert = createOrUpdateIndividual(newItems);
        if(!individualToUpsert.isEmpty()) {
            upsert individualToUpsert;
        }
    }

    /**
    * Trigger handle on before update
    * @param {List<Case>} oldItems
    * @param {List<Case>} updatedItems
    * @param {Map<Id, Case>} itemMap
    * @param {Map<Id, Case>} oldItemMap
    */
    public void OnBeforeUpdate(List<Case> oldItems, List<Case> updatedItems, Map<Id, Case> itemMap, Map<Id, Case> oldItemMap) {
        Set<String> productReferences = new Set<String>();
        Set<Id> productIds = new Set<Id>();
        Set<String> customerCodes = new Set<String>();
        Set<Id> accountsId = new Set<Id>();
        Set<String> countiesIsoCode = new Set<String>();
        Set<Id> transcodificationIds = new Set<Id>();
        for (Case i : updatedItems) {
            if (i.cel_Product__c == null && String.isNotBlank(i.cel_Productreference__c)) {
                productReferences.add(i.cel_Productreference__c);
            }
            if (i.cel_Product__c != null) {
                productIds.add(i.cel_Product__c);
            }
            if (i.AccountId == null && String.isNotBlank(i.cel_ext_account_id__c)) {
                customerCodes.add(i.cel_ext_account_id__c);
            }
            if (i.AccountId != null) {
                accountsId.add(i.AccountId);
            }
            if (i.cel_WebCountry__c == null && String.isNotBlank(i.cel_country_iso_code__c)) {
                countiesIsoCode.add(i.cel_country_iso_code__c);
            }
            if (i.cel_WebCountry__c != null) {
                transcodificationIds.add(i.cel_WebCountry__c);
            }
        }
        
        updatedItems = attachProductInfos(updatedItems, productReferences, productIds);
        updatedItems = attachCountry(updatedItems, countiesIsoCode, transcodificationIds);
        updatedItems = attachAccount(updatedItems, customerCodes, accountsId);
    } 
    
    /**
    * Trigger handle on after update
    * @param {List<Case>} olditems
    * @param {List<Case>} updatedItems
    * @param {Map<Id, Case>} itemMap
    * @param {Map<Id, Case>} oldItemMap
    */
    public void OnAfterUpdate(List<Case> oldItems, List<Case> updatedItems, Map<Id, Case> itemMap, Map<Id, Case> oldItemMap) {
        List<Individual> individualToUpsert = createOrUpdateIndividual(updatedItems);
        if(!individualToUpsert.isEmpty()) {
            upsert individualToUpsert;
        }   
    }    

    
    /**
    * Trigger handle on before delete
    * @param {List<Case>} itemsToDelete
    * @param {Map<Id, Case>} itemMap
    */
    public void OnBeforeDelete(List<Case> itemsToDelete, Map<Id, Case> itemMap) {
        
    }
    
    /**
    * Trigger handle on after delete
    * @param {List<Case>} itemsToDelete
    * @param {Map<Id, Case>} itemMap
    */
    public void OnAfterDelete(List<Case> itemsToDelete, Map<Id, Case> itemMap) {
            
        
    }
    
    /**
    * Trigger handle on after undelete
    * @param {List<Case>} restoredItems
    */
    public void OnUndelete(List<Case> restoredItems) {
        
    }
    
   
    /**
     * attachProductInfos : retrieve product Id from SKU
     * @param {List<Case>} items
     * @return {List<Case>}
     */
    private static List<Case> attachProductInfos(List<Case> items, Set<String> productReferences, Set<Id> productIds) {
        // Handy special map constructor
        List<Product2> products = new List<Product2>([
                SELECT Id, cel_id_sku__c
                FROM Product2
                WHERE cel_id_sku__c IN :productReferences 
                OR Id IN :productIds]);

        for (Case i : items) {
            for(Product2 p : products) {
                if (i.cel_Product__c == null && String.isNotBlank(i.cel_Productreference__c)) {
                    if(p != null && p.cel_id_sku__c == i.cel_Productreference__c) {
                        i.cel_Product__c = p.Id;
                    }
                }
            }
        }
        
        return items;
    }
    
    /**
     * attachCountry : retrieve Country from country iso code
     * @param {List<Case>} items
     * @return {List<Case>}
     */
    private static List<Case> attachCountry(List<Case> items, Set<String> countiesIsoCode, Set<Id> transcodificationIds) { 
        // Handy special map constructor
        List<cel_transcodification__c> transcodifications = new List<cel_transcodification__c>([
                SELECT Id, cel_transcodification_label1__c
                FROM cel_transcodification__c
                WHERE cel_transcodification_label1__c IN :countiesIsoCode 
                OR Id IN :transcodificationIds]);

        for (Case i : items) {
            for(cel_transcodification__c t : transcodifications) {
                if (i.cel_WebCountry__c == null && String.isNotBlank(i.cel_country_iso_code__c)) {
                    if(t != null && t.cel_transcodification_label1__c == i.cel_country_iso_code__c) {
                        i.cel_WebCountry__c = t.Id;
                    }
                }
            }
        }
        
        return items;
    }
    
    /**
     * attachAccount : retrieve Account from Maison ID
     * @param {List<Case>} items
     * @return {List<Case>}
     */
    private static List<Case> attachAccount(List<Case> items, Set<String> customerCodes, Set<Id> accountsId) {        
        // Handy special map constructor
        List<Account> accounts = new List<Account>([
                SELECT Id, cel_ext_account_id__c
                FROM account
                WHERE cel_ext_account_id__c IN :customerCodes 
                OR Id IN :accountsId]);

        for (Case i : items) {
            for(Account a : accounts) {
                if (i.AccountId == null && String.isNotBlank(i.cel_ext_account_id__c)) {
                    if(a != null && a.cel_ext_account_id__c == i.cel_ext_account_id__c) {
                        i.AccountId = a.Id;
                    }
                }
            }
        }
        
        return items;
    }

    
    
    /**
    * createOrUpdateIndividual : Create or update consent from transactions
    * @param {Map<ID,cel_Transaction__c>} mapAccountTransa
    * @return {List<Individual>}
    */
    private List<Individual> createOrUpdateIndividual(List<Case> cases) {
        List<Individual> individualsToUpsert = new List<Individual>();
        List<Id> relatedAccounts = new List<Id>();
        List<Individual> listExistingIndiv = new List<Individual>();
        Map<ID,Individual> mapAccountCaseConsent = new Map<ID,Individual>();
        Individual existingCaseConsent;
        Individual newCaseConsent;
        Individual existingOptinConsent;
        Id accountId;
        Id caseClaimRtID  = CEL_Constants.caseClaimRtID;  
        Id caseCaseRtID = CEL_Constants.caseCaseRtID;  
        String ccmConsent = CEL_Constants.consentPurpose.get('CCM');
        String caseConsent = CEL_Constants.consentType.get('Case');
        String claimConsent = CEL_Constants.consentType.get('Claim');
        List<String> consentsType = new List<String>();
        consentsType.add(caseConsent);
        consentsType.add(claimConsent);

        
        for (Case c : cases){
            if(c.AccountId != null) {
                relatedAccounts.add(c.AccountId);
            }
        }
        
        if(!relatedAccounts.isEmpty()) {
            listExistingIndiv = [SELECT Id, cel_Consent_log__c, cel_consent_status__c, cel_purpose__c, cel_Type__c, cel_start_date_consentment__c FROM Individual WHERE cel_Consent_log__c = :relatedAccounts AND (cel_purpose__c = :ccmConsent OR cel_Type__c in :consentsType) order by createdDate DESC];
            
            for(Individual indiv : listExistingIndiv) {
                if (indiv.cel_Type__c == caseConsent || indiv.cel_Type__c == claimConsent) {
                    mapAccountCaseConsent.put(indiv.cel_consent_log__c,indiv);
                }
            }
            
            for (Case c : cases){
                accountId = c.AccountId;
                if (mapAccountCaseConsent.containsKey(AccountId)){
                    existingCaseConsent = mapAccountCaseConsent.get(accountId);
                    if(existingCaseConsent.cel_start_date_consentment__c == null || existingCaseConsent.cel_start_date_consentment__c < c.LastModifiedDate) {
                        Individual indToUpdate;
                        if(c.recordTypeId == caseClaimRtID) {
                            indToUpdate = CEL_IndividualMgr.constructIndividualFromCaseClaim(c);
                        } else {
                            indToUpdate = CEL_IndividualMgr.constructIndividualFromCase(c);
                        }
                        indToUpdate.Id = existingCaseConsent.Id;
                        mapAccountCaseConsent.put(existingCaseConsent.cel_consent_log__c, indToUpdate);
                    }
                } else {
                    if(c.recordTypeId == caseClaimRtID) {
                        newCaseConsent = CEL_IndividualMgr.constructIndividualFromCaseClaim(c);
                    } else {
                        newCaseConsent = CEL_IndividualMgr.constructIndividualFromCase(c);
                    }
                    mapAccountCaseConsent.put(accountId, newCaseConsent);
                }
            }
            
            individualsToUpsert.addAll(mapAccountCaseConsent.values());
        }
        return individualsToUpsert;
    }
 
}