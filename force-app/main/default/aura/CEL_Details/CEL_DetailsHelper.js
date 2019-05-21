({
    /**
     * changeSelectValue: Change the selected value
     */
    changeSelectValue: function changeSelectValue(component, id, variable) {
        var selectedValue = component.find(id).get('v.value');
        if (variable === 'v.account.cel_is_email_contactibiliy__c') {
            if (selectedValue === true) {
                component.set('v.account.cel_is_email_contactibiliy__c', true);
            } else {
                component.set('v.account.cel_is_email_contactibiliy__c', false);
            }
        }
    }
});