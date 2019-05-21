public class CEL_KpiVM_CampaignParent {
    
    public Id idCampaign;
    public Id idCampaignAll;
    public Double NbOfTransaction;
    public Double NbOfTransactionCrossSelling;
    public Double CrossSellingRate;
    public Double TurnOver;
    
    public CEL_KpiVM_CampaignParent(Id campaignId, Id campaignIdAll) 
    {
        this.idCampaignAll = campaignIdAll;
        this.TurnOver = 0;
        this.NbOfTransaction = 0;
        this.CrossSellingRate = 0;
        this.idCampaign = campaignId;
        this.NbOfTransactionCrossSelling = 0;
    }
}