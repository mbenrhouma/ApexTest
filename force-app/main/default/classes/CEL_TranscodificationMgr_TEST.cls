@isTest
public class CEL_TranscodificationMgr_TEST {

    @isTest
    static void testGetTitles() {
        Cel_DataFactoryForTests.createTranscodifications(1, CEL_Constants.transcoTitleRtID);
        system.assertNotEquals(null, CEL_TranscodificationMgr.getTitles());    
    }

    @isTest
    static void testGetFamilyStatus() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getFamilyStatus());    
    }

    @isTest
    static void testGetChildrenNumber() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getChildrenNumber());    
    }

    @isTest
    static void testGetCountries() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getCountries());    
    }

    @isTest
    static void testGetPreferredContactMethod() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getPreferredContactMethod());    
    }

    @isTest
    static void testGetSpokenLangage() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getSpokenLangage());    
    }

    @isTest
    static void testGetPreferredAppointmentTime() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getPreferredAppointmentTime());    
    }

    @isTest
    static void testGetTrousersSize() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getTrousersSize());    
    }

    @isTest
    static void testGetTop() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getTop());    
    }

    @isTest
    static void testGetDress() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getDress());    
    }

    @isTest
    static void testGetKnitwear() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getKnitwear());    
    }

    @isTest
    static void testGetShoes() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getShoes());    
    }

    @isTest
    static void testGetGeneralStyle() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getGeneralStyle());    
    }

    @isTest
    static void testGetWearing() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getWearing());    
    }

    @isTest
    static void testGetColourTone() {
        system.assertNotEquals(null, CEL_TranscodificationMgr.getColourTone());    
    }

}