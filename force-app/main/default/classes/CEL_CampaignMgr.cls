public class CEL_CampaignMgr {
    
    /**
     * createCampaignTransaction Create custom object Campaign Transaction for report
     * @param {String} campaignId
     * @return   {Boolean}
     */
    public static Boolean createCampaignTransaction(String campaignId) {
        if(campaignId == null) {
            return false;
        }
        
        try{
            // Get Campaign current
            List<Campaign> c = [SELECT Id, cel_Activity_Validity_End_Date__c, cel_activity_validity_start_date__c  FROM Campaign WHERE Id = :campaignId];
            if(c != null && c.size() > 0){
                Id cId = c.get(0).Id;
                Date startDate = c.get(0).cel_activity_validity_start_date__c;
                Date endDate = c.get(0).cel_Activity_Validity_End_Date__c;
                
                if(cId != null){
                    // Delete old Campaign Transaction Object
                    List<cel_campaign_transaction__c> toDelete = [SELECT Id FROM cel_campaign_transaction__c WHERE cel_campaign__c = :cId AND cel_transaction_line__c = null];
                    delete toDelete;
                    
                    // Get Campaigns Members Status
                    List<cel_Campaign_Member_Status__c > cms = [SELECT Id, cel_Campaign__c, cel_Contact__r.AccountId FROM cel_Campaign_Member_Status__c 
                                                                    WHERE cel_Campaign__c = :cId 
                                                                    AND cel_Campaign__c != null 
                                                                    AND cel_Contact__c != null];
                    List<Id> accsId = new List<Id>();
                    for(cel_Campaign_Member_Status__c cm : cms){
                        accsId.add(cm.cel_Contact__r.AccountId);
                    }
                    
                    if(accsId != null && accsId.size() > 0){
                        // Get All transactions by account Id, StartDate and EndDate
                        List<cel_Transaction__c> transactions = [SELECT Id, cel_sale_date__c, cel_AccountId__c 
                                                                FROM cel_Transaction__c 
                                                                WHERE cel_AccountId__c IN :accsId
                                                                AND cel_is_cancelled__c = false
                                                                AND cel_sale_date__c > :startDate
                                                                AND cel_sale_date__c < :endDate];
                        
                        if(transactions != null && transactions.size() > 0){
                            List<cel_campaign_transaction__c> cts = new List<cel_campaign_transaction__c>();
                            
                            for(cel_Transaction__c t : transactions){
                                cts.add(new cel_campaign_transaction__c(
                                    cel_campaign__c = cId,
                                    cel_transaction__c = t.Id,
                                    cel_transaction_line__c = null
                                ));
                            }
                            
                            insert cts;
                            return true;
                        }
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('Exception: ' + ex.getTypeName() + ' : Message ' + ex.getMessage()  + ' - Cause : ' + ex.getCause() + ' - Trace : ' + ex.getStackTraceString());
        }
        
        return false;
    }
    
    /**
     * createCampaignTransactionLine Create custom object Campaign Transaction with line for report
     * @param {String} campaignId
     * @return   {Boolean}
     */
    public static Boolean createCampaignTransactionLine(String campaignId) {
        if(campaignId == null) {
            return false;
        }
        
        try{
            
            // Get Campaign current
            List<Campaign> c = [SELECT Id, cel_Activity_Validity_End_Date__c, cel_activity_validity_start_date__c  FROM Campaign WHERE Id = :campaignId];
            if(c != null && c.size() > 0){
                Id cId = c.get(0).Id;
                Date startDate = c.get(0).cel_activity_validity_start_date__c;
                Date endDate = c.get(0).cel_Activity_Validity_End_Date__c;
                
                if(cId != null){
                    // Delete old Campaign Transaction Object
                    List<cel_campaign_transaction__c> toDelete = [SELECT Id FROM cel_campaign_transaction__c WHERE cel_campaign__c = :cId AND cel_transaction__c = null];
                    delete toDelete;
                    
                    // Get Campaigns Members
                    List<cel_Campaign_Member_Status__c > cms = [SELECT Id, cel_Campaign__c, cel_Contact__r.AccountId FROM cel_Campaign_Member_Status__c 
                                                                WHERE cel_Campaign__c = :cId 
                                                                AND cel_Campaign__c != null 
                                                                AND cel_Contact__c != null];
                    List<Id> accsId = new List<Id>();
                    for(cel_Campaign_Member_Status__c cm : cms){
                        accsId.add(cm.cel_Contact__r.AccountId);
                    }
                    
                    if(accsId != null && accsId.size() > 0){
                        // Get All transactions by account Id, StartDate and EndDate
                        List<cel_Transaction__c> transactions = [SELECT Id, cel_sale_date__c, cel_AccountId__c 
                                                                FROM cel_Transaction__c 
                                                                WHERE cel_AccountId__c IN :accsId
                                                                AND cel_is_cancelled__c = false
                                                                AND cel_sale_date__c > :startDate
                                                                AND cel_sale_date__c < :endDate];
                                                                
                        List<Id> tIds = new List<Id>();
                        for(cel_Transaction__c t : transactions){
                            tIds.add(t.Id);
                        }
                                                                
                        // Get All transactions Lines by transaction Id
                        List<cel_Transaction_Line__c> transactionsLines = [SELECT Id, cel_transaction__c 
                                                                           FROM cel_Transaction_Line__c 
                                                                           WHERE cel_transaction__c IN :tIds];
                        
                        if(transactionsLines != null && transactionsLines.size() > 0){
                            List<cel_campaign_transaction__c> cts = new List<cel_campaign_transaction__c>();
                            
                            for(cel_Transaction_Line__c tl : transactionsLines){
                                cts.add(new cel_campaign_transaction__c(
                                    cel_campaign__c = cId,
                                    cel_transaction__c = null,
                                    cel_transaction_line__c = tl.Id
                                ));
                            }
                            
                            insert cts;
                            return true;
                        }
                    }
                }
            }
        }
        catch( exception ex ){
            system.debug('Exception: ' + ex.getTypeName() + ' : Message ' + ex.getMessage()  + ' - Cause : ' + ex.getCause() + ' - Trace : ' + ex.getStackTraceString());
        }
        
        return false;
    }
    
    /**
     * getAvailableListZoneCountrieStore Return Map Zone, Countrie and Store for Campaign
     * @param {String} campaignId
     * @return   {Map<String, List<Map<String, String>>>}
     */
    public static Map<String, List<Map<String, String>>> getAvailableListZoneCountrieStore(String recordId, String campaignParentId, String campaignRecordType) {
        Map<String, List<Map<String, String>>> result = new Map<String, List<Map<String, String>>>();
        List<Map<String, String>> zones = new List<Map<String, String>>();
        List<Map<String, String>> countries = new List<Map<String, String>>();
        List<Map<String, String>> stores = new List<Map<String, String>>();
        String campaignParentRecordType = CEL_Constants.campaignParentRecordType;
        String campaignEnfantRecordType = CEL_Constants.campaignEnfantRecordType;
        String storeRecordType = CEL_Constants.storeRecordType;
        
        // Control get recordType values
        if(String.isNotBlank(campaignParentRecordType) && String.isNotBlank(campaignEnfantRecordType) && String.isNotBlank(storeRecordType)) {
            
            // Get elements where is create campaign Parent
            if(String.isBlank(recordId) && String.isBlank(campaignParentId) && campaignRecordType == campaignParentRecordType){
                
            }
            
            // Get elements where is create campaign Enfant
            if(String.isBlank(recordId) && String.isBlank(campaignParentId) && campaignRecordType == campaignEnfantRecordType){
                
            }
            
            // Get elements where is update or view campaign Parent
            if(String.isNotBlank(recordId) && String.isBlank(campaignParentId) && campaignRecordType == campaignParentRecordType){
                
            }
            
            // Get elements where is update or view campaign Enfant
            if(String.isNotBlank(recordId) && String.isNotBlank(campaignParentId) && campaignRecordType == campaignEnfantRecordType){
                
            }
            
            
            
            // Get Stores
            List<Account> ss = [SELECT Id, Name, 
                                           cel_short_name__c
                                           //cel_store_area__r.cel_transcodification_code__c 
                                           FROM Account 
                                           WHERE RecordTypeId = :storeRecordType
                                           AND cel_store_area__c != NULL];
            
            Map<String, Map<String, String>> resStores = new Map<String, Map<String, String>>();
            for(Account s : ss){
                    resStores.put(s.Name, new Map<String, String>{
                        'label' => s.Name,
                        'value' => s.Id
                    });
            }
                
            stores.addAll(resStores.values());
        }
        
        result.put('zones',zones);
        result.put('countries',countries);
        result.put('stores',stores);
        return result;
    }
    
    /**
     * createChildForCampaignAll : Creating a child by Region ( Type Parent )
     * @param {Campaign} campaignParentAll
     */
    public static void createChildForCampaignAll(Campaign campaignParentAll) {
        String recordTypeParent = CEL_Constants.campaignParentRecordType;
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        
        
        if(String.isNotBlank(recordTypeParent)){
            try{
                // List campaign to insert
                List<Campaign> campaignToInsert = new List<Campaign>();
                
                // Get all stores
                List<Account> allStores = [SELECT cel_store_area__c
                                           FROM Account 
                                           WHERE RecordTypeId =: storeRecordType
                                           AND cel_store_status__c =: storeStatusOpen];
                
                // Get label for region by transco object
                Set<Id> regionTranscoIds = new Set<Id>();
                for(Account store : allStores){
                    ID idTransco = ID.valueOf(store.cel_store_area__c);
                    if(!regionTranscoIds.contains(idTransco)){
                        regionTranscoIds.add(idTransco);
                    }
                }
                
                List<cel_transcodification__c> transcoRegions = [SELECT Id, Name, cel_transcodification_code__c 
                                                                 FROM cel_transcodification__c 
                                                                 WHERE Id IN :regionTranscoIds ORDER BY Name];
                
                if(transcoRegions != null && !transcoRegions.isEmpty()){
                    for(cel_transcodification__c region : transcoRegions){
                        Campaign c = new Campaign();
                        c.Type = campaignParentAll.Type;
                        c.ParentId = campaignParentAll.Id;
                        c.recordTypeId = recordTypeParent;
                        c.endDate = campaignParentAll.endDate;
                        c.IsActive = campaignparentAll.IsActive;
                        c.startDate = campaignParentAll.startDate;
                        c.cel_Reason__c = campaignParentAll.cel_Reason__c;
                        c.cel_Category__c = campaignParentAll.cel_Category__c;
                        c.cel_MenWomen__c = campaignParentAll.cel_MenWomen__c;
                        c.cel_Collection__c = campaignParentAll.cel_Collection__c;
                        c.Name = campaignParentAll.Name + ' - ' + region.Name;
                        c.cel_SubCatergory__c = campaignParentAll.cel_SubCatergory__c;
                        c.cel_ClientTarget__c = campaignParentAll.cel_ClientTarget__c;
                        campaignToInsert.add(c);
                    }
                }
                
                insert campaignToInsert;
            }
            catch(exception ex){
                system.debug('Exception: ' + ex.getTypeName() + ' : Message ' + ex.getMessage()  + ' - Cause : ' + ex.getCause() + ' - Trace : ' + ex.getStackTraceString());
            }
        }
    }
    
    /**
     * fillingChildFieldsWithParent : filling Child Fields With Parent values
     * @param {Campaign} child
     * @return {Campaign} child updated
     */
    public static Campaign fillingChildFieldsWithParent(Campaign child) {
        List<Campaign> parents = [SELECT Id, 
                                         IsActive,
                                         cel_Category__c,
                                         cel_SubCatergory__c,
                                         cel_ClientTarget__c,
                                         cel_Collection__c
                                         FROM Campaign 
                                         WHERE id = :child.ParentId LIMIT 1];
        
        if(parents != null && parents.size() > 0){
            Campaign parent = parents.get(0);
            
            child.IsActive = parent.IsActive;
            child.cel_Category__c = parent.cel_Category__c;
            child.cel_Collection__c = parent.cel_Collection__c;
            child.cel_SubCatergory__c = parent.cel_SubCatergory__c;
            child.cel_ClientTarget__c = parent.cel_ClientTarget__c;
        }
        
        return child;
    }
    
    /**
     * getNumberOfChilren : get the number of children
     * @param {Campaign} c
     * @return {Integer} nbChild
     */
    public static Integer getNumberOfChilren(Campaign c) {
        Integer nbChild = 0;
        List<Campaign> childs = [SELECT Id FROM Campaign WHERE ParentId = :c.Id ];
        
        if(childs != null && !childs.isEmpty()){
            nbChild = childs.size();
        }
        
        return nbChild;
    }
    
    /**
     * getNameChildrenOutRangeDate : get the names of children if out of parent range date 
     * @param {Campaign} c
     * @return {List<String>} namesChild
     */
    public static List<String> getNameChildrenOutRangeDate(Campaign c) {
        List<String> namesChild = new List<String>();
        Date startDateParent = c.StartDate;
        Date endDateParent = c.EndDate;
        
        List<Campaign> childsOnError = [SELECT Id, Name, StartDate, EndDate
                                 FROM Campaign 
                                 WHERE ParentId = :c.Id
                                 AND (StartDate < :startDateParent
                                 OR EndDate > :endDateParent)];
        
        if(childsOnError != null && !childsOnError.isEmpty()){
            for(Campaign child : childsOnError){
                namesChild.add(child.Name);
            }
        }
        
        return namesChild;
    }
    
    /**
     * createCampaignRegionCountryStoreForAllCampaign : create objects CEL_Campaign_RegionCountryStore__c for the campaign "ALL"
     * @param {Campaign} c
     */
    public static void createCampaignRegionCountryStoreForAllCampaign(Campaign c) {
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        List<CEL_Campaign_RegionCountryStore__c> campaignStores = new List<CEL_Campaign_RegionCountryStore__c>();
        
        
        // Get all stores available
        List<Account> allStores = CEL_AccountMgr.getAllStoresOpen();
        
        //get the transco of the stores countries
        Set<String> setOfCOuntries = CEL_AccountMgr.getOpenStoresCountries();
        Map<String,String> mapOfCountryCodeAndTranscoId = new Map<String,String>();
        
        List<cel_transcodification__c> countryTranscoList = [Select Id, cel_transcodification_code__c,RecordTypeId From cel_transcodification__c Where cel_transcodification_code__c IN :setOfCOuntries AND RecordType.Name = 'Country'];
        for(cel_transcodification__c transco : countryTranscoList){
            mapOfCountryCodeAndTranscoId.put(transco.cel_transcodification_code__c,transco.Id);
        }
        
        if(allStores != null && !allStores.isEmpty()){
            for(Account store : allStores){
                CEL_Campaign_RegionCountryStore__c cRCS = new CEL_Campaign_RegionCountryStore__c();
                cRCS.cel_Campaign__c = c.Id;
                cRCS.cel_Region__c = ID.valueOf(store.cel_store_area__c);
                cRCS.cel_Country__c = mapOfCountryCodeAndTranscoId.get(store.cel_addr_1_country__c);
                cRCS.cel_Store__c = store.Id;
                campaignStores.add(cRCS);
            }
            
            if(campaignStores != null && !campaignStores.isEmpty()){
                insert campaignStores;
            }
        }
    }

    /**
     * convertAmount Convert amount from locale to corporate currency
     * @param  {Campaign}   c
     * @param  {Map<String, decimal>}   mapCurrentRate
     * @return {Campaign}
     */
    public static Campaign convertAmount(Campaign c, Map<String, decimal> mapCurrentRate) {
        //Convertion Budget with convertion rate
        Decimal rateConvertion = (c.cel_local_Currency__c != null && mapCurrentRate.get(c.cel_local_Currency__c) != 0) ? 1/mapCurrentRate.get(c.cel_local_Currency__c) : 1;
        c.cel_BudgetEuro__c = (Double)(c.cel_TotalBudgetedCost__c * rateConvertion).setScale(2);
        c.cel_SalesTargetResWDepositEuro__c = (Double)(c.cel_SalesTargetResWDeposit__c * rateConvertion).setScale(2);
        c.cel_SalesTargetResWODepositEuro__c = (Double)(c.cel_SalesTargetResWODeposit__c * rateConvertion).setScale(2);
        c.cel_SalesTargetDirectSalesEuro__c = (Double)(c.cel_SalesTargetDirectSales__c * rateConvertion).setScale(2);
        c.cel_TotalSales__c = (Double)(c.cel_TotalSales_locale__c * rateConvertion).setScale(2);
        return c;
    }
    
    /**
     * getCampaignDetails return campaign details
     * @param  {Id} CampaignId
     * @return {Campaign}
     */
    public static Campaign getCampaignDetails(Id CampaignId) {
        List<Campaign> cs = [SELECT Id, 
                                    Name,
                                    Type,
                                    EndDate,
                                    ParentId,
                                    IsActive,
                                    StartDate,
                                    NumberSent,
                                    cel_level__c,
                                    cel_Total__c,
                                    BudgetedCost,
                                    cel_Period__c, 
                                    cel_Reason__c,
                                    cel_Format__c,
                                    cel_TotalRTW__c,
                                    cel_TotalACC__c,
                                    cel_MenWomen__c,
                                    cel_TotalSLG__c,
                                    cel_TotalBags__c,
                                    cel_ClientTarget__c,
                                    toLabel(cel_ClientTarget__c) targetLabel,
                                    cel_TotalShoes__c,
                                    NumberOfResponses,
                                    cel_TotalSales__c, 
                                    cel_BudgetEuro__c, 
                                    cel_ROI_Amount__c,
                                    cel_TotalShowUp__c, 
                                    cel_AmountTotal__c,
                                    cel_TotalResWDep__c,
                                    cel_TotalInvited__c,
                                    cel_TotalResWODep__c,
                                    cel_TotalConfirmed__c,
                                    cel_showup_Percent__c,
                                    cel_TotalContacted__c,
                                    cel_Store_Turnover__c,
                                    cel_TotalPurchasing__c,
                                    cel_Activation_Rate__c,
                                    cel_Target_achieved__c,
                                    cel_ext_id_campaign__c,
                                    cel_TotalDirectSales__c,
                                    cel_Clienteling_Rate__c,
                                    cel_Confirmed_Parent__c,
                                    cel_Confirmed_percent__c,
                                    Recordtype.DeveloperName,
                                    cel_contacted_Percent__c,
                                    cel_TotalShowupParent__c,
                                    cel_Purchasing_percent__c,
                                    cel_Cross_Selling_Rate__c,
                                    cel_TotalInvitedParent__c,
                                    cel_direct_sales_percent__c,
                                    cel_Performance_vs_Budget__c,
                                    cel_Total_potential_sales__c,
                                    cel_Total_Sales_Target_Eur__c,
                                    cel_TotalPurchasing_Parent__c,
                                    cel_Resa_w_deposit_percent__c,
                                    cel_Target_Achieved_Amount__c,
                                    cel_Resa_w_o_deposit_percent__c,
                                    cel_Activity_Validity_End_Date__c,
                                    cel_TotalContactedParentAction__c,
                                    cel_SalesTargetResWDepositEuro__c,
                                    cel_SalesTargetResWODepositEuro__c,
                                    ToLabel(cel_category__c) categories,
                                    ToLabel(cel_SubCatergory__c) subcategory,
                                    cel_activity_validity_start_date__c
                                    FROM Campaign where Id = : CampaignId];
        
        Campaign c = new Campaign();
        if(cs != null && !cs.isEmpty()){
            c = cs.get(0);
        }
        
        return c;
    }
    
     /**
     * getCampaign return campaign details
     * @param  {Id} CampaignId
     * @return {Campaign}
     */
    public static Campaign getCampaign(Id CampaignId) {
        List<Campaign> cs = [SELECT Id, 
                                    Name,
                                    ParentId,
                                    IsActive,
                                    cel_level__c
                                    FROM Campaign where Id = : CampaignId];
        
        Campaign c = new Campaign();
        if(cs != null && !cs.isEmpty()){
            c = cs.get(0);
            return c;
        }
        
        return null;
    }
    
     /**
     * getCampaignParentWithChildren return campaign details
     * @param  {Id} CampaignId
     * @return {Campaign}
     */
    public static Campaign getCampaignParentWithChildren(Id CampaignId) {
        List<Campaign> cs = [SELECT Id,
                                    IsActive,
                                    ParentId,
                                    cel_region_all__c,
                                    RecordTypeId,
                                    cel_TotalInvited__c,
                                    cel_TotalInvitedParent__c,
                                    cel_Total_potential_sales__c,
                                    cel_Clienteling_Rate__c,
                                    cel_TotalContacted__c,
                                    cel_TotalContactedParentAction__c,
                                    cel_TotalDirectSales__c,
                                    cel_TotalConfirmed__c,
                                    cel_Confirmed_Parent__c,
                                    cel_TotalResWDep__c,
                                    cel_TotalShowUp__c,
                                    cel_TotalShowupParent__c,
                                    cel_TotalResWODep__c,
                                    cel_Target_Achieved_Amount__c,
                                    cel_TotalPurchasing__c,
                                    cel_TotalPurchasing_Parent__c,
                                    cel_Performance_vs_Budget__c,
                                    cel_TotalBudgetedCost__c,
                                    cel_SalesTargetResWDeposit__c,
                                    cel_SalesTargetResWODeposit__c,
                                    cel_SalesTargetDirectSales__c,
                                    cel_BudgetEuro__c,
                                    cel_TotalResWDep_locale__c,
                                    cel_TotalResWODep_locale__c,
                                    cel_TotalDirectSales_locale__c,
                                    cel_local_Currency__c,
                                    cel_SalesTargetResWDepositEuro__c,
                                    cel_SalesTargetResWODepositEuro__c,
                                    cel_SalesTargetDirectSalesEuro__c,
                                    cel_TotalSales__c,
                                    cel_TotalSales_locale__c,
                                    cel_TotalSLG__c,
                                    cel_TotalRTW__c,
                                    cel_TotalShoes__c,
                                    cel_TotalBags__c,
                                    cel_TotalACC__c,
                                    cel_Total__c,
                                    (SELECT Id,
                                            ParentId,
                                            RecordTypeId,
                                            cel_region_all__c,
                                            cel_TotalInvited__c,
                                            cel_TotalInvitedParent__c,
                                            cel_Total_potential_sales__c,
                                            cel_Clienteling_Rate__c,
                                            cel_TotalContacted__c,
                                            cel_TotalContactedParentAction__c,
                                            cel_TotalDirectSales__c,
                                            cel_TotalConfirmed__c,
                                            cel_Confirmed_Parent__c,
                                            cel_TotalResWDep__c,
                                            cel_TotalShowUp__c,
                                            cel_TotalShowupParent__c,
                                            cel_TotalResWODep__c,
                                            cel_Target_Achieved_Amount__c,
                                            cel_TotalPurchasing__c,
                                            cel_TotalPurchasing_Parent__c,
                                            cel_Performance_vs_Budget__c,
                                            cel_TotalBudgetedCost__c,
                                            cel_SalesTargetResWDeposit__c,
                                            cel_SalesTargetResWODeposit__c,
                                            cel_SalesTargetDirectSales__c,
                                            cel_BudgetEuro__c,
                                            cel_TotalResWDep_locale__c,
                                            cel_TotalResWODep_locale__c,
                                            cel_TotalDirectSales_locale__c,
                                            cel_local_Currency__c,
                                            cel_SalesTargetResWDepositEuro__c,
                                            cel_SalesTargetResWODepositEuro__c,
                                            cel_SalesTargetDirectSalesEuro__c,
                                            cel_TotalSales__c,
                                            cel_TotalSales_locale__c,
                                            cel_TotalSLG__c,
                                            cel_TotalRTW__c,
                                            cel_TotalShoes__c,
                                            cel_TotalBags__c,
                                            cel_TotalACC__c,
                                            cel_Total__c
                                            FROM ChildCampaigns) 
                                    FROM Campaign 
                                    WHERE Id = :CampaignId LIMIT 1];
        
        Campaign c = new Campaign();
        if(cs != null && !cs.isEmpty()){
            c = cs.get(0);
        }
        
        return c;
    }
    
     /**
     * getCampaignParentWithChildren return campaign details
     * @param  {Id} CampaignId
     * @return {List<Campaign>}
     */
    public static List<Campaign> getAllCampaignParent(Id CampaignId) {
         List<Campaign> allParents = [SELECT Id,
                                             ParentId,
                                             cel_region_all__c,
                                             RecordTypeId,
                                             cel_TotalInvited__c,
                                             cel_TotalInvitedParent__c,
                                             cel_Total_potential_sales__c,
                                             cel_Clienteling_Rate__c,
                                             cel_TotalContacted__c,
                                             cel_TotalContactedParentAction__c,
                                             cel_TotalDirectSales__c,
                                             cel_TotalConfirmed__c,
                                             cel_Confirmed_Parent__c,
                                             cel_TotalResWDep__c,
                                             cel_TotalShowUp__c,
                                             cel_TotalShowupParent__c,
                                             cel_TotalResWODep__c,
                                             cel_Target_Achieved_Amount__c,
                                             cel_TotalPurchasing__c,
                                             cel_TotalPurchasing_Parent__c,
                                             cel_Performance_vs_Budget__c,
                                             cel_TotalBudgetedCost__c,
                                             cel_SalesTargetResWDeposit__c,
                                             cel_SalesTargetResWODeposit__c,
                                             cel_SalesTargetDirectSales__c,
                                             cel_BudgetEuro__c,
                                             cel_TotalResWDep_locale__c,
                                             cel_TotalResWODep_locale__c,
                                             cel_TotalDirectSales_locale__c,
                                             cel_local_Currency__c,
                                             cel_SalesTargetResWDepositEuro__c,
                                             cel_SalesTargetResWODepositEuro__c,
                                             cel_SalesTargetDirectSalesEuro__c,
                                             cel_TotalSales__c,
                                             cel_TotalSales_locale__c,
                                             cel_TotalSLG__c,
                                             cel_TotalRTW__c,
                                             cel_TotalShoes__c,
                                             cel_TotalBags__c,
                                             cel_TotalACC__c,
                                             cel_Total__c
                                             FROM Campaign WHERE ParentId = :CampaignId];
        return allParents;
    }
    
     /**
     * getCampaignParentWithChildren return campaign details
     * @param  {Set<Id>} parentIds
     * @return {List<Campaign>}
     */
    public static List<Campaign> getAllCampaignChildren(Set<Id> parentIds) {
         List<Campaign> childs = [SELECT Id,
                                         ParentId,
                                         cel_region_all__c,
                                         RecordTypeId,
                                         cel_TotalInvited__c,
                                         cel_TotalInvitedParent__c,
                                         cel_Total_potential_sales__c,
                                         cel_Clienteling_Rate__c,
                                         cel_TotalContacted__c,
                                         cel_TotalContactedParentAction__c,
                                         cel_TotalDirectSales__c,
                                         cel_TotalConfirmed__c,
                                         cel_Confirmed_Parent__c,
                                         cel_TotalResWDep__c,
                                         cel_TotalShowUp__c,
                                         cel_TotalShowupParent__c,
                                         cel_TotalResWODep__c,
                                         cel_Target_Achieved_Amount__c,
                                         cel_TotalPurchasing__c,
                                         cel_TotalPurchasing_Parent__c,
                                         cel_Performance_vs_Budget__c,
                                         cel_TotalBudgetedCost__c,
                                         cel_SalesTargetResWDeposit__c,
                                         cel_SalesTargetResWODeposit__c,
                                         cel_SalesTargetDirectSales__c,
                                         cel_BudgetEuro__c,
                                         cel_TotalResWDep_locale__c,
                                         cel_TotalResWODep_locale__c,
                                         cel_TotalDirectSales_locale__c,
                                         cel_local_Currency__c,
                                         cel_SalesTargetResWDepositEuro__c,
                                         cel_SalesTargetResWODepositEuro__c,
                                         cel_SalesTargetDirectSalesEuro__c,
                                         cel_TotalSales__c,
                                         cel_TotalSales_locale__c,
                                         cel_TotalSLG__c,
                                         cel_TotalRTW__c,
                                         cel_TotalShoes__c,
                                         cel_TotalBags__c,
                                         cel_TotalACC__c,
                                         cel_Total__c
                                         FROM Campaign WHERE ParentId IN :parentIds];
        return childs;
    }
    
    /**
    * getFirstCampaignMemberStatus : return the first Campaign Members Status
    * @param {String} CampaignId
    * @return {cel_Campaign_Member_Status__c} cms
    */
    public static cel_Campaign_Member_Status__c getFirstCampaignMemberStatus(String CampaignId){
        List<cel_Campaign_Member_Status__c> cms = [SELECT Id, 
                                                         cel_Campaign__c,
                                                         cel_TotalSales__c,
                                                         cel_ResWDep_Euro__c,
                                                         cel_ResWODep_Euro__c,
                                                         cel_Direct_Sales__c,
                                                         cel_SLG__c,
                                                         cel_RTW__c,
                                                         cel_Shoes__c,
                                                         cel_Bags__c,
                                                         cel_ACC__c,
                                                         cel_total_units__c
                                                         FROM cel_Campaign_Member_Status__c 
                                                         WHERE cel_Campaign__c = :CampaignId];
        
        if(cms != null && !cms.isEmpty()){
            return cms.get(0);
        }
        else{
            return null;
        }
    }
    
    /**
    * getCampaignRegionCountryStoreByCampaignId : return the list of Campaign Region Country Store object By CampaignId
    * @param {Id} CampaignId
    * @return {List<CEL_Campaign_RegionCountryStore__c>}
    */
    public static List<CEL_Campaign_RegionCountryStore__c> getCampaignRegionCountryStoreByCampaignId(Id CampaignId){
        List<CEL_Campaign_RegionCountryStore__c> campaignStores = new List<CEL_Campaign_RegionCountryStore__c>();
        
        campaignStores = [SELECT Id, cel_Campaign__c, cel_Region__c, cel_Country__c, cel_Store__c 
                                                                   FROM CEL_Campaign_RegionCountryStore__c 
                                                                   WHERE cel_Campaign__c =: CampaignId];
        
        return campaignStores;
    }
    
    /**
    * getCampaignMembersStatusByCampaignId : return the list of Campaign Members Status object By CampaignId
    * @param {Id} CampaignId
    * @return {List<cel_Campaign_Member_Status__c>}
    */
    public static List<cel_Campaign_Member_Status__c> getCampaignMembersStatusByCampaignId(Id CampaignId){
        List<cel_Campaign_Member_Status__c> allCms = new List<cel_Campaign_Member_Status__c>();
        
        allCms = [SELECT Id, 
                         cel_Campaign__c,
                         cel_TotalSales__c,
                         cel_ResWDep_Euro__c,
                         cel_ResWODep_Euro__c,
                         cel_Direct_Sales__c,
                         cel_SLG__c,
                         cel_RTW__c,
                         cel_Shoes__c,
                         cel_Bags__c,
                         cel_ACC__c,
                         cel_total_units__c
                         FROM cel_Campaign_Member_Status__c 
                         WHERE cel_Campaign__c = :CampaignId];
        
        return allCms;
    }
}