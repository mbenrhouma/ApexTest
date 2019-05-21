({
    /**
     * openReport : Called to open a report
     */
    openReport: function openReport(reportId, customerId) {
        window.open('/lightning/r/Report/' + reportId + '/view?fv0=' + customerId, 'blank');
    }
});