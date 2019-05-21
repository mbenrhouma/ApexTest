@isTest
private class CEL_KpiVM_CampaignEnfant_TEST {
    
    @isTest
    static void testKpiVM_CampaignEnfant() {
        CEL_KpiVM_CampaignEnfant cp = new CEL_KpiVM_CampaignEnfant(Id.valueOf('001xa000003DIlo'), Id.valueOf('001xa000003DIla'));
        System.assertNotEquals(null,cp);
    }
}