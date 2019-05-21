({
    /**
     * doInit: Called at component initialization
     */
    doInit: function doInit(component) {
        var availableListAction = component.get('c.getAvailableList');
        availableListAction.setStorable();
        availableListAction.setCallback(this,
                function availableListActionCallback(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        var availableList = response.getReturnValue();
                        component.set('v.allCountries', availableList.allCountries);
                        component.set('v.allLanguages', availableList.allLanguages);
                        component.set('v.allChannels', availableList.allChannels);
                        component.set('v.allAppointment', availableList.allAppointment);
                    }
                });

        var getEditAccessAction = component.get('c.getFieldsAccess');

        getEditAccessAction.setCallback(this,
                function getEditAccessActionCallback(responseAccess) {
                    var resultAccess = responseAccess.getReturnValue();
                    component.set('v.fieldAccess', resultAccess);
                });

        $A.enqueueAction(availableListAction);
        $A.enqueueAction(getEditAccessAction);
    },

    /**
     * editRecord: Change mode of this component to edit mode
     */
    editRecord: function editRecord(component) {
        component.set('v.isEditMode', true);
    },
     /**
     *  emailChangedHandler : Assign the value of the field cel_PersonEmail__c
     * to PersonEmail when saving record
     *
     */
    emailChangedHandler: function emailChangedHandler(component) {
        let email = component.get('v.simpleRecord.cel_PersonEmail__c');
        component.set('v.simpleRecord.PersonEmail', email);
    },
    /**
     * handleSave: Save the record current with modification
     */
    handleSave: function handleSave(component) {
        component.find('recordHandler').saveRecord(
                $A.getCallback(function saveRecordAction(saveResult) {
                    let toastEvent = $A.get('e.force:showToast');
                    if (saveResult.state === 'SUCCESS' || saveResult.state === 'DRAFT') {
                        toastEvent.setParams({
                            title: 'Success',
                            message: 'Record saved.',
                            type: 'success'
                        });
                        $A.get('e.force:refreshView').fire();
                        component.set('v.isEditMode', false);
                    } else if (saveResult.state === 'ERROR') {
                        if (saveResult.error[0] != null && saveResult.error[0].pageErrors[0] != null && saveResult.error[0].pageErrors[0].statusCode === 'DUPLICATES_DETECTED') {
                            var bypassSaveAction = component.get('c.bypassDuplicateRules');
                            bypassSaveAction.setParams({
                                account: component.get('v.simpleRecord')
                            });
                            bypassSaveAction.setCallback(this, function bypassSaveActionCallback(response) {
                                var state = response.getState();
                                if (state === 'SUCCESS') {
                                    var result = response.getReturnValue();
                                    if (result) {
                                        let toastEventDuplicate = $A.get('e.force:showToast');
                                        toastEventDuplicate.setParams({
                                            title: 'Warning',
                                            message: $A.get('$Label.c.cel_account_message_warning_duplicate'),
                                            type: 'warning'
                                        });
                                        component.set('v.isEditMode', false);
                                        toastEventDuplicate.fire();
                                    }
                                }
                            });
                            
                            $A.enqueueAction(bypassSaveAction);
                            $A.get('e.force:refreshView').fire();
                        }
                        else {
                            let errorMsg = JSON.stringify(saveResult.error[0].message);
                            errorMsg = errorMsg.slice(0, -3);
                            errorMsg = errorMsg.substr(1);
                            toastEvent.setParams({
                                title: 'Error',
                                message: errorMsg,
                                type: 'error'
                            });
                            component.set('v.recordError', errorMsg);
                            errorMsg = '';
                        }
                    }
                    toastEvent.fire();
                }));
    },

    /**
     * handleCancel: Change mode of this component to view Mode
     */
    handleCancel: function handleCancel(component) {
        component.set('v.isEditMode', false);
    },

    /**
     * changeStateSectionOne: Change the state of the section One to expanded Section
     */
    changeStateSectionOne: function changeStateSectionOne(component) {
        component.set('v.isExpandedSectionOne', !component.get('v.isExpandedSectionOne'));
    },

    /**
     * handleRatioState: Get the state of the different radio buttons
     */
    handleRatioState: function handleRatioState(component) {
        if (document.querySelector('input[name="options"]:checked') !== null) {
            let radio = document.querySelector('input[name="options"]:checked').value;
            if (radio === 'False' || radio === 'True') {
                if (radio === 'True') {
                    component.set('v.simpleRecord.cel_do_not_email__c', true);
                } else {
                    component.set('v.simpleRecord.cel_do_not_email__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsaddress"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsaddress"]:checked').value;
            if (radio === 'FalseAddr' || radio === 'TrueAddr') {
                (radio === 'TrueAddr') ? component.set('v.simpleRecord.cel_optin_postal_mail__c', true) : component.set('v.simpleRecord.cel_optin_postal_mail__c', false);
            }
        }
        if (document.querySelector('input[name="optionschat"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionschat"]:checked').value;
            if (radio === 'FalseChat' || radio === 'TrueChat') {
                (radio === 'TrueChat') ? component.set('v.simpleRecord.cel_optin_sms__c', true) : component.set('v.simpleRecord.cel_optin_sms__c', false);
            }
        }

        if (document.querySelector('input[name="optionsValidityChat"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityChat"]:checked').value;
            if (radio === 'FalseValidityChat' || radio === 'TrueValidityChat') {
                (radio === 'TrueValidityChat') ? component.set('v.simpleRecord.cel_wechat_id__c', true) : component.set('v.simpleRecord.cel_wechat_id__c', false);
            }
        }
        if (document.querySelector('input[name="optionsphone"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsphone"]:checked').value;
            if (radio === 'FalsePhone' || radio === 'TruePhone') {
                (radio === 'TruePhone') ? component.set('v.simpleRecord.PersonDoNotCall', true) : component.set('v.simpleRecord.PersonDoNotCall', false);
            }
        }

        if (document.querySelector('input[name="optionsValidityEmail"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityEmail"]:checked').value;
            if (radio === 'FalseValidityPhone' || radio === 'TrueValidityPhone') {
                (radio === 'TrueValidityPhone') ? component.set('v.simpleRecord.cel_email_validity__c', true) : component.set('v.simpleRecord.cel_email_validity__c', false);
            }
        }

        if (document.querySelector('input[name="optionsValidityPhone1"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityPhone1"]:checked').value;
            if (radio === 'FalseValidityPhone1' || radio === 'TrueValidityPhone1') {
                if (radio === 'TrueValidityPhone1') {
                    component.set('v.simpleRecord.cel_homephone_validity__c', true);
                } else {
                    component.set('v.simpleRecord.cel_homephone_validity__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsValidityPhone2"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityPhone2"]:checked').value;
            if (radio === 'FalseValidityPhone2' || radio === 'TrueValidityPhone2') {
                if (radio === 'TrueValidityPhone2') {
                    component.set('v.simpleRecord.cel_mobile_validity__c', true);
                } else {
                    component.set('v.simpleRecord.cel_mobile_validity__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsValidityPhone3"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityPhone3"]:checked').value;
            if (radio === 'FalseValidityPhone3' || radio === 'TrueValidityPhone3') {
                if (radio === 'TrueValidityPhone3') {
                    component.set('v.simpleRecord.cel_otherphone_validity__c', true);
                } else {
                    component.set('v.simpleRecord.cel_otherphone_validity__c', false);
                }
            }
        }
        if (document.querySelector('input[name="optionsValidityAddress"]:checked') !== null) {
            let radio = document.querySelector('input[name="optionsValidityAddress"]:checked').value;
            if (radio === 'FalseValidityAddress' || radio === 'TrueValidityAddress') {
                if (radio === 'TrueValidityAddress') {
                    component.set('v.simpleRecord.cel_addr_1_validity__c', true);
                } else {
                    component.set('v.simpleRecord.cel_addr_1_validity__c', false);
                }
            }
        }
    },

    /**
     * changeStateSectionTwo : Change the state of the section Two to expanded Section
     */
    changeStateSectionTwo: function changeStateSectionTwo(component) {
        component.set('v.isExpandedSectionTwo', !component.get('v.isExpandedSectionTwo'));
    },

    /**
     * validateEmail: Control the Person email
     */
    validateEmail: function validateEmail(component) {
        var inp = component.get('v.simpleRecord.cel_PersonEmail__c');
        if (inp.length > 100) {
            component.set('v.simpleRecord.cel_PersonEmail__c', inp.substring(0, 100));
        }
    },

    /**
     * validateSecondaryEmail: Control the Secondary email
     */
    validateSecondaryEmail: function validateSecondaryEmail(component) {
        var inp = component.get('v.simpleRecord.cel_email_2__c');
        if (inp.length > 100) {
            component.set('v.simpleRecord.cel_email_2__c', inp.substring(0, 100));
        }
    },

    /**
     * validateLineId: Control the line Id
     */
    validateLineId: function validateLineId(component) {
        var inp = component.get('v.simpleRecord.cel_line_id__c');
        if (inp.length > 70) {
            component.set('v.simpleRecord.cel_line_id__c', inp.substring(0, 70));
        }
    },

    /**
     * validateWeLineId: Control the we chat Id
     */
    validateWeLineId: function validateWeLineId(component) {
        var inp = component.get('v.simpleRecord.cel_wechat_id__c');
        if (inp.length > 17) {
            component.set('v.simpleRecord.cel_wechat_id__c', inp.substring(0, 17));
        }
    },

    /**
     * validateStreet1: Control the address 1 line 1
     */
    validateStreet1: function validateStreet1(component) {
        var inp = component.get('v.simpleRecord.cel_addr_1_line_1__c');
        if (inp.length > 255) {
            component.set('v.simpleRecord.cel_addr_1_line_1__c', inp.substring(0, 255));
        }
    },

    /**
     * validateStreet2: Control the address 1 line 2
     */
    validateStreet2: function validateStreet2(component) {
        var inp = component.get('v.simpleRecord.cel_addr_1_line_2__c');
        if (inp.length > 255) {
            component.set('v.simpleRecord.cel_addr_1_line_2__c', inp.substring(0, 255));
        }
    },

    /**
     * validateStreet3: Control the address 1 line 3
     */
    validateStreet3: function validateStreet3(component) {
        var inp = component.get('v.simpleRecord.cel_addr_1_line_3__c');
        if (inp.length > 255) {
            component.set('v.simpleRecord.cel_addr_1_line_3__c', inp.substring(0, 255));
        }
    },

    /**
     * validateZipCode: Control the address 1 line 3
     */
    validateZipCode: function validateZipCode(component) {
        var inp = component.get('v.simpleRecord.cel_addr_1_zipcode__c');
        if (inp.length > 50) {
            component.set('v.simpleRecord.cel_addr_1_zipcode__c', inp.substring(0, 50));
        }
    },

    /**
     * validateState: Control the address 1 region
     */
    validateState: function validateState(component) {
        var inp = component.get('v.simpleRecord.cel_addr_1_region__c');
        if (inp.length > 50) {
            component.set('v.simpleRecord.cel_addr_1_region__c', inp.substring(0, 50));
        }
    },

    /**
     * validateCity: Control the address 1 city
     */
    validateCity: function validateCity(component) {
        var inp = component.get('v.simpleRecord.cel_addr_1_city__c');
        if (inp.length > 50) {
            component.set('v.simpleRecord.cel_addr_1_city__c', inp.substring(0, 50));
        }
    }
});