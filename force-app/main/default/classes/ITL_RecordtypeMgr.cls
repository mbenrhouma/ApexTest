public with sharing class ITL_RecordtypeMgr {


    @InvocableMethod
    public static List<Recordtype> getCampaignRecordtypesAvailable() {
        List<Recordtype> recordtypes = new List<Recordtype>();
        Schema.DescribeSObjectResult objCampaign = Schema.SObjectType.Campaign; 
        Map<Id,Schema.RecordTypeInfo> rtMapById = objCampaign.getRecordTypeInfosById();
        Recordtype rt;
        for(Schema.RecordTypeInfo rti : rtMapById.values()) {
            if(rti.isAvailable()) {
                rt = new Recordtype();
                rt.Id = rti.getRecordTypeId();
                rt.Name = rti.getName();
                recordtypes.add(rt);
            }
        }
        return recordtypes;
    }

}