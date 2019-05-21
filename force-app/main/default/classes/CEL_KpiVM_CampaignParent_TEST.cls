@isTest
private class CEL_KpiVM_CampaignParent_TEST {
    
    @isTest
    static void testKpiVM_CampaignParent() {
        CEL_KpiVM_CampaignParent cp = new CEL_KpiVM_CampaignParent(Id.valueOf('001xa000003DIlo'), Id.valueOf('001xa000003DIla'));
        System.assertNotEquals(null,cp);
    }
}