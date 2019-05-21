({
    /**
     * validateForm: Control if form and fileds are valid
     */
    validateForm: function validateForm(component) {
        let validAccount = true;
        let allValid = component.find('formField').reduce(function reduceFunction(validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            let account = component.get('v.recordInfo');
            if ($A.util.isEmpty(account)) {
                validAccount = false;
            }
            return (validAccount);
        }
    }
});