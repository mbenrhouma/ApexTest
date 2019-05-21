global class CEL_KpiCrossSellingBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private List<CEL_KpiVM_Campaign> campaignLittleChildToUpdate;
    private List<CEL_KpiVM_CampaignEnfant> campaignChildToUpdate;
    private List<CEL_KpiVM_CampaignParent> campaignParentToUpdate;
    private List<CEL_KpiVM_CampaignAll> campaignAllToUpdate;
    private Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap;
    private Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap;
    private Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap;
    private Map<Id, CEL_KpiVM_CampaignAll> campaignsAllMap;
    
    global CEL_KpiCrossSellingBatch() {
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
                                                cel_activity_validity_start_date__c, 
                                                cel_Activity_Validity_End_Date__c,
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
        Map<Id, Set<Id>> membersMap = new Map<Id, Set<Id>>();
        Map<Id, List<cel_Transaction__c>> transactionsMap = new Map<Id, List<cel_Transaction__c>>();
        Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap = this.campaignsLittleChildMap;
        Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap = this.campaignsChildMap;
        Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap = this.campaignsParentMap;
        Map<Id, CEL_KpiVM_CampaignAll> campaignsAllMap = this.campaignsAllMap;
        
        // Init Map campaignsLittleChildMap ( CampaignId , CEL_KpiVM_Campaign ) 
        // Init Map campaignsChildMap ( CampaignId , CEL_KpiVM_CampaignEnfant ) 
        // Init Map campaignsParentMap ( CampaignId , CEL_KpiVM_CampaignParent )
        // Init Map campaignsAllMap ( CampaignId , CEL_KpiVM_CampaignAll )
        for(Campaign c : campaigns){
            // Add a campaignsLittleChild on Map
            if(!campaignsLittleChildMap.containsKey(c.Id) && !campaignsChildMap.containsKey(c.Id) && !campaignsParentMap.containsKey(c.Id) && !campaignsAllMap.containsKey(c.Id)
                && c.ParentId != null && String.valueOf(c.RecordTypeId) == recordTypeEnfant && (c.ChildCampaigns == null  || c.ChildCampaigns.size() == 0)) {
                CEL_KpiVM_Campaign vmc = new CEL_KpiVM_Campaign(c.Id, c.ParentId);
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
        
        // Get account Id members status
        List<cel_Campaign_Member_Status__c > members = [SELECT Id, cel_Campaign__c, cel_Contact__r.AccountId FROM cel_Campaign_Member_Status__c 
                                                        WHERE cel_Campaign__c IN :campaignsIds 
                                                        AND cel_Campaign__c != null 
                                                        AND cel_Contact__c != null];
        
        Set<Id> accIds = new Set<Id>();
        for(cel_Campaign_Member_Status__c  m : members){
            accIds.add(m.cel_Contact__r.AccountId);
        }
        
        // Get all transaction with account Id membersCampaign
        List<cel_Transaction__c> transactions = [SELECT Id,
                                                        cel_sale_date__c,
                                                        cel_AccountId__c,
                                                        // Select line items type
                                                        (SELECT cel_macro_activity_name__c FROM Transactions_Line__r)
                                                FROM cel_Transaction__c
                                                WHERE cel_AccountId__c IN :accIds
                                                    AND cel_is_cancelled__c = false
                                                    AND cel_sale_date__c >= :firstStartDate
                                                    AND cel_sale_date__c != null
                                                    AND cel_AccountId__c != null
                                                ORDER BY cel_AccountId__c];
        
        
        // Init Map ( CampaignId , Set<Id Account> )
        for(cel_Campaign_Member_Status__c m : members){
            Set<Id> membersList;
            if(membersMap.containsKey(m.cel_Campaign__c)) {
                membersList = membersMap.get(m.cel_Campaign__c);
            } else {
                membersList = new Set<Id>();
            }
            membersList.add(m.cel_Contact__r.AccountId);
            membersMap.put(m.cel_Campaign__c, membersList);
        }
        
        // Init Map ( CampaignId , List<cel_Transaction__c> And Add transaction )
        for(Id c : membersMap.keySet()){
            Set<Id> membersList = membersMap.get(c);
            CEL_KpiVM_Campaign campaign = campaignsLittleChildMap.get(c);
            List<cel_Transaction__c> transactionList = new List<cel_Transaction__c>();
            
            for(cel_Transaction__c t : transactions) {
                if(t != null && campaign != null && campaign.startDate != null && campaign.endDate != null && t.cel_AccountId__c != null && membersList.contains(t.cel_AccountId__c) && t.cel_sale_date__c > campaign.startDate &&  t.cel_sale_date__c < campaign.endDate){
                    if(transactionsMap.containsKey(c)) {
                        transactionList = transactionsMap.get(c);
                    } else {
                        transactionList = new List<cel_Transaction__c>();
                    }
                    transactionList.add(t);
                    transactionsMap.put(c, transactionList);
                }
            }
            if(campaign != null){
                campaign.transactions.addAll(transactionList);
            }
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
        this.calculCrossSellingLittleChild(campaignsLittleChildMap);
        this.calculCrossSellingChild(campaignsLittleChildMap, campaignsChildMap);
        this.calculCrossSellingParent(campaignsChildMap, campaignsParentMap);
        this.calculCrossSellingAll(campaignsParentMap, campaignsAllMap);
        
        // Make list to update
        this.campaignLittleChildToUpdate.addAll(this.campaignsLittleChildMap.values());
        this.campaignChildToUpdate.addAll(this.campaignsChildMap.values());
        this.campaignParentToUpdate.addAll(this.campaignsParentMap.values());
        this.campaignAllToUpdate.addAll(this.campaignsAllMap.values());
    }
    
    /**
    * KPIs calculation littleChild
    * @param {Map<Id, CEL_KpiVM_Campaign>} campaignsMap
    */
    private void calculCrossSellingLittleChild(Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap) {
        List<CEL_KpiVM_Campaign> campaigns = campaignsLittleChildMap.values();
        
        for(CEL_KpiVM_Campaign c : campaigns){
            // Calcul Nb All transactions
            c.NbOfTransaction = c.transactions != null ? c.transactions.size() : 0;
            // Calcul Nb transactions CrossSelling
            c.NbOfTransactionCrossSelling = this.calculNbCrossSellingTransaction(c);
            // Calcul Rate CrossSelling
            c.CrossSellingRate = c.NbOfTransaction != 0 ? ((c.NbOfTransactionCrossSelling / c.NbOfTransaction) * 100) : 0;
        }
    }
    
    /**
    * KPIs calculation Enfant with littlechild
    * @param {Map<Id, CEL_KpiVM_Campaign>} campaignsLittleChildMap
    * @param {Map<Id, CEL_KpiVM_CampaignEnfant>} campaignsChildMap
    */
    private void calculCrossSellingChild(Map<Id, CEL_KpiVM_Campaign> campaignsLittleChildMap, Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap) {
        List<CEL_KpiVM_Campaign> campaignsLittleChilds = campaignsLittleChildMap.values();
        List<CEL_KpiVM_CampaignEnfant> campaignsChilds = campaignsChildMap.values();
        
        for(CEL_KpiVM_CampaignEnfant cc : campaignsChilds){
            for(CEL_KpiVM_Campaign clc : campaignsLittleChilds){
                if(clc.idCampaignEnfant == cc.idCampaign){
                    // Calcul Nb All transaction
                    cc.NbOfTransaction = cc.NbOfTransaction + clc.NbOfTransaction;
                    // Calcul Nb transaction CrossSelling
                    cc.NbOfTransactionCrossSelling = cc.NbOfTransactionCrossSelling + clc.NbOfTransactionCrossSelling;
                }
            }
            // Calcul Rate CrossSeeling
            cc.CrossSellingRate = cc.NbOfTransaction != 0 ? ((cc.NbOfTransactionCrossSelling / cc.NbOfTransaction ) * 100 ) : 0;
        }
    }
    
    /**
    * KPIs calculation Parent with Enfant
    * @param {Map<Id, CEL_KpiVM_CampaignEnfant>} campaignsChildMap
    * @param {Map<Id, CEL_KpiVM_CampaignParent>} campaignsParentMap
    */
    private void calculCrossSellingParent(Map<Id, CEL_KpiVM_CampaignEnfant> campaignsChildMap, Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap) {
        List<CEL_KpiVM_CampaignEnfant> campaignsChild = campaignsChildMap.values();
        List<CEL_KpiVM_CampaignParent> campaignsParent = campaignsParentMap.values();
        
        for(CEL_KpiVM_CampaignParent cp : campaignsParent){
            for(CEL_KpiVM_CampaignEnfant cc : campaignsChild){
                if(cp.idCampaign == cc.idCampaignParent){
                    // Calcul Nb All transaction
                    cp.NbOfTransaction = cp.NbOfTransaction + cc.NbOfTransaction;
                    // Calcul Nb transaction CrossSelling
                    cp.NbOfTransactionCrossSelling = cp.NbOfTransactionCrossSelling + cc.NbOfTransactionCrossSelling;
                }
            }
            // Calcul Rate CrossSeeling
            cp.CrossSellingRate = cp.NbOfTransaction != 0 ? ((cp.NbOfTransactionCrossSelling / cp.NbOfTransaction ) * 100 ) : 0;
        }
        
    }
    
    /**
    * KPIs calculation All with parent
    * @param {Map<Id, CEL_KpiVM_CampaignParent>} campaignsParentMap
    * @param {Map<Id, CEL_KpiVM_CampaignAll>} campaignsAllMap
    */
    private void calculCrossSellingAll( Map<Id, CEL_KpiVM_CampaignParent> campaignsParentMap,  Map<Id, CEL_KpiVM_CampaignAll> campaignsAllMap) {
        List<CEL_KpiVM_CampaignParent> campaignsParents = campaignsParentMap.values();
        List<CEL_KpiVM_CampaignAll> campaignsAlls = campaignsAllMap.values();
        
        for(CEL_KpiVM_CampaignAll ca : campaignsAlls){
            for(CEL_KpiVM_CampaignParent cp : campaignsParents){
                if(ca.idCampaign == cp.idCampaignAll){
                    // Calcul Nb All transaction
                    ca.NbOfTransaction = ca.NbOfTransaction + cp.NbOfTransaction;
                    // Calcul Nb transaction CrossSelling
                    ca.NbOfTransactionCrossSelling = ca.NbOfTransactionCrossSelling + cp.NbOfTransactionCrossSelling;
                }
            }
            // Calcul Rate CrossSeeling
            ca.CrossSellingRate = ca.NbOfTransaction != 0 ? ((ca.NbOfTransactionCrossSelling / ca.NbOfTransaction ) * 100 ) : 0;
        }
    }
    
    /**
    * Calcul Nb CrossSelling transactions
    * @param {Map<Id, CEL_KpiVM_Campaign>} campaignsMap
    */
    private Double calculNbCrossSellingTransaction(CEL_KpiVM_Campaign campaign) {
        List<cel_Transaction__c> transactions = campaign.transactions;
        Double nbTransactionCrossSelling = 0;
        
        if(transactions != null && transactions.size() > 0){
            for(cel_Transaction__c t : transactions){
                // Get Transaction Line de la transaction
                List<cel_Transaction_Line__c> lines = t.Transactions_Line__r;
                Double isCrossSelling = 0;
                
                if(lines != null && lines.size() > 1){
                    
                    // Compare lines type, if not equal so Is CrossSelling
                    String typeLine = lines.get(0).cel_macro_activity_name__c;
                    
                    for(Integer i = 1; i < lines.size(); i++){
                        if(typeLine != lines.get(i).cel_macro_activity_name__c){
                            isCrossSelling = 1;
                        }
                    }
                }
                
                // Add transaction CrosseSelling
                nbTransactionCrossSelling = nbTransactionCrossSelling + isCrossSelling;
            }
        }
        
        return nbTransactionCrossSelling;
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
                                          cel_Cross_Selling_Rate__c = (Double)Decimal.valueOf(ca.CrossSellingRate).setScale(0));
                cs.add(c);
            }
            
            // Create Campaign with Parent
            for(CEL_KpiVM_CampaignParent cp : this.campaignParentToUpdate){
                Campaign c = new Campaign(
                                          Id = cp.idCampaign,
                                          cel_Cross_Selling_Rate__c = (Double)Decimal.valueOf(cp.CrossSellingRate).setScale(0));
                cs.add(c);
            }
            
            // Create Campaign with Enfant
            for(CEL_KpiVM_CampaignEnfant cc : this.campaignChildToUpdate){
                Campaign c = new Campaign(
                                          Id = cc.idCampaign,
                                          cel_Cross_Selling_Rate__c = (Double)Decimal.valueOf(cc.CrossSellingRate).setScale(0));
                cs.add(c);
            }
            
            // Create Campaign with little Child
            for(CEL_KpiVM_Campaign clc : this.campaignLittleChildToUpdate){
                Campaign c = new Campaign(
                                          Id = clc.idCampaign,
                                          cel_Cross_Selling_Rate__c = (Double)Decimal.valueOf(clc.CrossSellingRate).setScale(0));
                cs.add(c);
            }
            
            update cs;
        }
        catch( exception ex){
            system.debug('Exception: ' + ex.getTypeName() + ' : Message ' + ex.getMessage()  + ' - Cause : ' + ex.getCause() + ' - Trace : ' + ex.getStackTraceString());
        }
    }
}