({
    /**
     * doInit: Called at component initialization
     */
    doInit: function doInit(component) {
        var availableListAction = component.get('c.getAvailableList');
        availableListAction.setStorable();
        availableListAction.setCallback(this, function availableListActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var availableList = response.getReturnValue();
                component.set('v.allCountries', availableList.allCountries);
                component.set('v.allTitles', availableList.allTitles);
            }
        });

        var getEditAccessAction = component.get('c.getFieldsAccess');

        getEditAccessAction.setCallback(this, function getEditAccessActionCallback(responseAccess) {
            var resultAccess = responseAccess.getReturnValue();
            component.set('v.fieldAccess', resultAccess);
        });

        $A.enqueueAction(availableListAction);
        $A.enqueueAction(getEditAccessAction);
    },

    /**
     * editRecord: Called when click on edit button
     */
    editRecord: function editRecord(component) {
        component.set('v.isEditMode', true);
    },
    /**
     * handleSave: Called when click on save button
     * show a toast on success or on error when saving
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
                    toastEvent.fire();
                }));
    },

    handleCancel: function handleCancel(component) {
        component.set('v.isEditMode', false);
    },
    validateFirstName: function validateFirstName(component) {
        var inp = component.get('v.simpleRecord.FirstName');
        if (inp.length > 100) {
            component.set('v.simpleRecord.FirstName', inp.substring(0, 100));
        }
    }

});