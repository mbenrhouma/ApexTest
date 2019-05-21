public class CEL_CampaignMemberStatusTriggerHandler {

    
    public CEL_CampaignMemberStatusTriggerHandler(){
        
    }
    
    /**
    * Trigger handle on before insert
    * @param {Map<Id, cel_Campaign_Member_Status__c>} oldMap
    * @param {List<cel_Campaign_Member_Status__c>} newItems
    */
    public void OnBeforeInsert(Map<Id,cel_Campaign_Member_Status__c> oldMap, List<cel_Campaign_Member_Status__c> newItems) {
        List<Campaign> listCamp = new List<Campaign>();
        set<String> setidCampas = new Set<String>();
        List<String> customerCodeList = new List<String>();
        Account client;  
        Id personAccounRtID = CEL_Constants.peronAccountRtID;

        //get the min startDate, and max endDate
        Date startDatett = Date.today(), endDatett= Date.today();
        Set<String> setIdContacts = new Set<String>();
        
        Map<String, decimal> map_curr_rate = new Map<String, decimal>();
        map_curr_rate = CEL_DatedConversionRateMgr.getMapCurrentConversionRate();
        
        Map<String, String> mapidCamp_currenylocale = new Map<String, String>();

        for(cel_Campaign_Member_Status__c c : newItems) {
            if(c.cel_ext_account_id__c != null) {
                customerCodeList.add(c.cel_ext_account_id__c);
            }
        }

        List<Account> clients = [SELECT Id, cel_ext_account_id__c, PersonContactId FROM Account WHERE cel_ext_account_id__c IN :customerCodeList AND RecordtypeId = :personAccounRtID];
        Map<String, Account> mapCustomerCodeAccount = new Map<String, Account>();
        for(Account a : clients) {
            mapCustomerCodeAccount.put(a.cel_ext_account_id__c, a);
        }
                     
        for(cel_Campaign_Member_Status__c c : newItems) {
            if(c.cel_ext_account_id__c != null) {
                client = mapCustomerCodeAccount.get(c.cel_ext_account_id__c);
                c.cel_Contact__c = client.PersonContactId;
                c.cel_Member_Name__c = client.Id;
            }
            setidCampas.add(c.cel_Campaign__c);
            String defaultCurrency = UserInfo.getDefaultCurrency();
            if( c.CurrencyIsoCode != defaultCurrency){
                c.CurrencyIsoCode = defaultCurrency;
            }
            
            if(c.cel_Activity_Validity_Start_Date__c != null && c.cel_Activity_Validity_End_Date__c != null){
                if(c.cel_Activity_Validity_Start_Date__c < startDatett){
                    startDatett = c.cel_Activity_Validity_Start_Date__c;
                }
                
                if(c.cel_Activity_Validity_End_Date__c > endDatett){
                    endDatett = c.cel_Activity_Validity_End_Date__c;
                }
            }
            
            setIdContacts.add(c.cel_Contact__c);
        }
        
        if(!setidCampas.isempty()){
            listCamp = [select id, cel_local_Currency__c from campaign where id in : setidCampas];    
            
            for(Campaign c : listCamp){
                mapidCamp_currenylocale.put(c.id, c.cel_local_Currency__c);
            }
        }
               
       calculate_DirectSales(newItems, setIdContacts, startDatett, endDatett );
       //convert values
       for(cel_Campaign_Member_Status__c c : newItems) {
           convertAmount_campaignMemberStatus(c,  map_curr_rate, mapidCamp_currenylocale);
       }
    }
    
    /**
    * Trigger handle on after insert
    * @param {List<cel_Campaign_Member_Status__c>} newItems
    */
    public void OnAfterInsert(List<cel_Campaign_Member_Status__c> newItems) {
        Set<Id> setCamp = new Set<Id>();
        List<Campaign> listCamp = new List<Campaign>();
        for(cel_Campaign_Member_Status__c c : newItems){
            setCamp.add(c.cel_campaign__c);
        }
        //Update all the campaign associated to get the result 
        listCamp = [select id, recordtypeid, parentid from campaign where id in : setCamp];
        set<String> setCampaignParent = new Set<String>();
        String campaignParentRecordType = CEL_Constants.campaignParentRecordType;
        
        if(!listCamp.isempty()){
            update listCamp;
        }
         
        //Parents
        for(Campaign cp : listCamp){
            if(cp.recordtypeId == campaignParentRecordType){
                setCampaignParent.add(cp.parentId);
            }
        }
        //Then the Parents Campaigns !
        List<Campaign> listParents = new List<Campaign>();
        listParents = [select id from campaign where id in :setCampaignParent];
        if(!listParents.isempty()){
            update listParents;
        }
    }
    
    /**
    * Trigger handle on before update
    * @param {List<cel_Campaign_Member_Status__c>} oldItems
    * @param {List<cel_Campaign_Member_Status__c>} updatedItems
    * @param {Map<Id, cel_Campaign_Member_Status__c>} itemMap
    * @param {Map<Id, cel_Campaign_Member_Status__c>} oldItemMap
    */
    public void OnBeforeUpdate(List<cel_Campaign_Member_Status__c> oldItems, List<cel_Campaign_Member_Status__c> updatedItems, Map<Id, cel_Campaign_Member_Status__c> itemMap, Map<Id, cel_Campaign_Member_Status__c> oldItemMap){
        List<cel_Transaction__c> listTransactions = new List<cel_Transaction__c>();
        integer i = 0;
        Date startDatett = Date.today(), endDatett= Date.today();
        Set<String> setIdContacts = new Set<String>();
        List<Campaign> listCamp = new List<Campaign>();
        set<String> setidCampas = new Set<String>();
        
        Map<String, decimal> map_curr_rate = new Map<String, decimal>();
        map_curr_rate = CEL_DatedConversionRateMgr.getMapCurrentConversionRate();
        Map<String, String> mapidCamp_currenylocale = new Map<String, String>();
        List<cel_Campaign_Member_Status__c> listToEvaluateAgain = new List<cel_Campaign_Member_Status__c>();
        //Affectations
        for(cel_Campaign_Member_Status__c c : updatedItems){
            setidCampas.add(c.cel_Campaign__c);
            String defaultCurrency = UserInfo.getDefaultCurrency();
            if( c.CurrencyIsoCode != defaultCurrency){
                c.CurrencyIsoCode = defaultCurrency;
            }
            
            startDatett = c.cel_Activity_Validity_Start_Date__c;
            endDatett = c.cel_Activity_Validity_End_Date__c;
            
            listToEvaluateAgain.add(c);
            setIdContacts.add(c.cel_Contact__c);
            
            i += 1;
        }
        //calculate Sales Target
        if(!listToEvaluateAgain.isempty()){
            calculate_DirectSales(listToEvaluateAgain, setIdContacts, startDatett, endDatett);
        }
        
        //convert values
        if(!setidCampas.isempty()){
            listCamp = [select id, cel_local_Currency__c from campaign where id in : setidCampas];
            for(Campaign c : listCamp){
                mapidCamp_currenylocale.put(c.id, c.cel_local_Currency__c);
            }
        }
        for(cel_Campaign_Member_Status__c c : updatedItems){
           convertAmount_campaignMemberStatus(c, map_curr_rate, mapidCamp_currenylocale);
        }
    }
    
    /**
    * Trigger handle on after update
    * @param {List<cel_Campaign_Member_Status__c>} olditems
    * @param {List<cel_Campaign_Member_Status__c>} updatedItems
    * @param {Map<Id, cel_Campaign_Member_Status__c>} itemMap
    * @param {Map<Id, cel_Campaign_Member_Status__c>} oldItemMap
    */
    public void OnAfterUpdate(List<cel_Campaign_Member_Status__c> oldItems, List<cel_Campaign_Member_Status__c> updatedItems, Map<Id, cel_Campaign_Member_Status__c> itemMap, Map<Id, cel_Campaign_Member_Status__c> oldItemMap) 
    {
        Set<Id> setCamp = new Set<Id>();
        List<Campaign> listCamp = new List<Campaign>();
        for(cel_Campaign_Member_Status__c c : updatedItems){
            setCamp.add(c.cel_campaign__c);
        }
        //Update all the campaign associated to get the result 
        listCamp = [select id, recordtypeid, parentid from campaign where id in : setCamp];
        set<String> setCampaignParent = new Set<String>();
        
        String campaignParentRecordType = CEL_Constants.campaignParentRecordType;
        
        if(!listCamp.isempty()){
            update listCamp;
        }
        
        //Parents
        for(Campaign cp : listCamp){
            if(cp.recordtypeId == campaignParentRecordType){
                setCampaignParent.add(cp.parentId);
            }
        }
        //Then the Parents Campaigns
        List<Campaign> listParents = new List<Campaign>();
        listParents = [select id from campaign where id in :setCampaignParent];
        if(!listParents.isempty()){
            update listParents;
        }
    }
    
    /**
    * Trigger handle on before delete
    * @param {List<cel_Campaign_Member_Status__c>} itemsToDelete
    * @param {Map<Id, cel_Campaign_Member_Status__c>} itemMap
    */
    public void OnBeforeDelete(List<cel_Campaign_Member_Status__c> itemsToDelete, Map<Id, cel_Campaign_Member_Status__c> itemMap) {
        
    }
    
    /**
    * Trigger handle on after delete
    * @param {List<cel_Campaign_Member_Status__c>} itemsToDelete
    * @param {Map<Id, cel_Campaign_Member_Status__c>} itemMap
    */
    public void OnAfterDelete(List<cel_Campaign_Member_Status__c> itemsToDelete, Map<Id, cel_Campaign_Member_Status__c> itemMap) {
        
    }
    
    /**
    * Trigger handle on after undelete
    * @param {List<cel_Campaign_Member_Status__c>} restoredItems
    */
    public void OnUndelete(List<cel_Campaign_Member_Status__c> restoredItems) {
        
    }
    
    /**
    * calculate_DirectSales calcul Direct Sales
    * @param {List<cel_Campaign_Member_Status__c>} newItems
    * @param {Set<String>} setIdContacts
    * @param {Date} startDatett
    * @param {Date} endDatett
    */
    public void calculate_DirectSales(List<cel_Campaign_Member_Status__c> newItems, Set<String> setIdContacts, Date startDatett, Date endDatett){
        if(!setIdContacts.isempty()){
            //get the accounts first
            List<contact> listCont = [select accountId, id from contact where id in : setIdContacts];
            
            Set<String> setIdAccounts = new Set<String>();
            Map<String, String> map_contactid_accountId = new Map<String, String>();
            for(contact c : listCont){
                setIdAccounts.add(c.accountID);
                map_contactid_accountId.put(c.id, c.accountID);
            }
            
            List<cel_Transaction__c> listTransactions = new List<cel_Transaction__c>();
            listTransactions =  [select id, 
                                        cel_Total_Net_Value_local_tax_inc_EUR__c , 
                                        cel_sale_date__c, 
                                        cel_AccountId__c
                                 FROM cel_Transaction__c 
                                 WHERE cel_Total_Net_Value_local_tax_inc_EUR__c != NULL 
                                 AND cel_is_cancelled__c = false
                                 AND cel_sale_date__c >= :startDatett 
                                 AND cel_sale_date__c <= :endDatett 
                                 AND cel_AccountId__c in : setIdAccounts ];
            
            Decimal transEur = 0;
            for(cel_Campaign_Member_Status__c c : newItems){
                for(cel_Transaction__c trans : listTransactions){
                    if(!map_contactid_accountId.isempty()){
                        if(map_contactid_accountId.get(c.cel_Contact__c) != null){
                            if(map_contactid_accountId.get(c.cel_Contact__c) == trans.cel_AccountId__c
                              && c.cel_Activity_Validity_Start_Date__c <= trans.cel_sale_date__c
                              && c.cel_Activity_Validity_End_Date__c >= trans.cel_sale_date__c){
                                //valeurs euro
                                transEur += trans.cel_Total_Net_Value_local_tax_inc_EUR__c;
                            }
                        }
                    }
                }
                c.cel_total_Transaction_Sales_Euro__c  = transEur;
                //Reset value
                transEur = 0;
            }
        }
    }
    
    /**
    * convertAmount_campaignMemberStatus convert amount
    * @param {cel_Campaign_Member_Status__c} c
    * @param {Map<String, Decimal>} map_curr_rate
    * @param {Map<String, String>} mapidCamp_currenylocale
    */
    public void convertAmount_campaignMemberStatus(cel_Campaign_Member_Status__c c, Map<String, Decimal> map_curr_rate, Map<String, String> mapidCamp_currenylocale){
         Decimal transactionsEuros = 0, transactionss = 0; 
         Decimal wdepLocale = 0, wdep = 0, wodepLocale = 0, wodep = 0, theRate = 0;
         String theCurrencyIsoCode_OfCampaign = '';
         //Updates amounts
         if(map_curr_rate != null && !map_curr_rate.isempty()){
             theCurrencyIsoCode_OfCampaign = mapidCamp_currenylocale.get(c.cel_Campaign__c);
             theRate = map_curr_rate.get(theCurrencyIsoCode_OfCampaign);
             
             if(theRate != null && theRate > 0){
                if(c.cel_total_Transaction_Sales_Euro__c != null){
                    transactionsEuros = c.cel_total_Transaction_Sales_Euro__c;
                    transactionss = (1/theRate)*c.cel_total_Transaction_Sales_Euro__c;
                }
                
                if(c.cel_Res_w_dep__c != null){
                    wdep = (1/theRate)*c.cel_Res_w_dep__c;
                    wdepLocale = c.cel_Res_w_dep__c;
                }
                
                if(c.cel_Reswodep__c != null){
                    wodep = (1/theRate)*c.cel_Reswodep__c;
                    wodepLocale = c.cel_Reswodep__c;
                }
                
                //get the rates
                c.cel_total_Transaction_Sales__c = transactionss ;
                c.cel_ResWDep_Euro__c = wdep;
                c.cel_ResWODep_Euro__c = wodep;
                
                //Direct Sales
                c.cel_Direct_Sales__c = transactionsEuros;
                c.cel_Direct_Sales_locale__c = transactionss;
                c.cel_TotalSales_locale__c = wdepLocale + wodepLocale + transactionss;
                Decimal totalLocal = c.cel_TotalSales_locale__c ;
                //Eur
                c.cel_TotalSales__c = (wdepLocale + wodepLocale + transactionss)*(1/theRate);
            }
        }
    }

}