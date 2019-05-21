public class CEL_KpiVM_CampaignEnfant {
    
    public Id idCampaign;
    public Id idCampaignParent;
    public Double NbOfTransaction;
    public Double NbOfTransactionCrossSelling;
    public Double CrossSellingRate;
    public Double TurnOver;
    
    public CEL_KpiVM_CampaignEnfant(Id campaignId, Id campaignParentId) 
    {
        this.TurnOver = 0;
        this.NbOfTransaction = 0;
        this.CrossSellingRate = 0;
        this.idCampaign = campaignId;
        this.NbOfTransactionCrossSelling = 0;
        this.idCampaignParent = campaignParentId;
    }
}