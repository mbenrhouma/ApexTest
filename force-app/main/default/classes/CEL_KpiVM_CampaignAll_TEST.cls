@isTest
private class CEL_KpiVM_CampaignAll_TEST {
    
    @isTest
    static void testKpiVM_CampaignAll() {
        CEL_KpiVM_CampaignAll cp = new CEL_KpiVM_CampaignAll(Id.valueOf('001xa000003DIlo'));
        System.assertNotEquals(null,cp);
    }
}