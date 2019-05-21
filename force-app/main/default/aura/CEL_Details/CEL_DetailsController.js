({
    /**
     * changeContactTabLayout: Handle when change Contact tab layout
     */
    changeContactTabLayout: function changeContactTabLayout(component) {
        component.set('v.isEditContactTab', true);
    },

    /**
     * clickCancel: Handle when cancel
     */
    clickCancel: function clickCancel(component) {
        component.set('v.isEditContactTab', false);
        var event = component.getEvent('CEL_EventContactDetail');
        event.fire();
    },

    /**
     * createAccount: called for create account
     */
    createAccount: function createAccount(component) {
        var newAcc = component.get('v.account');
        var action = component.get('c.saveAccount');
        if (document.querySelector('input[name="options"]:checked') !== null) {
            let radio = document.querySelector('input[name="options"]:checked').value;
            if (radio === 'False' || radio === 'True') {
                if (radio === 'True') {
                    component.set('v.account.cel_do_not_email__c', true);
                } else {
                    component.set('v.account.cel_do_not_email__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsaddress"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsaddress"]:checked').value;
            if (radio === 'FalseAddr' || radio === 'TrueAddr') {
                if (radio === 'TrueAddr') {
                    component.set('v.account.cel_optin_postal_mail__c', true);
                } else {
                    component.set('v.account.cel_optin_postal_mail__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionschat"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionschat"]:checked').value;
            if (radio === 'FalseChat' || radio === 'TrueChat') {
                if (radio === 'TrueChat') {
                    component.set('v.account.cel_optin_sms__c', true);
                } else {
                    component.set('v.account.cel_optin_sms__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsphone"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsphone"]:checked').value;
            if (radio === 'FalsePhone' || radio === 'TruePhone') {
                if (radio === 'TruePhone') {
                    component.set('v.account.PersonDoNotCall', true);
                } else {
                    component.set('v.account.PersonDoNotCall', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsValidityEmail"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityEmail"]:checked').value;
            if (radio === 'FalseValidityPhone' || radio === 'TrueValidityPhone') {
                if (radio === 'TrueValidityPhone') {
                    component.set('v.account.cel_email_validity__c', true);
                } else {
                    component.set('v.account.cel_email_validity__c', false);
                }
            }
        }

        if (document.querySelector('input[name="optionsValidityPhone1"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityPhone1"]:checked').value;
            if (radio === 'FalseValidityPhone1' || radio === 'TrueValidityPhone1') {
                if (radio === 'TrueValidityPhone1') {
                    component.set('v.account.cel_homephone_validity__c', true);
                } else {
                    component.set('v.account.cel_homephone_validity__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsValidityPhone2"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityPhone2"]:checked').value;
            if (radio === 'FalseValidityPhone2' || radio === 'TrueValidityPhone2') {
                if (radio === 'TrueValidityPhone2') {
                    component.set('v.account.cel_mobile_validity__c', true);
                } else {
                    component.set('v.account.cel_mobile_validity__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsValidityPhone3"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityPhone3"]:checked').value;
            if (radio === 'FalseValidityPhone3' || radio === 'TrueValidityPhone3') {
                if (radio === 'TrueValidityPhone3') {
                    component.set('v.account.cel_otherphone_validity__c', true);
                } else {
                    component.set('v.account.cel_otherphone_validity__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsValidityAddress"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityAddress"]:checked').value;
            if (radio === 'FalseValidityAddress' || radio === 'TrueValidityAddress') {
                if (radio === 'TrueValidityAddress') {
                    component.set('v.account.cel_addr_1_validity__c', true);
                } else {
                    component.set('v.account.cel_addr_1_validity__c', false);
                }
            }
        }
        action.setParams({
            acc: newAcc
        });
        var tab = ['cel_addr_1_city__c'];
        // ,"PersonHomePhone", "PersonMobilePhone", "PersonOtherPhone"
        for (let i = 0; i < tab.length; i++) {
            let inputField = component.find(tab[i]);
            inputField.set('v.errors', [{
                message: null
            }]);
            $A.util.removeClass(inputField, 'slds-has-error');
        }
        action.setCallback(this, function actionCallBack(a) {
            var state = a.getState();
            if (state === 'SUCCESS') {
                component.set('v.isEditContactTab', false);
                var event = component.getEvent('CEL_EventContactDetail');
                event.fire();
            } else {
                var obj = JSON.stringify(a.getError());
                var stringify = JSON.parse(obj);
                var stringify2;
                for (let i = 0; i < stringify.length; i++) {
                    stringify2 = stringify[i].fieldErrors;
                }
                for (let i = 0; i < Object.keys(stringify2).length; i++) {
                    var inputField = component.find(Object.keys(stringify2)[i]);
                    $A.util.addClass(inputField, 'slds-has-error');
                    inputField.set('v.errors', [{
                        message: 'Please Enter a Valid City'
                    }]);
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * validateEmail: control and validate email
     */
    validateEmail: function validateEmail(component) {
        var inp = component.get('v.account.cel_PersonEmail__c');
        if (inp.length > 100) {
            component.set('v.account.cel_PersonEmail__c', inp.substring(0, 100));
        }
    },

    /**
     * validateSecondaryEmail: control and validate secondary email
     */
    validateSecondaryEmail: function validateSecondaryEmail(component) {
        var inp = component.get('v.account.cel_email_2__c');
        if (inp.length > 100) {
            component.set('v.account.cel_email_2__c', inp.substring(0, 100));
        }
    },

    /**
     * validateLineId: control and validate line Id
     */
    validateLineId: function validateLineId(component) {
        var inp = component.get('v.account.cel_line_id__c');
        if (inp.length > 70) {
            component.set('v.account.cel_line_id__c', inp.substring(0, 70));
        }
    },

    /**
     * validateWeLineId: control and validate WE line Id
     */
    validateWeLineId: function validateWeLineId(component) {
        var inp = component.get('v.account.cel_wechat_id__c');
        if (inp.length > 17) {
            component.set('v.account.cel_wechat_id__c', inp.substring(0, 17));
        }
    },

    /**
     * validateStreet1: control and validate Street 1
     */
    validateStreet1: function validateStreet1(component) {
        var inp = component.get('v.account.cel_addr_1_line_1__c');
        if (inp.length > 255) {
            component.set('v.account.cel_addr_1_line_1__c', inp.substring(0, 255));
        }
    },

    /**
     * validateStreet2: control and validate Street 2
     */
    validateStreet2: function validateStreet2(component) {
        var inp = component.get('v.account.cel_addr_1_line_2__c');
        if (inp.length > 255) {
            component.set('v.account.cel_addr_1_line_2__c', inp.substring(0, 255));
        }
    },

    /**
     * validateStreet3: control and validate Street 3
     */
    validateStreet3: function validateStreet3(component) {
        var inp = component.get('v.account.cel_addr_1_line_3__c');
        if (inp.length > 255) {
            component.set('v.account.cel_addr_1_line_3__c', inp.substring(0, 255));
        }
    },

    /**
     * validateZipCode: control and validate Zipcode
     */
    validateZipCode: function validateZipCode(component) {
        var inp = component.get('v.account.cel_addr_1_zipcode__c');
        if (inp.length > 50) {
            component.set('v.account.cel_addr_1_zipcode__c', inp.substring(0, 50));
        }
    },

    /**
     * validateState: control and validate State
     */
    validateState: function validateState(component) {
        var inp = component.get('v.account.cel_addr_1_region__c');
        if (inp.length > 50) {
            component.set('v.account.cel_addr_1_region__c', inp.substring(0, 50));
        }
    },

    /**
     * validateCity: control and validate City
     */
    validateCity: function validateCity(component) {
        var inp = component.get('v.account.cel_addr_1_city__c');
        if (inp.length > 50) {
            component.set('v.account.cel_addr_1_city__c', inp.substring(0, 50));
        }
        var city = component.find('city');
        var regExpCityformat = /^[a-z {2}A-Z]*$/;

        if (!inp.match(regExpCityformat)) {
            $A.util.addClass(city, 'slds-has-error');
            city.set('v.errors', [{
                message: 'Please Enter a Valid City'
            }]);
        } else {
            city.set('v.errors', [{
                message: null
            }]);
            $A.util.removeClass(city, 'slds-has-error');
        }
    }
});