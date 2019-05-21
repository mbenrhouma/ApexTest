@isTest
public class CEL_CustomMetadataMgr_TEST {
    @isTest
    static void testGetRelatedTaskCustomMetadata() {
        cel_email_task__mdt emailTaskTest = CEL_CustomMetadataMgr.getRelatedTaskCustomMetadata('cel_birthday_normal');
        System.assertNotEquals(null,emailTaskTest);
    }
    
    @isTest
    static void testGetConcernedSegmentSet() {
        cel_email_task__mdt emailTaskTest = CEL_CustomMetadataMgr.getRelatedTaskCustomMetadata('cel_birthday_normal');
        Set<String> segmentsSetTest = CEL_CustomMetadataMgr.getConcernedSegmentSet(emailTaskTest.Id);
        System.assertNotEquals(null,segmentsSetTest);
    }
    

}