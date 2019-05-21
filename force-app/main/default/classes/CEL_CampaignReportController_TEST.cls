@isTest
public class CEL_CampaignReportController_TEST {
    
    @isTest
    static void testGetAvailableReports() {
        Cel_DataFactoryForTests.createCustomSettings();
        Map<String, String> result = CEL_CampaignReportController.getAvailableReports();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.get('campaignReportIdAction'));
        System.assertNotEquals(null, result.get('campaignReportIdMembers'));
        System.assertNotEquals(null, result.get('campaignReportIdTransactions'));
        System.assertNotEquals(null, result.get('campaignReportIdLines'));
    }
    
    @isTest
    static void testCreateCampaignTransaction() {
        Cel_DataFactoryForTests.createCustomSettings();
        Boolean result = CEL_CampaignReportController.createCampaignTransaction('');
        System.assertEquals(false, result);
    }
    
    @isTest
    static void testCreateCampaignTransactionLine() {
        Cel_DataFactoryForTests.createCustomSettings();
        Boolean result = CEL_CampaignReportController.createCampaignTransactionLine('');
        System.assertEquals(false, result);
    }
}