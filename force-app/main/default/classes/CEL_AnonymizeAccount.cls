global class CEL_AnonymizeAccount implements Process.Plugin { 
    
    /**
     * invoke: Invoke plugin
     * @param  {Process.PluginRequest} request
     * @return {Process.PluginResult}
     */
    global Process.PluginResult invoke(Process.PluginRequest request) {
        Boolean sendOK = false;
        String accountId = (String) request.inputParameters.get('AccountId');
        
        if(!String.isEmpty(accountId)) {
            Account a = New Account(Id = accountId);
            List<Account> accts = new List<Account>();
            accts.add(a);
            sendOk = CEL_AnonymizeUtil.anonymizeAccountAndRelation(accts);
        }
 
        Map<String,Object> result = new Map<String,Object>();
        result.put('result', sendOK);
        return new Process.PluginResult(result);
    }

    /**
     * describe: Plugin describe
     * @return {Process.PluginDescribeResult}
     */
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'Anonymized an account';
        result.Tag = 'Account';
        result.inputParameters = new 
            List<Process.PluginDescribeResult.InputParameter>{ 
            new Process.PluginDescribeResult.InputParameter('AccountId', 
            Process.PluginDescribeResult.ParameterType.STRING, true)
            }; 
        result.outputParameters = new 
            List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('result', 
            Process.PluginDescribeResult.ParameterType.BOOLEAN)
                }; 
        return result; 
   }
}