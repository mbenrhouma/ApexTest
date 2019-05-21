public class CEL_CustomMetadataMgr {
    
    /**
    * getRelatedTaskCustomMetadata: get the related custom metadata of the task
    * @param  {String}  api name of the custom metadata
    * @return cel_email_task__mdt
    */
    public static cel_email_task__mdt getRelatedTaskCustomMetadata(String apiName) {
        cel_email_task__mdt taskCustomMetadata = new cel_email_task__mdt();
        taskCustomMetadata =[Select Id, DeveloperName, cel_end_date__c,cel_marked_on_entry__c,
                             cel_priority__c,cel_start_date__c,cel_task__c,cel_template__c,cel_type__c
                             From cel_email_task__mdt
                             Where DeveloperName = :apiName];
        
        return taskCustomMetadata;
    }
    
    /**
    * getConcernedSegmentSet: get the related segments set tp the tasl
    * @param  {Id}  id of the custom metadata email task
    * @return Set<String>
    */
    public static Set<String> getConcernedSegmentSet(Id metadataId) {
        Set<String> concernedSegmentList = new Set<String>();
        
        List<cel_metadata_segment_map__mdt> listOfMapRelatedToMetadata = new List<cel_metadata_segment_map__mdt>();

        listOfMapRelatedToMetadata = [Select Id, DeveloperName, cel_related_segment__c, cel_Email_Task__c
                                      From cel_metadata_segment_map__mdt
                                      Where cel_Email_Task__c = :metadataId];
        
        if(listOfMapRelatedToMetadata != null && !listOfMapRelatedToMetadata.isEmpty()){
            for(cel_metadata_segment_map__mdt metadataSegmentMap : listOfMapRelatedToMetadata){
               concernedSegmentList.add(metadataSegmentMap.cel_related_segment__c); 
            } 
            
        }
        
        return concernedSegmentList;
    }

}