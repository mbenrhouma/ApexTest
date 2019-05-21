public class CEL_PortabilityController {

    /**
     * getAvailableReports: Return available reports for screen
     * @return {Map<String, String>}
    */
    @AuraEnabled
    public static Map<String, String> getAvailableReports() {
        return new Map<String, String> {
            'customerCard' => CEL_Constants.gdprReportCustomerCard,
            'transactions' => CEL_Constants.gdprReportTransaction,
            'campaigns'  => CEL_Constants.gdprReportCampaign,
            'cases'  => CEL_Constants.gdprReportCase
        };
    }


    /**
     * updateExtractionDate Update extraction date when launch portability
     * @param  {Account} account
     */
    @AuraEnabled
    public static void updateExtractionDate(String accountId){
        CEL_IndividualMgr.updateExtrationDate(accountId);
    }

    /**
     * getAccount Retrieve personContactID from account ID
     * @param  {Account} account
     */
    @AuraEnabled
    public static String getAccount(String accountId){
        return CEL_AccountMgr.getPersonContactID(accountId);
    }

}