@isTest
public class CEL_Campaign_PicklistsController_TEST {
    
    @isTest
    static void testPicklistsController() {
        Cel_DataFactoryForTests.createCustomSettings();
        String recordType = CEL_Constants.campaignEnfantRecordType;
        Campaign c = new Campaign();
        c.Name = 'test';
        insert c;
        
        Campaign child = new Campaign();
        child.Name = 'test enfant';
        child.ParentId = c.Id;
        child.recordTypeId = recordType;
        insert child;
        
        Map<String, List<Map<String, String>>> result = CEL_Campaign_PicklistsController.getAvailableList(String.valueOf(child.Id), String.valueOf(c.Id), recordType);
        
        System.assertNotEquals(null, result);
    }
}