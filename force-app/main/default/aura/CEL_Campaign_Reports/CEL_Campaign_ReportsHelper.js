({
    /**
     * openReport : Called to open a report
     */
    openReport: function openReport(reportId, campaignId) {
        window.open('/lightning/r/Report/' + reportId + '/view?fv0=' + campaignId, 'blank');
    }
});