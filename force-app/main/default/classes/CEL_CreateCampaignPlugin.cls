global class CEL_CreateCampaignPlugin implements Process.Plugin {
    
    /**
     * invoke: Invoke plugin
     * @param  {Process.PluginRequest} request
     * @return {Process.PluginResult}
     */
    global Process.PluginResult invoke(Process.PluginRequest request) {
        Map<String,String> recordtypes = new Map<String,String>();
        Schema.DescribeSObjectResult objCampaign = Schema.SObjectType.Campaign; 
        Map<Id,Schema.RecordTypeInfo> rtMapById = objCampaign.getRecordTypeInfosById();
        for(Schema.RecordTypeInfo rti : rtMapById.values()) {
            if(rti.isAvailable()) {
                recordtypes.put('RecordtypeId', rti.getRecordTypeId());
                recordtypes.put('RecordtypeName', rti.getName());
            }
        }

        Map<String,Object> result = new Map<String,Object>();
        result.put('result', recordtypes);
        return new Process.PluginResult(result);
    }

    /**
     * describe: Plugin describe
     * @return {Process.PluginDescribeResult}
     */
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'Retrieve campaign recordtype available';
        result.Tag = 'Campaign';
        result.inputParameters = new 
            List<Process.PluginDescribeResult.InputParameter>(); 
        result.outputParameters = new List<
            Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter(
                'RecordtypeId', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(
                'RecordtypeName', 
                Process.PluginDescribeResult.ParameterType.STRING)                
        };

        return result; 
   }

}