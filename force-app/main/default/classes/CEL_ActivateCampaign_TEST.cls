@isTest
public class CEL_ActivateCampaign_TEST {
    
    @isTest
    static void testActivate() {
        Cel_DataFactoryForTests.createCustomSettings();
        Campaign c = new Campaign();
        c.Name = 'test';
        insert c;
        
        Campaign child = new Campaign();
        child.Name = 'test enfant';
        child.ParentId = c.Id;
        insert child;
        
        CEL_ActivateCampaign plugin = new CEL_ActivateCampaign();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('CampaignId', String.valueOf(c.Id));
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        plugin.invoke(request);
        Process.PluginDescribeResult result = plugin.describe();
        
        System.assertNotEquals(null, result);
    }
}