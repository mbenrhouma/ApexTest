public class CEL_DatedConversionRateMgr {
    
    /**
    * getMapCurrentConversionRate : get map of Current Conversion Rate
    * @return {Map<String, decimal>} mapCurrentRate
    */
    public static Map<String, decimal> getMapCurrentConversionRate(){
        Map<String, decimal> mapCurrentRate = new Map<String, decimal>();
        
        List<DatedConversionRate> listRates = [SELECT id, IsoCode, StartDate, NextStartDate, ConversionRate 
                                                     FROM DatedConversionRate 
                                                     WHERE StartDate <= today 
                                                     AND NextStartDate  >= today];
        
        for(DatedConversionRate dcr : listRates){
            mapCurrentRate.put(dcr.IsoCode, dcr.ConversionRate);
        }
        
        return mapCurrentRate;
    }
}