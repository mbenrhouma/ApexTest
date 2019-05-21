@isTest
public class CEL_AnonymizeAccount_TEST {

    @isTest
    static void testAnonymize(){
        Cel_DataFactoryForTests.createCustomSettings();
        List<Account> accts = Cel_DataFactoryForTests.createAccounts(1);
        Account a = accts.get(0);
        String accountId = a.Id;
        
        CEL_AnonymizeAccount plugin = new CEL_AnonymizeAccount();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('AccountId', String.valueOf(accountId));
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        
        Process.PluginResult result = plugin.invoke(request);
        
        System.AssertNotEquals(null, result.outputParameters);
        System.AssertNotEquals(null, result.outputParameters.get('result'));
    }

    @isTest
    static void testDescribe() {
        CEL_AnonymizeAccount plugin = new CEL_AnonymizeAccount();
        
        Process.PluginDescribeResult result = plugin.describe();
        
        System.AssertEquals(result.inputParameters.size(), 1, 'Input parameters size should be 1');
        System.AssertEquals(result.OutputParameters.size(), 1, 'Output parameters size should be 1');
     }
}