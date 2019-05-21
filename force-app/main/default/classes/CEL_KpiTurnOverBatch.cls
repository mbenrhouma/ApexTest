global class CEL_KpiTurnOverBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private List<CEL_KpiVM_Campaign> campaignLittleChildToUpdate;
    private List<CEL_KpiVM_CampaignEnfant> campaignChildToUpdate;
    private List<CEL_KpiVM_CampaignParent> campaignParentToUpdate;
    private List<CEL_KpiVM_CampaignAll> campaignAllToUpdate;
    private Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap;
    private Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap;
    private Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap;
    private Map<Id, CEL_KpiVM_CampaignAll> campaignsAllMap;
    
    global CEL_KpiTurnOverBatch() {
        this.campaignLittleChildToUpdate = new List<CEL_KpiVM_Campaign>();
        this.campaignChildToUpdate = new List<CEL_KpiVM_CampaignEnfant>();
        this.campaignParentToUpdate = new List<CEL_KpiVM_CampaignParent>();
        this.campaignAllToUpdate = new List<CEL_KpiVM_CampaignAll>();
        this.campaignsLittleChildMap = new Map<Id, CEL_KpiVM_Campaign>();
        this.campaignsChildMap = new Map<Id, CEL_KpiVM_CampaignEnfant>();
        this.campaignsParentMap = new Map<Id, CEL_KpiVM_CampaignParent>();
        this.campaignsAllMap = new Map<Id, CEL_KpiVM_CampaignAll>();
    }
    
    public void execute(SchedulableContext context) 
    {
        Database.executeBatch(this);
    }
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} context
     * @return Database.QueryLocator 
     */
    global Database.QueryLocator start( Database.BatchableContext context )
    {
        Date dayStartBatch = Date.today().addDays(-1);
        return Database.getQueryLocator([SELECT Id,
                                                cel_region_all__c,
                                                cel_Activity_Validity_End_Date__c, 
                                                cel_activity_validity_start_date__c,
                                                ParentId,
                                                RecordTypeId,
                                                cel_level__c,
                                                (Select Id FROM ChildCampaigns)
                                                FROM Campaign 
                                                WHERE cel_Activity_Validity_End_Date__c >= :dayStartBatch 
                                                AND cel_activity_validity_start_date__c <= :dayStartBatch
                                                AND cel_activity_validity_start_date__c != null
                                                AND cel_Activity_Validity_End_Date__c != null
                                                AND cel_level__c != null
                                                ORDER BY cel_level__c desc]);
    }
    
    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param {List<Campaign> campaigns} campaigns
     */
    global void execute(Database.BatchableContext context, List<Campaign> campaigns)
    {
        String recordTypeParent = CEL_Constants.campaignParentRecordType;
        String recordTypeEnfant = CEL_Constants.campaignEnfantRecordType;
        String recordTypeStore = CEL_Constants.storeRecordType;
        
        Date dayStartBatch = Date.today().addDays(-1);
        Date firstStartDate = Date.today();
        if(campaigns != null && campaigns.size() > 0){
            for(Campaign c : campaigns){
                if(c.cel_activity_validity_start_date__c < firstStartDate){
                    firstStartDate = c.cel_activity_validity_start_date__c;
                }
            }
        }
        
        Map<Id, campaign> allCampaignsMap = new Map<Id, campaign>(campaigns);
        Set<Id> campaignsIds = new Set<Id>((new Map<Id,SObject>(campaigns)).keySet());
        Map<Id, Set<Id>> storesMap = new Map<Id, Set<Id>>();
        Map<Id, List<cel_Transaction__c>> transactionsMap = new Map<Id, List<cel_Transaction__c>>();
        Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap = this.campaignsLittleChildMap;
        Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap = this.campaignsChildMap;
        Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap = this.campaignsParentMap;
        Map<Id, CEL_KpiVM_CampaignAll> campaignsAllMap = this.campaignsAllMap;
        Set<Id> allstoresId = new Set<Id>();
        
        // Init List Stores Ids
        // Init Map campaignsLittleChildMap ( CampaignId , CEL_KpiVM_Campaign ) 
        // Init Map campaignsChildMap ( CampaignId , CEL_KpiVM_CampaignEnfant ) 
        // Init Map campaignsParentMap ( CampaignId , CEL_KpiVM_CampaignParent )
        // Init Map campaignsAllMap ( CampaignId , CEL_KpiVM_CampaignAll )
        for(Campaign c : campaigns) 
        {
            // Add a campaignsLittleChild on Map
            if(!campaignsLittleChildMap.containsKey(c.Id) && !campaignsChildMap.containsKey(c.Id) && !campaignsParentMap.containsKey(c.Id) && !campaignsAllMap.containsKey(c.Id)
                && c.ParentId != null && String.valueOf(c.RecordTypeId) == recordTypeEnfant && (c.ChildCampaigns == null  || c.ChildCampaigns.size() == 0)) {
                CEL_KpiVM_Campaign vmc = new CEL_KpiVM_Campaign(c.Id, c.ParentId);
                
                // Get Stores by CEL_Campaign_RegionCountryStore__c
                List<CEL_Campaign_RegionCountryStore__c> campaignStores = [SELECT Id, cel_Campaign__c, cel_Store__c FROM CEL_Campaign_RegionCountryStore__c WHERE cel_Campaign__c =: c.Id];
                if(campaignStores != null && !campaignStores.isEmpty()){
                    Set<Id> storesIds = new Set<Id>();
                    for(CEL_Campaign_RegionCountryStore__c cRCS : campaignStores){
                        storesIds.add(cRCS.cel_Store__c);
                    }
                    
                    vmc.stores.addAll(storesIds);
                    allstoresId.addAll(storesIds);
                }
                vmc.startDate = c.cel_activity_validity_start_date__c;
                vmc.endDate = c.cel_Activity_Validity_End_Date__c;
                campaignsLittleChildMap.put(c.Id, vmc);
                
                // Add a campaignsChild on Map
                Campaign cc = allCampaignsMap.get(c.ParentId);
                if(cc != null && !campaignsChildMap.containsKey(cc.Id) && !campaignsLittleChildMap.containsKey(cc.Id) && !campaignsParentMap.containsKey(cc.Id) && !campaignsAllMap.containsKey(cc.Id)){
                    CEL_KpiVM_CampaignEnfant vmcEnfant = new CEL_KpiVM_CampaignEnfant(cc.Id, cc.ParentId);
                    campaignsChildMap.put(cc.Id, vmcEnfant);
                    
                    if(cc.ParentId != null){
                        // Add a campaignsParent on Map
                        Campaign cp = allCampaignsMap.get(cc.ParentId);
                        if(cp != null && !campaignsParentMap.containsKey(cp.Id) && !campaignsLittleChildMap.containsKey(cp.Id) && !campaignsChildMap.containsKey(cp.Id) && !campaignsAllMap.containsKey(cp.Id)){
                            CEL_KpiVM_CampaignParent vmcParent = new CEL_KpiVM_CampaignParent(cp.Id, cp.ParentId);
                            campaignsParentMap.put(cp.Id, vmcParent);
                            
                            if(cp.ParentId != null){
                                // Add a campaignsAll on Map
                                Campaign ca = allCampaignsMap.get(cp.ParentId);
                                if(ca != null && !campaignsAllMap.containsKey(ca.Id) && !campaignsLittleChildMap.containsKey(ca.Id) && !campaignsChildMap.containsKey(ca.Id) && !campaignsParentMap.containsKey(ca.Id)){
                                    CEL_KpiVM_CampaignAll vmcAll = new CEL_KpiVM_CampaignAll(ca.Id);
                                    campaignsAllMap.put(ca.Id, vmcAll);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Get all transaction with store Id membersCampaign
        List<cel_Transaction__c> transactions = [SELECT Id,
                                                        cel_sale_date__c,
                                                        cel_store__c,
                                                        cel_Total_Net_Value_local_tax_inc_EUR__c
                                                FROM cel_Transaction__c
                                                WHERE cel_store__c IN :allstoresId
                                                    AND cel_is_cancelled__c = false
                                                    AND cel_sale_date__c >= :firstStartDate
                                                    AND cel_store__c != null
                                                ORDER BY cel_store__c];
        
        // Init Map ( CampaignId , List<cel_Transaction__c> And Add transaction )
        for(CEL_KpiVM_Campaign clc : campaignsLittleChildMap.values()){
            List<cel_Transaction__c> transactionList = new List<cel_Transaction__c>();
            
            for(cel_Transaction__c t : transactions) {
                if(clc.stores.contains(t.cel_store__c) && t.cel_sale_date__c >= clc.startDate &&  t.cel_sale_date__c <= clc.endDate){
                    transactionList.add(t);
                }
            }
            clc.transactions.addAll(transactionList);
        }
        
        this.run(campaignsLittleChildMap, campaignsChildMap,campaignsParentMap, campaignsAllMap);
    }
    
    /**
    * Run KPIs calculation
    * @param {Map<Id, CEL_KpiVM_Campaign>} campaignsLittleChildMap
    * @param {Map<Id, CEL_KpiVM_CampaignEnfant>} campaignsChildMap
    * @param {Map<Id, CEL_KpiVM_CampaignParent>} campaignsParentMap
    * @param {Map<Id, CEL_KpiVM_CampaignAll>} campaignsAllMap
    */
    private void run(Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap, Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap,  Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap,  Map<Id, CEL_KpiVM_CampaignAll> campaignsAllMap) {
        // Kpis Calcul
        this.calculTurnOverLittleChild(campaignsLittleChildMap);
        this.calculTurnOverChild(campaignsLittleChildMap, campaignsChildMap);
        this.calculTurnOverParent(campaignsChildMap, campaignsParentMap);
        this.calculTurnOverAll(campaignsParentMap, campaignsAllMap);
        
        // Make list to update
        this.campaignLittleChildToUpdate.addAll(this.campaignsLittleChildMap.values());
        this.campaignChildToUpdate.addAll(this.campaignsChildMap.values());
        this.campaignParentToUpdate.addAll(this.campaignsParentMap.values());
        this.campaignAllToUpdate.addAll(this.campaignsAllMap.values());
    }
    
    /**
    * KPIs calculation little Child
    * @param {Map<Id, CEL_KpiVM_Campaign>} campaignsLittleChildMap
    */
    private void calculTurnOverLittleChild(Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap) {
        List<CEL_KpiVM_Campaign> campaigns = campaignsLittleChildMap.values();
        
        for(CEL_KpiVM_Campaign c : campaigns){
            // Calcul TornOver All transactions
            for(cel_Transaction__c t : c.transactions){
                c.TurnOver = c.TurnOver + t.cel_Total_Net_Value_local_tax_inc_EUR__c;
            }
        }
    }
    
    /**
    * KPIs calculation Child
    * @param {Map<Id, CEL_KpiVM_Campaign>} campaignsLittleChildMap
    * @param {Map<Id, CEL_KpiVM_CampaignEnfant>} campaignsChildMap
    */
    private void calculTurnOverChild(Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap, Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap) {
        List<CEL_KpiVM_Campaign> campaignsLittleChild = campaignsLittleChildMap.values();
        List<CEL_KpiVM_CampaignEnfant> campaignsChild = campaignsChildMap.values();
        
        for(CEL_KpiVM_CampaignEnfant cc : campaignsChild){
            for(CEL_KpiVM_Campaign clc : campaignsLittleChild){
                if(cc.idCampaign == clc.idCampaignEnfant){
                    // Calcul TurnOver with TurnOver child 
                    cc.TurnOver = cc.TurnOver + clc.TurnOver;
                }
            }
        }
    }
    
    /**
    * KPIs calculation Parent
    * @param {Map<Id, CEL_KpiVM_CampaignEnfant>} campaignsChildMap
    * @param {Map<Id, CEL_KpiVM_CampaignParent>} campaignsParentMap
    */
    private void calculTurnOverParent(Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap, Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap) {
        List<CEL_KpiVM_CampaignEnfant> campaignsChild = campaignsChildMap.values();
        List<CEL_KpiVM_CampaignParent> campaignsParent = campaignsParentMap.values();
        
        for(CEL_KpiVM_CampaignParent cp : campaignsParent){
            for(CEL_KpiVM_CampaignEnfant cc : campaignsChild){
                if(cp.idCampaign == cc.idCampaignParent){
                    // Calcul TurnOver with TurnOver child
                    cp.TurnOver = cp.TurnOver + cc.TurnOver;
                }
            }
        }
    }
    
    /**
    * KPIs calculation All
    * @param {Map<Id, CEL_KpiVM_CampaignParent>} campaignsParentMap
    * @param {Map<Id, CEL_KpiVM_CampaignAll>} campaignsAllMap
    */
    private void calculTurnOverAll(Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap, Map<Id, CEL_KpiVM_CampaignAll> campaignsAllMap) {
        List<CEL_KpiVM_CampaignParent> campaignsParent = campaignsParentMap.values();
        List<CEL_KpiVM_CampaignAll> campaignsAll = campaignsAllMap.values();
        
        for(CEL_KpiVM_CampaignAll ca : campaignsAll){
            for(CEL_KpiVM_CampaignParent cp : campaignsParent){
                if(ca.idCampaign == cp.idCampaignAll){
                    // Calcul TurnOver with TurnOver child
                    ca.TurnOver = ca.TurnOver + cp.TurnOver;
                }
            }
        }
    }
    
    /**
     * finish: Call at the end of the batch
     * @param  {BatchableContext} BC
     */
    global void finish(Database.BatchableContext context) {
        try{
            List<Campaign> cs = new List<Campaign>();
            
            // Create Campaign with All
            for(CEL_KpiVM_CampaignAll ca : this.campaignAllToUpdate){
                Campaign c = new Campaign(
                                          Id = ca.idCampaign,
                                          cel_Store_Turnover__c = (Double)Decimal.valueOf(ca.TurnOver).setScale(2));
                cs.add(c);
            }
            
            // Create Campaign with Parent
            for(CEL_KpiVM_CampaignParent cp : this.campaignParentToUpdate){
                Campaign c = new Campaign(
                                          Id = cp.idCampaign,
                                          cel_Store_Turnover__c = (Double)Decimal.valueOf(cp.TurnOver).setScale(2));
                cs.add(c);
            }
            
            // Create Campaign with Enfant
            for(CEL_KpiVM_CampaignEnfant cc : this.campaignChildToUpdate){
                Campaign c = new Campaign(
                                          Id = cc.idCampaign,
                                          cel_Store_Turnover__c = (Double)Decimal.valueOf(cc.TurnOver).setScale(2));
                cs.add(c);
            }
            
            // Create Campaign with little Child
            for(CEL_KpiVM_Campaign clc : this.campaignLittleChildToUpdate){
                Campaign c = new Campaign(
                                          Id = clc.idCampaign,
                                          cel_Store_Turnover__c = (Double)Decimal.valueOf(clc.TurnOver).setScale(2));
                cs.add(c);
            }
            
            update cs;
        }
        catch( exception ex){
            system.debug('Exception: ' + ex.getTypeName() + ' : Message ' + ex.getMessage()  + ' - Cause : ' + ex.getCause() + ' - Trace : ' + ex.getStackTraceString());
        }
    }
}