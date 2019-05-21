@isTest
private class CEL_KpiVM_Campaign_TEST {
    
    @isTest
    static void testKpiVM_Campaign() {
        CEL_KpiVM_Campaign c = new CEL_KpiVM_Campaign(Id.valueOf('001xa000003DIlo'),Id.valueOf('001xa000003DIla'));
        System.assertNotEquals(null,c);
    }
}