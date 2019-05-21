public class CEL_KpiVM_Campaign {
    
    public Id idCampaign;
    public Id idCampaignEnfant;
    public Date startDate;
    public Date endDate;
    public Double NbOfTransaction;
    public Double NbOfTransactionCrossSelling;
    public Double CrossSellingRate;
    public Double TurnOver;
    
    public List<Id> stores;
    public List<cel_Transaction__c> transactions;
    
    public CEL_KpiVM_Campaign(Id campaignId, Id campaignEnfantId) 
    {
        this.TurnOver = 0;
        this.NbOfTransaction = 0;
        this.CrossSellingRate = 0;
        this.endDate = Date.today();
        this.idCampaign = campaignId;
        this.stores = new List<Id>();
        this.startDate = Date.today();
        this.NbOfTransactionCrossSelling = 0;
        this.idCampaignEnfant = campaignEnfantId;
        this.transactions = new List<cel_Transaction__c>();
    }
}