public with sharing class CEL_CustomSettingsMgr {
    /**
     * The SINGLETON handle to the instance
     */
    private static CEL_CustomSettingsMgr self;


    /**
     * Initialize the SINGLETON instance or return it if already exists
     *
     * @returns {SSCSiteCustomSettingHelper}
     */
    public static CEL_CustomSettingsMgr self() {
        if (self != null) {
            return self;
        }

        // To create org wide defaults in new org automatically. This will prevent NPE's in future.
        if (CEL_Configurations__c.getInstance() == null) {
            upsert new CEL_Configurations__c(SetupOwnerId = Userinfo.getOrganizationId());
        }

        self = new CEL_CustomSettingsMgr();
        return self;
    }

    /**
    * CEL_CustomSettingsMgr: private constructor of singleton 
    * to disable class standard instantiation
    */
    private CEL_CustomSettingsMgr() {}

    /**
    * getInterfaceUserId: return interface user Id
    * @return {String}
    */
    public String getInterfaceUserId() {
        return CEL_Configurations__c.getInstance().cel_interface_user_id__c;
    }

    /**
    * getGdprReportCustomerCard: return GDPR Customer Card Report Id
    * @return {String}
    */
    public String getGdprReportCustomerCard() {
        return CEL_Configurations__c.getInstance().cel_gpdr_report_customer_card__c;
    }

    /**
    * getGdprReportTransaction: return GDPR Transaction Report Id
    * @return {String}
    */
    public String getGdprReportTransaction() {
        return CEL_Configurations__c.getInstance().cel_gdpr_report_transactions__c;
    }

    /**
    * getGdprReportCampaign: return GDPR Campaign Report Id
    * @return {String}
    */
    public String getGdprReportCampaign() {
        return CEL_Configurations__c.getInstance().cel_gdpr_report_campaign__c;
    }

    /**
    * getGdprReportCase: return GDPR Case Report Id
    * @return {String}
    */
    public String getGdprReportCase() {
        return CEL_Configurations__c.getInstance().cel_gdpr_report_case__c;
    }

    /**
    * getReportCampaignIdAction: return campaign action Report Id
    * @return {String}
    */
    public String getReportCampaignIdAction() {
        return CEL_Configurations__c.getInstance().cel_report_campaign_action__c;
    }
    
    /**
    * getReportCampaignIdMembers: return campaign members Report Id
    * @return {String}
    */
    public String getReportCampaignIdMembers() {
        return CEL_Configurations__c.getInstance().cel_report_campaign_members__c;
    }
    
    /**
    * getReportCampaignIdTransactions: return campaign transactoins Report Id
    * @return {String}
    */
    public String getReportCampaignIdTransactions() {
        return CEL_Configurations__c.getInstance().cel_report_campaign_transactions__c;
    }
    
    /**
    * getReportCampaignIdLines: return campaign Lines Report Id
    * @return {String}
    */
    public String getReportCampaignIdLines() {
        return CEL_Configurations__c.getInstance().cel_report_campaign_lines__c;
    }
    
    /**
    * getTaskOpenStatuses: return the open statuses of Task
    * @return {Set<String>}
    */
    public Set<String> getTaskOpenStatuses() {
        String openStatusesAsString = CEL_Configurations__c.getInstance().cel_task_open_status__c;
        List<String> listOfOpenStatuses = String.isNotBlank(openStatusesAsString) ? openStatusesAsString.split(',') : null;
        
        Set<String> setOfOpenStatuses = listOfOpenStatuses != null ? new Set<String>(listOfOpenStatuses) : new Set<String>();
        return setOfOpenStatuses;
    }
}