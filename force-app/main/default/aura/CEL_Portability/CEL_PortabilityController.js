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

                component.set('v.customerCardReport', availableReport.customerCard);
                component.set('v.transactionReport', availableReport.transactions);
                component.set('v.campaignReport', availableReport.campaigns);
                component.set('v.caseReport', availableReport.cases);
            }
        });

        var accountAction = component.get('c.getAccount');
        accountAction.setParams({
            accountId: component.get('v.recordId')
        });
        accountAction.setCallback(this, function accountActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.personContactID', response.getReturnValue());
            }
        });

        var updateExtractionDateAction = component.get('c.updateExtractionDate');
        updateExtractionDateAction.setParams({
            accountId: component.get('v.recordId')
        });
        updateExtractionDateAction.setCallback(this, function updateExtractionDateActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                $A.enqueueAction(accountAction);
                $A.enqueueAction(availableReportAction);
            }
        });

        $A.enqueueAction(updateExtractionDateAction);
    },

    /**
     * openReportCustomerCard: Open Customer Card report
     */
    openReportCustomerCard: function openReportCustomerCard(component, event, helper) {
        var customerId = component.get('v.recordId');
        var reportId = component.get('v.customerCardReport');
        helper.openReport(reportId, customerId);
    },

    /**
     * openReportTransactions: Open Transactions report
     */
    openReportTransactions: function openReportTransactions(component, event, helper) {
        var customerId = component.get('v.recordId');
        var reportId = component.get('v.transactionReport');
        helper.openReport(reportId, customerId);
    },

    /**
     * openReportCampaigns: Open Campaigns report
     */
    openReportCampaigns: function openReportCampaigns(component, event, helper) {
        var customerId = component.get('v.personContactID');
        var reportId = component.get('v.campaignReport');
        helper.openReport(reportId, customerId);
    },

    /**
     * openReportCases: Open Cases report
     */
    openReportCases: function openReportCases(component, event, helper) {
        var customerId = component.get('v.recordId');
        var reportId = component.get('v.caseReport');
        helper.openReport(reportId, customerId);
    }
});