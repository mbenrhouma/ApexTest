@isTest
public class CEL_Utils_TEST {
    
    @isTest
    static void testGetFieldValues() {
        List<Map<String, String>> result = CEL_Utils.getFieldValues(Account.cel_addr_1_country__c.getDescribe(), true, null);
        system.assertNotEquals(null, result);
        
        Set<String> t = new Set<String>();
        t.add('Normal');
        result = CEL_Utils.getFieldValues(Account.cel_store_type__c.getDescribe(), true, '', t);
        system.assertNotEquals(null, result);
        
        result = CEL_Utils.getFieldValues(Account.cel_store_type__c.getDescribe(), true, t, '');
        system.assertNotEquals(null, result);
        
        result = CEL_Utils.getFieldValues(Account.cel_store_type__c.getDescribe(), true, '', t, '');
        system.assertNotEquals(null, result);
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType accountSchema = schemaMap.get('Account');
        Map<String, Schema.SObjectField> fieldMap = accountSchema.getDescribe().fields.getMap();
        Schema.SObjectField f = fieldMap.get('AccountSource');
        String label = CEL_Utils.getStdPicklistLabelFromValue(f, 'Other');
        system.assertNotEquals(null, label);
        
        List<Map<String, String>> result1 = CEL_Utils.getStdPicklistValues(f);
        system.assertNotEquals(null, result1);
        
        Boolean access = CEL_Utils.hasFieldEditAccess('Account', 'AccountSource');
        system.assertNotEquals(false, access);
    }
    
    @isTest
    static void testGetFieldValuesMap() {
        Map<String, String> result = CEL_Utils.getFieldValuesMap(Task.Type.getDescribe(), null);
        system.assertNotEquals(null, result);
    }
}