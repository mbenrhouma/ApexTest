public class CEL_Constants {
    /**
     * Interface user Id.
     */
    public static String interfaceUserId = CEL_CustomSettingsMgr.self().getInterfaceUserId() == null ? '' : CEL_CustomSettingsMgr.self().getInterfaceUserId();
    
    public static ID peronAccountRtID= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    public static ID storeRtID= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
    public static ID slavePersonAccountRtID= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Slave').getRecordTypeId();
    public static ID caseCaseRtID = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CEL_Case_Case').getRecordTypeId();
    public static ID caseClaimRtID = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CEL_claim_case').getRecordTypeId();
    public static ID transcoTitleRtID = Schema.SObjectType.cel_transcodification__c.getRecordTypeInfosByDeveloperName().get('cel_title').getRecordTypeId();
    public static ID transcoAreaRtID = Schema.SObjectType.cel_transcodification__c.getRecordTypeInfosByDeveloperName().get('Area').getRecordTypeId();
    public static ID transcoCountryRtID = Schema.SObjectType.cel_transcodification__c.getRecordTypeInfosByDeveloperName().get('Country').getRecordTypeId();
    public static ID transcoRegionRtID = Schema.SObjectType.cel_transcodification__c.getRecordTypeInfosByDeveloperName().get('Region').getRecordTypeId();

    
    public static String gdprReportCustomerCard = CEL_CustomSettingsMgr.self().getGdprReportCustomerCard() == null ? '' : CEL_CustomSettingsMgr.self().getGdprReportCustomerCard();
    public static String gdprReportTransaction = CEL_CustomSettingsMgr.self().getGdprReportTransaction() == null ? '' : CEL_CustomSettingsMgr.self().getGdprReportTransaction();
    public static String gdprReportCampaign = CEL_CustomSettingsMgr.self().getGdprReportCampaign() == null ? '' : CEL_CustomSettingsMgr.self().getGdprReportCampaign();
    public static String gdprReportCase = CEL_CustomSettingsMgr.self().getGdprReportCase() == null ? '' : CEL_CustomSettingsMgr.self().getGdprReportCase();

    public static String campaignReportIdAction = CEL_CustomSettingsMgr.self().getReportCampaignIdAction() == null ? '' : CEL_CustomSettingsMgr.self().getReportCampaignIdAction();
    public static String campaignReportIdMembers = CEL_CustomSettingsMgr.self().getReportCampaignIdMembers() == null ? '' : CEL_CustomSettingsMgr.self().getReportCampaignIdMembers();
    public static String campaignReportIdTransactions = CEL_CustomSettingsMgr.self().getReportCampaignIdTransactions() == null ? '' : CEL_CustomSettingsMgr.self().getReportCampaignIdTransactions();
    public static String campaignReportIdLines = CEL_CustomSettingsMgr.self().getReportCampaignIdLines() == null ? '' : CEL_CustomSettingsMgr.self().getReportCampaignIdLines();
    public static Set<String> taskOpenStatuses = CEL_CustomSettingsMgr.self().getTaskOpenStatuses() == null ? new Set<String>() : CEL_CustomSettingsMgr.self().getTaskOpenStatuses();
    
    public static String campaignParentRecordType = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('ParentAction').getRecordTypeId();
    public static String campaignEnfantRecordType = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('ChildAction').getRecordTypeId();
    public static String storeRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
    
    public static Map<String, String> storeStatus = new Map<String, String>{
        'Open' => 'Open',
        'Future' => 'Future',
        'Closed' => 'Closed'
    };
     
    public static Map<String, String> consentPurpose = new Map<String, String>{
        'CCM' => 'CCM',
        'CRM' => 'CRM',
        'ASM' => 'ASM'
    };

    public static Map<String, String> consentType = new Map<String, String>{
        'Transaction' => 'Transaction',
        'Claim' => 'Claim',
        'Case' => 'Case'
    };

    public static Map<String, String> consentStatus = new Map<String, String>{
        'ON' => 'true',
        'OFF' => 'false'
    };

    public static Map<String, String> accountModificationFrom = new Map<String, String>{
        'RCU' => 'RCU',
        'IndividualTrigger' => 'IndividualTrigger'
    };
    
    public static Map<String, String> levelsCampaign = new Map<String, String>{
        'Level_1' => '1',
        'Level_2' => '2',
        'Level_3' => '3',
        'Level_4' => '4'
    };
    
    public static Map<String, String> namePicklistCampaign = new Map<String, String>{
        'Picklist_Region' => 'Region',
        'Picklist_Country' => 'Country',
        'Picklist_Store' => 'Store'
    };
    
    public static String typeAccountKey = 'CLI';
    
    public static String regionNameALL = 'ALL';
    
    public static Map<String, String> taskStatus = CEL_Utils.getFieldValuesMap(Task.Status.getDescribe(),null);
    
    public static Map<String, String> taskTypes = CEL_Utils.getFieldValuesMap(Task.Type.getDescribe(),null);
    
    public static Map<String, String> taskSubjects = CEL_Utils.getFieldValuesMap(Task.Subject.getDescribe(),null);
    
    public static Map<String, String> activityClosureTypes = CEL_Utils.getFieldValuesMap(Task.cel_Activity_Closure_Reason__c.getDescribe(),null);
    
    public static Map<String, String> activityStatus = CEL_Utils.getFieldValuesMap(Task.cel_Activity_Status__c.getDescribe(),null);
    
    public static Map<String, String> taskStatusMap = new Map<String, String>{
        'Open_Status' => 'Open',
        'Closed_Status' => 'Closed'
    };
    
}