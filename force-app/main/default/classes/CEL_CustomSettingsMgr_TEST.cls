@isTest
public class CEL_CustomSettingsMgr_TEST {

    @isTest
    static void testCustomSettings() {
        Cel_DataFactoryForTests.createCustomSettings();

        CEL_CustomSettingsMgr customSettings = CEL_CustomSettingsMgr.self();

        String interfaceUserId= customSettings.getInterfaceUserId();
    }
}