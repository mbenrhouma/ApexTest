global with sharing class CEL_BatchUpdateCurrency implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} BC
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT id, IsoCode, ConversionRate FROM DatedConversionRate WHERE StartDate <= today AND NextStartDate  >= today]);
    }
    
    /**
     * execute
     * @param {SchedulableContext} sc
     */    
    global void execute(SchedulableContext sc)
    {
        CEL_BatchUpdateCurrency b = new CEL_BatchUpdateCurrency();      
        Database.executeBatch(b);
    }

    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param [{Account}] accounts
     */
    global void execute(Database.BatchableContext BC, List<DatedConversionRate> datedConversionRates) {
        List<CurrencyType> currencies = [SELECT ISOCode FROM CurrencyType WHERE IsActive = TRUE AND IsCorporate = TRUE];
        CurrencyType corporateCurrency;
        if(currencies != null && !currencies.isEmpty()) {
        	corporateCurrency = currencies.get(0);
        }
        if(datedConversionRates != null && !datedConversionRates.isEmpty()) {
            for(DatedConversionRate dcr : datedConversionRates) {
                if(corporateCurrency != null && corporateCurrency.ISOCode != dcr.IsoCode) {
                    updateCurrencyType(dcr);
                }
            }
        }
    }

    
    /**
     * finish: Call at the end of the batch
     * @param  {BatchableContext} BC
     */
    global void finish(Database.BatchableContext BC) {
        System.debug( '================= FINISH ====================' );
    }


    /**
     * updateCurrencyType Update CurrencyType from DateConversionReate
     * @param  {DatedConversionRate} dcr
     */
    private void updateCurrencyType(DatedConversionRate dcr) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v28.0/sobjects/CurrencyType/');
        req.setMethod('POST');
        String body = '{ "IsoCode" : "' + dcr.IsoCode + '", "DecimalPlaces" : 6, "ConversionRate" : ' + dcr.ConversionRate + ', "IsActive" : "true"}';
        req.setBody(body);
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = h.send(req);
    }

}