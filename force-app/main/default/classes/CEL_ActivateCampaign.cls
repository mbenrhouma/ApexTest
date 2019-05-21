global class CEL_ActivateCampaign implements Process.Plugin { 
    
    /**
     * invoke: Invoke plugin
     * @param  {Process.PluginRequest} request
     * @return {Process.PluginResult}
     */
    global Process.PluginResult invoke(Process.PluginRequest request) {
        String names = null;
        String campaignId = (String) request.inputParameters.get('CampaignId');
        
        if(!String.isEmpty(campaignId)) {
            List<Campaign> cs = [SELECT Id, StartDate, EndDate FROM Campaign WHERE Id = :campaignId LIMIT 1];
            if(cs != null && !cs.isEmpty()){
                Campaign c = cs.get(0);
                List<String> allNames = new List<String>();
                allNames = CEL_CampaignMgr.getNameChildrenOutRangeDate(c);
                if(allNames != null && !allNames.isEmpty()){
                    names = System.Label.cel_campaign_ErrorMessageBeforeActiveParentStart + ' ' + string.join(allNames,',') + ' ' + System.Label.cel_campaign_ErrorMessageBeforeActiveParentEnd;
                }
            }
        }
        
        Map<String,Object> result = new Map<String,Object>();
        result.put('result', names);
        return new Process.PluginResult(result);
    }
    
    /**
     * describe: Plugin describe
     * @return {Process.PluginDescribeResult}
     */
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'Activate Campaign';
        result.Tag = 'Campaign';
        result.inputParameters = new 
            List<Process.PluginDescribeResult.InputParameter>{ 
            new Process.PluginDescribeResult.InputParameter('CampaignId', 
            Process.PluginDescribeResult.ParameterType.STRING, true)
            }; 
        result.outputParameters = new 
            List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('result', 
            Process.PluginDescribeResult.ParameterType.String)
                }; 
        return result; 
   }
}