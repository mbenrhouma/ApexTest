public class CEL_KpiVM_CampaignAll {
    
    public Id idCampaign;
    public Double NbOfTransaction;
    public Double NbOfTransactionCrossSelling;
    public Double CrossSellingRate;
    public Double TurnOver;
    
    public CEL_KpiVM_CampaignAll(Id campaignId) 
    {
        this.TurnOver = 0;
        this.NbOfTransaction = 0;
        this.CrossSellingRate = 0;
        this.idCampaign = campaignId;
        this.NbOfTransactionCrossSelling = 0;
    }
}