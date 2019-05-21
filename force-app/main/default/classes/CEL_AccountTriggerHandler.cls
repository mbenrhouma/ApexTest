public class CEL_AccountTriggerHandler {
    
    public CEL_AccountTriggerHandler(){
        
    }
    
    /**
    * Trigger handle on before insert
    * @param {Map<Id, Account>} oldMap
    * @param {List<Account>} newItems
    */
    public void OnBeforeInsert(Map<Id,Account> oldMap, List<Account> newItems) {
        Id transcoAreaRtID = CEL_Constants.transcoAreaRtID;
        Map<String, ID> mapTranscoAreaByCode = new Map<String, ID>(); 
        Id storeRtID = CEL_Constants.storeRtID;
        Map<String, String> mapStoreLabelByCode = new Map<String, String>(); 

        for(cel_transcodification__c tr : [SELECT ID, Name, cel_transcodification_code__c FROM cel_transcodification__c where RecordTypeId = :transcoAreaRtID]) {
            mapTranscoAreaByCode.put(tr.Name, tr.ID);
        } 

        for(Account a : [SELECT ID,Name,cel_store_code_Y2__c FROM Account WHERE RecordTypeId = :storeRtID]) {
            mapStoreLabelByCode.put(a.cel_store_code_Y2__c, a.Name);
        }
        for(Account account: newItems){
            if(account.RecordTypeId != storeRtID) {
                checkModificationUserAndUpdate(account);
                updateSegmentLabel(account,account.cel_segmentation__c);
                getStoreLabelByCode(account,mapStoreLabelByCode);
                updateSalutationLabel(account, account.Salutation);
            } else {
                updateStoreArea(account, mapTranscoAreaByCode);
            }
        }    
    }
    
    /**
    * Trigger handle on after insert
    * @param {List<Account>} newItems
    */
    public void OnAfterInsert(List<Account> newItems) {
        Id personAccountRtID = CEL_Constants.peronAccountRtID;
        List<Individual> listIndiv = new List<Individual>();
        cel_Transaction__c tr;
        Case c;
        Individual indTransaction;
        Individual indCase;
        for(Account a : newItems) {
            if(a.RecordTypeId == personAccountRtID) {
                listIndiv.add(CEL_IndividualMgr.constructIndividualFromAccount(a));
                tr = new cel_Transaction__c(cel_AccountId__c = a.Id);
                indTransaction = CEL_IndividualMgr.constructIndividualFromTransaction(tr);
                indTransaction.cel_consent_status__c = CEL_Constants.consentStatus.get('OFF');
                listIndiv.add(indTransaction);
                c = new Case(accountId = a.Id);
                indCase = CEL_IndividualMgr.constructIndividualFromCaseClaim(c);
                indCase.cel_consent_status__c = CEL_Constants.consentStatus.get('OFF');
                listIndiv.add(indCase);
            }
        }
       
        insert listIndiv;
    }

    /**
    * Trigger handle on before update
    * @param {List<Account>} oldItems
    * @param {List<Account>} updatedItems
    * @param {Map<Id, Account>} itemMap
    * @param {Map<Id, Account>} oldItemMap
    */
    public void OnBeforeUpdate(List<Account> oldItems, List<Account> updatedItems, Map<Id, Account> itemMap, Map<Id, Account> oldItemMap) {
        Id transcoAreaRtID = CEL_Constants.transcoAreaRtID;
        Map<String, ID> mapTranscoAreaByCode = new Map<String, ID>(); 
        Map<ID, Individual> mapConsentsByAccountId = new Map<ID, Individual>();
        Map<String, String> mapStoreLabelByCode = new Map<String, String>(); 
        String purposeCCM = CEL_Constants.consentPurpose.get('CCM');
        List<Individual> individualToUpdate = new List<Individual>();
        Account oldAccount;
        Account updatedAccount;
        Individual actualConsent;
        String actualConsentStatus;
        Boolean consentStatus;
        String newConsentStatus;
        Id storeRtID = CEL_Constants.storeRtID;
        Integer nbUpdatedAccounts = updatedItems.size();

        for(cel_transcodification__c tr : [SELECT ID, Name FROM cel_transcodification__c where RecordTypeId = :transcoAreaRtID]) {
            mapTranscoAreaByCode.put(tr.Name, tr.ID);
        }  
        for(Account a : [SELECT ID,Name,cel_store_code_Y2__c FROM Account WHERE RecordTypeId = :storeRtID]){
            mapStoreLabelByCode.put(a.cel_store_code_Y2__c, a.Name);
        }
        List<Individual> existingConsents = [SELECT ID, cel_consent_log__c, cel_start_date_consentment__c, cel_consent_status__c FROM Individual WHERE cel_Consent_log__c in :updatedItems AND cel_Purpose__c = :purposeCCM];

        for(Individual c : existingConsents) {
            mapConsentsByAccountId.put(c.cel_consent_log__c, c);
        }
        
        for(Integer ind = 0; ind < updatedItems.size(); ind++){
            updatedAccount = updatedItems.get(ind);
            consentStatus =  CEL_AccountMgr.getOptinConsent(updatedAccount);
            newConsentStatus = String.valueOf(consentStatus);
            actualConsent = mapConsentsByAccountId.get(updatedAccount.Id);
            actualConsentStatus = actualConsent != null ? actualConsent.cel_consent_status__c : null;

            if(updatedAccount.RecordTypeId != storeRtID) {
                if(updatedAccount.Id !=null && oldItemMap.containsKey(updatedAccount.Id)) {
                    oldAccount = oldItemMap.get(updatedAccount.Id);
                } 
                if ((updatedAccount.cel_addr_1_line_1__c !=null && updatedAccount.cel_addr_1_line_1__c != oldAccount.cel_addr_1_line_1__c)
                    || (updatedAccount.cel_addr_1_line_2__c !=null && updatedAccount.cel_addr_1_line_2__c != oldAccount.cel_addr_1_line_2__c)
                    || (updatedAccount.cel_addr_1_line_3__c !=null && updatedAccount.cel_addr_1_line_3__c != oldAccount.cel_addr_1_line_3__c)
                    || (updatedAccount.cel_addr_1_zipcode__c !=null && updatedAccount.cel_addr_1_zipcode__c != oldAccount.cel_addr_1_zipcode__c)
                    || (updatedAccount.cel_addr_1_region__c !=null && updatedAccount.cel_addr_1_region__c != oldAccount.cel_addr_1_region__c)
                    || (updatedAccount.cel_addr_1_city__c !=null && updatedAccount.cel_addr_1_city__c != oldAccount.cel_addr_1_city__c)
                    || (updatedAccount.cel_addr_1_region__c !=null && updatedAccount.cel_addr_1_region__c != oldAccount.cel_addr_1_region__c)
                    || (updatedAccount.cel_addr_1_country__c !=null && updatedAccount.cel_addr_1_country__c != oldAccount.cel_addr_1_country__c)) {
                        updatedAccount.cel_rcu_update__c = true;
                    }    
                if (updatedAccount.PersonBirthDate != null) {
                    Date birthDate = updatedAccount.PersonBirthDate;
                    updatedAccount.cel_birthdate_day__c = birthDate.day();
                    updatedAccount.cel_birthdate_month__c = birthDate.month();
                    updatedAccount.cel_birthdate_year__c = birthDate.year(); 
                }

                if (actualConsentStatus != null 
                        && actualConsentStatus != newConsentStatus 
                        && updatedAccount.AccountSource != CEL_Constants.accountModificationFrom.get('IndividualTrigger')) {
                    
                    actualConsent.cel_consent_status__c = newConsentStatus;
                    if(newConsentStatus == CEL_Constants.consentStatus.get('ON')) {
                        actualConsent.cel_start_date_consentment__c = Datetime.now();
                    }
                    actualConsent.cel_updated_by_trigger__c = true;
                    individualToUpdate.add(actualConsent);
                }

                getStoreLabelByCode(updatedAccount,mapStoreLabelByCode);
                updateSegmentLabel(updatedAccount,updatedAccount.cel_segmentation__c);
                checkModificationUserAndUpdate(updatedAccount);
                updateSalutationLabel(updatedAccount, updatedAccount.Salutation);
            } else {
                updateStoreArea(updatedAccount, mapTranscoAreaByCode);
            }
        }
        
        if(!individualToUpdate.isEmpty()) {
            update individualToUpdate;
        }
    } 
    
    /**
    * Trigger handle on after update
    * @param {List<Account>} olditems
    * @param {List<Account>} updatedItems
    * @param {Map<Id, Account>} itemMap
    * @param {Map<Id, Account>} oldItemMap
    */
    public void OnAfterUpdate(List<Account> oldItems, List<Account> updatedItems, Map<Id, Account> itemMap, Map<Id, Account> oldItemMap) {
        
    }
    
    /**
    * Trigger handle on before delete
    * @param {List<Account>} itemsToDelete
    * @param {Map<Id, Account>} itemMap
    */
    public void OnBeforeDelete(List<Account> itemsToDelete, Map<Id, Account> itemMap) {
        
    }
    
    /**
    * Trigger handle on after delete
    * @param {List<Account>} itemsToDelete
    * @param {Map<Id, Account>} itemMap
    */
    public void OnAfterDelete(List<Account> itemsToDelete, Map<Id, Account> itemMap) {
        Set<String> mastersAccountList = new Set<String>();
        for(Account act : itemsToDelete){
          mastersAccountList.add(act.MasterRecordId);    
        }
        
        List<CEL_Customer_Duplication__c> customerDuplicationRecordsList = [SELECT ID, cel_idGroup__c, cel_account__c,cel_is_treated_flag__c FROM CEL_Customer_Duplication__c WHERE cel_account__c IN :itemsToDelete OR cel_account__c IN :mastersAccountList];

        if(customerDuplicationRecordsList.size() > 0){
            for(CEL_Customer_Duplication__c customerDuplicationRecord : customerDuplicationRecordsList){
                customerDuplicationRecord.cel_is_treated_flag__c = true;
            }
            update customerDuplicationRecordsList;
        }      
    }
    
    /**
    * Trigger handle on after undelete
    * @param {List<Account>} restoredItems
    */
    public void OnUndelete(List<Account> restoredItems) {
        
    }
    
    /**
     * Update account source field
     * @param {Account} Account to update
     * 
     */
    private void checkModificationUserAndUpdate(Account account) {
        // Update in RCU
        if(UserInfo.getUserId() != CEL_Constants.interfaceUserId) {
            account.AccountSource = CEL_Constants.accountModificationFrom.get('RCU');
        }
    }
    
    /**
    * Update cel_segmentation__c field with the value of the account.segmentation
    * @param {Account , String} account to update , value of the segment 
    *
    */
    private void updateSegmentLabel(Account account, String value) {
        //get the account segmentation label and set the field cel_segment_value_label__c
        
        if(String.isNotBlank(value)) {
            Schema.SobjectField segmentationField = CEL_Utils.getFieldSchemaObject('Account', 'cel_segmentation__c');
            String segmentLabel = CEL_Utils.getStdPicklistLabelFromValue(segmentationField, value);
            account.cel_segment_value_label__c = segmentLabel;
        }
        
    }

    /**
     * updateStoreArea Update store area with the transcodification
     * @param  {Account}    account
     * @param  {Map<Id, cel_transcodification__c>}  mapTranscoAreaById
     * @param  {Map<String, ID>} mapTranscoAreaByCode 
     */
    private void updateStoreArea(Account account, Map<String, ID> mapTranscoAreaByCode) {
        if(account.cel_addr_1_region__c != null) {
            account.cel_store_area__c = mapTranscoAreaByCode.containsKey(account.cel_addr_1_region__c) ? mapTranscoAreaByCode.get(account.cel_addr_1_region__c) : mapTranscoAreaByCode.get('EMEA');
        }         
	}

    /**
     * getStoreLabelByCode Fill the first purchase store name
     * @param  {Account} account
     * @param  {Map<String, String>} mapStoreLabelByCode
     */
    private void getStoreLabelByCode(Account account, Map<String, String> mapStoreLabelByCode){
        account.cel_first_purchase_store_name__c = mapStoreLabelByCode.containsKey(account.cel_first_purchase_store__c) ? mapStoreLabelByCode.get(account.cel_first_purchase_store__c) : '';
    }
    
    /**
     * Update account salutation label field
     * @param {Account} Account to update
     * 
     */
    private void updateSalutationLabel(Account account, String value) {
        //get the account salutation and set the field salutation label
        if(String.isNotBlank(account.Salutation)) {
            Schema.SobjectField salutaionField = CEL_Utils.getFieldSchemaObject('Account','Salutation');
            String titleLabel = CEL_Utils.getStdPicklistLabelFromValue(salutaionField, value);
            account.cel_salutation_label__c = titleLabel;
        }
        else{
            account.cel_salutation_label__c = null;
        }
    }

}