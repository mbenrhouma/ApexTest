public class CEL_CampaignReportController {
    
    /**
     * getAvailableReports: Return available reports for screen
     * @return {Map<String, String>}
    */
    @AuraEnabled
    public static Map<String, String> getAvailableReports() {
        return new Map<String, String> {
            'campaignReportIdAction'  => CEL_Constants.campaignReportIdAction,
            'campaignReportIdMembers'  => CEL_Constants.campaignReportIdMembers,
            'campaignReportIdTransactions'  => CEL_Constants.campaignReportIdTransactions,
            'campaignReportIdLines'  => CEL_Constants.campaignReportIdLines
        };
    }
    
    /**
     * createCampaignTransaction: Create custom object Campaign Transaction for report
     * @return {Boolean}
    */
    @AuraEnabled
    public static Boolean createCampaignTransaction(String CampaingId) {
        return CEL_CampaignMgr.createCampaignTransaction(CampaingId);
    }
    
     /**
     * createCampaignTransactionLine: Create custom object Campaign Transaction with line for report
     * @return {Boolean}
    */
    @AuraEnabled
    public static Boolean createCampaignTransactionLine(String CampaingId) {
        return CEL_CampaignMgr.createCampaignTransactionLine(CampaingId);
    }
}