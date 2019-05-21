({
    /**
     * getContactsList : hadnle when click on Search button
     * @param {*} component
     * @param {*} event
     * @param {*} helper
     */
    getContactsList: function getContactsList(component, event, helper) {
        helper.fetchcontacts(component);
    },

    /**
     * gotToReportController : Handle when click on report link
     * @param {*} component
     * @param {*} event
     * @param {*} helper
     */
    gotToReportController: function gotToReportController(component, event, helper) {
        helper.gotToReportHelper(component, event, helper);
    },

    /**
     * addSelected : Handle when click on Add member button
     * @param {*} component
     * @param {*} event
     * @param {*} helper
     */
    addSelected: function addSelected(component, event, helper) {
        var tempIDs = [];
        var getAllId = component.find('checkBox');
        if (getAllId != null) {
            if (Array.isArray(getAllId)) {
                for (var i = 0; i < getAllId.length; i++) {
                    // select those who checked
                    if (getAllId[i].get('v.value') === true) {
                        tempIDs.push(getAllId[i].get('v.text'));
                    }
                }
            } else if (getAllId.get('v.value') === true) {
                tempIDs.push(getAllId.get('v.text'));
            }
        }
        // call the helper function and pass all selected record id's.
        if (tempIDs != null && tempIDs.length > 0) {
            helper.addSelectedHelper(component, event, tempIDs);
        }
    },

    /**
     * handleSelectAllContact: Handle when click on Select All button
     * @param {*} component
     * @param {*} event
     * @param {*} helper
     */
    handleSelectAllContact: function handleSelectAllContact(component, event, helper) {
        helper.handleSelectAllContact(component, event, helper);
    }
});