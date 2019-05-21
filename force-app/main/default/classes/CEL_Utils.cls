public with sharing class CEL_Utils {

    /**
     * Get values from the given field picklist
     *
     * @param {Schema.DescribeFieldResult} picklistDescribe
     * @param {Boolean} addNoneValue
     * @param {Set<String>} excludedValues
     *
     * @return {List<Map<String, String>>}
     **/
    public static List<Map<String, String>> getFieldValues(Schema.DescribeFieldResult picklistDescribe, Boolean addNoneValue, Set<String> excludedValues) {
        return getFieldValues(picklistDescribe, addNoneValue, excludedValues,'');
    }

    /**
     * Get values from the given field picklist
     *
     * @param {Schema.DescribeFieldResult} picklistDescribe
     * @param {Boolean} addNoneValue
     * @param {String} defaultValue set on top of the list
     * @param {Set<String>} excludedValues
     *
     * @return {List<Map<String, String>>}
     **/
    public static List<Map<String, String>> getFieldValues(Schema.DescribeFieldResult picklistDescribe, Boolean addNoneValue, String defaultValue, Set<String> excludedValues) {
        return getFieldValues(picklistDescribe, addNoneValue, defaultValue, excludedValues,'');
    }
    
    /**
     * Get values from the given field picklist
     *
     * @param {Schema.DescribeFieldResult} picklistDescribe
     * @param {Boolean} addNoneValue
     * @param {Set<String>} excludedValues
     * @param {String} emptyLabel
     *
     * @return {List<Map<String, String>>}
     **/
    public static List<Map<String, String>> getFieldValues(Schema.DescribeFieldResult picklistDescribe, Boolean addNoneValue, Set<String> excludedValues, String emptyLabel) {
        return getFieldValues(picklistDescribe, addNoneValue, null, excludedValues,'');
    }
    
    /**
     * Get values from the given field picklist
     *
     * @param {Schema.DescribeFieldResult} picklistDescribe
     * @param {Boolean} addNoneValue
     * @param {String} defaultValue set on top of the list
     * @param {Set<String>} excludedValues
     * @param {String} emptyLabel
     *
     * @return {List<Map<String, String>>}
     **/
    public static List<Map<String, String>> getFieldValues(Schema.DescribeFieldResult picklistDescribe, Boolean addNoneValue, String defaultValue, Set<String> excludedValues, String emptyLabel) {
        List<Map<String, String>> values = new List<Map<String, String>>();
        List<Schema.PicklistEntry> picklistEntries = picklistDescribe.getPicklistValues();
        if(excludedValues == null) {
            excludedValues = new Set<String>();
        }

        // Add empty entry at first
        if(addNoneValue == true) {
            values.add(new Map<String, String>{
                'value' => '',
                'label' => emptyLabel
            });
        }

        for(Schema.PicklistEntry f : picklistEntries) {
            if(!excludedValues.contains(f.getValue())) {
                values.add(new Map<String, String>{
                    'value' => f.getValue(),
                    'label' => f.getLabel()
                });
            }
        }
        
        if(defaultValue != null) {
            Integer index = 0;
            for(Map<String, String> elem : values) {
                if(elem.get('value') == defaultValue) {
                    values.add(0, values.remove(index));
                    break;
                }
                index++;
            }
        }

        return values;
    }
    
    /**
    * Return a picklist label from its value
    * @param {Schema.SObjectField} field
    * @param {String} value
    * @return {String}
    */
    public static String getStdPicklistLabelFromValue(Schema.SObjectField field, String value)
    {
        List<Map<String, String>> values = CEL_Utils.getStdPicklistValues(field);
        for(Map<String, String> elt : values)
        {
            if(elt.get('value') == value){ return elt.get('label'); }
        }
        
        return null;
    }
    
    /**
    * Return all picklist values from the sObject field in param
    * @param {Schema.SObjectField} field
    *
    * @return {List<Map<String, String>>}
    */
    public static List<Map<String, String>> getStdPicklistValues(Schema.SObjectField field)
    {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            Map<String, String> m = new Map<String, String>{
                'value' => f.getValue(),
                'label' => f.getLabel()
            };
            options.add(m);
        }
        
        return options;
    }

    
    
    /**
    * hasFieldEditAccess: return if logged user has edit access right on a field
    * @param {String} Field APIname
    * @return {Boolean}
    */
    public static Boolean hasFieldEditAccess(String objectName,String fieldName) {
        return CEL_UserMgr.hasFieldEditAccess(objectName, fieldName);
    }
    
    /**
    * Get values map from the given field picklist
    *
    * @param {Schema.DescribeFieldResult} picklistDescribe
    * @param {Set<String>} excludedValues
    * @return {Map<String, String>}
    **/
    public static Map<String, String> getFieldValuesMap(Schema.DescribeFieldResult picklistDescribe, Set<String> excludedValues) {
        
        Map<String, String> values = new Map<String, String>();
        List<Schema.PicklistEntry> picklistEntries = picklistDescribe.getPicklistValues();
        if(excludedValues == null) {
            excludedValues = new Set<String>();
        }


        for(Schema.PicklistEntry f : picklistEntries) {
            if(!excludedValues.contains(f.getValue())) {
                values.put(f.getLabel(),f.getValue());
            }
        }

        return values;
    }
    
    /**
    * getFieldSchemaObject: return the Schema.SobjectField of a field
    * @param {String,String} Field, Object
    * @return {Schema.SobjectField}
    */
    public static Schema.SobjectField getFieldSchemaObject(String objectName,String fieldName) {
        
        Schema.SobjectField theField;
        if(String.isNotBlank(objectName) && String.isNotBlank(fieldName)){
            theField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName); 
        }
        return theField;
    }
    
}