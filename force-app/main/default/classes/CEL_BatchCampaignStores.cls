global class CEL_BatchCampaignStores implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    private Map<Id, Campaign> campaignsLittleChildMap;
    private Map<Id, Campaign> campaignsChildMap;
    private Map<Id, Campaign> campaignsParentMap;
    private Map<Id, Campaign> campaignsAllMap;
    private Map<String, Account> allStores;
    private List<CEL_Campaign_RegionCountryStore__c> allCampaignStores;
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} BC
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,
                                                cel_region_all__c,
                                                cel_Region__c,
                                                cel_Countries__c,
                                                cel_Stores__c,
                                                cel_level__c,
                                                ParentId,
                                                RecordTypeId,
                                                (Select Id FROM ChildCampaigns)
                                                FROM Campaign 
                                                ORDER BY cel_level__c desc]);
    }
    
    /**
     * execute
     * @param {SchedulableContext} sc
     */    
    global void execute(SchedulableContext sc){
        CEL_BatchCampaignStores b = new CEL_BatchCampaignStores();
        database.executebatch(b);
    }

    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param [{Account}] accounts
     */
    global void execute(Database.BatchableContext BC, List<Campaign> campaigns){
        String recordTypeParent = CEL_Constants.campaignParentRecordType;
        String recordTypeEnfant = CEL_Constants.campaignEnfantRecordType;
        Map<Id, campaign> allCampaignsMap = new Map<Id, campaign>(campaigns);
        List<Account> storesOpen = CEL_AccountMgr.getAllStoresOpen();
        
        // Create map Stores
        for(Account s : storesOpen){
            if(!allStores.containsKey(s.cel_long_name__c)){
                allStores.put(s.cel_long_name__c, s);
            }
        }
        
        // Init Map campaignsLittleChildMap ( CampaignId , Campaign ) 
        // Init Map campaignsChildMap ( CampaignId , Campaign ) 
        // Init Map campaignsParentMap ( CampaignId , Campaign )
        // Init Map campaignsAllMap ( CampaignId , Campaign )
        for(Campaign c : campaigns){
            // Add a campaignsLittleChild on Map
            if(!campaignsLittleChildMap.containsKey(c.Id) && !campaignsChildMap.containsKey(c.Id) && !campaignsParentMap.containsKey(c.Id) && !campaignsAllMap.containsKey(c.Id)
                && c.ParentId != null && String.valueOf(c.RecordTypeId) == recordTypeEnfant && (c.ChildCampaigns == null  || c.ChildCampaigns.size() == 0)) {
                campaignsLittleChildMap.put(c.Id, c);
                // Add a campaignsChild on Map
                Campaign cc = allCampaignsMap.get(c.ParentId);
                if(cc != null && !campaignsChildMap.containsKey(cc.Id) && !campaignsLittleChildMap.containsKey(cc.Id) && !campaignsParentMap.containsKey(cc.Id) && !campaignsAllMap.containsKey(cc.Id)){
                    CEL_KpiVM_CampaignEnfant vmcEnfant = new CEL_KpiVM_CampaignEnfant(cc.Id, cc.ParentId);
                    campaignsChildMap.put(cc.Id, cc);
                    
                    if(cc.ParentId != null){
                        // Add a campaignsParent on Map
                        Campaign cp = allCampaignsMap.get(cc.ParentId);
                        if(cp != null && !campaignsParentMap.containsKey(cp.Id) && !campaignsLittleChildMap.containsKey(cp.Id) && !campaignsChildMap.containsKey(cp.Id) && !campaignsAllMap.containsKey(cp.Id)){
                            CEL_KpiVM_CampaignParent vmcParent = new CEL_KpiVM_CampaignParent(cp.Id, cp.ParentId);
                            campaignsParentMap.put(cp.Id, cp);
                            if(cp.ParentId != null){
                                // Add a campaignsAll on Map
                                Campaign ca = allCampaignsMap.get(cp.ParentId);
                                if(ca != null && !campaignsAllMap.containsKey(ca.Id) && !campaignsLittleChildMap.containsKey(ca.Id) && !campaignsChildMap.containsKey(ca.Id) && !campaignsParentMap.containsKey(ca.Id)){
                                    CEL_KpiVM_CampaignAll vmcAll = new CEL_KpiVM_CampaignAll(ca.Id);
                                    campaignsAllMap.put(ca.Id, ca);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        createCampaignStoreForLittleChild(campaignsLittleChildMap);
        createCampaignStoreForChild(campaignsChildMap);
        createCampaignStoreForChild(campaignsParentMap);
        createCampaignStoreForChild(campaignsAllMap);
    }
    
    /**
     * finish: Call at the end of the batch
     * @param  {BatchableContext} BC
     */
    global void finish(Database.BatchableContext BC) {
        try{
            List<Campaign> cs = new List<Campaign>();
            
            // Create Campaign with All
            for(Campaign ca : this.campaignsAllMap.values()){
                Campaign c = new Campaign(
                                          Id = ca.Id,
                                          cel_Region__c = null,
                                          cel_Countries__c = null,
                                          cel_Stores__c = null,
                                          cel_region_all__c = true);
                cs.add(c);
            }
            
            // Create Campaign with Parent
            for(Campaign cp : this.campaignsParentMap.values()){
                Campaign c = new Campaign(
                                          Id = cp.Id,
                                          cel_Region__c = null,
                                          cel_Countries__c = null,
                                          cel_Stores__c = null);
                cs.add(c);
            }
            
            // Create Campaign with Enfant
            for(Campaign cc : this.campaignsChildMap.values()){
                Campaign c = new Campaign(
                                          Id = cc.Id,
                                          cel_Region__c = null,
                                          cel_Countries__c = null,
                                          cel_Stores__c = null);
                cs.add(c);
            }
            
            // Create Campaign with little Child
            for(Campaign clc : this.campaignsChildMap.values()){
                Campaign c = new Campaign(
                                          Id = clc.Id,
                                          cel_Region__c = null,
                                          cel_Countries__c = null,
                                          cel_Stores__c = null);
                cs.add(c);
            }
            
            update cs;
        }
        catch( exception ex){
            system.debug('Exception: ' + ex.getTypeName() + ' : Message ' + ex.getMessage()  + ' - Cause : ' + ex.getCause() + ' - Trace : ' + ex.getStackTraceString());
        }
    }
    
    /**
    * createCampaignStoreForLittleChild
    * @param {Map<Id, Campaign>} campaignsMap
    */
    private void createCampaignStoreForLittleChild(Map<Id, Campaign> campaignsLittleChildMap) {
        List<Campaign> campaigns = campaignsLittleChildMap.values();
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        List<CEL_Campaign_RegionCountryStore__c> campaignStoreToInsert = new List<CEL_Campaign_RegionCountryStore__c>();
        
        Set<String> countriesCode = new Set<String>();
        Map<String,String> mapOfCountryCodeAndTranscoId = new Map<String,String>();

        for(Campaign c : campaigns){
            if(String.isNotBlank(c.cel_Stores__c)){
                List<String> allStoresNames = c.cel_Stores__c.split(';');
                List<Account > stores = new list<Account>();
                
                for(String storeName : allStoresNames){
                    if(allStores.containsKey(storeName)){
                        stores.add(allStores.get(StoreName));
                        countriesCode.add(allStores.get(StoreName).cel_addr_1_country__c);
                    }
                }
                
                //get the transco id of courties to fill it since the coutry in store in picklist and in campaignstore is transco
                List<cel_transcodification__c> countryTranscoList = [Select Id, cel_transcodification_code__c,RecordTypeId From cel_transcodification__c Where cel_transcodification_code__c IN :countriesCode AND RecordType.Name = 'Country'];
                for(cel_transcodification__c transco : countryTranscoList){
                   mapOfCountryCodeAndTranscoId.put(transco.cel_transcodification_code__c,transco.Id);      
                }
                
                for(Account store : stores){
                    CEL_Campaign_RegionCountryStore__c cRCS = new CEL_Campaign_RegionCountryStore__c();
                    cRCS.cel_Campaign__c = c.Id;
                    cRCS.cel_Region__c = Id.valueOf(store.cel_store_area__c);
                    cRCS.cel_Country__c = mapOfCountryCodeAndTranscoId.get(store.cel_addr_1_country__c);
                    cRCS.cel_Store__c = store.Id;
                    campaignStoreToInsert.add(cRCS);
                }
            }
        }
        
        allCampaignStores.addAll(campaignStoreToInsert);
        insert campaignStoreToInsert;
    }
    
    /**
    * createCampaignStoreForChild
    * @param {Map<Id, Campaign>} campaignsMap
    */
    private void createCampaignStoreForChild(Map<Id, Campaign> campaignsChildMap) {
        List<Campaign> campaigns = campaignsChildMap.values();
        List<CEL_Campaign_RegionCountryStore__c> campaignStoreToInsert = new List<CEL_Campaign_RegionCountryStore__c>();
        
        for(Campaign c : campaigns){
            List<CEL_Campaign_RegionCountryStore__c> campaignStoreschildren = new List<CEL_Campaign_RegionCountryStore__c>();
            List<Campaign> allChildren = c.ChildCampaigns;
            Set<Id> campaignIds = new Set<Id>();
            
            // Get all children
            for(Campaign cc : allChildren){
                campaignIds.add(cc.Id);
            }
            
            // Get all CEL_Campaign_RegionCountryStore__c for this children
            for(Id cId : campaignIds){
                for(CEL_Campaign_RegionCountryStore__c cRCS : allCampaignStores){
                    if(cRCS.cel_Campaign__c == cId){
                        campaignStoreschildren.add(cRCS);
                    }
                }
            }
            
            for(CEL_Campaign_RegionCountryStore__c rcs : campaignStoreschildren){
                CEL_Campaign_RegionCountryStore__c cRCS = new CEL_Campaign_RegionCountryStore__c();
                cRCS.cel_Campaign__c = c.Id;
                cRCS.cel_Region__c = rcs.cel_Region__c;
                cRCS.cel_Country__c = rcs.cel_Country__c;
                cRCS.cel_Store__c = rcs.cel_Store__c;
                campaignStoreToInsert.add(cRCS);
            }
        }
        
        allCampaignStores.addAll(campaignStoreToInsert);
        insert campaignStoreToInsert;
    }
}