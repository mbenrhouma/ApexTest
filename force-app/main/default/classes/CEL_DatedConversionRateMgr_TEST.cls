@isTest
public class CEL_DatedConversionRateMgr_TEST {
    
    @isTest
    static void testDatedConversionRateMgr() {
        Map<String, decimal> mapCurrent = CEL_DatedConversionRateMgr.getMapCurrentConversionRate(); 
        System.assertNotEquals(null, mapCurrent); 
    }
}