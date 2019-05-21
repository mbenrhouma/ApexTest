({

    /**
     * doInit: Called at component initialization
     */
    doInit: function doInit(component) {
        var availableReportAction = component.get('c.getAvailableReports');
        availableReportAction.setStorable();
        availableReportAction.setCallback(this, function availableReportActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var availableReport = response.getReturnValue();
                component.set('v.campaignReportIdAction', availableReport.campaignReportIdAction);
                component.set('v.campaignReportIdMembers', availableReport.campaignReportIdMembers);
                component.set('v.campaignReportIdTransactions', availableReport.campaignReportIdTransactions);
                component.set('v.campaignReportIdLines', availableReport.campaignReportIdLines);
            }
        });

        $A.enqueueAction(availableReportAction);
    },

    /**
     * openReportCampaignAction: Open Campaigns report Action
     */
    openReportCampaignAction: function openReportCampaignAction(component, event, helper) {
        var campaignId = component.get('v.recordId');
        var reportId = component.get('v.campaignReportIdAction');
        helper.openReport(reportId, campaignId);
    },

    /**
     * openReportCampaignMembers: Open Campaigns report Members
     */
    openReportCampaignMembers: function openReportCampaignMembers(component, event, helper) {
        var campaignId = component.get('v.recordId');
        var reportId = component.get('v.campaignReportIdMembers');
        helper.openReport(reportId, campaignId);
    },

    /**
     * openReportCampaignTransactions: Open Campaigns report Transactions
     */
    openReportCampaignTransactions: function openReportCampaignTransactions(component, event, helper) {
        var campaignId = component.get('v.recordId');
        var reportId = component.get('v.campaignReportIdTransactions');

        var getTransactionAction = component.get('c.createCampaignTransaction');
        getTransactionAction.setStorable();
        getTransactionAction.setParam('CampaingId', campaignId);
        getTransactionAction.setCallback(this, function getTransactionActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    helper.openReport(reportId, campaignId);
                }
            }
        });

        $A.enqueueAction(getTransactionAction);
    },

    /**
     * openReportCampaignLines: Open Campaigns report Lines
     */
    openReportCampaignLines: function openReportCampaignLines(component, event, helper) {
        var campaignId = component.get('v.recordId');
        var reportId = component.get('v.campaignReportIdLines');

        var getTransactionLineAction = component.get('c.createCampaignTransactionLine');
        getTransactionLineAction.setStorable();
        getTransactionLineAction.setParam('CampaingId', campaignId);
        getTransactionLineAction.setCallback(this, function getTransactionLineActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    helper.openReport(reportId, campaignId);
                }
            }
        });

        $A.enqueueAction(getTransactionLineAction);
    }
});