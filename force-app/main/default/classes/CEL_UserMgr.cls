public without sharing class CEL_UserMgr {

    /**
    * hasFieldEditAccess: return if user has edit access right on a field
    * @param {String} fieldName
    * @param {String} userId
    * @return {Boolean}
    */
    public static Boolean hasFieldEditAccess(String objectName, String fieldName)
    {
        Boolean accessResult = false;
        if(String.isNotBlank(objectName) && String.isNotBlank(fieldName) && Schema.getGlobalDescribe().get(objectName)!= null ){
            
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            
            if(objectFields.get(fieldName) != null){
                Schema.DescribeFieldResult parameterField = objectFields.get(fieldName).getDescribe();
                accessResult = parameterField.isUpdateable();
            }
            
        }
        
        return accessResult;
    }
}