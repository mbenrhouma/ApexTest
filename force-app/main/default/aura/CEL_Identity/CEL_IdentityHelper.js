({
    /**
     * showHide: Called for show or hide form
     */
    showHide: function showHide(component) {
        let editForm = component.find('editForm');
        $A.util.toggleClass(editForm, 'slds-hide');
        let viewForm = component.find('viewForm');
        $A.util.toggleClass(viewForm, 'slds-hide');
    }
});